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
            <h1 className="crias-title" aria-label="Leilão dos Crias">
              <span className="crias-title-white">LEILÃO</span>
              <span className="crias-title-red">DOS CRIAS</span>
            </h1>
          </div>

          <div className="crias-scene" aria-label="Martelo de leilão e bola de futebol">
            <div className="crias-glow" aria-hidden="true" />

            <div className="crias-gavel-wrap" aria-hidden="true">
              <div className="crias-gavel">
                <div className="crias-gavel-head">
                  <span className="crias-gavel-band" />
                </div>
                <div className="crias-gavel-handle" />
              </div>
            </div>

            <div className="crias-block" aria-hidden="true">
              <span />
            </div>

            <div className="crias-impact" aria-hidden="true">
              <i />
              <i />
              <i />
            </div>

            <div className="crias-ball" aria-hidden="true">
              <span className="crias-ball-center" />
              <span className="crias-ball-patch p1" />
              <span className="crias-ball-patch p2" />
              <span className="crias-ball-patch p3" />
              <span className="crias-ball-patch p4" />
              <span className="crias-ball-patch p5" />
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
