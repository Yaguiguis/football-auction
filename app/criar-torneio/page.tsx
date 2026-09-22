"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import LeagueMultiSelect, { type LeagueOption } from "../../components/LeagueMultiSelect";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function CreateTournamentPage() {
  const router = useRouter();

  const [name, setName] = useState("");
  const [mode, setMode] = useState<"football" | "futsal">("football");
  const [tournamentSize, setTournamentSize] = useState<4 | 8 | 16>(8);
  const [budget, setBudget] = useState("100");
  const [reserveCount, setReserveCount] = useState(5);
  const [allowIcons, setAllowIcons] = useState(true);
  const [allowBase, setAllowBase] = useState(true);
  const [allowSpecials, setAllowSpecials] = useState(true);
  const [minOverall, setMinOverall] = useState(1);
  const [maxOverall, setMaxOverall] = useState(100);
  const [disconnectMode, setDisconnectMode] = useState<"skip" | "bot">("skip");
  const [spectatorsAllowed, setSpectatorsAllowed] = useState(true);
  const [password, setPassword] = useState("");
  const [leagues, setLeagues] = useState<LeagueOption[]>([]);
  const [selectedLeagues, setSelectedLeagues] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    let alive = true;

    void (async () => {
      try {
        await ensureAnonymousSession();

        const { data, error: catalogError } = await getSupabase()
          .from("fa_catalog_players")
          .select("league")
          .eq("enabled", true)
          .limit(2000);

        if (catalogError) throw catalogError;
        if (!alive) return;

        const counts = new Map<string, number>();

        for (const row of data || []) {
          const league = String(row.league || "").trim();
          if (!league) continue;
          counts.set(league, (counts.get(league) || 0) + 1);
        }

        setLeagues(
          Array.from(counts.entries())
            .map(([league, count]) => ({ name: league, count }))
            .sort((a, b) => a.name.localeCompare(b.name, "pt-BR")),
        );
      } catch {
        // A criação continua funcionando mesmo se a lista visual não carregar.
      }
    })();

    return () => {
      alive = false;
    };
  }, []);

  const selectedLeagueCount = useMemo(() => {
    const aliases: Record<string, string> = {
      "LALIGA EA SPORTS": "La Liga",
      "Ligue 1 McDonald's": "Ligue 1",
      "Serie A Enilive": "Serie A",
    };

    return new Set(selectedLeagues.map((league) => aliases[league] || league)).size;
  }, [selectedLeagues]);

  function changeMode(next: "football" | "futsal") {
    setMode(next);
    setReserveCount(next === "futsal" ? 2 : 5);
  }

  async function createTournament() {
    setError("");
    setLoading(true);

    try {
      if (!allowBase && !allowIcons && !allowSpecials) {
        throw new Error("Selecione ao menos um tipo de carta.");
      }

      await ensureAnonymousSession();

      const { data, error: rpcError } = await getSupabase().rpc("fa_create_tournament_room", {
        p_display_name: name.trim() || "Administrador",
        p_mode: mode,
        p_budget: Number(budget),
        p_tournament_size: tournamentSize,
        p_reserve_count: reserveCount,
        p_allow_icons: allowIcons,
        p_min_overall: minOverall,
        p_max_overall: maxOverall,
        p_allowed_leagues: selectedLeagues.length ? selectedLeagues : null,
        p_disconnect_mode: disconnectMode,
        p_spectators_allowed: spectatorsAllowed,
        p_password: password.trim() || null,
        p_allow_base: allowBase,
        p_allow_specials: allowSpecials,
      });

      if (rpcError) throw rpcError;

      const room = Array.isArray(data) ? data[0] : data;
      if (!room?.room_code) throw new Error("O torneio não foi criado.");

      router.push(`/sala/${room.room_code}/lobby`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Erro ao criar o torneio.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="room-setup-page">
      <div className="room-setup-glow room-setup-glow-one" />
      <div className="room-setup-glow room-setup-glow-two" />

      <div className="room-setup-shell">
        <button className="setup-back-button" type="button" onClick={() => router.push("/")}>
          <span>←</span>
          Voltar
        </button>

        <header className="setup-hero">
          <span className="setup-eyebrow">🏆 MODO TORNEIO</span>
          <h1>Criar torneio</h1>
          <p>Monte os elencos no leilão e depois dispute uma chave mata-mata até sair o campeão.</p>
        </header>

        <div className="setup-layout">
          <div className="setup-main">
            <section className="setup-section">
              <div className="setup-section-heading">
                <span className="setup-step">01</span>
                <div>
                  <h2>Formato do torneio</h2>
                  <p>Escolha o tamanho máximo da chave e a modalidade.</p>
                </div>
              </div>

              <label className="setup-field">
                <span>Nome do administrador</span>
                <input
                  className="input setup-input"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Ex.: Gabriel"
                  maxLength={24}
                />
              </label>

              <div className="setup-field">
                <span>Tamanho da chave</span>
                <div className="tournament-size-grid">
                  {[4, 8, 16].map((value) => (
                    <button
                      type="button"
                      key={value}
                      className={`tournament-size-card ${tournamentSize === value ? "active" : ""}`}
                      onClick={() => setTournamentSize(value as 4 | 8 | 16)}
                    >
                      <strong>{value}</strong>
                      <small>até {value} participantes</small>
                    </button>
                  ))}
                </div>
                <small className="muted">
                  Pode começar com menos jogadores. O sistema cria avanços automáticos na primeira fase.
                </small>
              </div>

              <div className="setup-field">
                <span>Modalidade</span>
                <div className="mode-selector">
                  <button
                    type="button"
                    className={mode === "football" ? "active" : ""}
                    onClick={() => changeMode("football")}
                  >
                    <span className="mode-selector-icon">⚽</span>
                    <span><strong>Campo</strong><small>11 titulares</small></span>
                  </button>
                  <button
                    type="button"
                    className={mode === "futsal" ? "active" : ""}
                    onClick={() => changeMode("futsal")}
                  >
                    <span className="mode-selector-icon">◉</span>
                    <span><strong>Futsal</strong><small>5 titulares</small></span>
                  </button>
                </div>
              </div>
            </section>

            <section className="setup-section">
              <div className="setup-section-heading">
                <span className="setup-step">02</span>
                <div>
                  <h2>Regras do leilão</h2>
                  <p>O leilão funciona igual ao modo normal antes do mata-mata.</p>
                </div>
              </div>

              <div className="setup-grid-two">
                <label className="setup-field">
                  <span>Orçamento por pessoa</span>
                  <select className="input setup-input" value={budget} onChange={(e) => setBudget(e.target.value)}>
                    {[50, 100, 150, 200, 500].map((value) => (
                      <option key={value} value={value}>{value} créditos</option>
                    ))}
                  </select>
                </label>

                <label className="setup-field">
                  <span>Reservas</span>
                  <select
                    className="input setup-input"
                    value={reserveCount}
                    onChange={(e) => setReserveCount(Number(e.target.value))}
                  >
                    {[0, 1, 2, 3, 4, 5].map((value) => (
                      <option key={value} value={value}>{value}</option>
                    ))}
                  </select>
                </label>

                <label className="setup-field">
                  <span>GER mínimo</span>
                  <input
                    className="input setup-input"
                    type="number"
                    min={1}
                    max={100}
                    value={minOverall}
                    onChange={(e) => setMinOverall(Number(e.target.value))}
                  />
                </label>

                <label className="setup-field">
                  <span>GER máximo</span>
                  <input
                    className="input setup-input"
                    type="number"
                    min={1}
                    max={100}
                    value={maxOverall}
                    onChange={(e) => setMaxOverall(Number(e.target.value))}
                  />
                </label>

                <label className="setup-field">
                  <span>Quando alguém desconectar</span>
                  <select
                    className="input setup-input"
                    value={disconnectMode}
                    onChange={(e) => setDisconnectMode(e.target.value as "skip" | "bot")}
                  >
                    <option value="skip">Continuar sem o jogador</option>
                    <option value="bot">BOT conservador assume</option>
                  </select>
                </label>

                <label className="setup-field">
                  <span>Senha opcional</span>
                  <input
                    className="input setup-input"
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Sala aberta se ficar vazio"
                    maxLength={32}
                  />
                </label>
              </div>

              <div className="setup-toggle-grid">
                <label className="setup-toggle-card">
                  <input type="checkbox" checked={allowBase} onChange={(e) => setAllowBase(e.target.checked)} />
                  <span className="setup-toggle-copy"><strong>BASE</strong><small>Cartas normais do catálogo.</small></span>
                  <span className="setup-switch" />
                </label>

                <label className="setup-toggle-card">
                  <input type="checkbox" checked={allowIcons} onChange={(e) => setAllowIcons(e.target.checked)} />
                  <span className="setup-toggle-copy"><strong>ICONS</strong><small>Lendas podem aparecer.</small></span>
                  <span className="setup-switch" />
                </label>

                <label className="setup-toggle-card">
                  <input type="checkbox" checked={allowSpecials} onChange={(e) => setAllowSpecials(e.target.checked)} />
                  <span className="setup-toggle-copy"><strong>SPECIALS</strong><small>Versões históricas especiais.</small></span>
                  <span className="setup-switch" />
                </label>

                <label className="setup-toggle-card">
                  <input
                    type="checkbox"
                    checked={spectatorsAllowed}
                    onChange={(e) => setSpectatorsAllowed(e.target.checked)}
                  />
                  <span className="setup-toggle-copy"><strong>Espectadores</strong><small>Podem assistir e conversar no chat.</small></span>
                  <span className="setup-switch" />
                </label>
              </div>
            </section>

            <section className="setup-section">
              <div className="setup-section-heading">
                <span className="setup-step">03</span>
                <div>
                  <h2>Filtro de ligas</h2>
                  <p>Sem seleção, todas ficam liberadas.</p>
                </div>
              </div>

              <LeagueMultiSelect
                options={leagues}
                selected={selectedLeagues}
                onChange={setSelectedLeagues}
              />
            </section>

            {error && (
              <div className="setup-error">
                <strong>Não foi possível criar o torneio</strong>
                <span>{error}</span>
              </div>
            )}
          </div>

          <aside className="setup-summary-card">
            <span className="setup-summary-kicker">RESUMO DO TORNEIO</span>
            <h2>{name.trim() || "Seu torneio"}</h2>

            <div className="setup-summary-list">
              <div><span>Chave</span><strong>Até {tournamentSize}</strong></div>
              <div><span>Modalidade</span><strong>{mode === "football" ? "Campo" : "Futsal"}</strong></div>
              <div><span>Orçamento</span><strong>{budget} créditos</strong></div>
              <div><span>Reservas</span><strong>{reserveCount}</strong></div>
              <div><span>GER</span><strong>{minOverall}–{maxOverall}</strong></div>
              <div><span>Ligas</span><strong>{selectedLeagueCount || "Todas"}</strong></div>
            </div>

            <div className="setup-summary-tags">
              <span>🏆 MATA-MATA</span>
              {allowBase && <span>BASE</span>}
              {allowIcons && <span>★ ICONS</span>}
              {allowSpecials && <span>SPECIALS</span>}
              {disconnectMode === "bot" && <span>BOT</span>}
            </div>

            <button
              className="btn btn-primary setup-create-button"
              onClick={() => void createTournament()}
              disabled={loading || minOverall > maxOverall}
            >
              {loading ? "Criando torneio..." : "Criar torneio"}
            </button>

            <small>
              Depois que todos finalizarem os times, a chave é criada automaticamente.
            </small>
          </aside>
        </div>
      </div>
    </main>
  );
}
