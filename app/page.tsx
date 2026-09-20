import Image from "next/image";
import Link from "next/link";

export default function HomePage() {
  return (
    <main className="crias-home-v2">
      <div className="crias-wall" aria-hidden="true" />

      <section className="crias-shell-v2">
        <div className="crias-hero-v2">
          <div className="crias-logo-panel">
            <Image
              src="/crias-graffiti.jpg"
              alt="Leilão dos Crias"
              width={720}
              height={486}
              priority
              className="crias-graffiti-image"
            />
          </div>

          <div className="crias-gavel-stage" aria-label="Martelo de leilão animado">
            <div className="crias-red-haze" aria-hidden="true" />

            <div className="crias-real-gavel" aria-hidden="true">
              <svg viewBox="0 0 760 420" role="presentation" focusable="false">
                <defs>
                  <linearGradient id="woodA" x1="0" y1="0" x2="1" y2="1">
                    <stop offset="0%" stopColor="#070403" />
                    <stop offset="18%" stopColor="#2a120d" />
                    <stop offset="42%" stopColor="#6a2d1e" />
                    <stop offset="58%" stopColor="#1f0c08" />
                    <stop offset="78%" stopColor="#5a2418" />
                    <stop offset="100%" stopColor="#090403" />
                  </linearGradient>
                  <linearGradient id="woodB" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#5a2418" />
                    <stop offset="22%" stopColor="#120706" />
                    <stop offset="58%" stopColor="#3c160f" />
                    <stop offset="100%" stopColor="#050202" />
                  </linearGradient>
                  <linearGradient id="metalA" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#5c3514" />
                    <stop offset="16%" stopColor="#b98538" />
                    <stop offset="42%" stopColor="#f4cf71" />
                    <stop offset="62%" stopColor="#9d6422" />
                    <stop offset="84%" stopColor="#e0b459" />
                    <stop offset="100%" stopColor="#56310f" />
                  </linearGradient>
                  <linearGradient id="handleA" x1="0" y1="0" x2="1" y2="0">
                    <stop offset="0%" stopColor="#2b110c" />
                    <stop offset="32%" stopColor="#7a3322" />
                    <stop offset="48%" stopColor="#1c0a07" />
                    <stop offset="74%" stopColor="#542117" />
                    <stop offset="100%" stopColor="#070302" />
                  </linearGradient>
                  <radialGradient id="baseTop" cx="50%" cy="35%" r="75%">
                    <stop offset="0%" stopColor="#5f2720" />
                    <stop offset="34%" stopColor="#1b0b08" />
                    <stop offset="100%" stopColor="#030202" />
                  </radialGradient>
                  <filter id="grain" x="-20%" y="-20%" width="140%" height="140%">
                    <feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" seed="7" result="noise" />
                    <feColorMatrix in="noise" type="saturate" values="0" result="mono" />
                    <feBlend in="SourceGraphic" in2="mono" mode="soft-light" />
                  </filter>
                  <filter id="shadow" x="-30%" y="-40%" width="180%" height="220%">
                    <feDropShadow dx="0" dy="18" stdDeviation="16" floodColor="#000" floodOpacity=".85" />
                    <feDropShadow dx="0" dy="0" stdDeviation="10" floodColor="#e50914" floodOpacity=".26" />
                  </filter>
                </defs>

                <g className="crias-gavel-swing" filter="url(#shadow)">
                  <g transform="rotate(-15 300 180)">
                    <ellipse cx="230" cy="104" rx="118" ry="30" fill="#160907" stroke="#3f1a13" strokeWidth="6" />
                    <rect x="120" y="100" width="220" height="132" rx="42" fill="url(#woodA)" stroke="#240e0b" strokeWidth="6" filter="url(#grain)" />
                    <ellipse cx="230" cy="226" rx="119" ry="31" fill="url(#woodB)" stroke="#1c0a08" strokeWidth="6" />
                    <rect x="176" y="113" width="108" height="106" rx="16" fill="url(#metalA)" stroke="#7a4a1d" strokeWidth="4" />
                    <path d="M340 164 L640 164" stroke="url(#handleA)" strokeWidth="36" strokeLinecap="round" />
                    <path d="M350 154 L624 154" stroke="rgba(255,255,255,.12)" strokeWidth="6" strokeLinecap="round" />
                    <ellipse cx="651" cy="164" rx="28" ry="33" fill="#1a0a07" stroke="#35150e" strokeWidth="5" />
                  </g>
                </g>

                <g className="crias-gavel-base">
                  <ellipse cx="325" cy="326" rx="170" ry="34" fill="#070303" opacity=".95" />
                  <rect x="145" y="302" width="360" height="76" rx="26" fill="url(#woodB)" stroke="#1f0b08" strokeWidth="6" filter="url(#grain)" />
                  <ellipse cx="325" cy="304" rx="162" ry="34" fill="url(#baseTop)" stroke="#4a1914" strokeWidth="5" />
                  <ellipse cx="325" cy="300" rx="128" ry="18" fill="#140806" stroke="#7e271f" strokeWidth="3" />
                </g>

                <g className="crias-hit-rays">
                  <path d="M326 290 L326 238" />
                  <path d="M285 294 L248 252" />
                  <path d="M365 294 L406 251" />
                  <path d="M270 310 L216 297" />
                  <path d="M381 309 L439 296" />
                </g>
              </svg>
            </div>
          </div>
        </div>

        <div className="crias-actions-v2">
          <Link href="/criar-sala" className="crias-btn-v2 primary">
            <span>COMEÇAR</span>
            <strong>Criar sala</strong>
            <b>→</b>
          </Link>

          <Link href="/entrar" className="crias-btn-v2 secondary">
            <span>JÁ TEM CÓDIGO?</span>
            <strong>Entrar com código</strong>
            <b>→</b>
          </Link>
        </div>
      </section>
    </main>
  );
}
