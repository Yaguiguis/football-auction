"use client";

import Link from "next/link";
import { useState } from "react";

export default function HomePage() {
  const [modesOpen, setModesOpen] = useState(false);

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

          <button
            type="button"
            className="grafite-btn grafite-btn-modes"
            onClick={() => setModesOpen(true)}
          >
            <span className="grafite-btn-kicker">⚽ ESCOLHA COMO JOGAR</span>
            <strong>Modos</strong>
            <small>Leilão • Maletas • Torneio</small>
          </button>
        </div>
      </section>

      {modesOpen && (
        <div
          className="game-modes-backdrop"
          role="dialog"
          aria-modal="true"
          aria-label="Modos de jogo"
          onMouseDown={(event) => {
            if (event.currentTarget === event.target) setModesOpen(false);
          }}
        >
          <section className="game-modes-panel">
            <div className="game-modes-heading">
              <div>
                <span>MODOS DE JOGO</span>
                <h2>Como os crias vão montar o time?</h2>
              </div>
              <button
                type="button"
                aria-label="Fechar modos"
                onClick={() => setModesOpen(false)}
              >
                ×
              </button>
            </div>

            <div className="game-modes-grid">
              <Link href="/criar-sala" className="game-mode-card classic">
                <span className="game-mode-icon">🔨</span>
                <span className="game-mode-tag">CLÁSSICO</span>
                <strong>Leilão</strong>
                <small>Dispute cada jogador no lance e monte seu elenco.</small>
              </Link>

              <Link href="/criar-maletas" className="game-mode-card cases featured">
                <span className="game-mode-icon">▣</span>
                <span className="game-mode-tag">NOVO</span>
                <strong>Maletas</strong>
                <small>Escolha uma maleta às cegas e revele quem entrou no seu time.</small>
              </Link>

              <Link href="/criar-torneio" className="game-mode-card tournament">
                <span className="game-mode-icon">🏆</span>
                <span className="game-mode-tag">MATA-MATA</span>
                <strong>Torneio</strong>
                <small>Monte o elenco e dispute a chave até sair o campeão.</small>
              </Link>
            </div>
          </section>
        </div>
      )}
    </main>
  );
}
