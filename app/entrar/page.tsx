"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function JoinRoom() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [room, setRoom] = useState("");
  const [password, setPassword] = useState("");
  const [loadingMode, setLoadingMode] = useState<"player" | "spectator" | null>(null);
  const [error, setError] = useState("");

  async function enter(asSpectator: boolean) {
    setError("");
    setLoadingMode(asSpectator ? "spectator" : "player");

    try {
      await ensureAnonymousSession();
      const code = room.trim().toUpperCase();
      const supabase = getSupabase();

      const { error: rpcError } = await supabase.rpc("fa_join_room_v2", {
        p_code: code,
        p_display_name: name.trim() || (asSpectator ? "Espectador" : "Jogador"),
        p_password: password.trim() || null,
        p_as_spectator: asSpectator,
      });

      if (rpcError) throw rpcError;
      router.push(`/sala/${code}/lobby`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível entrar na sala.");
    } finally {
      setLoadingMode(null);
    }
  }

  const validCode = room.trim().length === 6;

  return (
    <main className="room-setup-page join-page">
      <div className="room-setup-glow room-setup-glow-one" />
      <div className="room-setup-glow room-setup-glow-two" />

      <div className="room-setup-shell join-shell">
        <button className="setup-back-button" type="button" onClick={() => router.push("/")}>
          <span>←</span>
          Voltar
        </button>

        <header className="setup-hero join-hero">
          <span className="setup-eyebrow">ENTRAR NA PARTIDA</span>
          <h1>Entrar na sala</h1>
          <p>Use o código enviado pelo administrador para voltar direto para o jogo.</p>
        </header>

        <section className="join-premium-card">
          <div className="join-card-accent" />

          <div className="join-card-heading">
            <span className="join-card-icon">⚽</span>
            <div>
              <h2>Dados de entrada</h2>
              <p>Se a sala tiver senha, informe junto com o código.</p>
            </div>
          </div>

          <div className="join-field-stack">
            <label className="setup-field">
              <span>Seu nome</span>
              <input
                className="input setup-input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Como seus amigos vão te ver"
                maxLength={24}
              />
            </label>

            <label className="setup-field">
              <span>Código da sala</span>
              <input
                className="input setup-input room-code-input"
                value={room}
                onChange={(e) =>
                  setRoom(
                    e.target.value
                      .toUpperCase()
                      .replace(/[^A-Z0-9]/g, "")
                      .slice(0, 6),
                  )
                }
                placeholder="ABC123"
                maxLength={6}
                autoCapitalize="characters"
                autoCorrect="off"
                spellCheck={false}
              />
              <small className="field-help">
                {room.length}/6 caracteres
              </small>
            </label>

            <label className="setup-field">
              <span>Senha da sala <em>opcional</em></span>
              <input
                className="input setup-input"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Preencha apenas se a sala tiver senha"
                maxLength={32}
              />
            </label>
          </div>

          {error && (
            <div className="setup-error">
              <strong>Não foi possível entrar</strong>
              <span>{error}</span>
            </div>
          )}

          <div className="join-choice-grid">
            <button
              className="join-choice-card primary"
              onClick={() => void enter(false)}
              disabled={loadingMode !== null || !validCode}
            >
              <span className="join-choice-icon">🎮</span>
              <span className="join-choice-copy">
                <strong>{loadingMode === "player" ? "Entrando..." : "Entrar para jogar"}</strong>
                <small>Participa do leilão e monta seu próprio time.</small>
              </span>
              <span className="join-choice-arrow">→</span>
            </button>

            <button
              className="join-choice-card"
              onClick={() => void enter(true)}
              disabled={loadingMode !== null || !validCode}
            >
              <span className="join-choice-icon">👀</span>
              <span className="join-choice-copy">
                <strong>{loadingMode === "spectator" ? "Entrando..." : "Assistir como espectador"}</strong>
                <small>Acompanha a partida e participa do chat.</small>
              </span>
              <span className="join-choice-arrow">→</span>
            </button>
          </div>

          <div className="join-info-strip">
            <span>↻</span>
            <p>
              Já fazia parte desta sala neste navegador? Sua sessão é reconhecida e você volta para o estado atual da partida.
            </p>
          </div>
        </section>
      </div>
    </main>
  );
}
