"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { getSupabase } from "../lib/supabase";
import type { MatchResult, TeamSnapshot } from "../lib/match-simulator";

type Member = {
  id: string;
  display_name: string;
  squad_finalized: boolean;
  is_spectator: boolean;
};

type MatchStatus = "pending" | "declined" | "shootout" | "completed" | "cancelled";

type Match = {
  id: string;
  challenger_id: string;
  opponent_id: string;
  status: MatchStatus;
  result: MatchResult | null;
  team_a: TeamSnapshot | null;
  team_b: TeamSnapshot | null;
  created_at: string;
  responded_at: string | null;
  completed_at: string | null;
};

type PenaltySetup = {
  status: "selecting" | "started";
  a_ready: boolean;
  b_ready: boolean;
  both_ready: boolean;
  can_start: boolean;
  my_order: string[];
};

const directions = [
  { key: "left", label: "Esquerda" },
  { key: "center", label: "Meio" },
  { key: "right", label: "Direita" },
];

function winnerName(match: Match, winner: string | null) {
  if (!winner) return "Empate";
  return winner === match.team_a?.id ? match.team_a?.name : match.team_b?.name;
}

function MatchPlayback({ match }: { match: Match }) {
  const [minute, setMinute] = useState(0);
  const [skipped, setSkipped] = useState(false);

  useEffect(() => {
    const maxMinute = match.result?.extra_time ? 120 : 90;

    if (skipped || window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      setMinute(maxMinute);
      return;
    }

    const started = new Date(match.responded_at || match.created_at).getTime();
    const elapsed = () =>
      Math.min(maxMinute, Math.max(0, Math.floor((Date.now() - started) / 150)));

    setMinute(elapsed());

    if (elapsed() >= maxMinute) return;

    const timer = window.setInterval(() => {
      const next = elapsed();
      setMinute(next);
      if (next >= maxMinute) window.clearInterval(timer);
    }, 150);

    return () => window.clearInterval(timer);
  }, [match.responded_at, match.created_at, match.result?.extra_time, skipped]);

  const result = match.result!;
  const events = result.events.filter((event) => event.minute <= minute);
  const score = (side: "a" | "b") =>
    events.filter((event) => event.kind === "goal" && event.team === side).length;
  const maxMinute = result.extra_time ? 120 : 90;

  const finalText =
    result.decided_by === "extra_time"
      ? "120′ • Fim da prorrogação"
      : result.decided_by === "penalties"
        ? "120′ • Decidido nos pênaltis"
        : "90′ • Fim de jogo";

  return (
    <div className="x1-playback">
      <div className="x1-score" aria-label="Placar">
        <span>{match.team_a?.name}</span>
        <strong>{score("a")} : {score("b")}</strong>
        <span>{match.team_b?.name}</span>
      </div>

      <p className="muted">
        {minute < maxMinute ? `${minute}′ • Partida em andamento` : finalText}
      </p>

      <progress value={minute} max={maxMinute} aria-label="Tempo de partida" />

      {minute < maxMinute && (
        <button className="btn btn-secondary" onClick={() => setSkipped(true)}>
          Ver resultado
        </button>
      )}

      <ol className="x1-events">
        {events.map((event, index) => (
          <li key={index}>
            <b>{event.minute}′</b> {event.kind === "goal" ? "Gol" : "Defesa"} — {event.player}{" "}
            <small>({event.team === "a" ? match.team_a?.name : match.team_b?.name})</small>
          </li>
        ))}
      </ol>

      {minute === maxMinute && result.penalties && (
        <p className="muted">
          Pênaltis: {result.penalties.a} × {result.penalties.b}
        </p>
      )}

      {minute === maxMinute && (
        <p>
          <strong>Vitória de {winnerName(match, result.winner)}</strong>
        </p>
      )}

      <details>
        <summary>Dados da partida</summary>
        <p>
          Força: {result.strength.a.overall.toFixed(1)} × {result.strength.b.overall.toFixed(1)}
          {" • "}
          Gols esperados: {result.xg.a.toFixed(2)} × {result.xg.b.toFixed(2)}
        </p>
        <small>Motor {result.version} • Seed {result.seed}</small>
      </details>
    </div>
  );
}

function CompletedMatch({ match }: { match: Match }) {
  const finalKick = match.result?.penalty_shootout?.kicks.at(-1) || null;
  const completedRecently =
    !!match.completed_at &&
    Date.now() - new Date(match.completed_at).getTime() < 6000;
  const [showFinalKick, setShowFinalKick] = useState(
    completedRecently && !!finalKick && match.result?.decided_by === "penalties",
  );

  if (showFinalKick && finalKick && match.result?.penalty_shootout) {
    const shootout = match.result.penalty_shootout;

    return (
      <div className="x1-shootout">
        <div className="x1-score">
          <span>{match.team_a?.name}</span>
          <strong>
            {shootout.score.a - (finalKick.team === "a" && finalKick.goal ? 1 : 0)}
            {" : "}
            {shootout.score.b - (finalKick.team === "b" && finalKick.goal ? 1 : 0)}
          </strong>
          <span>{match.team_b?.name}</span>
        </div>

        <PenaltyKickAnimation
          shot={finalKick.shot}
          keeper={finalKick.keeper}
          goal={finalKick.goal}
          player={finalKick.player}
          onDone={() => setShowFinalKick(false)}
        />
      </div>
    );
  }

  return <MatchPlayback match={match} />;
}

function PenaltySetupPanel({
  match,
  me,
  setup,
  busy,
  onConfirm,
  onStart,
}: {
  match: Match;
  me: Member | null;
  setup: PenaltySetup | null;
  busy: boolean;
  onConfirm: (matchId: string, order: string[]) => void;
  onStart: (matchId: string) => void;
}) {
  const isA = me?.id === match.challenger_id;
  const isB = me?.id === match.opponent_id;
  const isPlayer = isA || isB;
  const team = isA ? match.team_a : isB ? match.team_b : null;

  const defaultOrder = useMemo(() => {
    if (!team) return [];

    return [...team.players]
      .sort((a, b) => {
        const aGoalkeeper = a.slot === "GOL" ? 1 : 0;
        const bGoalkeeper = b.slot === "GOL" ? 1 : 0;
        return aGoalkeeper - bGoalkeeper || a.penalty - b.penalty || b.overall - a.overall;
      })
      .slice(0, 5)
      .map((player) => player.id);
  }, [team]);

  const [order, setOrder] = useState<string[]>([]);

  useEffect(() => {
    if (setup?.my_order?.length === 5) {
      setOrder(setup.my_order);
    } else if (defaultOrder.length === 5) {
      setOrder(defaultOrder);
    }
  }, [match.id, setup?.my_order, defaultOrder]);

  if (!setup || setup.status === "started") return null;

  const myReady = isA ? setup.a_ready : isB ? setup.b_ready : false;
  const unique = new Set(order).size === 5;
  const complete = order.length === 5 && unique;

  function move(index: number, direction: -1 | 1) {
    const target = index + direction;
    if (target < 0 || target >= order.length) return;

    setOrder((current) => {
      const next = [...current];
      [next[index], next[target]] = [next[target], next[index]];
      return next;
    });
  }

  function replace(index: number, playerId: string) {
    setOrder((current) => {
      const next = [...current];
      const existing = next.indexOf(playerId);

      if (existing >= 0 && existing !== index) {
        [next[index], next[existing]] = [next[existing], next[index]];
      } else {
        next[index] = playerId;
      }

      return next;
    });
  }

  return (
    <div className="x1-shootout">
      <h3>Escolha a ordem dos cobradores</h3>

      <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
        <span className="badge">
          {match.team_a?.name}: {setup.a_ready ? "✓ ordem confirmada" : "escolhendo"}
        </span>
        <span className="badge">
          {match.team_b?.name}: {setup.b_ready ? "✓ ordem confirmada" : "escolhendo"}
        </span>
      </div>

      {!isPlayer ? (
        <p className="muted">Os dois jogadores estão escolhendo seus cobradores.</p>
      ) : (
        <>
          <p className="muted">
            Escolha 5 jogadores e coloque do 1º ao 5º cobrador. Em morte súbita, a ordem recomeça.
          </p>

          <div className="grid" style={{ gap: 8 }}>
            {order.map((playerId, index) => (
              <div
                key={index}
                className="card"
                style={{
                  padding: 10,
                  display: "grid",
                  gridTemplateColumns: "36px minmax(0,1fr) auto auto",
                  alignItems: "center",
                  gap: 8,
                }}
              >
                <strong className="red">{index + 1}º</strong>

                <select
                  className="input"
                  value={playerId}
                  disabled={busy}
                  onChange={(event) => replace(index, event.target.value)}
                >
                  {(team?.players || []).map((player) => (
                    <option key={player.id} value={player.id}>
                      {player.name} • {player.overall} GER
                    </option>
                  ))}
                </select>

                <button
                  type="button"
                  className="btn btn-secondary"
                  disabled={busy || index === 0}
                  onClick={() => move(index, -1)}
                  aria-label="Subir cobrador"
                >
                  ↑
                </button>

                <button
                  type="button"
                  className="btn btn-secondary"
                  disabled={busy || index === order.length - 1}
                  onClick={() => move(index, 1)}
                  aria-label="Descer cobrador"
                >
                  ↓
                </button>
              </div>
            ))}
          </div>

          <button
            className="btn btn-primary"
            style={{ width: "100%", marginTop: 12 }}
            disabled={busy || !complete}
            onClick={() => onConfirm(match.id, order)}
          >
            {myReady ? "Atualizar ordem confirmada" : "Confirmar ordem dos 5 cobradores"}
          </button>
        </>
      )}

      {setup.both_ready ? (
        isPlayer ? (
          <div className="card" style={{ marginTop: 14, textAlign: "center" }}>
            <strong>✓ As duas ordens estão prontas</strong>
            <p className="muted">Agora as cobranças podem começar.</p>
            <button
              className="btn btn-primary"
              disabled={busy}
              onClick={() => onStart(match.id)}
            >
              Iniciar cobranças
            </button>
          </div>
        ) : (
          <p className="muted">As duas ordens estão prontas. Aguardando o início das cobranças.</p>
        )
      ) : (
        <p className="muted" style={{ marginBottom: 0 }}>
          Aguardando os dois lados confirmarem a ordem.
        </p>
      )}
    </div>
  );
}

function PenaltyKickAnimation({
  shot,
  keeper,
  goal,
  player,
  onDone,
}: {
  shot: string;
  keeper: string;
  goal: boolean;
  player?: string | null;
  onDone: () => void;
}) {
  const [phase, setPhase] = useState<"ready" | "moving" | "result">("ready");

  useEffect(() => {
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const startTimer = window.setTimeout(() => setPhase("moving"), reducedMotion ? 20 : 90);
    const resultTimer = window.setTimeout(
      () => setPhase("result"),
      reducedMotion ? 80 : 760,
    );
    const doneTimer = window.setTimeout(
      onDone,
      reducedMotion ? 220 : 1350,
    );

    return () => {
      window.clearTimeout(startTimer);
      window.clearTimeout(resultTimer);
      window.clearTimeout(doneTimer);
    };
  }, [onDone, shot, keeper]);

  return (
    <div className="penalty-animation" aria-live="polite">
      <div className="penalty-animation-heading">
        <strong>{player || "Cobrador"}</strong>
        <span>{phase === "result" ? (goal ? "GOL!" : "DEFESA!") : "Bola rolando..."}</span>
      </div>

      <div
        className="penalty-goal-scene"
        data-phase={phase}
        data-shot={shot}
        data-keeper={keeper}
      >
        <div className="penalty-net">
          <span className="penalty-post penalty-post-left" />
          <span className="penalty-post penalty-post-right" />
          <span className="penalty-crossbar" />
          <span className="penalty-net-lines" />
        </div>

        <div className="penalty-keeper" aria-label={`Goleiro foi para ${keeper}`}>
          <span className="penalty-keeper-head" />
          <span className="penalty-keeper-body" />
          <span className="penalty-keeper-arm penalty-keeper-arm-left" />
          <span className="penalty-keeper-arm penalty-keeper-arm-right" />
        </div>

        <div className="penalty-ball" aria-label={`Bola foi para ${shot}`}>
          ⚽
        </div>

        {phase === "result" && (
          <div className={`penalty-result ${goal ? "goal" : "save"}`}>
            {goal ? "GOL!" : "DEFESA!"}
          </div>
        )}
      </div>
    </div>
  );
}

function ShootoutPanel({
  match,
  me,
  busy,
  onChoose,
}: {
  match: Match;
  me: Member | null;
  busy: boolean;
  onChoose: (matchId: string, direction: string) => void;
}) {
  const shootout = match.result?.penalty_shootout;
  const next = shootout?.next;
  const kickCount = shootout?.kicks.length || 0;
  const previousKickCount = useRef(kickCount);
  const [animatedKick, setAnimatedKick] = useState<
    NonNullable<typeof shootout>["kicks"][number] | null
  >(null);

  useEffect(() => {
    if (!shootout) return;

    if (shootout.kicks.length > previousKickCount.current) {
      const newestKick = shootout.kicks[shootout.kicks.length - 1];
      setAnimatedKick(newestKick || null);
    }

    previousKickCount.current = shootout.kicks.length;
  }, [shootout, kickCount]);

  const finishAnimation = useCallback(() => {
    setAnimatedKick(null);
  }, []);

  if (!shootout || shootout.status === "setup") return null;

  const shooterId = next.team === "a" ? match.challenger_id : match.opponent_id;
  const keeperId = next.team === "a" ? match.opponent_id : match.challenger_id;
  const isShooter = me?.id === shooterId;
  const isKeeper = me?.id === keeperId;

  const team = next.team === "a" ? match.team_a : match.team_b;
  const order = next.team === "a" ? shootout.setup?.order_a : shootout.setup?.order_b;
  const sideKick =
    next.team === "a"
      ? Math.floor((next.index + 1) / 2)
      : Math.floor(next.index / 2);
  const kickerId = order?.[(Math.max(1, sideKick) - 1) % 5];
  const kickerName = team?.players.find((player) => player.id === kickerId)?.name;
  const actorLabel = team?.name;

  return (
    <div className="x1-shootout">
      <div className="x1-score">
        <span>{match.team_a?.name}</span>
        <strong>
          {shootout.score.a - (animatedKick?.team === "a" && animatedKick.goal ? 1 : 0)}
          {" : "}
          {shootout.score.b - (animatedKick?.team === "b" && animatedKick.goal ? 1 : 0)}
        </strong>
        <span>{match.team_b?.name}</span>
      </div>

      {animatedKick ? (
        <PenaltyKickAnimation
          key={animatedKick.index}
          shot={animatedKick.shot}
          keeper={animatedKick.keeper}
          goal={animatedKick.goal}
          player={animatedKick.player}
          onDone={finishAnimation}
        />
      ) : next ? (
        <>
          <p className="muted">
            Pênaltis {next.suddenDeath ? "• morte súbita" : "• 5 cobranças"}
          </p>

          <strong>
            {kickerName ? `${kickerName} vai bater agora.` : `${actorLabel} vai bater agora.`}
          </strong>
        </>
      ) : null}

      {!animatedKick && next && (isShooter || isKeeper) ? (
        <>
          <p className="muted">
            {isShooter ? "Escolha onde bater." : "Escolha para onde o goleiro vai pular."}
          </p>

          <div className="x1-directions">
            {directions.map((direction) => (
              <button
                key={direction.key}
                className="btn btn-secondary"
                disabled={busy}
                onClick={() => onChoose(match.id, direction.key)}
              >
                {direction.label}
              </button>
            ))}
          </div>
        </>
      ) : !animatedKick && next ? (
        <p className="muted">Aguardando atacante e goleiro escolherem as direções.</p>
      ) : null}

      {shootout.kicks.length > 0 && (
        <ol className="x1-events">
          {shootout.kicks
            .filter((kick) => !animatedKick || kick.index !== animatedKick.index)
            .map((kick) => (
            <li key={kick.index}>
              <b>{kick.index}ª</b>{" "}
              {kick.player ? `${kick.player} — ` : ""}
              {kick.team === "a" ? match.team_a?.name : match.team_b?.name}:{" "}
              {kick.goal ? "Gol" : "Defesa"}
            </li>
          ))}
        </ol>
      )}
    </div>
  );
}

export default function X1Arena({
  roomId,
  members,
  me,
}: {
  roomId: string;
  members: Member[];
  me: Member | null;
}) {
  const [matches, setMatches] = useState<Match[]>([]);
  const [setups, setSetups] = useState<Record<string, PenaltySetup>>({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    const supabase = getSupabase();

    const { data, error: matchesError } = await supabase
      .from("fa_x1_matches")
      .select("*")
      .eq("room_id", roomId)
      .order("created_at", { ascending: false })
      .limit(100);

    if (matchesError) throw matchesError;

    const typedMatches = (data || []) as Match[];
    setMatches(typedMatches);

    const shootouts = typedMatches.filter((match) => match.status === "shootout");

    const setupPairs = await Promise.all(
      shootouts.map(async (match) => {
        const { data: setupData, error: setupError } = await supabase.rpc(
          "fa_get_x1_penalty_setup",
          { p_match_id: match.id },
        );

        if (setupError) throw setupError;
        return [match.id, setupData as PenaltySetup] as const;
      }),
    );

    setSetups(Object.fromEntries(setupPairs));
  }, [roomId]);

  useEffect(() => {
    let live = true;

    const refresh = () =>
      void load().catch((loadError) => {
        if (live) {
          setError(loadError instanceof Error ? loadError.message : "Não foi possível atualizar os desafios");
        }
      });

    refresh();
    const timer = window.setInterval(refresh, 3000);

    return () => {
      live = false;
      window.clearInterval(timer);
    };
  }, [load]);

  async function action(rpc: string, args: Record<string, unknown>) {
    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(rpc, args);
      if (rpcError) throw rpcError;
      await load();
    } catch (actionError) {
      setError(
        actionError &&
          typeof actionError === "object" &&
          "message" in actionError
          ? String(actionError.message)
          : "Falha ao atualizar o X1",
      );
    } finally {
      setBusy(false);
    }
  }

  const choosePenalty = (matchId: string, direction: string) =>
    void action("fa_choose_x1_penalty", {
      p_match_id: matchId,
      p_direction: direction,
    });

  const confirmPenaltyOrder = (matchId: string, order: string[]) =>
    void action("fa_set_x1_penalty_order", {
      p_match_id: matchId,
      p_player_ids: order,
    });

  const startPenalties = (matchId: string) =>
    void action("fa_start_x1_penalties", {
      p_match_id: matchId,
    });

  const name = (id: string) =>
    members.find((member) => member.id === id)?.display_name || "Participante";

  return (
    <section className="card x1-arena">
      <div className="topbar">
        <div>
          <span className="special-badge card-type-badge">DUELO DOS CRIAS</span>
          <h2>X1 entre elencos</h2>
        </div>
        <span className="muted">90 minutos, prorrogação e pênaltis se precisar.</span>
      </div>

      {error && <p role="alert" className="red">{error}</p>}

      {me && !me.is_spectator && (
        <div className="x1-opponents">
          {!me.squad_finalized ? (
            <p>Finalize seu time para desafiar.</p>
          ) : (
            members
              .filter(
                (member) =>
                  member.id !== me.id &&
                  !member.is_spectator &&
                  member.squad_finalized,
              )
              .map((member) => (
                <button
                  className="btn btn-primary"
                  key={member.id}
                  disabled={
                    busy ||
                    matches.some(
                      (match) =>
                        ["pending", "shootout"].includes(match.status) &&
                        [match.challenger_id, match.opponent_id].includes(me.id) &&
                        [match.challenger_id, match.opponent_id].includes(member.id),
                    )
                  }
                  onClick={() =>
                    void action("fa_challenge_x1", {
                      p_room_id: roomId,
                      p_opponent_id: member.id,
                    })
                  }
                >
                  Desafiar {member.display_name}
                </button>
              ))
          )}
        </div>
      )}

      {matches.length === 0 && (
        <p className="muted">Os desafios e resultados desta sala aparecem aqui.</p>
      )}

      {matches.map((match) => (
        <article className="x1-match" key={match.id}>
          {match.status === "completed" && match.result ? (
            <CompletedMatch match={match} />
          ) : match.status === "shootout" && match.result ? (
            <>
              <strong>
                {name(match.challenger_id)} × {name(match.opponent_id)}
              </strong>
              <p className="muted">
                Empate após a prorrogação. Disputa de pênaltis.
              </p>

              <PenaltySetupPanel
                match={match}
                me={me}
                setup={setups[match.id] || null}
                busy={busy}
                onConfirm={confirmPenaltyOrder}
                onStart={startPenalties}
              />

              <ShootoutPanel
                match={match}
                me={me}
                busy={busy}
                onChoose={choosePenalty}
              />
            </>
          ) : (
            <>
              <strong>
                {name(match.challenger_id)} × {name(match.opponent_id)}
              </strong>

              <p className="muted">
                {
                  (
                    {
                      pending: "Desafio aguardando resposta",
                      declined: "Desafio recusado",
                      cancelled: "Cancelado pela revanche",
                    } as Record<string, string>
                  )[match.status]
                }
              </p>

              {match.status === "pending" && me?.id === match.opponent_id && (
                <div className="x1-opponents">
                  <button
                    className="btn btn-primary"
                    disabled={busy}
                    onClick={() =>
                      void action("fa_respond_x1", {
                        p_match_id: match.id,
                        p_accept: true,
                      })
                    }
                  >
                    Aceitar X1
                  </button>

                  <button
                    className="btn btn-secondary"
                    disabled={busy}
                    onClick={() =>
                      void action("fa_respond_x1", {
                        p_match_id: match.id,
                        p_accept: false,
                      })
                    }
                  >
                    Recusar
                  </button>
                </div>
              )}
            </>
          )}
        </article>
      ))}
    </section>
  );
}
