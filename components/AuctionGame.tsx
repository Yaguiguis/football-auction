"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../lib/supabase";
import { benchSlotsForMode, positionGroup, rosterSizeForMode } from "../lib/squad-board";
import PlayerFace from "./PlayerFace";
import GavelWinAnimation from "./GavelWinAnimation";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  budget: number;
  mode: "football" | "futsal";
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
  squad_finalized: boolean;
};

type Player = {
  id: string;
  name: string;
  primary_position: string;
  overall: number;
  club: string | null;
  league: string | null;
  image_url: string | null;
  player_type: "ACTIVE" | "ICON";
};

type SquadSlot = {
  member_id: string;
  player_id: string;
  slot_key: string;
  is_bench: boolean;
};

type Auction = {
  id: string;
  room_id: string;
  player_id: string;
  status: "interest" | "bidding" | "sold" | "skipped";
  current_bid: number;
  current_bidder_member_id: string | null;
  turn_member_id: string | null;
  winner_member_id: string | null;
  final_price: number | null;
  created_at: string;
};

type Interest = {
  wants: boolean;
  bidding_active: boolean;
  turn_order: number | null;
};

const footballSlots = ["GOL", "LD", "ZAG1", "ZAG2", "LE", "VOL", "MC", "MEI", "PD", "PE", "ATA"];
const futsalSlots = ["GOL", "FIXO", "ALAE", "ALAD", "PIVO"];

function slotLabel(slot: string) {
  return slot
    .replace("ZAG1", "ZAG E")
    .replace("ZAG2", "ZAG D")
    .replace("ALAE", "ALA E")
    .replace("ALAD", "ALA D")
    .replace("PIVO", "PIVÔ");
}

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const value = (error as { message?: unknown }).message;
    if (typeof value === "string" && value.trim()) return value;
  }
  return "Falha temporária de sincronização.";
}

export default function AuctionGame() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [me, setMe] = useState<Member | null>(null);
  const [mySquad, setMySquad] = useState<SquadSlot[]>([]);
  const [auction, setAuction] = useState<Auction | null>(null);
  const [player, setPlayer] = useState<Player | null>(null);
  const [myInterest, setMyInterest] = useState<Interest | null>(null);
  const [answered, setAnswered] = useState(false);
  const [bid, setBid] = useState(1);
  const [actionError, setActionError] = useState("");
  const [syncError, setSyncError] = useState("");
  const [loading, setLoading] = useState(true);
  const lastAuctionId = useRef<string | null>(null);

  const refresh = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,budget,mode,status")
      .eq("code", code)
      .maybeSingle();
    if (roomError) throw roomError;
    if (!roomData) throw new Error("Sala não encontrada.");

    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,user_id,display_name,balance,is_host,squad_finalized")
      .eq("room_id", typedRoom.id)
      .order("joined_at");
    if (memberError) throw memberError;

    const typedMembers = (memberData || []) as Member[];
    setMembers(typedMembers);
    const myMember = typedMembers.find((m) => m.user_id === session.user.id) || null;
    setMe(myMember);
    if (!myMember) throw new Error("Sua sessão não está vinculada a esta sala. Entre novamente pelo código da sala.");

    const { data: squadData, error: squadError } = await supabase
      .from("fa_squad_players")
      .select("member_id,player_id,slot_key,is_bench")
      .eq("member_id", myMember.id);
    if (squadError) throw squadError;
    const typedSquad = (squadData || []) as SquadSlot[];
    setMySquad(typedSquad);

    const { data: auctionData, error: auctionError } = await supabase
      .from("fa_auctions")
      .select("id,room_id,player_id,status,current_bid,current_bidder_member_id,turn_member_id,winner_member_id,final_price,created_at")
      .eq("room_id", typedRoom.id)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (auctionError) throw auctionError;

    if (!auctionData) {
      setAuction(null);
      setPlayer(null);
      setMyInterest(null);
      setAnswered(false);
      lastAuctionId.current = null;
      setSyncError("");
      return;
    }

    const typedAuction = auctionData as Auction;
    const isNewAuction = lastAuctionId.current !== typedAuction.id;
    if (isNewAuction) {
      setAnswered(false);
      lastAuctionId.current = typedAuction.id;
      setBid(Math.max(1, typedAuction.current_bid + 1));
    } else {
      setBid((value) => Math.max(value, typedAuction.current_bid + 1));
    }
    setAuction(typedAuction);

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,club,primary_position,overall,league,image_url,player_type")
      .eq("id", typedAuction.player_id)
      .maybeSingle();
    if (playerError) throw playerError;
    if (!playerData) throw new Error("O jogador atual ainda não foi sincronizado. Tentando novamente...");
    setPlayer(playerData as Player);

    if (typedAuction.status === "interest" || typedAuction.status === "bidding") {
      const { data: interest, error: interestError } = await supabase
        .from("fa_player_interest")
        .select("wants,bidding_active,turn_order")
        .eq("auction_id", typedAuction.id)
        .eq("member_id", myMember.id)
        .maybeSingle();
      if (interestError) throw interestError;
      const typedInterest = (interest || null) as Interest | null;
      setMyInterest(typedInterest);
      if (typedAuction.status === "interest") setAnswered(!!typedInterest);
    } else {
      setMyInterest(null);
    }

    setSyncError("");
  }, [code]);

  const safeRefresh = useCallback(async () => {
    try {
      await refresh();
    } catch (error) {
      setSyncError(errorMessage(error));
    } finally {
      setLoading(false);
    }
  }, [refresh]);

  useEffect(() => {
    void safeRefresh();
    const retry = window.setInterval(() => void safeRefresh(), 4000);
    return () => window.clearInterval(retry);
  }, [safeRefresh]);


  useEffect(() => {
    if (!room?.id) return;

    const heartbeat = async () => {
      await getSupabase().rpc("fa_heartbeat_room", { p_room_id: room.id });
    };

    void heartbeat();
    const timer = window.setInterval(() => void heartbeat(), 8000);
    return () => window.clearInterval(timer);
  }, [room?.id]);

  useEffect(() => {
    if (room?.status === "squads") router.replace(`/sala/${code}/times`);
  }, [room?.status, code, router]);

  useEffect(() => {
    if (!room?.id) return;
    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:auction:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_auctions", filter: `room_id=eq.${room.id}` }, () => void safeRefresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_bids" }, () => void safeRefresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_player_interest" }, () => void safeRefresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => void safeRefresh())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_squad_players" }, () => void safeRefresh())
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` }, () => void safeRefresh())
      .subscribe();
    return () => { void supabase.removeChannel(channel); };
  }, [room?.id, safeRefresh]);

  const winnerName = useMemo(
    () => members.find((m) => m.id === auction?.winner_member_id)?.display_name || "",
    [members, auction?.winner_member_id],
  );
  const bidderName = useMemo(
    () => members.find((m) => m.id === auction?.current_bidder_member_id)?.display_name || "",
    [members, auction?.current_bidder_member_id],
  );
  const turnName = useMemo(
    () => members.find((m) => m.id === auction?.turn_member_id)?.display_name || "",
    [members, auction?.turn_member_id],
  );

  const isHost = !!room && !!me && room.host_user_id === me.user_id;
  const isMyTurn = !!auction && !!me && auction.turn_member_id === me.id;
  const isHighestBidder = !!auction && !!me && auction.current_bidder_member_id === me.id;
  const isActiveBidder = !!myInterest?.bidding_active;
  const requiredSlots = room?.mode === "futsal" ? futsalSlots : footballSlots;
  const benchSlots = benchSlotsForMode(room?.mode || "football").map((slot) => slot.key);
  const rosterSize = rosterSizeForMode(room?.mode || "football");
  const filledSlots = new Set(mySquad.map((s) => s.slot_key));
  const starterComplete = requiredSlots.every((slot) => filledSlots.has(slot));
  const rosterComplete = starterComplete && benchSlots.every((slot) => filledSlots.has(slot));
  const minimumBid = (auction?.current_bid || 0) + 1;

  const currentPositionFull = useMemo(() => {
    if (!player || !room) return false;
    if (mySquad.length >= rosterSize) return true;
    if (starterComplete) return false;

    const target = positionGroup(player.primary_position);

    if (room.mode === "futsal") {
      if (target === "GOL") return filledSlots.has("GOL");
      return ["FIXO", "ALAE", "ALAD", "PIVO"].every((slot) => filledSlots.has(slot));
    }

    if (target === "ZAG") return filledSlots.has("ZAG1") && filledSlots.has("ZAG2");
    if (["GOL", "LD", "LE", "VOL", "MC", "MEI", "PD", "PE", "ATA"].includes(target)) {
      return filledSlots.has(target);
    }
    return true;
  }, [player, room, mySquad.length, rosterSize, starterComplete, filledSlots]);

  async function chooseInterest(wants: boolean) {
    if (!auction) return;
    setActionError("");
    const { error } = await getSupabase().rpc("fa_set_interest", {
      p_auction_id: auction.id,
      p_wants: wants,
    });
    if (error) return setActionError(error.message);
    setAnswered(true);
    await safeRefresh();
  }

  async function placeBid() {
    if (!auction || !isMyTurn) return;
    setActionError("");
    const amount = Math.max(minimumBid, bid);
    const { error } = await getSupabase().rpc("fa_place_bid", {
      p_auction_id: auction.id,
      p_amount: amount,
    });
    if (error) return setActionError(error.message);
    await safeRefresh();
  }

  async function withdrawBid() {
    if (!auction || !isMyTurn) return;
    setActionError("");
    const { error } = await getSupabase().rpc("fa_withdraw_bid", {
      p_auction_id: auction.id,
    });
    if (error) return setActionError(error.message);
    await safeRefresh();
  }

  async function nextPlayer() {
    if (!room) return;
    setActionError("");
    const { data, error } = await getSupabase().rpc("fa_start_next_auction", { p_room_id: room.id });
    if (error) return setActionError(error.message);

    const result = data as {
      auto_completed_last?: boolean;
      waiting_for_lineups?: boolean;
      players_added?: number;
    } | null;

    if (result?.auto_completed_last) {
      setActionError(
        result.players_added
          ? `O último elenco recebeu ${result.players_added} jogador(es) automaticamente. Agora ele precisa organizar a prancheta e finalizar.`
          : "O último elenco já está completo. Falta organizar a prancheta e finalizar."
      );
    } else if (result?.waiting_for_lineups) {
      setActionError("Os elencos restantes já estão completos. Falta organizar a prancheta e finalizar.");
    }

    setAnswered(false);
    await safeRefresh();
  }

  if (loading) return <main className="container"><p>Carregando leilão...</p></main>;

  return (
    <main className="container">
      <div className="topbar">
        <span className="badge">Sala {code}</span>
        <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap", justifyContent: "flex-end" }}>
          <button className="btn btn-secondary" onClick={() => router.push(`/sala/${code}/elenco`)} disabled={!mySquad.length}>
            Organizar prancheta
          </button>
          <span className="badge">Elenco: {mySquad.length}/{rosterSize}</span>
          <strong>Saldo: {me?.balance ?? 0}</strong>
        </div>
      </div>

      <section className="card" style={{ marginBottom: 16 }}>
        <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
          {requiredSlots.map((slot) => (
            <span key={slot} className="badge" style={{ opacity: filledSlots.has(slot) ? 1 : 0.45 }}>
              {filledSlots.has(slot) ? "✓ " : "○ "}{slotLabel(slot)}
            </span>
          ))}
        </div>
        {mySquad.length > 0 && !me?.squad_finalized && (
          <p className="muted" style={{ marginBottom: 0 }}>
            Você pode reorganizar titulares e reservas na prancheta. O leilão prioriza as posições titulares que ainda faltam; depois, completa o banco.
          </p>
        )}
        {rosterComplete && !me?.squad_finalized && (
          <div style={{ marginTop: 14 }}>
            <p className="red" style={{ fontWeight: 900 }}>
              Seu elenco está completo. Organize titulares e reservas antes de finalizar.
            </p>
            <button className="btn btn-primary" onClick={() => router.push(`/sala/${code}/elenco`)}>
              Organizar prancheta e finalizar
            </button>
          </div>
        )}
        {me?.squad_finalized && (
          <p className="muted" style={{ marginBottom: 0 }}>✓ Seu time está finalizado. Você não entra mais nos próximos leilões.</p>
        )}
      </section>

      {syncError && (
        <div className="card" style={{ marginBottom: 16 }}>
          <p className="red" style={{ marginBottom: 6 }}>Sincronização instável</p>
          <p className="muted" style={{ margin: 0 }}>{syncError} O jogo tentará novamente automaticamente.</p>
        </div>
      )}
      {actionError && <div className="card" style={{ marginBottom: 16 }}><p className="red">{actionError}</p></div>}

      {!auction || !player ? (
        <section className="card" style={{ maxWidth: 620, margin: "0 auto", textAlign: "center" }}>
          <h2>Aguardando jogador</h2>
          <p className="muted">O administrador precisa iniciar o próximo leilão.</p>
        </section>
      ) : (
        <section className="card" style={{ maxWidth: 660, margin: "0 auto", textAlign: "center" }}>
          <div className="red" style={{ fontSize: 18, fontWeight: 900, letterSpacing: 2 }}>GER</div>
          <div className="red" style={{ fontSize: 58, fontWeight: 900, lineHeight: 1 }}>{player.overall}</div>
          {player.player_type === "ICON" && (
            <div style={{ marginTop: 8 }}>
              <span className="badge" style={{ fontWeight: 900, letterSpacing: 2 }}>ICON</span>
            </div>
          )}
          <div style={{ display: "flex", justifyContent: "center", margin: "14px 0 4px" }}>
            <PlayerFace name={player.name} imageUrl={player.image_url} size={124} />
          </div>
          <h1 style={{ fontSize: 42, margin: "12px 0 8px" }}>{player.name}</h1>
          <p style={{ margin: "0 0 12px", fontWeight: 900 }}>
            {player.name} — {player.club || (player.league === "LEGENDS" ? "Lendas" : "Clube em revisão")} — {player.primary_position} — GER {player.overall}
          </p>
          <div style={{ display: "flex", gap: 8, justifyContent: "center", flexWrap: "wrap" }}>
            <span className="badge"><strong>Clube:</strong> {player.club || "Em revisão"}</span>
            <span className="badge"><strong>Posição:</strong> {player.primary_position}</span>
            <span className="badge"><strong>Liga:</strong> {player.league === "LEGENDS" ? "Lendas" : (player.league || "—")}</span>
          </div>

          {auction.status === "interest" && (
            <div style={{ marginTop: 26 }}>
              <h2>Você quer disputar este jogador?</h2>
              {me?.squad_finalized ? (
                <p className="muted">Seu time já está finalizado.</p>
              ) : currentPositionFull ? (
                <p className="muted">Este jogador não pode entrar no seu elenco neste momento. PASSAR automático.</p>
              ) : answered ? (
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
            <div style={{ marginTop: 28 }}>
              <div className="card" style={{ background: "var(--surface-2)", marginBottom: 16 }}>
                {auction.current_bidder_member_id ? (
                  <p style={{ margin: 0, fontSize: 18 }}>
                    Maior lance: <strong className="red">{auction.current_bid} créditos</strong> — {bidderName}
                  </p>
                ) : (
                  <p style={{ margin: 0, fontSize: 18 }}>Ainda não houve lance.</p>
                )}
              </div>

              {!isActiveBidder ? (
                <p className="muted">Você desistiu deste leilão. Aguardando os demais jogadores.</p>
              ) : isHighestBidder ? (
                <div>
                  <h2 className="red">VOCÊ ESTÁ NA FRENTE</h2>
                  <p className="muted">Seu lance é o maior. Agora os outros participantes decidem se aumentam ou desistem.</p>
                </div>
              ) : isMyTurn ? (
                <div>
                  <h2 className="red" style={{ fontSize: 30 }}>SUA VEZ</h2>
                  <p className="muted">Aumente o maior lance ou desista deste jogador.</p>
                  <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap", alignItems: "center" }}>
                    <button className="btn btn-secondary" onClick={() => setBid((value) => Math.max(minimumBid, value - 1))}>−</button>
                    <span className="badge" style={{ minWidth: 132 }}>Seu lance: {Math.max(minimumBid, bid)}</span>
                    <button className="btn btn-secondary" onClick={() => setBid((value) => Math.min(me?.balance ?? value, Math.max(minimumBid, value + 1)))}>+</button>
                    <button className="btn btn-primary" onClick={placeBid} disabled={!me || Math.max(minimumBid, bid) > me.balance}>
                      AUMENTAR LANCE
                    </button>
                    <button className="btn btn-secondary" onClick={withdrawBid}>DESISTIR</button>
                  </div>
                </div>
              ) : (
                <div>
                  <h2>Vez de {turnName || "outro jogador"}</h2>
                  <p className="muted">Aguarde. Assim que ele der um lance ou desistir, a vez passa automaticamente.</p>
                </div>
              )}
            </div>
          )}

          {auction.status === "sold" && (
            <div style={{ marginTop: 28 }}>
              <GavelWinAnimation auctionId={auction.id} />
              <h2 className="red">LEILOADO PARA {winnerName.toUpperCase()}</h2>
              <p>{auction.final_price === 0 ? "Levou de graça." : `${auction.final_price} créditos`}</p>
              {isHost && <button className="btn btn-primary" onClick={nextPlayer}>Próximo jogador</button>}
              {!isHost && <p className="muted">Aguardando o administrador chamar o próximo jogador.</p>}
            </div>
          )}

          {auction.status === "skipped" && (
            <div style={{ marginTop: 28 }}>
              <h2>Ninguém ficou com este jogador</h2>
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
