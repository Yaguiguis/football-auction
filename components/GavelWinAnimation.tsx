export default function GavelWinAnimation({ auctionId }: { auctionId: string }) {
  return (
    <div key={auctionId} className="win-gavel-stage" aria-hidden="true">
      <svg viewBox="0 0 260 190" role="presentation" focusable="false">
        <defs>
          <linearGradient id={`winWood-${auctionId}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#35110c" />
            <stop offset="42%" stopColor="#8b3724" />
            <stop offset="68%" stopColor="#2a0d09" />
            <stop offset="100%" stopColor="#090302" />
          </linearGradient>
          <linearGradient id={`winMetal-${auctionId}`} x1="0" y1="0" x2="1" y2="0">
            <stop offset="0%" stopColor="#681018" />
            <stop offset="48%" stopColor="#ff1a2a" />
            <stop offset="100%" stopColor="#5b0710" />
          </linearGradient>
        </defs>

        <g className="win-gavel-swing">
          <g transform="rotate(-18 116 88)">
            <rect
              x="42"
              y="48"
              width="92"
              height="58"
              rx="18"
              fill={`url(#winWood-${auctionId})`}
              stroke="#4c1912"
              strokeWidth="3"
            />
            <ellipse cx="88" cy="49" rx="49" ry="13" fill="#2b0d09" stroke="#5b2117" strokeWidth="3" />
            <ellipse cx="88" cy="105" rx="49" ry="13" fill="#100503" stroke="#35100b" strokeWidth="3" />
            <rect x="72" y="55" width="32" height="44" rx="7" fill={`url(#winMetal-${auctionId})`} />
            <path d="M132 77 L225 77" stroke="#29100c" strokeWidth="15" strokeLinecap="round" />
            <path d="M137 72 L217 72" stroke="rgba(255,255,255,.16)" strokeWidth="3" strokeLinecap="round" />
          </g>
        </g>

        <g className="win-gavel-base">
          <rect x="66" y="139" width="132" height="28" rx="12" fill="#160706" stroke="#41100e" strokeWidth="3" />
          <ellipse cx="132" cy="140" rx="58" ry="14" fill="#250a08" stroke="#7c171b" strokeWidth="3" />
        </g>

        <g className="win-gavel-impact">
          <path d="M132 131 L132 111" />
          <path d="M112 134 L98 119" />
          <path d="M152 134 L167 118" />
          <path d="M105 142 L86 137" />
          <path d="M159 142 L179 137" />
        </g>
      </svg>
    </div>
  );
}
