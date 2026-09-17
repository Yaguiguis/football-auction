"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

function makeCode(){return Math.random().toString(36).slice(2,8).toUpperCase();}

export default function CreateRoom(){
  const router=useRouter();
  const [name,setName]=useState("");
  const [mode,setMode]=useState("football");
  const [budget,setBudget]=useState("100");
  function createRoom(){const room=makeCode();localStorage.setItem(`fa-room-${room}`,JSON.stringify({room,host:name||"Host",mode,budget:Number(budget)}));router.push(`/sala/${room}/lobby?name=${encodeURIComponent(name||"Host")}`);}
  return <main className="container"><div className="topbar"><h1>Criar sala</h1><span className="badge">MVP</span></div><div className="card grid" style={{maxWidth:620}}><label>Seu nome<input className="input" value={name} onChange={e=>setName(e.target.value)} placeholder="Ex.: Gabriel"/></label><label>Modalidade<select className="input" value={mode} onChange={e=>setMode(e.target.value)}><option value="football">Futebol de campo</option><option value="futsal">Futsal</option></select></label><label>Orçamento<select className="input" value={budget} onChange={e=>setBudget(e.target.value)}>{[50,100,150,200,500].map(v=><option key={v} value={v}>{v} créditos</option>)}</select></label><button className="btn btn-primary" onClick={createRoom}>Criar sala</button></div></main>;
}
