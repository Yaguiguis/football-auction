import "./globals.css";

export const metadata = {
  title: "Football Auction",
  description: "Leilão multiplayer de futebol",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
