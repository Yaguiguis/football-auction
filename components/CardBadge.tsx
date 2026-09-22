export type CardIdentity = { player_type?: string; metadata?: { version_label?: string; season_year?: number } | null };
export function cardClass(player?: CardIdentity | null) {
  return player?.player_type === 'SPECIAL' ? 'special-card' : player?.player_type === 'ICON' ? 'icon-card-mini' : '';
}
export default function CardBadge({ player }: { player: CardIdentity }) {
  const type = player.player_type;
  if (type !== 'ICON' && type !== 'SPECIAL') return null;
  return <span className={`card-type-badge ${type === 'SPECIAL' ? 'special-badge' : 'icon-badge'}`}>
    {type === 'SPECIAL' ? '✦ SPECIAL' : '★ ICON'}
    {type === 'SPECIAL' && <span> {player.metadata?.version_label || player.metadata?.season_year || ''}</span>}
  </span>;
}
