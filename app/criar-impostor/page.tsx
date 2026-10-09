"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function CreateImpostorRoomPage() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [spectatorsAllowed, setSpectatorsAllowed] = useState(true);
  const [adminMode, setAdminMode] = useState<"watch" | "play">("watch");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function createRoom() {
    if (loading) return;

    setLoading(true);
    setError("");

    try {
      await ensureAnonymousSession();

      const { data, error: rpcError } = await getSupabase().rpc(
        "fa_create_impostor_room",
        {
          p_display_name: name.trim() || "Administrador",
          p_spectators_allowed: spectatorsAllowed,
          p_password: password.trim() || null,
          p_admin_plays: adminMode === "play",
        },
      );

      if (rpcError) throw rpcError;

      const room = Array.isArray(data) ? data[0] : data;
      if (!room?.room_code) throw new Error("A sala não foi criada.");

      router.push(`/sala/${room.room_code}/lobby`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível criar a sala.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="room-setup-page impostor-create-page">
      <div className="room-setup-glow room-setup-glow-one" />
      <div className="room-setup-glow room-setup-glow-two" />

      <div className="room-setup-shell join-shell">
        <button className="setup-back-button" type="button" onClick={() => router.push("/")}>
          <span>←</span>
          Voltar
        </button>

        <header className="setup-hero join-hero">
          <span className="setup-eyebrow">🕵️ IMPOSTOR FC</span>
          <h1>Criar sala do impostor</h1>
          <p>
            {adminMode === "watch"
              ? "Você será o mestre da sala: escolhe o jogador secreto e a dica, mas não participa das perguntas nem das votações."
              : "Você também vai jogar. O jogo sorteia o jogador secreto, gera a dica e escolhe o impostor automaticamente."}
          </p>
        </header>

        <section className="join-premium-card impostor-create-card">
          <div className="join-card-accent" />

          <div className="join-card-heading">
            <span className="join-card-icon">🕵️</span>
            <div>
              <h2>Configuração inicial</h2>
              <p>Defina se você vai participar da partida ou apenas acompanhar como mestre.</p>
            </div>
          </div>

          <div className="impostor-admin-mode-options" role="group" aria-label="Participação do administrador">
            <button
              className={`impostor-admin-mode-card ${adminMode === "watch" ? "selected" : ""}`}
              type="button"
              aria-pressed={adminMode === "watch"}
              onClick={() => setAdminMode("watch")}
            >
              <span className="impostor-admin-mode-icon">👀</span>
              <strong>Assistir</strong>
              <small>Você escolhe o jogador secreto e escreve a dica. Não joga nem vota.</small>
            </button>
            <button
              className={`impostor-admin-mode-card ${adminMode === "play" ? "selected" : ""}`}
              type="button"
              aria-pressed={adminMode === "play"}
              onClick={() => setAdminMode("play")}
            >
              <span className="impostor-admin-mode-icon">🎮</span>
              <strong>Jogar</strong>
              <small>Você entra no sorteio como qualquer jogador. O sistema escolhe o segredo e a dica.</small>
            </button>
          </div>

          <div className="join-field-stack">
            <label className="setup-field">
              <span>Nome do administrador</span>
              <input
                className="input setup-input"
                value={name}
                onChange={(event) => setName(event.target.value)}
                placeholder="Ex.: Yago"
                maxLength={24}
              />
            </label>

            <label className="setup-field">
              <span>Senha da sala <em>opcional</em></span>
              <input
                className="input setup-input"
                type="password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                placeholder="Deixe vazio para sala aberta"
                maxLength={32}
              />
            </label>

            <label className="setup-toggle-card">
              <input
                type="checkbox"
                checked={spectatorsAllowed}
                onChange={(event) => setSpectatorsAllowed(event.target.checked)}
              />
              <span className="setup-toggle-copy">
                <strong>Permitir espectadores extras</strong>
                <small>{adminMode === "watch" ? "Você ficará fora das perguntas e votações." : "Você também entra no sorteio e joga como participante."}</small>
              </span>
              <span className="setup-switch" />
            </label>
          </div>

          <div className="impostor-create-rules">
            <div><strong>1</strong><span>Mínimo de 4 jogadores ativos.</span></div>
            <div><strong>2</strong><span>{adminMode === "watch" ? "Você escolhe o jogador secreto e a dica, inclusive um nome de fora do catálogo." : "O sistema sorteia o jogador secreto e gera uma dica automaticamente."}</span></div>
            <div><strong>3</strong><span>O impostor é sempre sorteado pelo servidor entre os jogadores ativos.</span></div>
          </div>

          {error && (
            <div className="setup-error">
              <strong>Não foi possível criar</strong>
              <span>{error}</span>
            </div>
          )}

          <button
            className="btn btn-primary setup-create-button"
            type="button"
            disabled={loading}
            onClick={() => void createRoom()}
          >
            {loading ? "Criando..." : "Criar sala do Impostor FC"}
          </button>
        </section>
      </div>
    </main>
  );
}
