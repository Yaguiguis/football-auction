"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import LeagueMultiSelect, { type LeagueOption } from "../../components/LeagueMultiSelect";
import { ensureAnonymousSession, getSupabase } from "../../lib/supabase";

export default function CreateCasesRoomPage() {
  const router = useRouter();

  const [name, setName] = useState("");
  const [mode, setMode] = useState<"football" | "futsal">("futsal");
  const [reserveCount, setReserveCount] = useState(2);
  const [allowBase, setAllowBase] = useState(true);
  const [allowIcons, setAllowIcons] = useState(true);
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
          .limit(3000);

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
        // A criação continua mesmo se a lista visual de ligas falhar.
      }
    })();

    return () => {
      alive = false;
    };
  }, []);

  const selectedLeagueCount = useMemo(
    () => new Set(selectedLeagues).size,
    [selectedLeagues],
  );

  function changeMode(next: "football" | "futsal") {
    setMode(next);
    setReserveCount(next === "futsal" ? 2 : 5);
  }

  async function createRoom() {
    if (loading) return;

    setLoading(true);
    setError("");

    try {
      if (!allowBase && !allowIcons && !allowSpecials) {
        throw new Error("Selecione ao menos um tipo de carta.");
      }

      if (minOverall > maxOverall) {
        throw new Error("O GER mínimo não pode ser maior que o máximo.");
      }

      await ensureAnonymousSession();

      const { data, error: rpcError } = await getSupabase().rpc("fa_create_case_room", {
        p_display_name: name.trim() || "Administrador",
        p_mode: mode,
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
      if (!room?.room_code) throw new Error("A sala de maletas não foi criada.");

      router.push(`/sala/${room.room_code}/lobby`);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Erro ao criar a sala.");
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
          <span className="setup-eyebrow">▣ MODO MALETAS</span>
          <h1>Criar sala de maletas</h1>
          <p>
            O administrador escolhe a posição. Cada participante pega uma maleta às cegas
            e só descobre a carta depois da escolha.
          </p>
        </header>

        <div className="setup-layout">
          <div className="setup-main">
            <section className="setup-section">
              <div className="setup-section-heading">
                <span className="setup-step">01</span>
                <div>
                  <h2>Sala</h2>
                  <p>Defina a modalidade e quantos jogadores vão compor cada elenco.</p>
                </div>
              </div>

              <label className="setup-field">
                <span>Seu nome</span>
                <input
                  className="input setup-input"
                  value={name}
                  onChange={(event) => setName(event.target.value)}
                  placeholder="Ex.: Yago"
                  maxLength={24}
                />
              </label>

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

              <div className="setup-grid-two">
                <label className="setup-field">
                  <span>Reservas</span>
                  <select
                    className="input setup-input"
                    value={reserveCount}
                    onChange={(event) => setReserveCount(Number(event.target.value))}
                  >
                    {[0, 1, 2, 3, 4, 5].map((value) => (
                      <option key={value} value={value}>{value}</option>
                    ))}
                  </select>
                </label>

                <label className="setup-field">
                  <span>Quando alguém desconectar</span>
                  <select
                    className="input setup-input"
                    value={disconnectMode}
                    onChange={(event) => setDisconnectMode(event.target.value as "skip" | "bot")}
                  >
                    <option value="skip">Continuar a rodada</option>
                    <option value="bot">BOT assume quando possível</option>
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
                    onChange={(event) => setMinOverall(Number(event.target.value))}
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
                    onChange={(event) => setMaxOverall(Number(event.target.value))}
                  />
                </label>

                <label className="setup-field">
                  <span>Senha opcional</span>
                  <input
                    className="input setup-input"
                    type="password"
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                    placeholder="Sala aberta se ficar vazio"
                    maxLength={32}
                  />
                </label>
              </div>
            </section>

            <section className="setup-section">
              <div className="setup-section-heading">
                <span className="setup-step">02</span>
                <div>
                  <h2>Cartas nas maletas</h2>
                  <p>O conteúdo fica secreto no servidor até alguém escolher a maleta.</p>
                </div>
              </div>

              <div className="setup-toggle-grid">
                <label className="setup-toggle-card">
                  <input type="checkbox" checked={allowBase} onChange={(e) => setAllowBase(e.target.checked)} />
                  <span className="setup-toggle-copy"><strong>BASE</strong><small>Cartas normais.</small></span>
                  <span className="setup-switch" />
                </label>

                <label className="setup-toggle-card">
                  <input type="checkbox" checked={allowIcons} onChange={(e) => setAllowIcons(e.target.checked)} />
                  <span className="setup-toggle-copy"><strong>ICONS</strong><small>Lendas podem aparecer.</small></span>
                  <span className="setup-switch" />
                </label>

                <label className="setup-toggle-card">
                  <input type="checkbox" checked={allowSpecials} onChange={(e) => setAllowSpecials(e.target.checked)} />
                  <span className="setup-toggle-copy"><strong>SPECIALS</strong><small>Versões históricas.</small></span>
                  <span className="setup-switch" />
                </label>

                <label className="setup-toggle-card">
                  <input
                    type="checkbox"
                    checked={spectatorsAllowed}
                    onChange={(e) => setSpectatorsAllowed(e.target.checked)}
                  />
                  <span className="setup-toggle-copy"><strong>Espectadores</strong><small>Podem assistir às revelações.</small></span>
                  <span className="setup-switch" />
                </label>
              </div>
            </section>

            <section className="setup-section">
              <div className="setup-section-heading">
                <span className="setup-step">03</span>
                <div>
                  <h2>Ligas permitidas</h2>
                  <p>Se nenhuma for marcada, todas entram nas maletas.</p>
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
                <strong>Não foi possível criar a sala</strong>
                <span>{error}</span>
              </div>
            )}
          </div>

          <aside className="setup-summary-card">
            <span className="setup-summary-kicker">RESUMO DO MODO</span>
            <h2>{name.trim() || "Sua sala"}</h2>

            <div className="setup-summary-list">
              <div><span>Modo</span><strong>Maletas</strong></div>
              <div><span>Modalidade</span><strong>{mode === "football" ? "Campo" : "Futsal"}</strong></div>
              <div><span>Reservas</span><strong>{reserveCount}</strong></div>
              <div><span>GER</span><strong>{minOverall}–{maxOverall}</strong></div>
              <div><span>Ligas</span><strong>{selectedLeagueCount || "Todas"}</strong></div>
            </div>

            <div className="setup-summary-tags">
              <span>▣ ÀS CEGAS</span>
              {allowBase && <span>BASE</span>}
              {allowIcons && <span>★ ICONS</span>}
              {allowSpecials && <span>SPECIALS</span>}
            </div>

            <button
              className="btn btn-primary setup-create-button"
              onClick={() => void createRoom()}
              disabled={loading || minOverall > maxOverall}
            >
              {loading ? "Criando..." : "Criar sala de maletas"}
            </button>

            <small>
              Em cada rodada aparecem duas maletas extras além do número de participantes.
            </small>
          </aside>
        </div>
      </div>
    </main>
  );
}
