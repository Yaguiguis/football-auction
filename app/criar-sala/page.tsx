"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function CreateRoom() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [mode, setMode] = useState("football");
  const [budget, setBudget] = useState("100");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function createRoom() {
    setError("");
    setLoading(true);
    try {
      await ensureAnonymousSession();
      const supabase = getSupabase();
      const { data, error: rpcError } = await supabase.rpc("fa_create_room", {
        p_display_name: name.trim() || "Administrador",
        p_mode: mode,
        p_budget: Number(budget),
        p_max_players: 2147483647,
      });
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
    <main className="container">
      <div className="topbar">
        <h1>Criar sala</h1>
        <span className="badge">sem limite de pessoas</span>
      </div>
      <div className="card grid" style={{ maxWidth: 620 }}>
        <label>
          Nome do administrador
          <input className="input" value={name} onChange={(e) => setName(e.target.value)} placeholder="Ex.: Gabriel" maxLength={24} />
        </label>
        <label>
          Modalidade
          <select className="input" value={mode} onChange={(e) => setMode(e.target.value)}>
            <option value="football">Futebol de campo</option>
            <option value="futsal">Futsal</option>
          </select>
        </label>
        <label>
          Orçamento por pessoa
          <select className="input" value={budget} onChange={(e) => setBudget(e.target.value)}>
            {[50, 100, 150, 200, 500].map((v) => (
              <option key={v} value={v}>{v} créditos</option>
            ))}
          </select>
        </label>
        <p className="muted">A sala não tem limite fixo de participantes.</p>
        {error && <p className="red">{error}</p>}
        <button className="btn btn-primary" onClick={createRoom} disabled={loading}>
          {loading ? "Criando..." : "Criar sala"}
        </button>
      </div>
    </main>
  );
}
