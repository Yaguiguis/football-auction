export type GameMode = "football" | "futsal";

export type BoardSlot = {
  key: string;
  label: string;
  x: number;
  y: number;
};

export type RatedPlayer = {
  id: string;
  name: string;
  primary_position: string;
  overall: number;
  image_url?: string | null;
};

export const footballBoard: BoardSlot[] = [
  { key: "GOL", label: "GOL", x: 50, y: 91 },
  { key: "LE", label: "LE", x: 14, y: 72 },
  { key: "ZAG1", label: "ZAG E", x: 37, y: 76 },
  { key: "ZAG2", label: "ZAG D", x: 63, y: 76 },
  { key: "LD", label: "LD", x: 86, y: 72 },
  { key: "VOL", label: "VOL", x: 50, y: 58 },
  { key: "MC", label: "MC", x: 30, y: 44 },
  { key: "MEI", label: "MEI", x: 70, y: 44 },
  { key: "PE", label: "PE", x: 18, y: 22 },
  { key: "ATA", label: "ATA", x: 50, y: 15 },
  { key: "PD", label: "PD", x: 82, y: 22 },
];

export const futsalBoard: BoardSlot[] = [
  { key: "GOL", label: "GOL", x: 50, y: 89 },
  { key: "FIXO", label: "FIXO", x: 50, y: 66 },
  { key: "ALAE", label: "ALA E", x: 24, y: 43 },
  { key: "ALAD", label: "ALA D", x: 76, y: 43 },
  { key: "PIVO", label: "PIVÔ", x: 50, y: 18 },
];

export function boardForMode(mode: GameMode) {
  return mode === "futsal" ? futsalBoard : footballBoard;
}

export function positionGroup(position: string) {
  const pos = position.toUpperCase().trim();
  if (pos === "MD") return "PD";
  if (pos === "ME") return "PE";
  if (pos === "SA") return "ATA";
  return pos;
}

function fieldPenalty(position: string, slot: string) {
  const pos = positionGroup(position);
  const natural =
    (pos === "ZAG" && (slot === "ZAG1" || slot === "ZAG2")) ||
    pos === slot;
  if (natural) return 0;

  const defensive = new Set(["LD", "LE", "ZAG", "VOL"]);
  const midfield = new Set(["VOL", "MC", "MEI"]);
  const attacking = new Set(["MEI", "PD", "PE", "ATA"]);
  const slotGroup = slot.startsWith("ZAG") ? "ZAG" : slot;

  if (defensive.has(pos) && defensive.has(slotGroup)) return 2;
  if (midfield.has(pos) && midfield.has(slotGroup)) return 2;
  if (attacking.has(pos) && attacking.has(slotGroup)) return 2;
  if ((pos === "PD" && slot === "PE") || (pos === "PE" && slot === "PD")) return 2;
  return 4;
}

function futsalPenalty(position: string, slot: string) {
  const pos = positionGroup(position);
  if (slot === "GOL") return pos === "GOL" ? 0 : 12;
  if (pos === "GOL") return 12;

  if (slot === "FIXO") {
    if (["ZAG", "VOL", "LD", "LE", "MC"].includes(pos)) return 0;
    if (["MEI", "PD", "PE"].includes(pos)) return 2;
    return 3;
  }
  if (slot === "ALAE") {
    if (["PE", "LE", "MC", "MEI"].includes(pos)) return 0;
    if (["PD", "LD", "VOL"].includes(pos)) return 2;
    return 3;
  }
  if (slot === "ALAD") {
    if (["PD", "LD", "MC", "MEI"].includes(pos)) return 0;
    if (["PE", "LE", "VOL"].includes(pos)) return 2;
    return 3;
  }
  if (slot === "PIVO") {
    if (["ATA", "MEI"].includes(pos)) return 0;
    if (["PD", "PE", "MC"].includes(pos)) return 2;
    return 4;
  }
  return 4;
}

export function positionPenalty(position: string, slot: string, mode: GameMode) {
  return mode === "futsal" ? futsalPenalty(position, slot) : fieldPenalty(position, slot);
}

export function effectiveGer(player: RatedPlayer, slot: string, mode: GameMode) {
  return Math.max(1, player.overall - positionPenalty(player.primary_position, slot, mode));
}

export function squadGer(
  squad: { player_id: string; slot_key: string }[],
  playersById: Map<string, RatedPlayer>,
  mode: GameMode,
) {
  const ratings = squad
    .map((row) => {
      const player = playersById.get(row.player_id);
      return player ? effectiveGer(player, row.slot_key, mode) : null;
    })
    .filter((value): value is number => value !== null);

  if (!ratings.length) return 0;
  return Math.round(ratings.reduce((sum, value) => sum + value, 0) / ratings.length);
}
