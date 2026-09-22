"use client";

import { useEffect, useMemo, useRef, useState } from "react";

export type LeagueOption = {
  name: string;
  count?: number;
};

const leagueVisuals: Record<string, { mark: string; flag: string }> = {
  "Brasileirão": { mark: "BR", flag: "🇧🇷" },
  "Bundesliga": { mark: "BUN", flag: "🇩🇪" },
  "La Liga": { mark: "LL", flag: "🇪🇸" },
  "LALIGA EA SPORTS": { mark: "LL", flag: "🇪🇸" },
  "LEGENDS": { mark: "★", flag: "🏆" },
  "Liga Portugal": { mark: "LP", flag: "🇵🇹" },
  "Ligue 1": { mark: "L1", flag: "🇫🇷" },
  "Ligue 1 McDonald's": { mark: "L1", flag: "🇫🇷" },
  "MLS": { mark: "MLS", flag: "🇺🇸" },
  "Premier League": { mark: "PL", flag: "🏴" },
  "Serie A": { mark: "SA", flag: "🇮🇹" },
  "Serie A Enilive": { mark: "SA", flag: "🇮🇹" },
  "Trendyol Süper Lig": { mark: "TSL", flag: "🇹🇷" },
};

function visualForLeague(name: string) {
  return leagueVisuals[name] || {
    mark: name
      .split(/\s+/)
      .map((part) => part[0])
      .join("")
      .slice(0, 3)
      .toUpperCase(),
    flag: "⚽",
  };
}

function LeagueMark({ name, compact = false }: { name: string; compact?: boolean }) {
  const visual = visualForLeague(name);

  return (
    <span className={`league-mark ${compact ? "compact" : ""}`} aria-hidden="true">
      <span className="league-mark-flag">{visual.flag}</span>
      <strong>{visual.mark}</strong>
    </span>
  );
}

export default function LeagueMultiSelect({
  options,
  selected,
  onChange,
}: {
  options: LeagueOption[];
  selected: string[];
  onChange: (next: string[]) => void;
}) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const rootRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    function onPointerDown(event: MouseEvent) {
      if (!rootRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    }

    document.addEventListener("mousedown", onPointerDown);
    return () => document.removeEventListener("mousedown", onPointerDown);
  }, []);

  const filtered = useMemo(() => {
    const normalized = query.trim().toLocaleLowerCase("pt-BR");
    if (!normalized) return options;

    return options.filter((option) =>
      option.name.toLocaleLowerCase("pt-BR").includes(normalized),
    );
  }, [options, query]);

  const selectedSet = useMemo(() => new Set(selected), [selected]);

  function toggle(name: string) {
    if (selectedSet.has(name)) {
      onChange(selected.filter((league) => league !== name));
    } else {
      onChange([...selected, name]);
    }
  }

  function selectAllVisible() {
    const next = new Set(selected);
    filtered.forEach((option) => next.add(option.name));
    onChange(Array.from(next));
  }

  return (
    <div className="league-picker" ref={rootRef}>
      <button
        type="button"
        className={`league-picker-trigger ${open ? "open" : ""}`}
        onClick={() => setOpen((value) => !value)}
        aria-expanded={open}
      >
        <div>
          <span className="league-picker-kicker">LIGAS PERMITIDAS</span>
          <strong>
            {selected.length === 0
              ? "Todas as ligas"
              : selected.length === 1
                ? selected[0]
                : `${selected.length} ligas selecionadas`}
          </strong>
        </div>

        <span className="league-picker-chevron">{open ? "▲" : "▼"}</span>
      </button>

      {selected.length > 0 && (
        <div className="league-chip-list">
          {selected.map((league) => (
            <button
              type="button"
              key={league}
              className="league-chip"
              onClick={() => toggle(league)}
              title={`Remover ${league}`}
            >
              <LeagueMark name={league} compact />
              <span>{league}</span>
              <b aria-hidden="true">×</b>
            </button>
          ))}
        </div>
      )}

      {open && (
        <div className="league-picker-popover">
          <div className="league-picker-toolbar">
            <div className="league-search-wrap">
              <span aria-hidden="true">⌕</span>
              <input
                autoFocus
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Buscar liga..."
                aria-label="Buscar liga"
              />
            </div>

            <div className="league-picker-actions">
              <button type="button" onClick={selectAllVisible}>
                Selecionar todas
              </button>
              <button type="button" onClick={() => onChange([])}>
                Limpar
              </button>
            </div>
          </div>

          <div className="league-option-list">
            {filtered.length === 0 && (
              <div className="league-empty">Nenhuma liga encontrada.</div>
            )}

            {filtered.map((option) => {
              const checked = selectedSet.has(option.name);

              return (
                <button
                  type="button"
                  key={option.name}
                  className={`league-option ${checked ? "selected" : ""}`}
                  onClick={() => toggle(option.name)}
                >
                  <LeagueMark name={option.name} />

                  <span className="league-option-copy">
                    <strong>{option.name}</strong>
                    {typeof option.count === "number" && (
                      <small>{option.count} jogador{option.count === 1 ? "" : "es"} no catálogo</small>
                    )}
                  </span>

                  <span className={`league-check ${checked ? "checked" : ""}`}>
                    {checked ? "✓" : ""}
                  </span>
                </button>
              );
            })}
          </div>

          <div className="league-picker-footer">
            <span>
              {selected.length === 0
                ? "Nenhuma selecionada = todas entram no sorteio"
                : `${selected.length} selecionada${selected.length === 1 ? "" : "s"}`}
            </span>
            <button type="button" className="btn btn-primary" onClick={() => setOpen(false)}>
              Concluir
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
