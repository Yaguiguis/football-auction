"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function CreateTimeImpostorRoomPage() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [password, setPassword] = useState("");
  const [spectatorsAllowed, setSpectatorsAllowed] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function createRoom() {
    if (loading) return;

    setLoading(true);
    setError("");

    try {
      await ensureAnonymousSession();

      const { data, error: rpcError } = await getSupabase().rpc(
        "fa_create_time_impostor_room",
        {
          p_display_name: name.trim() || "Administrador",
          p_spectators_allowed: spectatorsAllowed,
          p_password: password.trim() || null,
        },
      );

      if (rpcError) throw rpcError;

      const room = Array.isArray(data) ? data[0] : data;
      if (!room?.room_code) throw new Error("A sala não foi criada.");

      router.push(`/sala/${room.room_code}/lobby`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Erro ao criar a sala.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="room-setup-page time-impostor-create-page">
      <div className="room-setup-glow room-setup-glow-one" />
      <div className="room-setup-glow room-setup-glow-two" />

      <div className="room-setup-shell join-shell">
        <button
          className="setup-back-button"
          type="button"
          onClick={() => router.push("/")}
        >
          <span>←</span>
          Voltar
        </button>

        <header className="setup-hero">
          <span className="setup-eyebrow">⏱ IMPOSTOR DO TEMPO</span>
          <h1>Quem sabe a hora certa?</h1>
          <p>
            Você cria a sala e vira o administrador. O administrador não joga:
            ele define o tempo de cada rodada e acompanha os participantes.
          </p>
        </header>

        <section className="join-premium-card time-impostor-create-card">
          <div className="join-card-accent" />

          <div className="time-impostor-create-icon">⏱</div>

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

            <label className="setup-toggle-card time-impostor-spectator-toggle">
              <input
                type="checkbox"
                checked={spectatorsAllowed}
                onChange={(event) => setSpectatorsAllowed(event.target.checked)}
              />
              <span className="setup-toggle-copy">
                <strong>Permitir espectadores extras</strong>
                <small>O administrador já fica como espectador automaticamente.</small>
              </span>
              <span className="setup-switch" />
            </label>
          </div>

          <div className="time-impostor-how">
            <div>
              <span>1</span>
              <p>O jogo sorteia 1 impostor entre os jogadores.</p>
            </div>
            <div>
              <span>2</span>
              <p>Você informa o alvo, por exemplo <strong>20,22 s</strong>.</p>
            </div>
            <div>
              <span>3</span>
              <p>Inocentes veem o alvo; o impostor não.</p>
            </div>
            <div>
              <span>4</span>
              <p>O cronômetro roda escondido até cada pessoa apertar parar.</p>
            </div>
          </div>

          {error && (
            <div className="setup-error">
              <strong>Não foi possível criar a sala</strong>
              <span>{error}</span>
            </div>
          )}

          <button
            className="btn btn-primary setup-create-button"
            type="button"
            disabled={loading}
            onClick={() => void createRoom()}
          >
            {loading ? "Criando..." : "Criar sala como administrador"}
          </button>

          <small className="field-help" style={{ display: "block", textAlign: "center", marginTop: 10 }}>
            São necessários pelo menos 4 jogadores, além do administrador.
          </small>
        </section>
      </div>
    </main>
  );
}
