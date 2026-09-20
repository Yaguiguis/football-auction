import Link from "next/link";

export default function HomePage() {
  return (
    <main className="crias-home">
      <div className="crias-noise" aria-hidden="true" />
      <div className="crias-slash crias-slash-one" aria-hidden="true" />
      <div className="crias-slash crias-slash-two" aria-hidden="true" />

      <section className="crias-shell">
        <div className="crias-hero">
          <div className="crias-brand">
            <div className="crias-crown" aria-hidden="true">♛</div>

            <div className="crias-graffiti-wrap">
              <span className="spray spray-a" aria-hidden="true" />
              <span className="spray spray-b" aria-hidden="true" />
              <span className="spray spray-c" aria-hidden="true" />
              <span className="spray spray-d" aria-hidden="true" />
              <span className="spray spray-e" aria-hidden="true" />

              <h1 className="crias-title" aria-label="Leilão dos Crias">
                <span className="crias-title-white">LEILÃO</span>
                <span className="crias-title-red">DOS CRIAS</span>
              </h1>

              <span className="crias-brush crias-brush-white" aria-hidden="true" />
              <span className="crias-brush crias-brush-red" aria-hidden="true" />
            </div>
          </div>

          <div className="crias-scene" aria-label="Martelo de leilão animado">
            <div className="crias-glow" aria-hidden="true" />

            <div className="crias-gavel-wrap" aria-hidden="true">
              <svg
                className="crias-gavel-svg"
                viewBox="0 0 520 310"
                role="presentation"
                focusable="false"
              >
                <defs>
                  <linearGradient id="headMetal" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#4c4c4c" />
                    <stop offset="18%" stopColor="#111111" />
                    <stop offset="42%" stopColor="#262626" />
                    <stop offset="75%" stopColor="#080808" />
                    <stop offset="100%" stopColor="#2e2e2e" />
                  </linearGradient>
                  <linearGradient id="redBand" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#5d0007" />
                    <stop offset="48%" stopColor="#ff1b2a" />
                    <stop offset="100%" stopColor="#6a0008" />
                  </linearGradient>
                  <linearGradient id="handleMetal" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#4b4b4b" />
                    <stop offset="35%" stopColor="#171717" />
                    <stop offset="58%" stopColor="#050505" />
                    <stop offset="100%" stopColor="#303030" />
                  </linearGradient>
                  <filter id="gavelShadow" x="-30%" y="-40%" width="180%" height="200%">
                    <feDropShadow dx="0" dy="16" stdDeviation="12" floodColor="#000" floodOpacity=".7" />
                    <feDropShadow dx="0" dy="0" stdDeviation="10" floodColor="#e50914" floodOpacity=".18" />
                  </filter>
                </defs>

                <g filter="url(#gavelShadow)" transform="rotate(-14 210 150)">
                  <rect x="58" y="82" width="210" height="118" rx="34" fill="url(#headMetal)" stroke="#4a4a4a" strokeWidth="2" />
                  <ellipse cx="163" cy="83" rx="113" ry="23" fill="#303030" stroke="#555" strokeWidth="2" />
                  <ellipse cx="163" cy="199" rx="113" ry="23" fill="#090909" stroke="#303030" strokeWidth="2" />
                  <rect x="112" y="95" width="102" height="94" rx="14" fill="url(#redBand)" />
                  <rect x="141" y="95" width="18" height="94" rx="8" fill="rgba(255,255,255,.18)" />
                  <path d="M251 139 L456 139" stroke="url(#handleMetal)" strokeWidth="34" strokeLinecap="round" />
                  <path d="M269 129 L444 129" stroke="rgba(255,255,255,.13)" strokeWidth="6" strokeLinecap="round" />
                  <ellipse cx="463" cy="139" rx="23" ry="28" fill="#151515" stroke="#343434" strokeWidth="2" />
                </g>
              </svg>
            </div>

            <div className="crias-block" aria-hidden="true">
              <span />
            </div>

            <div className="crias-impact" aria-hidden="true">
              <i />
              <i />
              <i />
              <i />
              <i />
            </div>
          </div>
        </div>

        <div className="crias-actions">
          <Link className="crias-action crias-action-primary" href="/criar-sala">
            <span className="crias-action-kicker">COMEÇAR</span>
            <strong>Criar sala</strong>
            <b aria-hidden="true">→</b>
          </Link>

          <Link className="crias-action crias-action-secondary" href="/entrar">
            <span className="crias-action-kicker">JÁ TEM CÓDIGO?</span>
            <strong>Entrar com código</strong>
            <b aria-hidden="true">→</b>
          </Link>
        </div>
      </section>
    </main>
  );
}
