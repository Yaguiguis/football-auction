import Link from "next/link";

export default function HomePage(){
  return <main className="container"><div style={{display:"grid",minHeight:"calc(100vh - 48px)",placeItems:"center"}}><section style={{width:"100%",maxWidth:900}}><p className="red" style={{fontWeight:900,letterSpacing:3}}>MULTIPLAYER WEB</p><h1 className="brand">FOOTBALL<br/><span className="red">AUCTION</span></h1><p className="muted" style={{maxWidth:640,fontSize:18}}>Monte seu elenco no leilão, dispute jogadores com seus amigos e simule quem construiu o melhor time.</p><div className="grid grid-2" style={{marginTop:28}}><Link className="card" href="/criar-sala"><h2>Criar sala</h2><p className="muted">Escolha orçamento, modalidade e regras.</p></Link><Link className="card" href="/entrar"><h2>Entrar com código</h2><p className="muted">Use o código enviado pelo dono da sala.</p></Link></div></section></div></main>;
}
