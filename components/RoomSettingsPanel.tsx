"use client";

import { useEffect, useMemo, useState } from "react";
import LeagueMultiSelect, { type LeagueOption } from "./LeagueMultiSelect";
import { getSupabase } from "../lib/supabase";

export type RoomSettingsRoom = {
  id: string;
  mode: "football" | "futsal";
  budget: number;
  reserve_count: number;
  allow_icons: boolean;
  allow_base: boolean;
  allow_specials: boolean;
  min_overall: number;
  max_overall: number;
  active_only: boolean;
  allowed_leagues: string[] | null;
  disconnect_mode: "skip" | "bot";
  spectators_allowed: boolean;
  room_kind: "auction" | "tournament" | "cases";
  tournament_size: 4 | 8 | 16 | null;
  status: string;
};

type Draft = {
  roomKind: "auction" | "tournament" | "cases";
  mode: "football" | "futsal";
  budget: number;
  reserveCount: number;
  allowIcons: boolean;
  allowBase: boolean;
  allowSpecials: boolean;
  minOverall: number;
  maxOverall: number;
  activeOnly: boolean;
  allowedLeagues: string[];
  disconnectMode: "skip" | "bot";
  spectatorsAllowed: boolean;
  tournamentSize: 4 | 8 | 16;
  passwordAction: "keep" | "set" | "clear";
  password: string;
};

function draftFromRoom(room: RoomSettingsRoom): Draft {
  return {
    roomKind: room.room_kind,
    mode: room.mode,
    budget: room.budget,
    reserveCount: room.reserve_count,
    allowIcons: room.allow_icons,
    allowBase: room.allow_base,
    allowSpecials: room.allow_specials,
    minOverall: room.min_overall,
    maxOverall: room.max_overall,
    activeOnly: room.active_only,
    allowedLeagues: room.allowed_leagues || [],
    disconnectMode: room.disconnect_mode,
    spectatorsAllowed: room.spectators_allowed,
    tournamentSize: room.tournament_size || 8,
    passwordAction: "keep",
    password: "",
  };
}

function modeName(kind: Draft["roomKind"]) {
  if (kind === "cases") return "Maletas";
  if (kind === "tournament") return "Torneio";
  return "Leilão";
}

function gameName(mode: Draft["mode"]) {
  return mode === "futsal" ? "Futsal" : "Futebol de campo";
}

export default function RoomSettingsPanel({
  room,
  isHost,
  participantCount,
  onSaved,
}: {
  room: RoomSettingsRoom;
  isHost: boolean;
  participantCount: number;
  onSaved: () => Promise<void> | void;
}) {
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [confirming, setConfirming] = useState(false);
  const [draft, setDraft] = useState<Draft>(() => draftFromRoom(room));
  const [leagueOptions, setLeagueOptions] = useState<LeagueOption[]>([]);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");

  useEffect(() => {
    if (!editing) setDraft(draftFromRoom(room));
  }, [room, editing]);

  useEffect(() => {
    let alive = true;

    void (async () => {
      const { data, error: catalogError } = await getSupabase()
        .from("fa_catalog_players")
        .select("league")
        .eq("enabled", true)
        .limit(5000);

      if (catalogError || !alive) return;

      const counts = new Map<string, number>();
      for (const row of data || []) {
        const league = String(row.league || "").trim();
        if (!league) continue;
        counts.set(league, (counts.get(league) || 0) + 1);
      }

      setLeagueOptions(
        Array.from(counts.entries())
          .map(([name, count]) => ({ name, count }))
          .sort((a, b) => a.name.localeCompare(b.name, "pt-BR")),
      );
    })();

    return () => {
      alive = false;
    };
  }, []);

  const canEdit = isHost && room.status !== "auction";

  const structuralChange = useMemo(
    () =>
      draft.roomKind !== room.room_kind ||
      draft.mode !== room.mode ||
      draft.reserveCount !== room.reserve_count ||
      draft.budget !== room.budget ||
      draft.allowBase !== room.allow_base ||
      draft.allowIcons !== room.allow_icons ||
      draft.allowSpecials !== room.allow_specials ||
      draft.minOverall !== room.min_overall ||
      draft.maxOverall !== room.max_overall ||
      draft.activeOnly !== room.active_only ||
      draft.disconnectMode !== room.disconnect_mode ||
      draft.spectatorsAllowed !== room.spectators_allowed ||
      (draft.roomKind === "tournament" &&
        draft.tournamentSize !== (room.tournament_size || 8)) ||
      JSON.stringify([...draft.allowedLeagues].sort()) !==
        JSON.stringify([...(room.allowed_leagues || [])].sort()) ||
      draft.passwordAction !== "keep",
    [draft, room],
  );

  function update<K extends keyof Draft>(key: K, value: Draft[K]) {
    setDraft((current) => ({ ...current, [key]: value }));
  }

  function chooseActiveOnly(enabled: boolean) {
    if (enabled) {
      setDraft((current) => ({
        ...current,
        activeOnly: true,
        allowBase: true,
        allowIcons: false,
        allowSpecials: false,
      }));
    } else {
      update("activeOnly", false);
    }
  }

  function requestSave() {
    setError("");

    if (!draft.allowBase && !draft.allowIcons && !draft.allowSpecials) {
      setError("Ative pelo menos um tipo de carta.");
      return;
    }

    if (draft.minOverall < 1 || draft.maxOverall > 100 || draft.minOverall > draft.maxOverall) {
      setError("Confira a faixa de GER.");
      return;
    }

    if (draft.reserveCount < 0 || draft.reserveCount > 5) {
      setError("As reservas devem ficar entre 0 e 5.");
      return;
    }

    if (draft.roomKind === "tournament" && participantCount > draft.tournamentSize) {
      setError(
        `A chave de ${draft.tournamentSize} é menor que os ${participantCount} jogadores atuais.`,
      );
      return;
    }

    if (draft.passwordAction === "set" && !draft.password.trim()) {
      setError("Digite a nova senha da sala.");
      return;
    }

    if (room.status !== "lobby") {
      setConfirming(true);
      return;
    }

    void save();
  }

  async function save() {
    if (saving) return;

    setSaving(true);
    setError("");
    setNotice("");

    try {
      const { data, error: rpcError } = await getSupabase().rpc("fa_reconfigure_room", {
        p_room_id: room.id,
        p_room_kind: draft.roomKind,
        p_mode: draft.mode,
        p_budget: Math.trunc(draft.budget),
        p_reserve_count: draft.reserveCount,
        p_allow_icons: draft.allowIcons,
        p_allow_base: draft.allowBase,
        p_allow_specials: draft.allowSpecials,
        p_min_overall: draft.minOverall,
        p_max_overall: draft.maxOverall,
        p_active_only: draft.activeOnly,
        p_allowed_leagues: draft.allowedLeagues.length ? draft.allowedLeagues : null,
        p_disconnect_mode: draft.disconnectMode,
        p_spectators_allowed: draft.spectatorsAllowed,
        p_tournament_size: draft.roomKind === "tournament" ? draft.tournamentSize : null,
        p_password_action: draft.passwordAction,
        p_password: draft.passwordAction === "set" ? draft.password : null,
      });

      if (rpcError) throw rpcError;

      const result = data as { progress_reset?: boolean } | null;

      setConfirming(false);
      setEditing(false);
      setNotice(
        result?.progress_reset
          ? "Configurações salvas. A rodada anterior foi arquivada; código, participantes e chat foram mantidos."
          : "Configurações da sala atualizadas.",
      );

      await onSaved();
    } catch (saveError) {
      setConfirming(false);
      setError(
        saveError &&
          typeof saveError === "object" &&
          "message" in saveError
          ? String(saveError.message)
          : "Não foi possível salvar as configurações.",
      );
    } finally {
      setSaving(false);
    }
  }

  if (!editing) {
    return (
      <section className="card room-config-card">
        <div className="room-config-header">
          <div>
            <span className="room-config-kicker">PAINEL DA SALA</span>
            <h2>Configuração</h2>
            <p>Regras atuais da próxima partida.</p>
          </div>

          {canEdit && (
            <button
              className="btn btn-primary"
              type="button"
              onClick={() => {
                setDraft(draftFromRoom(room));
                setError("");
                setEditing(true);
              }}
            >
              Editar configurações
            </button>
          )}
        </div>

        {notice && <div className="room-config-notice">✓ {notice}</div>}

        <div className="room-config-summary-grid">
          <div className="room-config-summary-item accent">
            <small>MODO</small>
            <strong>{modeName(room.room_kind)}</strong>
          </div>
          <div className="room-config-summary-item">
            <small>MODALIDADE</small>
            <strong>{gameName(room.mode)}</strong>
          </div>
          <div className="room-config-summary-item">
            <small>RESERVAS</small>
            <strong>{room.reserve_count}</strong>
          </div>
          <div className="room-config-summary-item">
            <small>GER</small>
            <strong>{room.min_overall}–{room.max_overall}</strong>
          </div>
          {room.room_kind !== "cases" && (
            <div className="room-config-summary-item">
              <small>ORÇAMENTO</small>
              <strong>{room.budget} cr</strong>
            </div>
          )}
          {room.room_kind === "tournament" && (
            <div className="room-config-summary-item">
              <small>CHAVE</small>
              <strong>Até {room.tournament_size}</strong>
            </div>
          )}
        </div>

        <div className="room-config-pills">
          <span className={room.allow_base ? "on" : "off"}>BASE</span>
          <span className={room.allow_icons ? "on" : "off"}>ICONS</span>
          <span className={room.allow_specials ? "on" : "off"}>SPECIALS</span>
          {room.active_only && <span className="on">SÓ ATIVOS</span>}
          <span className="neutral">
            {room.disconnect_mode === "bot" ? "BOT na desconexão" : "Continuar sem offline"}
          </span>
          <span className="neutral">
            {room.spectators_allowed ? "Espectadores permitidos" : "Sem espectadores"}
          </span>
        </div>

        <div className="room-config-leagues">
          <small>LIGAS PERMITIDAS</small>
          <strong>
            {room.allowed_leagues?.length ? room.allowed_leagues.join(" • ") : "Todas as ligas"}
          </strong>
        </div>

        {!canEdit && isHost && room.status === "auction" && (
          <p className="muted room-config-lock">
            Termine a partida atual para alterar as regras da sala.
          </p>
        )}
      </section>
    );
  }

  return (
    <>
      <section className="card room-config-card room-config-editing">
        <div className="room-config-header">
          <div>
            <span className="room-config-kicker">EDITAR SALA</span>
            <h2>Configurações completas</h2>
            <p>O código da sala e o chat não mudam.</p>
          </div>

          <button
            className="btn btn-secondary"
            type="button"
            disabled={saving}
            onClick={() => {
              setEditing(false);
              setError("");
            }}
          >
            Cancelar
          </button>
        </div>

        <div className="room-settings-section">
          <div className="room-settings-title">
            <span>01</span>
            <div>
              <strong>Modo de jogo</strong>
              <small>Você pode reaproveitar a mesma sala em outro modo.</small>
            </div>
          </div>

          <div className="room-kind-selector">
            {([
              ["auction", "🔨", "Leilão", "Disputa por lances"],
              ["cases", "▣", "Maletas", "Escolha às cegas"],
              ["tournament", "🏆", "Torneio", "Leilão + mata-mata"],
            ] as const).map(([kind, icon, title, description]) => (
              <button
                key={kind}
                type="button"
                className={draft.roomKind === kind ? "active" : ""}
                onClick={() => update("roomKind", kind)}
              >
                <span>{icon}</span>
                <strong>{title}</strong>
                <small>{description}</small>
              </button>
            ))}
          </div>

          {draft.roomKind === "tournament" && (
            <div className="room-config-field">
              <span>Tamanho da chave</span>
              <div className="room-tournament-size">
                {([4, 8, 16] as const).map((size) => (
                  <button
                    key={size}
                    type="button"
                    className={draft.tournamentSize === size ? "active" : ""}
                    onClick={() => update("tournamentSize", size)}
                  >
                    {size}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="room-settings-section">
          <div className="room-settings-title">
            <span>02</span>
            <div>
              <strong>Formato do elenco</strong>
              <small>Modalidade, banco e orçamento.</small>
            </div>
          </div>

          <div className="room-mode-selector">
            <button
              type="button"
              className={draft.mode === "football" ? "active" : ""}
              onClick={() => update("mode", "football")}
            >
              ⚽ <strong>Campo</strong>
              <small>11 titulares</small>
            </button>
            <button
              type="button"
              className={draft.mode === "futsal" ? "active" : ""}
              onClick={() => update("mode", "futsal")}
            >
              ◉ <strong>Futsal</strong>
              <small>5 titulares</small>
            </button>
          </div>

          <div className="room-config-form-grid">
            <label className="room-config-field">
              <span>Reservas</span>
              <select
                className="input"
                value={draft.reserveCount}
                onChange={(event) => update("reserveCount", Number(event.target.value))}
              >
                {[0, 1, 2, 3, 4, 5].map((value) => (
                  <option key={value} value={value}>{value}</option>
                ))}
              </select>
            </label>

            <label className="room-config-field">
              <span>Orçamento por pessoa</span>
              <input
                className="input"
                type="number"
                min={1}
                max={100000}
                value={draft.budget}
                onChange={(event) => update("budget", Number(event.target.value))}
              />
              {draft.roomKind === "cases" && (
                <small>Fica salvo caso você volte para Leilão/Torneio.</small>
              )}
            </label>

            <label className="room-config-field">
              <span>GER mínimo</span>
              <input
                className="input"
                type="number"
                min={1}
                max={100}
                value={draft.minOverall}
                onChange={(event) => update("minOverall", Number(event.target.value))}
              />
            </label>

            <label className="room-config-field">
              <span>GER máximo</span>
              <input
                className="input"
                type="number"
                min={1}
                max={100}
                value={draft.maxOverall}
                onChange={(event) => update("maxOverall", Number(event.target.value))}
              />
            </label>
          </div>
        </div>

        <div className="room-settings-section">
          <div className="room-settings-title">
            <span>03</span>
            <div>
              <strong>Cartas e sala</strong>
              <small>Escolha o que pode aparecer e como a sala se comporta.</small>
            </div>
          </div>

          <div className="room-config-toggle-grid">
            <label>
              <input
                type="checkbox"
                checked={draft.allowBase}
                disabled={draft.activeOnly}
                onChange={(event) => update("allowBase", event.target.checked)}
              />
              <span><strong>BASE</strong><small>Cartas normais</small></span>
            </label>

            <label>
              <input
                type="checkbox"
                checked={draft.allowIcons}
                disabled={draft.activeOnly}
                onChange={(event) => update("allowIcons", event.target.checked)}
              />
              <span><strong>ICONS</strong><small>Lendas</small></span>
            </label>

            <label>
              <input
                type="checkbox"
                checked={draft.allowSpecials}
                disabled={draft.activeOnly}
                onChange={(event) => update("allowSpecials", event.target.checked)}
              />
              <span><strong>SPECIALS</strong><small>Versões históricas</small></span>
            </label>

            <label>
              <input
                type="checkbox"
                checked={draft.activeOnly}
                onChange={(event) => chooseActiveOnly(event.target.checked)}
              />
              <span><strong>Somente ativos</strong><small>Sem ICON/SPECIAL</small></span>
            </label>

            <label>
              <input
                type="checkbox"
                checked={draft.spectatorsAllowed}
                onChange={(event) => update("spectatorsAllowed", event.target.checked)}
              />
              <span><strong>Espectadores</strong><small>Permitir assistência</small></span>
            </label>
          </div>

          <div className="room-config-form-grid">
            <label className="room-config-field">
              <span>Quando alguém desconectar</span>
              <select
                className="input"
                value={draft.disconnectMode}
                onChange={(event) =>
                  update("disconnectMode", event.target.value as "skip" | "bot")
                }
              >
                <option value="skip">Continuar sem ele</option>
                <option value="bot">BOT conservador assume</option>
              </select>
            </label>

            <label className="room-config-field">
              <span>Senha da sala</span>
              <select
                className="input"
                value={draft.passwordAction}
                onChange={(event) =>
                  update(
                    "passwordAction",
                    event.target.value as "keep" | "set" | "clear",
                  )
                }
              >
                <option value="keep">Manter como está</option>
                <option value="set">Definir nova senha</option>
                <option value="clear">Remover senha</option>
              </select>
            </label>

            {draft.passwordAction === "set" && (
              <label className="room-config-field room-config-field-wide">
                <span>Nova senha</span>
                <input
                  className="input"
                  type="password"
                  maxLength={32}
                  value={draft.password}
                  onChange={(event) => update("password", event.target.value)}
                  placeholder="Até 32 caracteres"
                />
              </label>
            )}
          </div>
        </div>

        <div className="room-settings-section">
          <div className="room-settings-title">
            <span>04</span>
            <div>
              <strong>Ligas permitidas</strong>
              <small>Deixe tudo desmarcado para liberar o catálogo inteiro.</small>
            </div>
          </div>

          <LeagueMultiSelect
            options={leagueOptions}
            selected={draft.allowedLeagues}
            onChange={(next) => update("allowedLeagues", next)}
          />
        </div>

        {error && <div className="setup-error"><strong>Não foi possível salvar</strong><span>{error}</span></div>}

        <div className="room-config-savebar">
          <div>
            <strong>{modeName(draft.roomKind)} • {gameName(draft.mode)}</strong>
            <small>
              {structuralChange
                ? "Existem alterações prontas para salvar."
                : "Nenhuma alteração em relação à sala atual."}
            </small>
          </div>

          <button
            className="btn btn-primary"
            type="button"
            disabled={saving || !structuralChange}
            onClick={requestSave}
          >
            {saving ? "Salvando..." : "Salvar configurações"}
          </button>
        </div>
      </section>

      {confirming && (
        <div className="room-config-confirm-backdrop" role="dialog" aria-modal="true">
          <div className="room-config-confirm card">
            <span className="room-config-warning-icon">↻</span>
            <h2>Começar uma nova rodada nesta sala?</h2>
            <p>
              O progresso atual será arquivado e a sala volta ao lobby com as novas regras.
              <strong> O código, os participantes e o chat serão mantidos.</strong>
            </p>
            <div className="room-config-confirm-actions">
              <button
                className="btn btn-secondary"
                type="button"
                disabled={saving}
                onClick={() => setConfirming(false)}
              >
                Voltar
              </button>
              <button
                className="btn btn-primary"
                type="button"
                disabled={saving}
                onClick={() => void save()}
              >
                {saving ? "Aplicando..." : "Aplicar e voltar ao lobby"}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
