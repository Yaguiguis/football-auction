"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../../../lib/supabase";
import ConnectionBanner from "../../../../components/ConnectionBanner";
import PlayerFace from "../../../../components/PlayerFace";
import CardBadge, { cardClass } from "../../../../components/CardBadge";
import RoomChat from "../../../../components/RoomChat";

type Room = {
  id: string;
  code: string;
  host_user_id: string;
  room_kind: "auction" | "tournament" | "cases" | "impostor";
  status: string;
};

type SecretPlayer = {
  id: string;
  name: string;
  club: string | null;
  league: string | null;
  nationality: string | null;
  primary_position: string;
  overall: number;
  player_type: string;
  image_url: string | null;
};

type StateMember = {
  member_id: string;
  name: string;
  is_admin: boolean;
  is_spectator: boolean;
  eliminated: boolean;
  alive: boolean;
};

type Answer = {
  member_id: string;
  name: string;
  answer: string;
};

type Rating = {
  rater_member_id: string;
  rater_name: string;
  target_member_id: string;
  target_name: string;
  rating: "good" | "suspicious";
};

type HistoryQuestion = {
  id: string;
  round_no: number;
  questioner_member_id: string;
  questioner_name: string;
  question: string;
  answers: Answer[];
  ratings: Rating[];
};

type ActiveQuestion = {
  id: string;
  questioner_member_id: string;
  questioner_name: string;
  question: string;
  status: "answering" | "rating" | "completed";
  answers: Answer[];
  ratings: Rating[];
};

type ImpostorState = {
  room_status: string;
  has_game: boolean;
  game_id?: string;
  status?: "playing" | "finished";
  phase?:
    | "question"
    | "answering"
    | "rating"
    | "decision"
    | "elimination"
    | "runoff"
    | "finished";
  round_no?: number;
  role: "admin" | "player" | "spectator" | "impostor" | "innocent" | "eliminated";
  me_member_id?: string;
  secret_player?: SecretPlayer | null;
  hint?: string | null;
  impostor?: { member_id: string; name: string } | null;
  winner_side?: "innocents" | "impostor" | null;
  current_questioner_member_id?: string | null;
  active_question?: ActiveQuestion | null;
  my_answer?: { answer_text: string } | null;
  my_ratings?: Array<{ target_member_id: string; rating: "good" | "suspicious" }>;
  my_decision_vote?: "vote" | "continue" | null;
  my_elimination_vote?: string | null;
  last_decision?: {
    round: number;
    vote: number;
    continue: number;
    result: "vote" | "continue";
    tie: boolean;
  } | null;
  last_elimination?: {
    round: number;
    member_id: string | null;
    was_impostor: boolean;
    reason?: string;
    votes?: Array<{ voter_member_id: string; target_member_id: string }>;
  } | null;
  runoff_candidates?: string[];
  members?: StateMember[];
  history?: HistoryQuestion[];
};

function errorMessage(error: unknown) {
  if (error instanceof Error) return error.message;
  if (error && typeof error === "object" && "message" in error) {
    const message = (error as { message?: unknown }).message;
    if (typeof message === "string") return message;
  }
  return "Não foi possível atualizar a partida.";
}

function RoleCard({ state }: { state: ImpostorState }) {
  const secret = state.secret_player;

  if (state.status === "finished") {
    return (
      <section className="card impostor-role-card reveal">
        <span className="impostor-role-kicker">FIM DA PARTIDA</span>
        <h2>
          {state.winner_side === "innocents"
            ? "Os inocentes venceram"
            : "O impostor venceu"}
        </h2>

        <div className="impostor-final-reveal">
          {secret && (
            <div className={`impostor-secret-player ${cardClass(secret)}`}>
              <PlayerFace name={secret.name} imageUrl={secret.image_url} size={88} />
              <div>
                <CardBadge player={secret} />
                <strong>{secret.name}</strong>
                <span>
                  {secret.primary_position} • {secret.overall} GER
                </span>
              </div>
            </div>
          )}

          <div className="impostor-reveal-person">
            <span>🕵️</span>
            <div>
              <small>O IMPOSTOR ERA</small>
              <strong>{state.impostor?.name || "—"}</strong>
            </div>
          </div>
        </div>
      </section>
    );
  }

  if (state.role === "admin") {
    return (
      <section className="card impostor-role-card admin">
        <span className="impostor-role-kicker">MESTRE DA SALA</span>
        <h2>Você está assistindo</h2>
        <p>
          Você escolheu o jogador e a dica. O servidor sorteou o impostor.
        </p>

        <div className="impostor-role-details">
          {secret && (
            <div className="impostor-role-secret">
              <small>JOGADOR SECRETO</small>
              <strong>{secret.name}</strong>
            </div>
          )}
          <div>
            <small>DICA DO IMPOSTOR</small>
            <strong>{state.hint || "—"}</strong>
          </div>
          <div>
            <small>IMPOSTOR SORTEADO</small>
            <strong>{state.impostor?.name || "—"}</strong>
          </div>
        </div>
      </section>
    );
  }

  if (state.role === "impostor") {
    return (
      <section className="card impostor-role-card impostor">
        <span className="impostor-role-kicker">SEU PAPEL</span>
        <h2>🕵️ VOCÊ É O IMPOSTOR</h2>
        <p>Descubra o jogador pelas perguntas sem levantar suspeitas.</p>
        <div className="impostor-hint-box">
          <small>SUA DICA</small>
          <strong>{state.hint || "Sem dica"}</strong>
        </div>
      </section>
    );
  }

  if (state.role === "innocent" || state.role === "eliminated") {
    return (
      <section className={`card impostor-role-card innocent ${state.role === "eliminated" ? "eliminated" : ""}`}>
        <span className="impostor-role-kicker">
          {state.role === "eliminated" ? "VOCÊ FOI ELIMINADO" : "SEU PAPEL"}
        </span>
        <h2>{state.role === "eliminated" ? "Você era inocente" : "✅ VOCÊ É INOCENTE"}</h2>

        {secret && (
          <div className={`impostor-secret-player ${cardClass(secret)}`}>
            <PlayerFace name={secret.name} imageUrl={secret.image_url} size={80} />
            <div>
              <small>JOGADOR SECRETO</small>
              <CardBadge player={secret} />
              <strong>{secret.name}</strong>
              <span>
                {secret.primary_position} • {secret.overall} GER
              </span>
            </div>
          </div>
        )}
      </section>
    );
  }

  return (
    <section className="card impostor-role-card spectator">
      <span className="impostor-role-kicker">ESPECTADOR</span>
      <h2>👀 Você está assistindo</h2>
      <p>O jogador secreto e o impostor só aparecem quando a partida acabar.</p>
    </section>
  );
}

export default function ImpostorGamePage() {
  const params = useParams<{ code: string }>();
  const router = useRouter();
  const code = String(params.code).toUpperCase();

  const [room, setRoom] = useState<Room | null>(null);
  const [state, setState] = useState<ImpostorState | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  const [catalogSearch, setCatalogSearch] = useState("");
  const [catalog, setCatalog] = useState<SecretPlayer[]>([]);
  const [catalogLoading, setCatalogLoading] = useState(false);
  const [selectedPlayer, setSelectedPlayer] = useState<SecretPlayer | null>(null);
  const [hint, setHint] = useState("");

  const [questionText, setQuestionText] = useState("");
  const [answerText, setAnswerText] = useState("");

  const load = useCallback(async () => {
    const supabase = getSupabase();
    await ensureAnonymousSession();

    const { data: roomData, error: roomError } = await supabase
      .from("fa_rooms")
      .select("id,code,host_user_id,room_kind,status")
      .eq("code", code)
      .maybeSingle();

    if (roomError) throw roomError;
    if (!roomData) throw new Error("Sala não encontrada.");

    const typedRoom = roomData as Room;
    if (typedRoom.room_kind !== "impostor") {
      throw new Error("Esta sala não é do Impostor FC.");
    }

    setRoom(typedRoom);

    const { data: stateData, error: stateError } = await supabase.rpc(
      "fa_impostor_state",
      { p_room_id: typedRoom.id },
    );

    if (stateError) throw stateError;
    setState(stateData as ImpostorState);
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
    const timer = window.setInterval(() => void safeLoad(), 2200);
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
    if (!room?.id || state?.role !== "admin" || state.has_game) return;

    const timer = window.setTimeout(() => {
      void (async () => {
        setCatalogLoading(true);
        try {
          const { data, error: catalogError } = await getSupabase().rpc(
            "fa_impostor_catalog",
            {
              p_room_id: room.id,
              p_search: catalogSearch.trim() || null,
            },
          );

          if (catalogError) throw catalogError;
          setCatalog((data || []) as SecretPlayer[]);
        } catch (e) {
          setError(errorMessage(e));
        } finally {
          setCatalogLoading(false);
        }
      })();
    }, 250);

    return () => window.clearTimeout(timer);
  }, [room?.id, state?.role, state?.has_game, catalogSearch]);

  const members = state?.members || [];
  const aliveMembers = members.filter((member) => member.alive);
  const me = members.find((member) => member.member_id === state?.me_member_id) || null;
  const activeQuestion = state?.active_question || null;
  const history = state?.history || [];

  const suspicion = useMemo(() => {
    const totals = new Map<string, number>();

    for (const question of history) {
      for (const rating of question.ratings || []) {
        if (rating.rating === "suspicious") {
          totals.set(
            rating.target_member_id,
            (totals.get(rating.target_member_id) || 0) + 1,
          );
        }
      }
    }

    return aliveMembers
      .map((member) => ({
        ...member,
        suspicious: totals.get(member.member_id) || 0,
      }))
      .sort((a, b) => b.suspicious - a.suspicious || a.name.localeCompare(b.name));
  }, [history, aliveMembers]);

  const myRatings = new Map(
    (state?.my_ratings || []).map((rating) => [rating.target_member_id, rating.rating]),
  );

  const canParticipate =
    state?.role === "innocent" || state?.role === "impostor";

  const questioner = members.find(
    (member) => member.member_id === state?.current_questioner_member_id,
  );

  const runoffSet = new Set(state?.runoff_candidates || []);

  async function startGame() {
    if (!room || !selectedPlayer || !hint.trim() || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_start_impostor_game",
        {
          p_room_id: room.id,
          p_catalog_id: selectedPlayer.id,
          p_hint: hint.trim(),
        },
      );

      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function submitQuestion() {
    if (!state?.game_id || !questionText.trim() || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_impostor_submit_question",
        {
          p_game_id: state.game_id,
          p_question: questionText.trim(),
        },
      );

      if (rpcError) throw rpcError;
      setQuestionText("");
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function submitAnswer() {
    if (!activeQuestion || !answerText.trim() || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_impostor_submit_answer",
        {
          p_question_id: activeQuestion.id,
          p_answer: answerText.trim(),
        },
      );

      if (rpcError) throw rpcError;
      setAnswerText("");
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function rateAnswer(targetMemberId: string, rating: "good" | "suspicious") {
    if (!activeQuestion || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_impostor_rate_answer",
        {
          p_question_id: activeQuestion.id,
          p_target_member_id: targetMemberId,
          p_rating: rating,
        },
      );

      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function decide(choice: "vote" | "continue") {
    if (!state?.game_id || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_impostor_decide_round",
        {
          p_game_id: state.game_id,
          p_choice: choice,
        },
      );

      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function voteElimination(targetMemberId: string) {
    if (!state?.game_id || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_impostor_vote_elimination",
        {
          p_game_id: state.game_id,
          p_target_member_id: targetMemberId,
        },
      );

      if (rpcError) throw rpcError;
      await safeLoad();
    } catch (e) {
      setError(errorMessage(e));
    } finally {
      setBusy(false);
    }
  }

  async function resetGame() {
    if (!room || busy) return;

    setBusy(true);
    setError("");

    try {
      const { error: rpcError } = await getSupabase().rpc(
        "fa_reset_impostor_room",
        { p_room_id: room.id },
      );

      if (rpcError) throw rpcError;
      router.replace(`/sala/${code}/lobby`);
    } catch (e) {
      setError(errorMessage(e));
      setBusy(false);
    }
  }

  if (loading) {
    return (
      <main className="container">
        <p>Preparando o Impostor FC...</p>
      </main>
    );
  }

  return (
    <main className="impostor-game-page">
      <div className="container">
        <ConnectionBanner />

        <div className="topbar impostor-game-topbar">
          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <button
              className="btn btn-secondary"
              onClick={() => router.push(`/sala/${code}/lobby`)}
            >
              ← Lobby
            </button>
            <button className="btn btn-secondary" onClick={() => router.push("/")}>
              Início
            </button>
          </div>

          <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
            <span className="badge">🕵️ Impostor FC</span>
            <span className="badge">Sala {code}</span>
            {state?.round_no && <span className="badge">Rodada {state.round_no}</span>}
          </div>
        </div>

        <header className="impostor-game-hero">
          <span>DEDUÇÃO • FUTEBOL • BLEFE</span>
          <h1>Impostor FC</h1>
          <p>Faça perguntas, compare respostas e descubra quem não sabe o jogador.</p>
        </header>

        {error && (
          <div className="card impostor-error-card">
            <strong>Algo deu errado</strong>
            <span>{error}</span>
          </div>
        )}

        {!state?.has_game ? (
          state?.role === "admin" ? (
            <section className="card impostor-setup-panel">
              <div className="impostor-section-heading">
                <div>
                  <span>CONFIGURAÇÃO DO MESTRE</span>
                  <h2>Escolha o jogador secreto</h2>
                </div>
                <small>O jogo escolhe o impostor — você não escolhe.</small>
              </div>

              <label className="setup-field">
                <span>Buscar jogador</span>
                <input
                  className="input"
                  value={catalogSearch}
                  onChange={(event) => setCatalogSearch(event.target.value)}
                  placeholder="Nome, clube ou seleção..."
                />
              </label>

              <div className="impostor-catalog-grid">
                {catalogLoading && <p className="muted">Buscando jogadores...</p>}

                {!catalogLoading &&
                  catalog.map((player) => (
                    <button
                      type="button"
                      key={player.id}
                      className={`impostor-catalog-player ${selectedPlayer?.id === player.id ? "selected" : ""} ${cardClass(player)}`}
                      onClick={() => setSelectedPlayer(player)}
                    >
                      <PlayerFace name={player.name} imageUrl={player.image_url} size={58} />
                      <span>
                        <CardBadge player={player} />
                        <strong>{player.name}</strong>
                        <small>
                          {player.primary_position} • {player.overall} GER
                          {player.club ? ` • ${player.club}` : ""}
                        </small>
                      </span>
                    </button>
                  ))}
              </div>

              {selectedPlayer && (
                <div className="impostor-selected-secret">
                  <PlayerFace
                    name={selectedPlayer.name}
                    imageUrl={selectedPlayer.image_url}
                    size={72}
                  />
                  <div>
                    <small>JOGADOR ESCOLHIDO</small>
                    <strong>{selectedPlayer.name}</strong>
                    <span>
                      {selectedPlayer.primary_position} • {selectedPlayer.overall} GER
                    </span>
                  </div>
                </div>
              )}

              <label className="setup-field">
                <span>Dica que SOMENTE o impostor vai receber</span>
                <textarea
                  className="input impostor-textarea"
                  value={hint}
                  maxLength={160}
                  onChange={(event) => setHint(event.target.value)}
                  placeholder='Ex.: "Seleção: Brasil" ou "Atua em um clube espanhol"'
                />
                <small className="field-help">{hint.length}/160</small>
              </label>

              <button
                className="btn btn-primary"
                style={{ width: "100%" }}
                disabled={busy || !selectedPlayer || hint.trim().length < 2}
                onClick={() => void startGame()}
              >
                {busy ? "Sorteando..." : "Sortear impostor e começar"}
              </button>
            </section>
          ) : (
            <section className="card impostor-waiting-card">
              <span className="impostor-waiting-icon">🕵️</span>
              <h2>O administrador está preparando a partida</h2>
              <p className="muted">
                Ele está escolhendo o jogador secreto e a dica. O servidor vai sortear o impostor.
              </p>
            </section>
          )
        ) : (
          <>
            {state && <RoleCard state={state} />}

            {state?.status === "playing" && (
              <div className="impostor-game-layout">
                <section className="card impostor-main-panel">
                  <div className="impostor-section-heading">
                    <div>
                      <span>RODADA {state.round_no}</span>
                      <h2>
                        {state.phase === "question" && "Hora da pergunta"}
                        {state.phase === "answering" && "Hora de responder"}
                        {state.phase === "rating" && "Avalie as respostas"}
                        {state.phase === "decision" && "Votar ou continuar?"}
                        {state.phase === "elimination" && "Quem é o impostor?"}
                        {state.phase === "runoff" && "Desempate"}
                      </h2>
                    </div>
                    <small>{aliveMembers.length} jogadores vivos</small>
                  </div>

                  {state.phase === "question" && (
                    <>
                      <div className="impostor-turn-banner">
                        <small>VEZ DE PERGUNTAR</small>
                        <strong>{questioner?.name || "Jogador"}</strong>
                      </div>

                      {canParticipate &&
                      state.current_questioner_member_id === state.me_member_id ? (
                        <div className="impostor-action-box">
                          <label className="setup-field">
                            <span>Escreva sua pergunta</span>
                            <textarea
                              className="input impostor-textarea"
                              value={questionText}
                              maxLength={220}
                              onChange={(event) => setQuestionText(event.target.value)}
                              placeholder="Ex.: Esse jogador já jogou na Premier League?"
                            />
                          </label>
                          <button
                            className="btn btn-primary"
                            disabled={busy || questionText.trim().length < 2}
                            onClick={() => void submitQuestion()}
                          >
                            Enviar pergunta
                          </button>
                        </div>
                      ) : (
                        <p className="muted" style={{ textAlign: "center" }}>
                          Aguarde {questioner?.name || "o jogador"} escrever a pergunta.
                        </p>
                      )}
                    </>
                  )}

                  {state.phase === "answering" && activeQuestion && (
                    <>
                      <div className="impostor-question-card">
                        <small>{activeQuestion.questioner_name.toUpperCase()} PERGUNTOU</small>
                        <strong>{activeQuestion.question}</strong>
                      </div>

                      {state.current_questioner_member_id === state.me_member_id ? (
                        <p className="muted" style={{ textAlign: "center" }}>
                          Você fez a pergunta. Não precisa responder. Aguarde os outros jogadores.
                        </p>
                      ) : canParticipate ? (
                        state.my_answer ? (
                          <div className="impostor-submitted-box">
                            <span>✓</span>
                            <div>
                              <strong>Resposta enviada</strong>
                              <small>
                                As respostas só aparecem quando todo mundo terminar.
                              </small>
                            </div>
                          </div>
                        ) : (
                          <div className="impostor-action-box">
                            <label className="setup-field">
                              <span>Sua resposta</span>
                              <textarea
                                className="input impostor-textarea"
                                value={answerText}
                                maxLength={220}
                                onChange={(event) => setAnswerText(event.target.value)}
                                placeholder="Responda sem ver o que os outros escreveram..."
                              />
                            </label>
                            <button
                              className="btn btn-primary"
                              disabled={busy || !answerText.trim()}
                              onClick={() => void submitAnswer()}
                            >
                              Enviar resposta
                            </button>
                          </div>
                        )
                      ) : (
                        <p className="muted" style={{ textAlign: "center" }}>
                          Aguardando os jogadores responderem em segredo.
                        </p>
                      )}
                    </>
                  )}

                  {state.phase === "rating" && activeQuestion && (
                    <>
                      <div className="impostor-question-card">
                        <small>{activeQuestion.questioner_name.toUpperCase()} PERGUNTOU</small>
                        <strong>{activeQuestion.question}</strong>
                      </div>

                      <p className="muted">
                        Agora as respostas estão abertas. Avalie as respostas dos outros como
                        <b> Boa</b> ou <b>Suspeita</b>. As avaliações aparecem para todos depois.
                      </p>

                      <div className="impostor-answer-grid">
                        {activeQuestion.answers.map((answer) => {
                          const own = answer.member_id === state.me_member_id;
                          const rating = myRatings.get(answer.member_id);

                          return (
                            <article
                              className={`impostor-answer-card ${own ? "own" : ""}`}
                              key={answer.member_id}
                            >
                              <div>
                                <span>{answer.name}</span>
                                {own && <small>SUA RESPOSTA</small>}
                              </div>
                              <strong>“{answer.answer}”</strong>

                              {canParticipate && !own && (
                                <div className="impostor-rating-actions">
                                  <button
                                    type="button"
                                    className={rating === "good" ? "selected good" : "good"}
                                    disabled={busy}
                                    onClick={() => void rateAnswer(answer.member_id, "good")}
                                  >
                                    👍 Boa
                                  </button>
                                  <button
                                    type="button"
                                    className={rating === "suspicious" ? "selected suspicious" : "suspicious"}
                                    disabled={busy}
                                    onClick={() => void rateAnswer(answer.member_id, "suspicious")}
                                  >
                                    🤨 Suspeita
                                  </button>
                                </div>
                              )}
                            </article>
                          );
                        })}
                      </div>
                    </>
                  )}

                  {state.phase === "decision" && (
                    <>
                      <div className="impostor-decision-copy">
                        <span>🗳️</span>
                        <h3>Vocês já querem tentar achar o impostor?</h3>
                        <p>
                          Ganha a opção com mais votos. Se empatar, começa outra rodada de perguntas.
                        </p>
                      </div>

                      {canParticipate ? (
                        state.my_decision_vote ? (
                          <div className="impostor-submitted-box">
                            <span>✓</span>
                            <div>
                              <strong>
                                Você escolheu{" "}
                                {state.my_decision_vote === "vote"
                                  ? "VOTAR AGORA"
                                  : "CONTINUAR"}
                              </strong>
                              <small>Aguardando os outros jogadores.</small>
                            </div>
                          </div>
                        ) : (
                          <div className="impostor-decision-buttons">
                            <button
                              className="impostor-decision-button vote"
                              disabled={busy}
                              onClick={() => void decide("vote")}
                            >
                              <span>🗳️</span>
                              <strong>VOTAR AGORA</strong>
                              <small>Acho que já sei quem é.</small>
                            </button>
                            <button
                              className="impostor-decision-button continue"
                              disabled={busy}
                              onClick={() => void decide("continue")}
                            >
                              <span>🔎</span>
                              <strong>CONTINUAR</strong>
                              <small>Quero mais uma rodada.</small>
                            </button>
                          </div>
                        )
                      ) : (
                        <p className="muted" style={{ textAlign: "center" }}>
                          Os jogadores vivos estão decidindo se já querem votar.
                        </p>
                      )}
                    </>
                  )}

                  {(state.phase === "elimination" || state.phase === "runoff") && (
                    <>
                      <div className="impostor-vote-copy">
                        <span>{state.phase === "runoff" ? "⚖️" : "🕵️"}</span>
                        <div>
                          <h3>{state.phase === "runoff" ? "Votação de desempate" : "Vote em quem é o impostor"}</h3>
                          <p>
                            {state.phase === "runoff"
                              ? "Só os jogadores empatados podem receber votos."
                              : "Seu voto fica escondido até todo mundo votar."}
                          </p>
                        </div>
                      </div>

                      {canParticipate ? (
                        state.my_elimination_vote ? (
                          <div className="impostor-submitted-box">
                            <span>✓</span>
                            <div>
                              <strong>Voto enviado</strong>
                              <small>Aguardando os outros jogadores.</small>
                            </div>
                          </div>
                        ) : (
                          <div className="impostor-vote-grid">
                            {aliveMembers
                              .filter(
                                (member) =>
                                  member.member_id !== state.me_member_id &&
                                  (state.phase !== "runoff" ||
                                    runoffSet.has(member.member_id)),
                              )
                              .map((member) => (
                                <button
                                  type="button"
                                  key={member.member_id}
                                  disabled={busy}
                                  onClick={() => void voteElimination(member.member_id)}
                                >
                                  <span>?</span>
                                  <strong>{member.name}</strong>
                                  <small>Votar</small>
                                </button>
                              ))}
                          </div>
                        )
                      ) : (
                        <p className="muted" style={{ textAlign: "center" }}>
                          A votação está acontecendo entre os jogadores vivos.
                        </p>
                      )}
                    </>
                  )}
                </section>

                <aside className="impostor-side-column">
                  <section className="card impostor-suspicion-card">
                    <div className="impostor-section-heading compact">
                      <div>
                        <span>TERMÔMETRO</span>
                        <h3>Suspeitas</h3>
                      </div>
                    </div>

                    <div className="impostor-suspicion-list">
                      {suspicion.map((member, index) => (
                        <div key={member.member_id}>
                          <span>{index + 1}</span>
                          <strong>{member.name}</strong>
                          <b>{member.suspicious} 🤨</b>
                        </div>
                      ))}
                    </div>
                  </section>

                  {state.last_decision && (
                    <section className="card impostor-last-event">
                      <small>DECISÃO DA RODADA {state.last_decision.round}</small>
                      <strong>
                        {state.last_decision.vote} votar • {state.last_decision.continue} continuar
                      </strong>
                      <span>
                        {state.last_decision.tie
                          ? "Empate — a investigação continuou."
                          : state.last_decision.result === "vote"
                            ? "A votação foi aprovada."
                            : "A investigação continuou."}
                      </span>
                    </section>
                  )}

                  {state.last_elimination && (
                    <section className="card impostor-last-event danger">
                      <small>ÚLTIMA VOTAÇÃO</small>
                      <strong>
                        {state.last_elimination.member_id
                          ? members.find(
                              (member) =>
                                member.member_id === state.last_elimination?.member_id,
                            )?.name || "Jogador"
                          : "Ninguém foi eliminado"}
                      </strong>
                      <span>
                        {state.last_elimination.member_id
                          ? state.last_elimination.was_impostor
                            ? "ERA O IMPOSTOR."
                            : "Era inocente."
                          : "O desempate terminou empatado."}
                      </span>

                      {!!state.last_elimination.votes?.length && (
                        <div className="impostor-public-votes">
                          {state.last_elimination.votes.map((vote, index) => (
                            <small key={index}>
                              {members.find((m) => m.member_id === vote.voter_member_id)?.name || "?"}
                              {" → "}
                              {members.find((m) => m.member_id === vote.target_member_id)?.name || "?"}
                            </small>
                          ))}
                        </div>
                      )}
                    </section>
                  )}
                </aside>
              </div>
            )}

            {state?.status === "finished" && (
              <div className="impostor-finish-actions">
                {state.role === "admin" && (
                  <button
                    className="btn btn-primary"
                    disabled={busy}
                    onClick={() => void resetGame()}
                  >
                    {busy ? "Preparando..." : "Nova partida nesta sala"}
                  </button>
                )}
                <button
                  className="btn btn-secondary"
                  onClick={() => router.push(`/sala/${code}/lobby`)}
                >
                  Voltar ao lobby
                </button>
              </div>
            )}

            {history.length > 0 && (
              <section className="card impostor-history">
                <div className="impostor-section-heading">
                  <div>
                    <span>HISTÓRICO</span>
                    <h2>Perguntas e avaliações</h2>
                  </div>
                </div>

                <div className="impostor-history-list">
                  {[...history].reverse().map((question) => (
                    <article key={question.id}>
                      <div className="impostor-history-question">
                        <small>RODADA {question.round_no} • {question.questioner_name}</small>
                        <strong>{question.question}</strong>
                      </div>

                      <div className="impostor-history-answers">
                        {question.answers.map((answer) => {
                          const ratings = question.ratings.filter(
                            (rating) => rating.target_member_id === answer.member_id,
                          );

                          return (
                            <div key={answer.member_id}>
                              <strong>{answer.name}</strong>
                              <p>“{answer.answer}”</p>
                              <div className="impostor-rating-history">
                                {ratings.map((rating, index) => (
                                  <span
                                    key={index}
                                    className={rating.rating}
                                  >
                                    {rating.rating === "good" ? "👍 Boa" : "🤨 Suspeita"}
                                    {" — "}
                                    {rating.rater_name}
                                  </span>
                                ))}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </article>
                  ))}
                </div>
              </section>
            )}
          </>
        )}

        {room && <RoomChat roomId={room.id} />}
      </div>
    </main>
  );
}
