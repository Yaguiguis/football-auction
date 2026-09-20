import Link from "next/link";
import credits from "../../data/player-image-credits.json";

export const metadata = { title: "Créditos das fotos | Football Auction" };

export default function PhotoCreditsPage() {
  return (
    <main className="container">
      <Link href="/">← Football Auction</Link>
      <h1>Créditos das fotos</h1>
      <p>Fotos obtidas no Wikimedia Commons. Cada arquivo mantém sua própria licença.
        As fotos são exibidas em tamanho reduzido, com enquadramento circular na interface.
        Não são utilizados assets da EA.</p>
      <div className="grid">
        {credits.map((photo) => (
          <article className="card" key={photo.id} id={photo.id}>
            <h2>{photo.name}</h2>
            <p>Autor: {photo.author}</p>
            <p><a href={photo.image_source_url} target="_blank" rel="noreferrer">Arquivo original e atribuição no Wikimedia Commons</a></p>
            <p>Licença: {photo.license_url
              ? <a href={photo.license_url} target="_blank" rel="noreferrer">{photo.image_license}</a>
              : photo.image_license}</p>
          </article>
        ))}
      </div>
    </main>
  );
}
