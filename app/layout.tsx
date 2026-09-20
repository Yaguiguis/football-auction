import "./globals.css";

export const metadata = {
  title: "Football Auction",
  description: "Leilão multiplayer de futebol",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="pt-BR"><body>{children}<footer style={{ textAlign: "center", padding: "16px", fontSize: 12, color: "#aaa" }}><a href="/creditos">Créditos e licenças das fotos</a></footer></body></html>;
}
