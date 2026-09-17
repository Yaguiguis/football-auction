"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";

export default function JoinRoom(){
  const router=useRouter(); const [name,setName]=useState(""); const [room,setRoom]=useState("");
  return <main className="container"><h1>Entrar na sala</h1><div className="card grid" style={{maxWidth:620}}><input className="input" value={name} onChange={e=>setName(e.target.value)} placeholder="Seu nome"/><input className="input" value={room} onChange={e=>setRoom(e.target.value.toUpperCase())} placeholder="Código da sala"/><button className="btn btn-primary" onClick={()=>router.push(`/sala/${room}/lobby?name=${encodeURIComponent(name||"Jogador")}`)}>Entrar</button></div></main>;
}
