import Link from "next/link";

const showcasePlayers = [
  { name: "PEDRO RAUL", position: "ATA", ger: 99, country: "🇧🇷", initials: "PR", tilt: -7 },
  { name: "MESSI", position: "MEI", ger: 96, country: "🇦🇷", initials: "LM", tilt: 0 },
  { name: "CRISTIANO R.", position: "ATA", ger: 91, country: "🇵🇹", initials: "CR", tilt: 7 },
];

export default function HomePage() {
  return (
    <main className="home-page">
      <div className="home-accent home-accent-top" />
      <div className="home-accent home-accent-bottom" />

      <section className="home-shell">
        <div className="home-hero">
          <div className="home-copy">
            <div className="home-crown" aria-hidden="true">♛</div>
            <h1 className="home-title">
              MONTE SEU
              <span>TIME</span>
            </h1>
            <p className="home-subtitle">
              Escolha seus jogadores, dispute cada lance e monte o elenco perfeito.
            </p>

            <div className="home-features" aria-label="Recursos do jogo">
              <div><b>👥</b><span>Multiplayer</span></div>
              <div><b>🪙</b><span>Orçamento</span></div>
              <div><b>🏆</b><span>Competição</span></div>
            </div>
          </div>

          <div className="home-player-stack" aria-label="Jogadores em destaque">
            {showcasePlayers.map((player, index) => (
              <article
                className={"home-player-card home-player-card-" + index}
                key={player.name}
                style={{ transform: `rotate(${player.tilt}deg)` }}
              >
                <div className="home-player-rating">
                  <span>{player.position}</span>
                  <strong>{player.ger}</strong>
                </div>
                <div className="home-player-portrait" aria-hidden="true">
                  <span>{player.initials}</span>
                </div>
                <strong className="home-player-name">{player.name}</strong>
                <span className="home-player-country">{player.country}</span>
              </article>
            ))}
          </div>
        </div>

        <div className="home-actions">
          <Link className="home-action home-action-primary" href="/criar-sala">
            <div className="home-action-icon">👥</div>
            <div>
              <strong>Criar sala</strong>
              <span>Escolha o nome da sua sala e comece a jogar.</span>
            </div>
            <b className="home-action-arrow">→</b>
          </Link>

          <Link className="home-action home-action-secondary" href="/entrar">
            <div className="home-action-icon">↪</div>
            <div>
              <strong>Entrar com código</strong>
              <span>Use o código enviado pelo dono da sala.</span>
            </div>
            <b className="home-action-arrow">→</b>
          </Link>
        </div>

        <div className="home-info">
          <div>
            <b>🎯</b>
            <p>
              <strong>Sorteio inteligente</strong>
              <span>Saem jogadores das posições que ainda faltam nos times.</span>
            </p>
          </div>
          <div>
            <b>✓</b>
            <p>
              <strong>Final automático</strong>
              <span>Quando sobra só um time incompleto, o jogo completa as posições restantes.</span>
            </p>
          </div>
        </div>
      </section>
    </main>
  );
}
