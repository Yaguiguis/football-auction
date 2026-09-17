"use client";
import { useParams,useSearchParams } from "next/navigation";
import { useState } from "react";

const demo={name:"Jogador Demo",club:"Clube Europeu",position:"ATA",overall:90};

export default function Auction(){
  const params=useParams<{code:string}>(); const sp=useSearchParams(); const playerName=sp.get("name")||"Jogador";
  const [bid,setBid]=useState(1); const [balance,setBalance]=useState(100); const [status,setStatus]=useState("");
  function win(){if(bid>balance)return;setBalance(v=>v-bid);setStatus(`🔨 LEILOADO PARA ${playerName.toUpperCase()} — ${bid} créditos`);}
  return <main className="container"><div className="topbar"><span className="badge">Sala {params.code}</span><strong>Saldo: {balance}</strong></div><section className="card" style={{maxWidth:520,margin:"0 auto",textAlign:"center"}}><div className="red" style={{fontSize:42,fontWeight:900}}>{demo.overall}</div><h1>{demo.name}</h1><p>{demo.position} • {demo.club}</p>{status?<><h2 className="red">{status}</h2><button className="btn btn-secondary" onClick={()=>setStatus("")}>Próximo jogador</button></>:<div style={{display:"flex",gap:10,justifyContent:"center",flexWrap:"wrap"}}><button className="btn btn-secondary" onClick={()=>setBid(v=>Math.max(1,v-1))}>−</button><span className="badge">Lance: {bid}</span><button className="btn btn-secondary" onClick={()=>setBid(v=>Math.min(balance,v+1))}>+</button><button className="btn btn-primary" onClick={win}>Fechar lance</button><button className="btn btn-secondary">Passar</button></div>}</section><p className="muted" style={{textAlign:"center"}}>Protótipo inicial. A versão online real terá arbitragem de lances no servidor.</p></main>;
}
