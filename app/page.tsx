import Link from "next/link";

export default function HomePage() {
  return (
    <main className="home-grafite">
      <div className="home-grafite-bg" aria-hidden="true" />

      <section className="home-grafite-content">
        <div className="grafite-wrap">
          <div className="grafite-spray spray-1" />
          <div className="grafite-spray spray-2" />
          <div className="grafite-spray spray-3" />

          <h1 className="grafite-title" aria-label="Leilão dos Crias">
            <span className="grafite-top">LEILÃO</span>
            <span className="grafite-bottom">DOS CRIAS</span>
          </h1>
        </div>

        <div className="home-grafite-actions">
          <Link href="/criar-sala" className="grafite-btn grafite-btn-primary">
            <span className="grafite-btn-kicker">COMEÇAR</span>
            <strong>Criar sala</strong>
          </Link>

          <Link href="/entrar" className="grafite-btn grafite-btn-secondary">
            <span className="grafite-btn-kicker">JÁ TEM CÓDIGO?</span>
            <strong>Entrar com código</strong>
          </Link>

          <Link href="/criar-torneio" className="grafite-btn grafite-btn-tournament">
            <span className="grafite-btn-kicker">🏆 NOVO MODO</span>
            <strong>Criar torneio</strong>
            <small>Leilão + chave mata-mata até sair o campeão</small>
          </Link>
        </div>
      </section>
    </main>
  );
}
