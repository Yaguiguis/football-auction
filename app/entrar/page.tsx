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
    <main className="form-page">
      <div className="form-shell">
        <button className="back-button" type="button" onClick={() => router.push("/")}>
          ← Voltar
        </button>

        <h1 className="form-title">Entrar na sala</h1>

        <div className="card grid form-card">
          <input
            className="input"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Seu nome"
            maxLength={24}
          />

          <input
            className="input"
            value={room}
            onChange={(e) => setRoom(e.target.value.toUpperCase())}
            placeholder="Código da sala"
            maxLength={6}
          />

          <input
            className="input"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Senha da sala (se tiver)"
            maxLength={32}
          />

          {error && <p className="red">{error}</p>}

          <div className="join-actions">
            <button
              className="btn btn-primary"
              onClick={() => void enter(false)}
              disabled={loadingMode !== null || !validCode}
            >
              {loadingMode === "player" ? "Entrando..." : "Entrar para jogar"}
            </button>

            <button
              className="btn btn-secondary"
              onClick={() => void enter(true)}
              disabled={loadingMode !== null || !validCode}
            >
              {loadingMode === "spectator" ? "Entrando..." : "Assistir como espectador"}
            </button>
          </div>

          <p className="muted" style={{ margin: 0 }}>
            Se a partida já começou, use o modo espectador. Se você já fazia parte da sala neste navegador, o jogo reconecta sua sessão automaticamente.
          </p>
        </div>
      </div>
    </main>
  );
}
