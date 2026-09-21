"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import {
  benchSlotsForMode,
  boardForMode,
  effectiveGer,
  rosterSizeForMode,
  squadGer,
  type GameMode,
  type RatedPlayer,
} from "../../../../lib/squad-board";
import ConnectionBanner from "../../../../components/ConnectionBanner";
import PlayerFace from "../../../../components/PlayerFace";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  mode: GameMode;
  reserve_count: number;
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  balance: number;
  is_host: boolean;
  squad_finalized: boolean;
  replay_requested: boolean;
  is_spectator: boolean;
  last_seen_at: string;
};

type SquadRow = {
  member_id: string;
  player_id: string;
  slot_key: string;
};

type Player = RatedPlayer & {
  player_type: "ACTIVE" | "ICON";
};

type AuctionRow = {
  id: string;
  player_id: string;
  status: "interest" | "bidding" | "sold" | "skipped";
  winner_member_id: string | null;
  final_price: number | null;
  created_at: string;
};

export default function TeamsPage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [squads, setSquads] = useState<SquadRow[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [auctions, setAuctions] = useState<AuctionRow[]>([]);
  const [userId, setUserId] = useState("");
  const [loading, setLoading] = useState(true);
  const [replaying, setReplaying] = useState(false);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    const session = await ensureAnonymousSession();
    setUserId(session.user.id);

    const supabase = getSupabase();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,mode,reserve_count,status")
      .eq("code", code)
      .single();

    if (roomError) throw roomError;

    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const { data: memberData, error: memberError } = await supabase
      .from("fa_room_members")
      .select("id,user_id,display_name,balance,is_host,squad_finalized,replay_requested,is_spectator,last_seen_at")
      .eq("room_id", typedRoom.id)
      .order("joined_at");

    if (memberError) throw memberError;

    const typedMembers = (memberData || []) as Member[];
    setMembers(typedMembers);

    const { data: auctionData, error: auctionError } = await supabase
      .from("fa_auctions")
      .select("id,player_id,status,winner_member_id,final_price,created_at")
      .eq("room_id", typedRoom.id)
      .order("created_at", { ascending: false });

    if (auctionError) throw auctionError;

    const typedAuctions = (auctionData || []) as AuctionRow[];
    setAuctions(typedAuctions);

    const participantIds = typedMembers.filter((member) => !member.is_spectator).map((member) => member.id);

    let typedSquads: SquadRow[] = [];

    if (participantIds.length) {
      const { data: squadData, error: squadError } = await supabase
        .from("fa_squad_players")
        .select("member_id,player_id,slot_key")
        .in("member_id", participantIds);

      if (squadError) throw squadError;
      typedSquads = (squadData || []) as SquadRow[];
    }

    setSquads(typedSquads);

    const playerIds = Array.from(
      new Set([
        ...typedSquads.map((squad) => squad.player_id),
        ...typedAuctions.map((auction) => auction.player_id),
      ]),
    );

    if (!playerIds.length) {
      setPlayers([]);
      return;
    }

    const { data: playerData, error: playerError } = await supabase
      .from("fa_players")
      .select("id,name,primary_position,overall,image_url,player_type")
      .in("id", playerIds);

    if (playerError) throw playerError;
    setPlayers((playerData || []) as Player[]);
  }, [code]);

  useEffect(() => {
    void load()
      .catch((e) => setError(e instanceof Error ? e.message : "Erro ao carregar as escalações."))
      .finally(() => setLoading(false));
  }, [load]);

  useEffect(() => {
    if (!room?.id) return;

    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:teams:${room.id}`)
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_squad_players" }, () => void load())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_room_members", filter: `room_id=eq.${room.id}` }, () => void load())
      .on("postgres_changes", { event: "*", schema: "public", table: "fa_auctions", filter: `room_id=eq.${room.id}` }, () => void load())
      .on("postgres_changes", { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` }, () => void load())
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [room?.id, load]);

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
    if (room?.status === "lobby") {
      router.replace(`/sala/${code}/lobby`);
    }
  }, [room?.status, code, router]);

  const playerById = useMemo(() => new Map(players.map((player) => [player.id, player])), [players]);
  const memberById = useMemo(() => new Map(members.map((member) => [member.id, member])), [members]);

  const boardSlots = boardForMode(room?.mode || "football");
  const benchSlots = benchSlotsForMode(room?.mode || "football", room?.reserve_count);
  const rosterSize = rosterSizeForMode(room?.mode || "football", room?.reserve_count);

  const participants = members.filter((member) => !member.is_spectator);
  const spectators = members.filter((member) => member.is_spectator);
  const me = members.find((member) => member.user_id === userId) || null;
  const isHost = !!room && room.host_user_id === userId;
  const replayRequests = participants.filter((member) => member.replay_requested).length;

  const online = useCallback(
    (member: Member) => Date.now() - new Date(member.last_seen_at).getTime() < 30_000,
    [],
  );

  const stats = useMemo(() => {
    const sold = auctions.filter((auction) => auction.status === "sold" && auction.winner_member_id);
    const paid = sold.filter((auction) => (auction.final_price || 0) > 0);

    const mostExpensive = paid.reduce<AuctionRow | null>((best, auction) => {
      if (!best || (auction.final_price || 0) > (best.final_price || 0)) return auction;
      return best;
    }, null);

    const spending = new Map<string, number>();
    for (const auction of sold) {
      if (!auction.winner_member_id) continue;
      spending.set(
        auction.winner_member_id,
        (spending.get(auction.winner_member_id) || 0) + (auction.final_price || 0),
      );
    }

    let biggestSpender: { memberId: string; total: number } | null = null;
    for (const [memberId, total] of spending) {
      if (!biggestSpender || total > biggestSpender.total) biggestSpender = { memberId, total };
    }

    const teamRatings = participants.map((member) => {
      const memberSquad = squads.filter((squad) => squad.member_id === member.id);
      return {
        member,
        ger: room ? squadGer(memberSquad, playerById, room.mode) : 0,
      };
    });

    const highestGer = teamRatings.reduce<(typeof teamRatings)[number] | null>((best, item) => {
      if (!best || item.ger > best.ger) return item;
      return best;
    }, null);

    const bestValue = paid.reduce<{
      auction: AuctionRow;
      score: number;
    } | null>((best, auction) => {
      const player = playerById.get(auction.player_id);
      if (!player || !auction.final_price) return best;
      const score = player.overall / auction.final_price;
      if (!best || score > best.score) return { auction, score };
      return best;
    }, null);

    const iconCount = sold.filter((auction) => playerById.get(auction.player_id)?.player_type === "ICON").length;
    const freeCount = sold.filter((auction) => auction.final_price === 0).length;

    return { sold, mostExpensive, biggestSpender, highestGer, bestValue, iconCount, freeCount };
  }, [auctions, participants, playerById, room, squads]);

  async function requestReplay() {
    if (!room || replaying || me?.is_spectator) return;

    setReplaying(true);
    setError("");

    try {
      const { data, error: rpcError } = await getSupabase().rpc("fa_request_replay", {
        p_room_id: room.id,
      });

      if (rpcError) throw rpcError;

      const result = data as { restarted?: boolean } | null;

      if (result?.restarted) {
        router.replace(`/sala/${code}/lobby`);
        return;
      }

      await load();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível pedir uma nova partida.");
    } finally {
      setReplaying(false);
    }
  }

  if (loading) {
    return <main className="container"><p>Montando as pranchetas...</p></main>;
  }

  const mostExpensivePlayer = stats.mostExpensive ? playerById.get(stats.mostExpensive.player_id) : null;
  const biggestSpenderMember = stats.biggestSpender ? memberById.get(stats.biggestSpender.memberId) : null;
  const bestValuePlayer = stats.bestValue ? playerById.get(stats.bestValue.auction.player_id) : null;

  return (
    <main className="container">
      <ConnectionBanner />

      <div className="topbar">
        <div>
          <p className="red" style={{ margin: 0, fontWeight: 900, letterSpacing: 2 }}>RESULTADO DOS ELENCOS</p>
          <h1 style={{ marginTop: 6 }}>Pranchetas finais</h1>
        </div>
        <span className="badge">Sala {code}</span>
      </div>

      {error && (
        <div className="card" style={{ marginBottom: 16 }}>
          <p className="red" style={{ margin: 0 }}>{error}</p>
        </div>
      )}

      <section className="stats-grid">
        <div className="stat-card">
          <span>Maior GER</span>
          <strong>{stats.highestGer ? `${stats.highestGer.member.display_name} • ${stats.highestGer.ger}` : "—"}</strong>
        </div>

        <div className="stat-card">
          <span>Jogador mais caro</span>
          <strong>
            {mostExpensivePlayer && stats.mostExpensive
              ? `${mostExpensivePlayer.name} • ${stats.mostExpensive.final_price} cr`
              : "—"}
          </strong>
        </div>

        <div className="stat-card">
          <span>Maior gasto</span>
          <strong>
            {biggestSpenderMember && stats.biggestSpender
              ? `${biggestSpenderMember.display_name} • ${stats.biggestSpender.total} cr`
              : "—"}
          </strong>
        </div>

        <div className="stat-card">
          <span>Melhor GER por crédito</span>
          <strong>
            {bestValuePlayer && stats.bestValue
              ? `${bestValuePlayer.name} • ${stats.bestValue.auction.final_price} cr`
              : "—"}
          </strong>
        </div>

        <div className="stat-card">
          <span>ICONS conquistados</span>
          <strong>{stats.iconCount}</strong>
        </div>

        <div className="stat-card">
          <span>Jogadores grátis</span>
          <strong>{stats.freeCount}</strong>
        </div>
      </section>

      <div className="grid final-team-grid">
        {participants.map((member) => {
          const memberSquad = squads.filter((squad) => squad.member_id === member.id);
          const ger = room ? squadGer(memberSquad, playerById, room.mode) : 0;
          const bySlot = new Map(memberSquad.map((squad) => [squad.slot_key, playerById.get(squad.player_id)]));
          const isOnline = online(member);
          const statusText = member.squad_finalized
            ? "Time finalizado"
            : isOnline
              ? "Ainda não finalizou"
              : "Desconectado / abandonou";

          return (
            <section className="card" key={member.id}>
              <div className="topbar" style={{ marginBottom: 14 }}>
                <div>
                  <h2 style={{ margin: 0 }}>{member.is_host ? "👑 " : ""}{member.display_name}</h2>
                  <p className={member.squad_finalized ? "muted" : "red"} style={{ margin: "5px 0 0" }}>
                    {statusText}
                  </p>
                </div>

                <div style={{ textAlign: "center", minWidth: 82 }}>
                  <div className="red" style={{ fontSize: 34, fontWeight: 900, lineHeight: 1 }}>{ger}</div>
                  <small className="muted">GER ESCALAÇÃO</small>
                </div>
              </div>

              <div className="final-board" data-mode={room?.mode}>
                <div className="pitch-half-line" />
                <div className="pitch-center-circle" />

                {boardSlots.map((slot) => {
                  const player = bySlot.get(slot.key);
                  const effective = player && room ? effectiveGer(player, slot.key, room.mode) : 0;
                  const penalty = player ? player.overall - effective : 0;

                  return (
                    <div
                      key={slot.key}
                      className="final-board-slot"
                      style={{ left: `${slot.x}%`, top: `${slot.y}%` }}
                    >
                      <div className={`final-player-card ${player?.player_type === "ICON" ? "icon-card-mini" : ""}`}>
                        <div className="slot-label">{slot.label}</div>
                        {player && (
                          <div style={{ display: "flex", justifyContent: "center", margin: "3px 0" }}>
                            <PlayerFace name={player.name} imageUrl={player.image_url} size={34} />
                          </div>
                        )}
                        <div className="player-name-small">{player?.name || "Vazio"}</div>
                        {player && (
                          <div className="red" style={{ fontSize: 13, fontWeight: 900 }}>
                            {effective} GER{penalty > 0 ? ` (-${penalty})` : ""}
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>

              {benchSlots.length > 0 && (
                <div className="card" style={{ marginTop: 14, padding: 14 }}>
                  <h3 style={{ margin: "0 0 10px" }}>Banco de reservas</h3>
                  <div className="bench-final-grid">
                    {benchSlots.map((slot) => {
                      const player = bySlot.get(slot.key);

                      return (
                        <div className="bench-final-card" key={slot.key}>
                          <div className="muted" style={{ fontSize: 9, fontWeight: 900 }}>{slot.label}</div>
                          {player ? (
                            <>
                              <div style={{ display: "flex", justifyContent: "center", margin: "6px 0" }}>
                                <PlayerFace name={player.name} imageUrl={player.image_url} size={34} />
                              </div>
                              <strong className="player-name-small">{player.name}</strong>
                              <span className="red" style={{ fontSize: 11, fontWeight: 900 }}>{player.overall} GER</span>
                            </>
                          ) : (
                            <div className="muted" style={{ padding: "16px 0" }}>Vazio</div>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}

              <div style={{ display: "flex", justifyContent: "space-between", gap: 12, marginTop: 14 }}>
                <span className="muted">{memberSquad.length}/{rosterSize} jogadores</span>
                <strong>{member.balance} créditos restantes</strong>
              </div>
            </section>
          );
        })}
      </div>

      <section className="card" style={{ marginTop: 20 }}>
        <div className="topbar" style={{ marginBottom: 12 }}>
          <div>
            <h2 style={{ margin: 0 }}>Histórico da partida</h2>
            <p className="muted" style={{ margin: "4px 0 0" }}>{auctions.length} sorteios registrados</p>
          </div>
        </div>

        <div className="history-list">
          {auctions.map((auction) => {
            const historyPlayer = playerById.get(auction.player_id);
            const winner = auction.winner_member_id ? memberById.get(auction.winner_member_id) : null;

            return (
              <div className="history-row" key={auction.id}>
                <div>
                  <strong>{historyPlayer?.player_type === "ICON" ? "★ " : ""}{historyPlayer?.name || "Jogador"}</strong>
                  {historyPlayer && <span className="muted"> • GER {historyPlayer.overall}</span>}
                </div>

                <div style={{ textAlign: "right" }}>
                  {auction.status === "sold" ? (
                    <>
                      <strong className="red">{winner?.display_name || "Jogador"}</strong>
                      <div className="muted">
                        {auction.final_price === 0 ? "de graça" : `${auction.final_price} créditos`}
                      </div>
                    </>
                  ) : (
                    <span className="muted">Sem dono</span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {spectators.length > 0 && (
        <section className="card" style={{ marginTop: 20 }}>
          <h2>Espectadores</h2>
          <p className="muted" style={{ marginBottom: 0 }}>
            {spectators.map((spectator) => spectator.display_name).join(" • ")}
          </p>
        </section>
      )}

      <section className="card" style={{ marginTop: 20, textAlign: "center" }}>
        <h2>Outra partida?</h2>

        {!me?.is_spectator && (
          <p className="muted">
            {replayRequests}/{participants.length} participantes pediram para jogar novamente.
          </p>
        )}

        {!isHost && !me?.is_spectator && me?.replay_requested && (
          <p className="red" style={{ fontWeight: 900 }}>
            Pedido enviado. Aguardando o administrador.
          </p>
        )}

        <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap", marginTop: 14 }}>
          {!me?.is_spectator && (
            <button
              className="btn btn-primary"
              onClick={() => void requestReplay()}
              disabled={replaying || (!isHost && !!me?.replay_requested)}
            >
              {replaying
                ? "Preparando..."
                : !isHost && me?.replay_requested
                  ? "Aguardando administrador"
                  : "Jogar novamente"}
            </button>
          )}

          <button className="btn btn-secondary" onClick={() => router.push("/")}>
            Tela inicial
          </button>
        </div>
      </section>
    </main>
  );
}
