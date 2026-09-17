"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useParams } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";

type Room = { id: string; code: string; host_user_id: string; budget: number };
type Member = { id: string; user_id: string; display_name: string; balance: number; is_host: boolean };
type Player = { id: string; name: string; primary_position: string; overall: number | null };
type Auction = {
  id: string;
  room_id: string;
  player_id: string;
  status: "interest" | "bidding" | "sold" | "skipped";
  current_bid: number;
  current_bidder_member_id: string | null;
  winner_member_id: string | null;
  final_price: number | null;
  ends_at: string | null;
  created_at: string;
};

export default function AuctionPage() {
  const params = useParams<{ code: string }>();
  const code = String(params.code).toUpperCase();
  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [me, setMe] = useState<Member | null>(null);
  const [auction, setAuction] = useState<Auction | null>(null);
  const [player, setPlayer] = useState<Player | null>(null);
  const [answered, setAnswered] = useState(false);
  const [bid, setBid] = useState(1);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);
  const [now, setNow] = useState(Date.now());
  const finalizing = useRef(false);

  const refresh = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,budget")
      .eq("code", code)
      .single();
    if (roomError) throw roomError;
    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,user_id,display_name,balance,is_host")
      .eq("room_id", typedRoom.id)
      .order("joined_at");
    if (memberError) throw memberError;
    const typedMembers = (memberData || []) as Member[];
    setMembers(typedMembers);
    setMe(typedMembers.find((m) => m.user_id === session.user.id) || null);

    const { data: auctionData, error: auctionError } = await supabase
      .from("fa_auctions")
      .select("id,room_id,player_id,status,current_bid,current_bidder_member_id,winner_member_id,final_price,ends_at,created_at")
      .eq("room_id", typedRoom.id)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (auctionError) throw auctionError;

    if (!auctionData) {
      setAuction(null);
      setPlayer(null);
      return;
    }

    const typedAuction = auctionData as Auction;
    const previousAuctionId = auction?.id;
    setAuction(typedAuction);
    setBid(Math.max(1, typedAuction.current_bid + 1));
    if (previousAuctionId && previousAuctionId !== typedAuction.id) setAnswered(false);

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,primary_position,overall")
      .eq("id", typedAuction.player_id)
      .single();
    if (playerError) throw playerError;
    setPlayer(playerData as Player);

    if (typedAuction.status === "interest") {
      const myMember = typedMembers.find((m) => m.user_id === session.user.id);
      if (myMember) {
        const { data: interest } = await supabase
          .from("fa_player_interest")
          .select("wants")
          .eq("auction_id", typedAuction.id)
          .eq("member_id", myMember.id)
          .maybeSingle();
        setAnswered(!!interest);
      }
    }
  }, [code, auction?.id]);

  useEffect(() => {
    refresh().catch((e) => setError(e instanceof Error ? e.message : "Erro ao carregar o leilão.")).finally(() => setLoading(false));
  }, [refresh]);

  useEffect(() => {
    if (!room?.id) return;
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:auction:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_auctions", filter: `room_id=eq.${room.id}` }, () => refresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_bids" }, () => refresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_player_interest" }, () => refresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => refresh())
      .subscribe();
    return () => { supabase.removeChannel(channel); };
  }, [room?.id, refresh]);

  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 250);
    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    if (!auction || auction.status !== "bidding" || !auction.ends_at) return;
    if (new Date(auction.ends_at).getTime() > now || finalizing.current) return;

    finalizing.current = true;
    void (async () => {
      try {
        const { error: rpcError } = await getSupabase().rpc("fa_finalize_auction", { p_auction_id: auction.id });
        if (rpcError) setError(rpcError.message);
      } catch (e) {
        setError(e instanceof Error ? e.message : "Erro ao finalizar o leilão.");
      } finally {
        finalizing.current = false;
        try {
          await refresh();
        } catch {
          // O próximo evento do Realtime também atualizará a tela.
        }
      }
    })();
  }, [auction, now, refresh]);

  const winnerName = useMemo(() => members.find((m) => m.id === auction?.winner_member_id)?.display_name || "", [members, auction?.winner_member_id]);
  const bidderName = useMemo(() => members.find((m) => m.id === auction?.current_bidder_member_id)?.display_name || "", [members, auction?.current_bidder_member_id]);
  const secondsLeft = auction?.ends_at ? Math.max(0, Math.ceil((new Date(auction.ends_at).getTime() - now) / 1000)) : 0;
  const isHost = !!room && !!me && room.host_user_id === me.user_id;

  async function chooseInterest(wants: boolean) {
    if (!auction) return;
    setError("");
    const { error: rpcError } = await getSupabase().rpc("fa_set_interest", { p_auction_id: auction.id, p_wants: wants });
    if (rpcError) return setError(rpcError.message);
    setAnswered(true);
    await refresh();
  }

  async function placeBid() {
    if (!auction) return;
    setError("");
    const { error: rpcError } = await getSupabase().rpc("fa_place_bid", { p_auction_id: auction.id, p_amount: bid });
    if (rpcError) return setError(rpcError.message);
    await refresh();
  }

  async function nextPlayer() {
    if (!room) return;
    setError("");
    const { error: rpcError } = await getSupabase().rpc("fa_start_next_auction", { p_room_id: room.id });
    if (rpcError) return setError(rpcError.message);
    setAnswered(false);
    await refresh();
  }

  if (loading) return <main className="container"><p>Carregando leilão...</p></main>;

  return (
    <main className="container">
      <div className="topbar">
        <span className="badge">Sala {code}</span>
        <strong>Seu saldo: {me?.balance ?? 0}</strong>
      </div>

      {error && <div className="card" style={{ marginBottom: 16 }}><p className="red">{error}</p></div>}

      {!auction || !player ? (
        <section className="card" style={{ maxWidth: 560, margin: "0 auto", textAlign: "center" }}>
          <h2>Aguardando jogador</h2>
          <p className="muted">O administrador precisa iniciar o próximo leilão.</p>
        </section>
      ) : (
        <section className="card" style={{ maxWidth: 560, margin: "0 auto", textAlign: "center" }}>
          {player.overall && <div className="red" style={{ fontSize: 48, fontWeight: 900 }}>{player.overall}</div>}
          <h1 style={{ fontSize: 42, marginBottom: 6 }}>{player.name}</h1>
          <p>{player.primary_position}{player.overall ? ` • OVR ${player.overall}` : ""}</p>

          {auction.status === "interest" && (
            <div style={{ marginTop: 24 }}>
              <h2>Você quer esse jogador?</h2>
              {answered ? (
                <p className="muted">Resposta enviada. Aguardando os outros jogadores...</p>
              ) : (
                <div style={{ display: "flex", gap: 12, justifyContent: "center" }}>
                  <button className="btn btn-primary" onClick={() => chooseInterest(true)}>QUERO</button>
                  <button className="btn btn-secondary" onClick={() => chooseInterest(false)}>PASSAR</button>
                </div>
              )}
            </div>
          )}

          {auction.status === "bidding" && (
            <div style={{ marginTop: 24 }}>
              <div className="red" style={{ fontSize: 38, fontWeight: 900 }}>{secondsLeft}s</div>
              <p>Lance atual: <strong>{auction.current_bid}</strong>{bidderName ? ` — ${bidderName}` : ""}</p>
              <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap" }}>
                <button className="btn btn-secondary" onClick={() => setBid((v) => Math.max(auction.current_bid + 1, v - 1))}>−</button>
                <span className="badge">Seu lance: {bid}</span>
                <button className="btn btn-secondary" onClick={() => setBid((v) => Math.min(me?.balance ?? v, v + 1))}>+</button>
                <button className="btn btn-primary" onClick={placeBid} disabled={!me || bid > me.balance || secondsLeft <= 0}>DAR LANCE</button>
              </div>
            </div>
          )}

          {auction.status === "sold" && (
            <div style={{ marginTop: 28 }}>
              <div style={{ fontSize: 64 }}>🔨</div>
              <h2 className="red">LEILOADO PARA {winnerName.toUpperCase()}</h2>
              <p>{auction.final_price === 0 ? "Pegou de graça — foi o único que quis." : `${auction.final_price} créditos`}</p>
              {isHost && <button className="btn btn-primary" onClick={nextPlayer}>Próximo jogador</button>}
              {!isHost && <p className="muted">Aguardando o administrador chamar o próximo jogador.</p>}
            </div>
          )}

          {auction.status === "skipped" && (
            <div style={{ marginTop: 28 }}>
              <h2>Ninguém quis esse jogador</h2>
              <p className="muted">Jogador pulado.</p>
              {isHost && <button className="btn btn-primary" onClick={nextPlayer}>Próximo jogador</button>}
              {!isHost && <p className="muted">Aguardando o administrador.</p>}
            </div>
          )}
        </section>
      )}
    </main>
  );
}
