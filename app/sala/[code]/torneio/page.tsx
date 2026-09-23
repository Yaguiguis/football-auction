"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import ConnectionBanner from "../../../../components/ConnectionBanner";
import RoomChat from "../../../../components/RoomChat";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  room_kind: "auction" | "tournament";
  tournament_size: 4 | 8 | 16 | null;
  tournament_champion_member_id: string | null;
  mode: "football" | "futsal";
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  is_host: boolean;
  is_spectator: boolean;
  squad_finalized: boolean;
  replay_requested: boolean;
};

type MatchResult = {
  score?: { a?: number; b?: number };
  penalties?: { a?: number; b?: number };
  extra_time?: { score?: { a?: number; b?: number } };
  decided_by?: "normal_time" | "extra_time" | "penalties";
};

type TournamentMatch = {
  id: string;
  round_no: number;
  match_no: number;
  member_a_id: string | null;
  member_b_id: string | null;
  winner_member_id: string | null;
  status: "pending" | "completed" | "bye";
  result: MatchResult | null;
  played_at: string | null;
};

function roundLabel(round: number, totalRounds: number) {
  const remaining = totalRounds - round;
  if (remaining === 0) return "Final";
  if (remaining === 1) return "Semifinal";
  if (remaining === 2) return "Quartas de final";
  if (remaining === 3) return "Oitavas de final";
  return `Rodada ${round}`;
}

export default function TournamentPage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [matches, setMatches] = useState<TournamentMatch[]>([]);
  const [userId, setUserId] = useState("");
  const [loading, setLoading] = useState(true);
  const [playing, setPlaying] = useState(false);
  const [replaying, setReplaying] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");

  const load = useCallback(async () => {
    const session = await ensureAnonymousSession();
    setUserId(session.user.id);

    const supabase = getSupabase();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,room_kind,tournament_size,tournament_champion_member_id,mode,status")
      .eq("code", code)
      .maybeSingle();

    if (roomError) throw roomError;
    if (!roomData) throw new Error("Torneio não encontrado.");

    const typedRoom = roomData as Room;
    setRoom(typedRoom);

    const [{ data: memberData, error: memberError }, { data: matchData, error: matchError }] =
      await Promise.all([
        supabase
          .from("fa_room_members")
          .select("id,user_id,display_name,is_host,is_spectator,squad_finalized,replay_requested")
          .eq("room_id", typedRoom.id)
          .order("joined_at"),
        supabase
          .from("fa_tournament_matches")
          .select("id,round_no,match_no,member_a_id,member_b_id,winner_member_id,status,result,played_at")
          .eq("room_id", typedRoom.id)
          .order("round_no")
          .order("match_no"),
      ]);

    if (memberError) throw memberError;
    if (matchError) throw matchError;

    setMembers((memberData || []) as Member[]);
    setMatches((matchData || []) as TournamentMatch[]);
  }, [code]);

  const safeLoad = useCallback(async () => {
    try {
      await load();
      setError("");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível carregar o torneio.");
    } finally {
      setLoading(false);
    }
  }, [load]);

  useEffect(() => {
    void safeLoad();
    const timer = window.setInterval(() => void safeLoad(), 3500);
    return () => window.clearInterval(timer);
  }, [safeLoad]);

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
    if (!room?.id) return;

    const supabase = getSupabase();
    const channel = supabase
      .channel(`football-auction:tournament:${room.id}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "fa_tournament_matches", filter: `room_id=eq.${room.id}` },
        () => void safeLoad(),
      )
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` },
        () => void safeLoad(),
      )
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [room?.id, safeLoad]);

  const memberById = useMemo(
    () => new Map(members.map((member) => [member.id, member])),
    [members],
  );

  const participants = members.filter((member) => !member.is_spectator);
  const me = members.find((member) => member.user_id === userId) || null;
  const isHost = !!room && room.host_user_id === userId;
  const champion = room?.tournament_champion_member_id
    ? memberById.get(room.tournament_champion_member_id) || null
    : null;

  const firstRoundMatches = matches.filter((match) => match.round_no === 1).length;
  const totalRounds = firstRoundMatches > 0
    ? Math.max(1, Math.round(Math.log2(firstRoundMatches * 2)))
    : 1;
  const roundNumbers = Array.from(new Set(matches.map((match) => match.round_no))).sort((a, b) => a - b);
  const pendingRound = matches
    .filter((match) => match.status === "pending")
    .reduce<number | null>((min, match) => min === null ? match.round_no : Math.min(min, match.round_no), null);

  async function playNextRound() {
    if (!room || !isHost || playing) return;

    setPlaying(true);
    setError("");
    setNotice("");

    try {
      const { data, error: rpcError } = await getSupabase().rpc("fa_play_tournament_round", {
        p_room_id: room.id,
      });

      if (rpcError) throw rpcError;

      const result = (data || {}) as {
        finished?: boolean;
        round?: number;
        next_round?: number;
        champion_member_id?: string;
      };

      if (result.finished) {
        const winner = result.champion_member_id
          ? memberById.get(result.champion_member_id)?.display_name
          : "";
        setNotice(winner ? `🏆 ${winner} é o campeão!` : "🏆 Torneio finalizado!");
      } else if (result.next_round) {
        setNotice(`Fase concluída. Próxima rodada: ${roundLabel(result.next_round, totalRounds)}.`);
      }

      await safeLoad();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível jogar a próxima fase.");
    } finally {
      setPlaying(false);
    }
  }

  async function requestReplay() {
    if (!room || !me || me.is_spectator || replaying) return;

    setReplaying(true);
    setError("");

    try {
      const { data, error: rpcError } = await getSupabase().rpc("fa_request_replay", {
        p_room_id: room.id,
      });

      if (rpcError) throw rpcError;

      const result = (data || {}) as { restarted?: boolean };

      if (result.restarted) {
        router.replace(`/sala/${code}/lobby`);
        return;
      }

      setNotice("Pedido de revanche enviado. Aguardando o administrador.");
      await safeLoad();
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível pedir revanche.");
    } finally {
      setReplaying(false);
    }
  }

  if (loading) {
    return <main className="container"><p>Montando a chave...</p></main>;
  }

  if (room?.room_kind !== "tournament") {
    return (
      <main className="container">
        <section className="card">
          <h1>Esta sala não é um torneio.</h1>
          <button className="btn btn-primary" onClick={() => router.push(`/sala/${code}/times`)}>
            Ver resultados
          </button>
        </section>
      </main>
    );
  }

  if (room.status === "lobby" || room.status === "auction") {
    return (
      <main className="container tournament-page">
        <ConnectionBanner />
        {room && <RoomChat roomId={room.id} />}
        <section className="card tournament-waiting">
          <span className="tournament-champion-trophy">🏆</span>
          <h1>O mata-mata ainda não começou</h1>
          <p className="muted">
            Primeiro todos precisam montar e finalizar seus elencos no leilão.
          </p>
          <button
            className="btn btn-primary"
            onClick={() =>
              router.push(
                room.status === "lobby"
                  ? `/sala/${code}/lobby`
                  : `/sala/${code}/leilao`
              )
            }
          >
            {room.status === "lobby" ? "Voltar ao lobby" : "Voltar ao leilão"}
          </button>
        </section>
      </main>
    );
  }

  return (
    <main className="container tournament-page">
      <ConnectionBanner />
      {room && <RoomChat roomId={room.id} />}

      <div className="topbar">
        <button className="btn btn-secondary" onClick={() => router.push(`/sala/${code}/lobby`)}>
          ← Lobby
        </button>
        <span className="badge">Sala {code}</span>
      </div>

      <header className="tournament-hero">
        <span className="tournament-hero-kicker">🏆 LEILÃO DOS CRIAS</span>
        <h1>Mata-mata</h1>
        <p>
          {participants.length} times • {room.mode === "futsal" ? "Futsal" : "Campo"} • chave até {room.tournament_size}
        </p>
      </header>

      {error && (
        <div className="card" style={{ marginBottom: 14 }}>
          <p className="red" style={{ margin: 0 }}>{error}</p>
        </div>
      )}

      {notice && (
        <div className="card" style={{ marginBottom: 14, textAlign: "center" }}>
          <strong>{notice}</strong>
        </div>
      )}

      {champion && (
        <section className="tournament-champion">
          <span className="tournament-champion-trophy">🏆</span>
          <span className="tournament-hero-kicker">CAMPEÃO DO LEILÃO DOS CRIAS</span>
          <h2>{champion.display_name}</h2>
          <p className="muted">Sobreviveu ao mata-mata e ficou com o título.</p>
        </section>
      )}

      {matches.length === 0 ? (
        <section className="card tournament-waiting">
          <h2>Preparando chave...</h2>
          <p className="muted">A chave aparece assim que os times estiverem finalizados.</p>
        </section>
      ) : (
        <section className="card">
          <div className="topbar">
            <div>
              <h2 style={{ margin: 0 }}>Chave do torneio</h2>
              <p className="muted" style={{ margin: "5px 0 0" }}>
                Empates no mata-mata são decididos nos pênaltis.
              </p>
            </div>
            {!champion && pendingRound && (
              <span className="badge">{roundLabel(pendingRound, totalRounds)}</span>
            )}
          </div>

          <div className="tournament-bracket-wrap">
            <div className="tournament-bracket">
              {roundNumbers.map((round) => {
                const roundMatches = matches.filter((match) => match.round_no === round);

                return (
                  <div className="tournament-round" key={round}>
                    <div className="tournament-round-title">
                      <span>{roundLabel(round, totalRounds)}</span>
                      <span>{roundMatches.length} jogo{roundMatches.length === 1 ? "" : "s"}</span>
                    </div>

                    {roundMatches.map((match) => {
                      const a = match.member_a_id ? memberById.get(match.member_a_id) : null;
                      const b = match.member_b_id ? memberById.get(match.member_b_id) : null;
                      const scoreA = match.result?.score?.a;
                      const scoreB = match.result?.score?.b;
                      const penA = match.result?.penalties?.a;
                      const penB = match.result?.penalties?.b;

                      return (
                        <article
                          className={`tournament-match ${match.status === "completed" ? "completed" : ""}`}
                          key={match.id}
                        >
                          <div className={`tournament-team ${match.winner_member_id === match.member_a_id ? "winner" : ""}`}>
                            <strong>{a?.display_name || "A definir"}</strong>
                            {scoreA !== undefined && <span className="tournament-score">{scoreA}</span>}
                          </div>

                          <div className={`tournament-team ${match.winner_member_id === match.member_b_id ? "winner" : ""}`}>
                            <strong>{b?.display_name || (match.status === "bye" ? "BYE" : "A definir")}</strong>
                            {scoreB !== undefined && <span className="tournament-score">{scoreB}</span>}
                          </div>

                          {match.status === "bye" ? (
                            <p className="tournament-match-note">Avanço automático para a próxima fase.</p>
                          ) : match.status === "pending" ? (
                            <p className="tournament-match-note">Aguardando simulação.</p>
                          ) : match.result?.decided_by === "penalties" ? (
                            <p className="tournament-match-note">
                              Empate na prorrogação • Pênaltis {penA ?? "—"} × {penB ?? "—"}
                            </p>
                          ) : match.result?.decided_by === "extra_time" ? (
                            <p className="tournament-match-note">
                              Decidido na prorrogação
                            </p>
                          ) : (
                            <p className="tournament-match-note">Fim de jogo.</p>
                          )}
                        </article>
                      );
                    })}
                  </div>
                );
              })}
            </div>
          </div>
        </section>
      )}

      <div className="tournament-actions">
        {isHost && !champion && matches.some((match) => match.status === "pending") && (
          <button className="btn btn-primary" disabled={playing} onClick={() => void playNextRound()}>
            {playing
              ? "Jogando fase..."
              : pendingRound
                ? `Jogar ${roundLabel(pendingRound, totalRounds)}`
                : "Jogar próxima fase"}
          </button>
        )}

        {!isHost && !champion && (
          <span className="muted">O administrador controla o início de cada fase.</span>
        )}

        {champion && !me?.is_spectator && (
          <button
            className="btn btn-primary"
            disabled={replaying || (!isHost && !!me?.replay_requested)}
            onClick={() => void requestReplay()}
          >
            {replaying
              ? "Preparando..."
              : !isHost && me?.replay_requested
                ? "Aguardando administrador"
                : "Jogar outro torneio"}
          </button>
        )}
      </div>
    </main>
  );
}
