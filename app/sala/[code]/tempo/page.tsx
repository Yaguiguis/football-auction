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
  room_kind: string;
  status: string;
};

type TimeMember = {
  member_id: string;
  name: string;
  is_admin: boolean;
  is_spectator: boolean;
  eliminated: boolean;
  alive: boolean;
};

type TimeResult = {
  member_id: string;
  name: string;
  elapsed_ms: number | null;
  stopped: boolean;
};

type Decision = {
  round: number;
  vote: number;
  continue: number;
  tie: boolean;
  result: "vote" | "continue";
};

type LastElimination = {
  round: number;
  member_id: string | null;
  was_impostor: boolean;
  reason?: string;
  votes?: Array<{
    voter_member_id: string;
    target_member_id: string;
  }>;
};

type TimeState = {
  room_status: string;
  has_game: boolean;
  game_id?: string;
  status?: "playing" | "finished";
  phase?:
    | "admin_setup"
    | "timing"
    | "reveal"
    | "decision"
    | "elimination"
    | "runoff"
    | "finished";
  round_no?: number;
  role: "admin" | "spectator" | "player" | "innocent" | "impostor" | "eliminated";
  is_admin?: boolean;
  me_member_id?: string;
  winner_side?: "innocents" | "impostor" | null;
  impostor?: { member_id: string; name: string } | null;
  target_seconds?: number | null;
  active_round_id?: string | null;
  timer_state?: "ready" | "running" | "stopped" | null;
  results?: TimeResult[];
  my_decision_vote?: "vote" | "continue" | null;
  my_elimination_vote?: string | null;
  last_decision?: Decision | null;
  last_elimination?: LastElimination | null;
  runoff_candidates?: string[];
  members?: TimeMember[];
};

function formatSeconds(value: number) {
  return value.toLocaleString("pt-BR", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 3,
  });
}

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    return String((error as { message?: unknown }).message || "Erro inesperado.");
  }
  return "Não foi possível atualizar a partida.";
}

export default function TimeImpostorPage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [state, setState] = useState<TimeState | null>(null);
  const [targetInput, setTargetInput] = useState("20,22");
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    await ensureAnonymousSession();
    const supabase = getSupabase();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,room_kind,status")
      .eq("code", code)
      .maybeSingle();

    if (roomError) throw roomError;
    if (!roomData) throw new Error("Sala não encontrada.");

    const typedRoom = roomData as Room;
    if (typedRoom.room_kind !== "time_impostor") {
      throw new Error("Esta sala não é do Impostor do Tempo.");
    }

    const { data: stateData, error: stateError } = await supabase.rpc(
      "fa_time_impostor_state",
      { p_room_id: typedRoom.id },
    );

    if (stateError) throw stateError;

    setRoom(typedRoom);
    const nextState = stateData as TimeState;
    setState({ ...nextState, role: nextState.is_admin ? "admin" : nextState.role });
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
    const timer = window.setInterval(() => void safeLoad(), 900);
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
    if (!room || !state) return;
    if (room.status === "lobby" || !state.has_game) {
      router.replace(`/sala/${code}/lobby`);
    }
  }, [room, state, router, code]);

  const members = state?.members || [];
  const alivePlayers = members.filter((member) => member.alive);
  const me = members.find((member) => member.member_id === state?.me_member_id) || null;
  const isActivePlayer =
    state?.role === "innocent" || state?.role === "impostor";

  const previousEliminatedName = useMemo(() => {
    const id = state?.last_elimination?.member_id;
    return id ? members.find((member) => member.member_id === id)?.name || "Jogador" : null;
  }, [members, state?.last_elimination]);

  async function runAction(action: () => Promise<void>) {
    if (busy) return;
    setBusy(true);
    setError("");

    try {
      await action();
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function startRound() {
    if (!state?.game_id) return;

    const parsed = Number(targetInput.trim().replace(",", "."));
    if (!Number.isFinite(parsed) || parsed < 1 || parsed > 300) {
      setError("Digite um tempo entre 1 e 300 segundos. Ex.: 20,22");
      return;
    }

    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_start_round",
        {
          p_game_id: state.game_id,
          p_target_seconds: parsed,
        },
      );
      if (rpcError) throw rpcError;
    });
  }

  async function startTimer() {
    if (!state?.active_round_id) return;
    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_start_timer",
        { p_round_id: state.active_round_id },
      );
      if (rpcError) throw rpcError;
    });
  }

  async function stopTimer() {
    if (!state?.active_round_id) return;
    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_stop_timer",
        { p_round_id: state.active_round_id },
      );
      if (rpcError) throw rpcError;
    });
  }

  async function openDecision() {
    if (!state?.game_id) return;
    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_open_decision",
        { p_game_id: state.game_id },
      );
      if (rpcError) throw rpcError;
    });
  }

  async function decide(choice: "vote" | "continue") {
    if (!state?.game_id) return;
    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_decide_round",
        {
          p_game_id: state.game_id,
          p_choice: choice,
        },
      );
      if (rpcError) throw rpcError;
    });
  }

  async function voteElimination(memberId: string) {
    if (!state?.game_id) return;
    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_vote_elimination",
        {
          p_game_id: state.game_id,
          p_target_member_id: memberId,
        },
      );
      if (rpcError) throw rpcError;
    });
  }

  async function replay() {
    if (!room) return;
    await runAction(async () => {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_time_impostor_replay",
        { p_room_id: room.id },
      );
      if (rpcError) throw rpcError;
      router.push(`/sala/${code}/lobby`);
    });
  }

  if (loading) {
    return (
      <main className="time-impostor-page">
        <div className="container">
          <p>Preparando o cronômetro secreto...</p>
        </div>
      </main>
    );
  }

  if (!room || !state) {
    return (
      <main className="container">
        <p className="red">{error || "Sala indisponível."}</p>
      </main>
    );
  }

  const roleCard = (() => {
    if (state.role === "admin") {
      return {
        label: "ADMINISTRADOR",
        title: "Você controla a rodada",
        text: "Você não joga e nunca entra no sorteio do impostor.",
        icon: "👑",
        className: "admin",
      };
    }

    if (state.role === "impostor") {
      return {
        label: "SEU PAPEL",
        title: "VOCÊ É O IMPOSTOR",
        text: "O tempo-alvo está escondido. Observe os outros e tente se misturar.",
        icon: "🕵️",
        className: "impostor",
      };
    }

    if (state.role === "innocent") {
      return {
        label: "SEU PAPEL",
        title: "VOCÊ É INOCENTE",
        text:
          state.target_seconds != null
            ? `O alvo desta rodada é ${formatSeconds(Number(state.target_seconds))} segundos.`
            : "Aguarde o administrador escolher o tempo da rodada.",
        icon: "✓",
        className: "innocent",
      };
    }

    if (state.role === "eliminated") {
      return {
        label: "FORA DA RODADA",
        title: "Você foi eliminado",
        text: "Agora você acompanha sem iniciar cronômetro nem votar.",
        icon: "◌",
        className: "eliminated",
      };
    }

    return {
      label: "ESPECTADOR",
      title: "Você está assistindo",
      text: "Acompanhe a rodada sem interferir nas decisões.",
      icon: "👀",
      className: "spectator",
    };
  })();

  const votingCandidates = alivePlayers.filter((member) => {
    if (member.member_id === state.me_member_id) return false;
    if (
      state.phase === "runoff" &&
      !(state.runoff_candidates || []).includes(member.member_id)
    ) {
      return false;
    }
    return true;
  });

  return (
    <main className="time-impostor-page">
      <div className="container">
        <ConnectionBanner />

        <div className="topbar">
          <button
            className="btn btn-secondary"
            type="button"
            onClick={() => router.push(`/sala/${code}/lobby`)}
          >
            ← Lobby
          </button>

          <div className="time-impostor-topbadges">
            <span className="badge">⏱ Rodada {state.round_no || 1}</span>
            <span className="badge">{alivePlayers.length} vivos</span>
            <span className="badge">Sala {code}</span>
          </div>
        </div>

        <header className="time-impostor-hero">
          <span>IMPOSTOR DO TEMPO</span>
          <h1>Não olhe para o relógio.</h1>
          <p>
            Pare quando achar que chegou a hora certa — ou engane quem não sabe o alvo.
          </p>
        </header>

        {error && (
          <div className="card" style={{ marginBottom: 16 }}>
            <p className="red" style={{ margin: 0 }}>{error}</p>
          </div>
        )}

        <section className={`time-role-card ${roleCard.className}`}>
          <span className="time-role-icon">{roleCard.icon}</span>
          <div>
            <small>{roleCard.label}</small>
            <h2>{roleCard.title}</h2>
            <p>{roleCard.text}</p>
          </div>

          {state.role === "innocent" && state.target_seconds != null && (
            <strong className="time-target-number">
              {formatSeconds(Number(state.target_seconds))}<small>s</small>
            </strong>
          )}
        </section>

        {state.last_decision && state.phase === "admin_setup" && (
          <section className="time-round-result-banner">
            <strong>
              {state.last_decision.tie
                ? "Empate: a investigação continua."
                : state.last_decision.result === "continue"
                  ? "A maioria escolheu continuar."
                  : "A maioria escolheu votar."}
            </strong>
            <span>
              {state.last_decision.vote} votar • {state.last_decision.continue} continuar
            </span>
          </section>
        )}

        {state.last_elimination && state.phase === "admin_setup" && (
          <section className="time-round-result-banner danger">
            <strong>
              {state.last_elimination.member_id
                ? `${previousEliminatedName} foi eliminado.`
                : "O desempate terminou sem eliminação."}
            </strong>
            {state.last_elimination.member_id && (
              <span>
                {state.last_elimination.was_impostor
                  ? "Era o impostor."
                  : "Era inocente. O impostor continua entre vocês."}
              </span>
            )}
          </section>
        )}

        {state.phase === "admin_setup" && (
          <section className="card time-admin-setup-card">
            {state.role === "admin" ? (
              <>
                <span className="time-section-kicker">NOVO ALVO</span>
                <h2>Qual tempo os jogadores devem buscar?</h2>
                <p className="muted">
                  Pode usar vírgula. Exemplo: <strong>20,22</strong> significa 20,22 segundos.
                </p>

                <div className="time-target-input-wrap">
                  <input
                    className="input time-target-input"
                    inputMode="decimal"
                    value={targetInput}
                    onChange={(event) =>
                      setTargetInput(
                        event.target.value
                          .replace(/[^0-9,.]/g, "")
                          .slice(0, 7),
                      )
                    }
                    placeholder="20,22"
                  />
                  <span>segundos</span>
                </div>

                <button
                  className="btn btn-primary time-main-action"
                  type="button"
                  disabled={busy}
                  onClick={() => void startRound()}
                >
                  {busy ? "Preparando..." : "Começar rodada com este tempo"}
                </button>
              </>
            ) : (
              <div className="time-waiting-block">
                <span className="time-waiting-spinner" />
                <h2>O administrador está escolhendo o tempo...</h2>
                <p className="muted">
                  Quando ele iniciar, somente os inocentes verão o alvo.
                </p>
              </div>
            )}
          </section>
        )}

        {state.phase === "timing" && (
          <section className="card time-timer-stage">
            {isActivePlayer ? (
              <>
                {state.timer_state === "ready" && (
                  <>
                    <span className="time-section-kicker">SEU CRONÔMETRO</span>
                    <h2>Quando estiver pronto, inicie.</h2>
                    <p className="muted">
                      Depois do clique os números desaparecem. Você só decide quando parar.
                    </p>
                    <button
                      className="time-start-button"
                      type="button"
                      disabled={busy}
                      onClick={() => void startTimer()}
                    >
                      <span>▶</span>
                      INICIAR
                    </button>
                  </>
                )}

                {state.timer_state === "running" && (
                  <>
                    <span className="time-section-kicker live">CRONÔMETRO RODANDO</span>
                    <div className="time-hidden-clock" aria-label="Cronômetro oculto">
                      <span className="time-hidden-pulse" />
                      <strong>••:••.••</strong>
                      <small>O tempo está escondido</small>
                    </div>

                    <button
                      className="time-stop-button"
                      type="button"
                      disabled={busy}
                      onClick={() => void stopTimer()}
                    >
                      <span>■</span>
                      PARAR AGORA
                    </button>
                  </>
                )}

                {state.timer_state === "stopped" && (
                  <div className="time-waiting-block">
                    <span className="time-finished-check">✓</span>
                    <h2>Seu tempo foi registrado.</h2>
                    <p className="muted">
                      Ele continua escondido até todos terminarem.
                    </p>
                  </div>
                )}
              </>
            ) : (
              <div className="time-waiting-block">
                <span className="time-waiting-spinner" />
                <h2>Os cronômetros estão rodando.</h2>
                <p className="muted">
                  {state.role === "admin"
                    ? "Você acompanha a rodada sem participar."
                    : "Aguarde os jogadores terminarem."}
                </p>
              </div>
            )}
          </section>
        )}

        {state.phase === "reveal" && (
          <section className="card time-reveal-card">
            <div className="topbar">
              <div>
                <span className="time-section-kicker">TEMPOS REVELADOS</span>
                <h2 style={{ margin: "5px 0 0" }}>Quem parece estar fingindo?</h2>
              </div>

              {state.target_seconds != null && (
                <span className="time-target-chip">
                  Alvo: {formatSeconds(Number(state.target_seconds))}s
                </span>
              )}
            </div>

            <div className="time-results-grid">
              {(state.results || []).map((result, index) => {
                const seconds = (result.elapsed_ms || 0) / 1000;
                const canSeeTarget = state.target_seconds != null;
                const difference = canSeeTarget
                  ? seconds - Number(state.target_seconds)
                  : null;

                return (
                  <div className="time-result-row" key={result.member_id}>
                    <span className="time-result-place">#{index + 1}</span>
                    <div>
                      <strong>{result.name}</strong>
                      {difference != null && (
                        <small>
                          {difference === 0
                            ? "exato"
                            : `${difference > 0 ? "+" : ""}${formatSeconds(difference)}s do alvo`}
                        </small>
                      )}
                    </div>
                    <b>{formatSeconds(seconds)}s</b>
                  </div>
                );
              })}
            </div>

            {state.role === "impostor" && (
              <p className="time-impostor-note">
                🕵️ O alvo continua escondido de você. Use os tempos dos outros para tentar deduzir.
              </p>
            )}

            {state.role === "admin" ? (
              <button
                className="btn btn-primary time-main-action"
                type="button"
                disabled={busy}
                onClick={() => void openDecision()}
              >
                Abrir decisão da rodada
              </button>
            ) : (
              <p className="muted" style={{ textAlign: "center" }}>
                Aguarde o administrador abrir a decisão.
              </p>
            )}
          </section>
        )}

        {state.phase === "decision" && (
          <section className="card time-decision-card">
            <span className="time-section-kicker">DECISÃO DA RODADA</span>
            <h2>Querem votar no impostor ou tentar outro tempo?</h2>
            <p className="muted">
              A maioria vence. Em caso de empate, uma nova rodada começa.
            </p>

            {isActivePlayer ? (
              state.my_decision_vote ? (
                <div className="time-choice-sent">
                  <strong>Seu voto foi enviado.</strong>
                  <span>
                    Você escolheu{" "}
                    {state.my_decision_vote === "vote" ? "VOTAR" : "CONTINUAR"}.
                    Aguarde os outros.
                  </span>
                </div>
              ) : (
                <div className="time-decision-grid">
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() => void decide("continue")}
                  >
                    <span>↻</span>
                    <strong>CONTINUAR</strong>
                    <small>Administrador escolhe um novo tempo.</small>
                  </button>
                  <button
                    type="button"
                    className="danger"
                    disabled={busy}
                    onClick={() => void decide("vote")}
                  >
                    <span>🕵️</span>
                    <strong>VOTAR</strong>
                    <small>Tentar eliminar o impostor agora.</small>
                  </button>
                </div>
              )
            ) : (
              <p className="muted" style={{ textAlign: "center" }}>
                Os jogadores vivos estão decidindo.
              </p>
            )}
          </section>
        )}

        {(state.phase === "elimination" || state.phase === "runoff") && (
          <section className="card time-vote-card">
            <span className="time-section-kicker">
              {state.phase === "runoff" ? "DESEMPATE" : "VOTAÇÃO"}
            </span>
            <h2>Quem é o impostor?</h2>
            <p className="muted">
              Os votos ficam escondidos até todos os jogadores vivos terminarem.
            </p>

            {isActivePlayer ? (
              state.my_elimination_vote ? (
                <div className="time-choice-sent">
                  <strong>Voto registrado.</strong>
                  <span>Aguarde o restante do grupo.</span>
                </div>
              ) : (
                <div className="time-vote-grid">
                  {votingCandidates.map((member) => (
                    <button
                      type="button"
                      key={member.member_id}
                      disabled={busy}
                      onClick={() => void voteElimination(member.member_id)}
                    >
                      <span className="time-vote-avatar">
                        {member.name.slice(0, 1).toUpperCase()}
                      </span>
                      <strong>{member.name}</strong>
                      <small>Votar nesta pessoa</small>
                    </button>
                  ))}
                </div>
              )
            ) : (
              <p className="muted" style={{ textAlign: "center" }}>
                Você está assistindo à votação.
              </p>
            )}
          </section>
        )}

        {state.phase === "finished" && (
          <section className={`card time-finish-card ${state.winner_side || ""}`}>
            <span className="time-finish-icon">
              {state.winner_side === "innocents" ? "✓" : "🕵️"}
            </span>
            <span className="time-section-kicker">FIM DE JOGO</span>
            <h2>
              {state.winner_side === "innocents"
                ? "Os inocentes venceram!"
                : "O impostor venceu!"}
            </h2>

            {state.impostor && (
              <p>
                O impostor era <strong>{state.impostor.name}</strong>.
              </p>
            )}

            {state.role === "admin" ? (
              <button
                className="btn btn-primary time-main-action"
                type="button"
                disabled={busy}
                onClick={() => void replay()}
              >
                Jogar novamente com a mesma sala
              </button>
            ) : (
              <button
                className="btn btn-secondary"
                type="button"
                onClick={() => router.push(`/sala/${code}/lobby`)}
              >
                Voltar ao lobby
              </button>
            )}
          </section>
        )}

        <section className="card time-players-card">
          <div className="topbar">
            <div>
              <h2 style={{ margin: 0 }}>Participantes</h2>
              <p className="muted" style={{ margin: "4px 0 0" }}>
                O administrador nunca aparece como jogador.
              </p>
            </div>
          </div>

          <div className="time-player-list">
            {members.map((member) => (
              <div
                key={member.member_id}
                className={`time-player-pill ${member.eliminated ? "eliminated" : ""}`}
              >
                <span>{member.name.slice(0, 1).toUpperCase()}</span>
                <div>
                  <strong>{member.name}</strong>
                  <small>
                    {member.is_admin
                      ? "Administrador"
                      : member.is_spectator
                        ? "Espectador"
                        : member.eliminated
                          ? "Eliminado"
                          : "Jogando"}
                  </small>
                </div>
                {member.is_admin && <b>👑</b>}
              </div>
            ))}
          </div>
        </section>

        <RoomChat roomId={room.id} />
      </div>
    </main>
  );
}
