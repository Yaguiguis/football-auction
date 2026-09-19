import Image from "next/image";
import Link from "next/link";

export default function HomePage() {
  return (
    <main
      style={{
        minHeight: "100vh",
        background: "#050505",
        display: "grid",
        placeItems: "center",
        padding: 0,
        overflow: "hidden",
      }}
    >
      <section
        aria-label="Football Auction"
        style={{
          position: "relative",
          width: "100%",
          maxWidth: 1536,
          aspectRatio: "1536 / 715",
          margin: "0 auto",
        }}
      >
        <Image
          src="/home-auction.webp"
          alt="Monte seu time no Football Auction"
          fill
          priority
          sizes="100vw"
          style={{ objectFit: "contain", userSelect: "none" }}
        />

        <div
          aria-label="Pedro Raul GER 99"
          style={{
            position: "absolute",
            left: "50.1%",
            top: "28.2%",
            width: "4.8%",
            height: "8.8%",
            display: "grid",
            placeItems: "center",
            background: "#090909",
            color: "#fff",
            fontWeight: 900,
            fontSize: "clamp(14px, 2vw, 34px)",
            lineHeight: 1,
            transform: "rotate(-4deg)",
            zIndex: 2,
          }}
        >
          99
        </div>

        <Link
          href="/criar-sala"
          style={{
            position: "absolute",
            left: "9%",
            top: "69%",
            width: "37.5%",
            height: "16.5%",
            zIndex: 3,
            borderRadius: 16,
            border: "2px solid rgba(229,9,20,.9)",
            background: "rgba(95,0,8,.28)",
            display: "grid",
            alignContent: "center",
            padding: "0 4%",
            textDecoration: "none",
            color: "#fff",
            boxShadow: "inset 0 0 22px rgba(229,9,20,.12)",
          }}
        >
          <strong style={{ fontSize: "clamp(13px, 1.45vw, 24px)" }}>Criar sala</strong>
          <span style={{ opacity: .8, fontSize: "clamp(9px, .95vw, 15px)" }}>
            Escolha o nome da sua sala e comece a jogar.
          </span>
        </Link>

        <Link
          href="/entrar"
          style={{
            position: "absolute",
            left: "49%",
            top: "69%",
            width: "41.5%",
            height: "16.5%",
            zIndex: 3,
            borderRadius: 16,
            border: "2px solid rgba(255,255,255,.25)",
            background: "rgba(0,0,0,.32)",
            display: "grid",
            alignContent: "center",
            padding: "0 4%",
            textDecoration: "none",
            color: "#fff",
          }}
        >
          <strong style={{ fontSize: "clamp(13px, 1.45vw, 24px)" }}>Entrar com código</strong>
          <span style={{ opacity: .8, fontSize: "clamp(9px, .95vw, 15px)" }}>
            Use o código enviado pelo dono da sala.
          </span>
        </Link>
      </section>
    </main>
  );
}
