"use client";
import Link from "next/link";
import { useParams,useSearchParams } from "next/navigation";

export default function Lobby(){
  const params=useParams<{code:string}>(); const sp=useSearchParams(); const name=sp.get("name")||"Jogador";
  return <main className="container"><div className="topbar"><h1>Lobby</h1><span className="badge">Sala {params.code}</span></div><div className="grid grid-2"><section className="card"><h2>Participantes</h2><p>● {name}</p><p className="muted">Novos participantes aparecerão aqui em tempo real com Supabase Realtime.</p></section><section className="card"><h2>Regras</h2><p>Banco: 2 jogadores</p><p>Se só 1 quiser: custo 0</p><p>Se todos passarem: próximo jogador</p></section></div><Link className="btn btn-primary" style={{display:"inline-block",marginTop:16}} href={`/sala/${params.code}/leilao?name=${encodeURIComponent(name)}`}>Iniciar leilão</Link></main>;
}
