"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import type { RatedPlayer } from "../../../../lib/squad-board";
import ConnectionBanner from "../../../../components/ConnectionBanner";
import PlayerFace from "../../../../components/PlayerFace";
import CardBadge, { cardClass } from "../../../../components/CardBadge";
import RoomChat from "../../../../components/RoomChat";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  mode: "football" | "futsal";
  reserve_count: number;
  room_kind: "auction" | "tournament" | "cases";
  status: string;
};

type Member = {
  id: string;
  user_id: string;
  display_name: string;
  is_host: boolean;
  is_spectator: boolean;
  last_seen_at: string;
};

type CaseRound = {
  id: string;
  room_id: string;
  round_no: number;
  slot_key: string;
  status: "choosing" | "completed";
  case_count: number;
  created_at: string;
  completed_at: string | null;
};

type CasePick = {
  id: string;
  round_id: string;
  room_id: string;
  member_id: string;
  case_no: number;
  player_id: string;
  created_at: string;
};

type Player = RatedPlayer & {
  league?: string | null;
  club?: string | null;
};

const slotLabels: Record<string, string> = {
  GOL: "Goleiro",
  LD: "Lateral direito",
  LE: "Lateral esquerdo",
  ZAG1: "Zagueiro 1",
  ZAG2: "Zagueiro 2",
  VOL: "Volante",
  MC: "Meio-campo",
  MEI: "Meia",
  PD: "Ponta direita",
  PE: "Ponta esquerda",
  ATA: "Atacante",
  FIXO: "Fixo",
  ALAE: "Ala esquerda",
  ALAD: "Ala direita",
  PIVO: "Pivô",
};

function slotsForMode(mode: "football" | "futsal", reserves: number) {
  const starters =
    mode === "futsal"
      ? ["GOL", "FIXO", "ALAE", "ALAD", "PIVO"]
      : ["GOL", "LD", "ZAG1", "ZAG2", "LE", "VOL", "MC", "MEI", "PD", "PE", "ATA"];

  return [
    ...starters,
    ...Array.from({ length: Math.max(0, reserves) }, (_, index) => `BENCH${index + 1}`),
  ];
}

function labelForSlot(slot: string) {
  if (slot.startsWith("BENCH")) {
    return `Reserva ${Number(slot.replace("BENCH", "")) || ""}`.trim();
  }

  return slotLabels[slot] || slot;
}

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message;

  if (error && typeof error === "object" && "message" in error) {
    const message = (error as { message?: unknown }).message;
    if (typeof message === "string") return message;
  }

  return "Não foi possível atualizar o modo Maletas.";
}

export default function CasesModePage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [members, setMembers] = useState<Member[]>([]);
  const [userId, setUserId] = useState("");
  const [rounds, setRounds] = useState<CaseRound[]>([]);
  const [picks, setPicks] = useState<CasePick[]>([]);
  const [players, setPlayers] = useState<Player[]>([]);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [flashPlayer, setFlashPlayer] = useState<Player | null>(null);

  const load = useCallback(async () => {
    const supabase = getSupabase();
    const session = await ensureAnonymousSession();
    setUserId(session.user.id);

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,mode,reserve_count,room_kind,status")
      .eq("code", code)
      .maybeSingle();

    if (roomError) throw roomError;
    if (!roomData) throw new Error("Sala não encontrada.");

    const typedRoom = roomData as Room;
    if (typedRoom.room_kind !== "cases") {
      throw new Error("Esta sala não é do Modo Maletas.");
    }

    setRoom(typedRoom);

    const [membersResult, roundsResult, picksResult] = await Promise.all([
      supabase
        .from("fa_room_members")
        .select("id,user_id,display_name,is_host,is_spectator,last_seen_at")
        .eq("room_id", typedRoom.id)
        .is("kicked_at", null)
        .order("joined_at"),
      supabase
        .from("fa_case_rounds")
        .select("*")
        .eq("room_id", typedRoom.id)
        .order("round_no"),
      supabase
        .from("fa_case_picks")
        .select("*")
        .eq("room_id", typedRoom.id)
        .order("created_at"),
    ]);

    if (membersResult.error) throw membersResult.error;
    if (roundsResult.error) throw roundsResult.error;
    if (picksResult.error) throw picksResult.error;

    const typedMembers = (membersResult.data || []) as Member[];
    const typedRounds = (roundsResult.data || []) as CaseRound[];
    const typedPicks = (picksResult.data || []) as CasePick[];

    setMembers(typedMembers);
    setRounds(typedRounds);
    setPicks(typedPicks);

    const playerIds = Array.from(new Set(typedPicks.map((pick) => pick.player_id)));

    if (playerIds.length) {
      const { data: playerData, error: playerError } = await supabase
        .from("fa_players")
        .select("id,name,club,league,primary_position,secondary_positions,overall,image_url,player_type,metadata")
        .in("id", playerIds);

      if (playerError) throw playerError;
      setPlayers((playerData || []) as Player[]);
    } else {
      setPlayers([]);
    }

    setError("");
  }, [code]);

  const safeLoad = useCallback(async () => {
    try {
      await load();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setLoading(false);
    }
  }, [load]);

  useEffect(() => {
    void safeLoad();
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
    let timer: number | null = null;
    const refreshSoon = () => {
      if (timer !== null) window.clearTimeout(timer);
      timer = window.setTimeout(() => {
        timer = null;
        void safeLoad();
      }, 100);
    };

    const channel = supabase
      .channel(`football-auction:cases:${room.id}`)
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "fa_case_rounds", filter: `room_id=eq.${room.id}` },
        refreshSoon,
      )
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "fa_case_picks", filter: `room_id=eq.${room.id}` },
        refreshSoon,
      )
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "fa_rooms", filter: `id=eq.${room.id}` },
        refreshSoon,
      )
      .subscribe();

    return () => {
      if (timer !== null) window.clearTimeout(timer);
      void supabase.removeChannel(channel);
    };
  }, [room?.id, safeLoad]);

  useEffect(() => {
    if (!room) return;

    if (room.status === "lobby") {
      router.replace(`/sala/${code}/lobby`);
    } else if (room.status === "squads" || room.status === "finished") {
      router.replace(`/sala/${code}/times`);
    }
  }, [room, code, router]);

  const me = members.find((member) => member.user_id === userId) || null;
  const isHost = !!room && room.host_user_id === userId;
  const sequence = useMemo(
    () => (room ? slotsForMode(room.mode, room.reserve_count) : []),
    [room],
  );

  const completedSlots = useMemo(
    () =>
      new Set(
        rounds
          .filter((round) => round.status === "completed")
          .map((round) => round.slot_key),
      ),
    [rounds],
  );

  const remainingSlots = sequence.filter(
    (slot) => !rounds.some((round) => round.slot_key === slot),
  );

  const currentRound =
    [...rounds].reverse().find((round) => round.status === "choosing") || null;

  const latestRound = rounds.length ? rounds[rounds.length - 1] : null;
  const displayRound = currentRound || latestRound;
  const roundPicks = displayRound
    ? picks.filter((pick) => pick.round_id === displayRound.id)
    : [];

  const myCurrentPick =
    currentRound && me
      ? picks.find(
          (pick) =>
            pick.round_id === currentRound.id &&
            pick.member_id === me.id,
        ) || null
      : null;

  const playersById = useMemo(
    () => new Map(players.map((player) => [player.id, player])),
    [players],
  );

  const latestMyPick =
    displayRound && me
      ? [...picks]
          .reverse()
          .find(
            (pick) =>
              pick.round_id === displayRound.id &&
              pick.member_id === me.id,
          ) || null
      : null;

  const latestMyPlayer =
    flashPlayer ||
    (latestMyPick ? playersById.get(latestMyPick.player_id) || null : null);

  const takenCases = new Set(
    currentRound
      ? picks
          .filter((pick) => pick.round_id === currentRound.id)
          .map((pick) => pick.case_no)
      : [],
  );

  const finished =
    sequence.length > 0 &&
    sequence.every((slot) => completedSlots.has(slot));

  async function startRound(slotKey: string) {
    if (!room || !isHost || busy) return;

    setBusy(true);
    setError("");
    setFlashPlayer(null);

    try {
      const { error: rpcError } = await getSupabase().rpc("fa_start_case_round", {
        p_room_id: room.id,
        p_slot_key: slotKey,
      });

      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function chooseCase(caseNo: number) {
    if (!currentRound || !me || me.is_spectator || myCurrentPick || busy) return;

    setBusy(true);
    setError("");

    try {
      const { data, error: rpcError } = await getSupabase().rpc("fa_pick_case", {
        p_round_id: currentRound.id,
        p_case_no: caseNo,
      });

      if (rpcError) throw rpcError;

      const response = data as { player?: Player } | null;
      if (response?.player) setFlashPlayer(response.player);
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  if (loading) {
    return (
      <main className="container case-mode-page">
        <p>Preparando as maletas...</p>
      </main>
    );
  }

  return (
    <main className="case-mode-page">
      <div className="container">
        <ConnectionBanner />

        <div className="topbar">
          <button
            className="btn btn-secondary"
            onClick={() => router.push(`/sala/${code}/lobby`)}
          >
            ← Lobby
          </button>

          <div style={{ display: "flex", gap: 8, flexWrap: "wrap", justifyContent: "flex-end" }}>
            <span className="badge">Sala {code}</span>
            <span className="badge">
              {members.filter((member) => !member.is_spectator).length} jogadores
            </span>
          </div>
        </div>

        <header className="case-hero">
          <span className="case-hero-kicker">▣ MODO MALETAS</span>
          <h1>Escolha às cegas</h1>
          <p className="muted">
            O conteúdo só é revelado depois que a maleta é escolhida.
          </p>
        </header>

        <div className="case-progress">
          {sequence.map((slot) => (
            <span key={slot} className={completedSlots.has(slot) ? "done" : ""}>
              {completedSlots.has(slot) ? "✓ " : ""}
              {labelForSlot(slot)}
            </span>
          ))}
        </div>

        {error && (
          <div className="card" style={{ marginBottom: 16 }}>
            <p className="red" style={{ margin: 0 }}>{error}</p>
          </div>
        )}

        {finished ? (
          <section className="card" style={{ textAlign: "center", maxWidth: 720, margin: "0 auto 18px" }}>
            <span className="special-badge card-type-badge">ELENCO COMPLETO</span>
            <h2>As maletas acabaram.</h2>
            <p className="muted">
              Agora cada pessoa pode organizar titulares e reservas, fazer trocas e finalizar o time.
            </p>
            {!me?.is_spectator && (
              <button
                className="btn btn-primary"
                onClick={() => router.push(`/sala/${code}/elenco`)}
              >
                Organizar minha prancheta
              </button>
            )}
          </section>
        ) : !currentRound ? (
          <section className="card" style={{ marginBottom: 18 }}>
            {isHost ? (
              <>
                <div className="topbar">
                  <div>
                    <span className="case-hero-kicker">PRÓXIMA RODADA</span>
                    <h2 style={{ margin: "5px 0 0" }}>Escolha a posição</h2>
                  </div>
                  <span className="badge">{remainingSlots.length} posições faltando</span>
                </div>

                <div className="case-position-picker">
                  {remainingSlots.map((slot) => (
                    <button
                      key={slot}
                      type="button"
                      className="case-position-button"
                      disabled={busy}
                      onClick={() => void startRound(slot)}
                    >
                      <strong>{labelForSlot(slot)}</strong>
                      <small>Abrir maletas</small>
                    </button>
                  ))}
                </div>
              </>
            ) : (
              <div style={{ textAlign: "center" }}>
                <h2>Aguardando o administrador</h2>
                <p className="muted">Ele vai escolher a posição da próxima rodada.</p>
              </div>
            )}
          </section>
        ) : (
          <section className="card" style={{ marginBottom: 18 }}>
            <div className="topbar">
              <div>
                <span className="case-hero-kicker">RODADA {currentRound.round_no}</span>
                <h2 style={{ margin: "5px 0 0" }}>
                  {labelForSlot(currentRound.slot_key)}
                </h2>
              </div>
              <span className="badge">
                {roundPicks.length}/{members.filter((member) => !member.is_spectator).length} escolheram
              </span>
            </div>

            {me?.is_spectator ? (
              <p className="muted" style={{ textAlign: "center" }}>
                Você está assistindo. As cartas aparecem conforme os jogadores escolhem.
              </p>
            ) : myCurrentPick ? (
              <p className="muted" style={{ textAlign: "center" }}>
                Você já escolheu a maleta {myCurrentPick.case_no}. Aguarde os outros jogadores.
              </p>
            ) : (
              <p className="muted" style={{ textAlign: "center" }}>
                Escolha uma maleta. Depois do clique não dá para trocar.
              </p>
            )}

            <div className="case-grid">
              {Array.from({ length: currentRound.case_count }, (_, index) => {
                const caseNo = index + 1;
                const taken = takenCases.has(caseNo);
                const mine = myCurrentPick?.case_no === caseNo;

                return (
                  <button
                    type="button"
                    key={caseNo}
                    className={`case-box ${taken ? "taken" : ""} ${mine ? "mine" : ""}`}
                    disabled={
                      busy ||
                      taken ||
                      !!myCurrentPick ||
                      !!me?.is_spectator
                    }
                    onClick={() => void chooseCase(caseNo)}
                  >
                    <span>
                      <span className="case-number">{caseNo}</span>
                      <small>{taken ? "ESCOLHIDA" : "MALETA"}</small>
                    </span>
                  </button>
                );
              })}
            </div>
          </section>
        )}

        {latestMyPlayer && latestMyPick && (
          <section className={`card case-reveal-card ${cardClass(latestMyPlayer)}`}>
            <span className="case-hero-kicker">SUA MALETA {latestMyPick.case_no}</span>
            <div className="case-reveal-face">
              <PlayerFace
                name={latestMyPlayer.name}
                imageUrl={latestMyPlayer.image_url}
                size={100}
              />
            </div>
            <CardBadge player={latestMyPlayer} />
            <h2>{latestMyPlayer.name}</h2>
            <div className="auction-ger">{latestMyPlayer.overall}</div>
            <p className="muted">
              {latestMyPlayer.primary_position}
              {latestMyPlayer.club ? ` • ${latestMyPlayer.club}` : ""}
              {latestMyPlayer.league ? ` • ${latestMyPlayer.league}` : ""}
            </p>
          </section>
        )}

        {displayRound && roundPicks.length > 0 && (
          <section className="card" style={{ marginBottom: 18 }}>
            <div className="topbar">
              <div>
                <h2 style={{ margin: 0 }}>Revelações da rodada</h2>
                <p className="muted" style={{ margin: "4px 0 0" }}>
                  {labelForSlot(displayRound.slot_key)}
                </p>
              </div>
            </div>

            <div className="case-picks-grid">
              {roundPicks.map((pick) => {
                const member = members.find((item) => item.id === pick.member_id);
                const player = playersById.get(pick.player_id);

                return (
                  <div className="case-pick-row" key={pick.id}>
                    {player && (
                      <PlayerFace
                        name={player.name}
                        imageUrl={player.image_url}
                        size={46}
                      />
                    )}
                    <div>
                      <span className="muted">
                        {member?.display_name || "Jogador"} • Maleta {pick.case_no}
                      </span>
                      <strong>{player?.name || "Revelando..."}</strong>
                      {player && (
                        <span className="red">
                          {player.primary_position} • {player.overall} GER
                        </span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </section>
        )}

        {room && <RoomChat roomId={room.id} />}
      </div>
    </main>
  );
}
