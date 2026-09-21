"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function CreateRoom() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [mode, setMode] = useState<"football" | "futsal">("football");
  const [budget, setBudget] = useState("100");
  const [reserveCount, setReserveCount] = useState(5);
  const [allowIcons, setAllowIcons] = useState(true);
  const [minOverall, setMinOverall] = useState(1);
  const [maxOverall, setMaxOverall] = useState(100);
  const [activeOnly, setActiveOnly] = useState(false);
  const [disconnectMode, setDisconnectMode] = useState<"skip" | "bot">("skip");
  const [spectatorsAllowed, setSpectatorsAllowed] = useState(true);
  const [password, setPassword] = useState("");
  const [leagues, setLeagues] = useState<string[]>([]);
  const [selectedLeagues, setSelectedLeagues] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let alive = true;

    void (async () => {
      try {
        await ensureAnonymousSession();
        const { data } = await getSupabase()
          .from("fa_catalog_players")
          .select("league")
          .eq("enabled", true)
          .limit(1000);

        if (!alive) return;
        const unique = Array.from(
          new Set((data || []).map((row) => String(row.league || "").trim()).filter(Boolean)),
        ).sort((a, b) => a.localeCompare(b));
        setLeagues(unique);
      } catch {
        // A lista de ligas é opcional; a sala pode ser criada sem filtro.
      }
    })();

    return () => {
      alive = false;
    };
  }, []);

  function changeMode(next: "football" | "futsal") {
    setMode(next);
    setReserveCount(next === "futsal" ? 2 : 5);
  }

  async function createRoom() {
    setError("");
    setLoading(true);

    try {
      await ensureAnonymousSession();
      const supabase = getSupabase();

      const { data, error: rpcError } = await supabase.rpc("fa_create_room_v2", {
        p_display_name: name.trim() || "Administrador",
        p_mode: mode,
        p_budget: Number(budget),
        p_reserve_count: reserveCount,
        p_allow_icons: allowIcons,
        p_min_overall: minOverall,
        p_max_overall: maxOverall,
        p_active_only: activeOnly,
        p_allowed_leagues: selectedLeagues.length ? selectedLeagues : null,
        p_disconnect_mode: disconnectMode,
        p_spectators_allowed: spectatorsAllowed,
        p_password: password.trim() || null,
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
    <main className="form-page">
      <div className="form-shell">
        <button className="back-button" type="button" onClick={() => router.push("/")}>
          ← Voltar
        </button>

        <h1 className="form-title">Criar sala</h1>

        <div className="card grid form-card">
          <label>
            Nome do administrador
            <input
              className="input"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Ex.: Gabriel"
              maxLength={24}
            />
          </label>

          <label>
            Modalidade
            <select
              className="input"
              value={mode}
              onChange={(e) => changeMode(e.target.value as "football" | "futsal")}
            >
              <option value="football">Futebol de campo</option>
              <option value="futsal">Futsal</option>
            </select>
          </label>

          <div className="settings-grid">
            <label>
              Orçamento por pessoa
              <select className="input" value={budget} onChange={(e) => setBudget(e.target.value)}>
                {[50, 100, 150, 200, 500].map((value) => (
                  <option key={value} value={value}>{value} créditos</option>
                ))}
              </select>
            </label>

            <label>
              Reservas
              <select
                className="input"
                value={reserveCount}
                onChange={(e) => setReserveCount(Number(e.target.value))}
              >
                {[0, 1, 2, 3, 4, 5].map((value) => (
                  <option key={value} value={value}>{value}</option>
                ))}
              </select>
            </label>

            <label>
              GER mínimo
              <input
                className="input"
                type="number"
                min={1}
                max={100}
                value={minOverall}
                onChange={(e) => setMinOverall(Number(e.target.value))}
              />
            </label>

            <label>
              GER máximo
              <input
                className="input"
                type="number"
                min={1}
                max={100}
                value={maxOverall}
                onChange={(e) => setMaxOverall(Number(e.target.value))}
              />
            </label>
          </div>

          <label>
            Ligas permitidas
            <select
              className="input league-multiselect"
              multiple
              value={selectedLeagues}
              onChange={(e) =>
                setSelectedLeagues(Array.from(e.target.selectedOptions).map((option) => option.value))
              }
            >
              {leagues.map((league) => (
                <option key={league} value={league}>{league}</option>
              ))}
            </select>
            <small className="muted">Sem seleção = todas as ligas. No celular, selecione apenas se quiser filtrar.</small>
          </label>

          <div className="settings-grid">
            <label>
              Desconexão
              <select
                className="input"
                value={disconnectMode}
                onChange={(e) => setDisconnectMode(e.target.value as "skip" | "bot")}
              >
                <option value="skip">Continuar sem o jogador</option>
                <option value="bot">BOT conservador assume</option>
              </select>
            </label>

            <label>
              Senha opcional
              <input
                className="input"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Deixe vazio para sala aberta"
                maxLength={32}
              />
            </label>
          </div>

          <div className="settings-checks">
            <label className="check-row">
              <input type="checkbox" checked={allowIcons} onChange={(e) => setAllowIcons(e.target.checked)} />
              Permitir ICONS e cartas especiais
            </label>

            <label className="check-row">
              <input type="checkbox" checked={activeOnly} onChange={(e) => setActiveOnly(e.target.checked)} />
              Somente jogadores ativos
            </label>

            <label className="check-row">
              <input
                type="checkbox"
                checked={spectatorsAllowed}
                onChange={(e) => setSpectatorsAllowed(e.target.checked)}
              />
              Permitir espectadores
            </label>
          </div>

          {error && <p className="red">{error}</p>}

          <button
            className="btn btn-primary"
            onClick={createRoom}
            disabled={loading || minOverall > maxOverall}
          >
            {loading ? "Criando..." : "Criar sala"}
          </button>
        </div>
      </div>
    </main>
  );
}
