"use client";

import { useMemo } from "react";

export type LeagueOption = {
  name: string;
  count?: number;
};

type LeagueVisual = {
  label: string;
  short: string;
  country: string;
  variant: string;
};

const leagueAliases: Record<string, string> = {
  "LALIGA EA SPORTS": "La Liga",
  "Ligue 1 McDonald's": "Ligue 1",
  "Serie A Enilive": "Serie A",
};

const leagueVisuals: Record<string, LeagueVisual> = {
  "Brasileirão": { label: "Brasileirão", short: "BR", country: "BR", variant: "brasileirao" },
  "Bundesliga": { label: "Bundesliga", short: "B", country: "DE", variant: "bundesliga" },
  "La Liga": { label: "La Liga", short: "LL", country: "ES", variant: "laliga" },
  "LEGENDS": { label: "Lendas", short: "★", country: "ICON", variant: "legends" },
  "Liga Portugal": { label: "Liga Portugal", short: "LP", country: "PT", variant: "portugal" },
  "Ligue 1": { label: "Ligue 1", short: "L1", country: "FR", variant: "ligue1" },
  "MLS": { label: "MLS", short: "MLS", country: "US", variant: "mls" },
  "Premier League": { label: "Premier League", short: "PL", country: "EN", variant: "premier" },
  "Serie A": { label: "Serie A", short: "A", country: "IT", variant: "seriea" },
  "Trendyol Süper Lig": { label: "Süper Lig", short: "SL", country: "TR", variant: "superlig" },
};

function canonicalLeague(name: string) {
  return leagueAliases[name] || name;
}

function visualForLeague(name: string): LeagueVisual {
  const canonical = canonicalLeague(name);
  return (
    leagueVisuals[canonical] || {
      label: canonical,
      short: canonical
        .split(/\s+/)
        .map((part) => part[0])
        .join("")
        .slice(0, 3)
        .toUpperCase(),
      country: "⚽",
      variant: "generic",
    }
  );
}

function LeagueLogo({ name }: { name: string }) {
  const visual = visualForLeague(name);

  return (
    <span className={`league-logo league-logo-${visual.variant}`} aria-hidden="true">
      <span className="league-logo-inner">
        <strong>{visual.short}</strong>
        <small>{visual.country}</small>
      </span>
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
  const groups = useMemo(() => {
    const map = new Map<
      string,
      { canonical: string; values: string[]; count: number; visual: LeagueVisual }
    >();

    for (const option of options) {
      const canonical = canonicalLeague(option.name);
      const current = map.get(canonical);

      if (current) {
        current.values.push(option.name);
        current.count += option.count || 0;
      } else {
        map.set(canonical, {
          canonical,
          values: [option.name],
          count: option.count || 0,
          visual: visualForLeague(canonical),
        });
      }
    }

    return Array.from(map.values()).sort((a, b) =>
      a.visual.label.localeCompare(b.visual.label, "pt-BR"),
    );
  }, [options]);

  const selectedSet = useMemo(() => new Set(selected), [selected]);

  const selectedGroups = useMemo(
    () =>
      groups.filter((group) =>
        group.values.some((value) => selectedSet.has(value)),
      ),
    [groups, selectedSet],
  );

  function isSelected(values: string[]) {
    return values.some((value) => selectedSet.has(value));
  }

  function toggleGroup(values: string[]) {
    const active = isSelected(values);
    const next = new Set(selected);

    for (const value of values) {
      if (active) next.delete(value);
      else next.add(value);
    }

    onChange(Array.from(next));
  }

  function selectAll() {
    onChange(options.map((option) => option.name));
  }

  return (
    <div className="league-grid-picker">
      <div className="league-grid-toolbar">
        <div>
          <span className="league-grid-kicker">LIGAS PERMITIDAS</span>
          <strong>
            {selectedGroups.length === 0
              ? "Todas as ligas estão liberadas"
              : `${selectedGroups.length} liga${selectedGroups.length === 1 ? "" : "s"} selecionada${selectedGroups.length === 1 ? "" : "s"}`}
          </strong>
        </div>

        <div className="league-grid-actions">
          <button type="button" onClick={selectAll}>Todas</button>
          <button type="button" onClick={() => onChange([])}>Limpar</button>
        </div>
      </div>

      <div className="league-logo-grid">
        {groups.map((group) => {
          const active = isSelected(group.values);

          return (
            <button
              type="button"
              key={group.canonical}
              className={`league-logo-card ${active ? "selected" : ""}`}
              onClick={() => toggleGroup(group.values)}
              aria-pressed={active}
            >
              <span className={`league-select-check ${active ? "checked" : ""}`}>
                {active ? "✓" : ""}
              </span>

              <LeagueLogo name={group.canonical} />

              <span className="league-logo-copy">
                <strong>{group.visual.label}</strong>
                <small>{group.count} jogador{group.count === 1 ? "" : "es"}</small>
              </span>
            </button>
          );
        })}
      </div>

      <div className="league-grid-hint">
        <span>✓</span>
        <p>
          Você pode marcar quantas quiser. Se nenhuma ficar marcada, o sorteio usa todas as ligas.
        </p>
      </div>
    </div>
  );
}
