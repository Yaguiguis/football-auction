"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { ensureAnonymousSession, getSupabase } from "@/lib/supabase";

export default function JoinRoom() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [room, setRoom] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function joinRoom() {
    setError("");
    setLoading(true);
    try {
      await ensureAnonymousSession();
      const supabase = getSupabase();
      const { error: rpcError } = await supabase.rpc("fa_join_room", {
        p_code: room.trim().toUpperCase(),
        p_display_name: name.trim() || "Jogador",
      });
      if (rpcError) throw rpcError;
      router.push(`/sala/${room.trim().toUpperCase()}/lobby`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Não foi possível entrar na sala.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="container">
      <h1>Entrar na sala</h1>
      <div className="card grid" style={{ maxWidth: 620 }}>
        <input className="input" value={name} onChange={(e) => setName(e.target.value)} placeholder="Seu nome" maxLength={24} />
        <input className="input" value={room} onChange={(e) => setRoom(e.target.value.toUpperCase())} placeholder="Código da sala" maxLength={6} />
        <p className="muted">A sala aceita no máximo 5 pessoas.</p>
        {error && <p className="red">{error}</p>}
        <button className="btn btn-primary" onClick={joinRoom} disabled={loading || room.trim().length !== 6}>
          {loading ? "Entrando..." : "Entrar"}
        </button>
      </div>
    </main>
  );
}
