"use client";
import { useCallback, useEffect, useState } from "react";
import { getSupabase } from "../lib/supabase";
import type { MatchResult, TeamSnapshot } from "../lib/match-simulator";

type Member = { id:string; display_name:string; squad_finalized:boolean; is_spectator:boolean };
type MatchStatus = "pending" | "declined" | "shootout" | "completed" | "cancelled";
type Match = {id:string; challenger_id:string; opponent_id:string; status:MatchStatus; result:MatchResult|null; team_a:TeamSnapshot|null; team_b:TeamSnapshot|null; created_at:string; responded_at:string|null};
const directions = [
  { key: "left", label: "Esquerda" },
  { key: "center", label: "Meio" },
  { key: "right", label: "Direita" },
];

function winnerName(match: Match, winner: string | null) {
  if (!winner) return "Empate";
  return winner === match.team_a?.id ? match.team_a?.name : match.team_b?.name;
}

function MatchPlayback({ match }: {match:Match}) {
  const [minute,setMinute]=useState(0);
  const [skipped,setSkipped]=useState(false);
  useEffect(()=>{
    const maxMinute = match.result?.extra_time ? 120 : 90;
    if (skipped || window.matchMedia("(prefers-reduced-motion: reduce)").matches) { setMinute(maxMinute); return; }
    const started=new Date(match.responded_at||match.created_at).getTime();
    const elapsed=()=>Math.min(maxMinute,Math.max(0,Math.floor((Date.now()-started)/150)));
    setMinute(elapsed());
    if (elapsed()>=maxMinute) return;
    const timer=window.setInterval(()=>{const next=elapsed();setMinute(next);if(next>=maxMinute)window.clearInterval(timer);},150);
    return()=>window.clearInterval(timer);
  },[match.responded_at,match.created_at,match.result?.extra_time,skipped]);
  const result=match.result!;
  const events=result.events.filter(e=>e.minute<=minute);
  const score=(side:"a"|"b")=>events.filter(e=>e.kind==='goal'&&e.team===side).length;
  const maxMinute = result.extra_time ? 120 : 90;
  const finalText = result.decided_by === "extra_time"
    ? "120′ • Fim da prorrogação"
    : result.decided_by === "penalties"
      ? "120′ • Decidido nos pênaltis"
      : "90′ • Fim de jogo";
  return <div className="x1-playback">
    <div className="x1-score" aria-label="Placar"><span>{match.team_a?.name}</span><strong>{score('a')} : {score('b')}</strong><span>{match.team_b?.name}</span></div>
    <p className="muted">{minute<maxMinute?`${minute}′ • Partida em andamento`:finalText}</p>
    <progress value={minute} max={maxMinute} aria-label="Tempo de partida" />
    {minute<maxMinute && <button className="btn btn-secondary" onClick={()=>setSkipped(true)}>Ver resultado</button>}
    <ol className="x1-events">{events.map((event,index)=><li key={index}><b>{event.minute}′</b> {event.kind==='goal'?'Gol':'Defesa'} — {event.player} <small>({event.team==='a'?match.team_a?.name:match.team_b?.name})</small></li>)}</ol>
    {minute===maxMinute && result.penalties && <p className="muted">Pênaltis: {result.penalties.a} × {result.penalties.b}</p>}
    {minute===maxMinute && <p><strong>Vitória de {winnerName(match,result.winner)}</strong></p>}
    <details><summary>Dados da partida</summary><p>Força: {result.strength.a.overall.toFixed(1)} × {result.strength.b.overall.toFixed(1)} • Gols esperados: {result.xg.a.toFixed(2)} × {result.xg.b.toFixed(2)}</p><small>Motor {result.version} • Seed {result.seed}</small></details>
  </div>;
}

function ShootoutPanel({
  match,
  me,
  busy,
  onChoose,
  onSaveOrder,
  onStart,
}: {
  match: Match;
  me: Member | null;
  busy: boolean;
  onChoose: (matchId:string,direction:string)=>void;
  onSaveOrder: (matchId:string,playerIds:string[])=>void;
  onStart: (matchId:string)=>void;
}) {
  const shootout = match.result?.penalty_shootout;
  const [order,setOrder]=useState<string[]>([]);
  const myTeam = me?.id === match.challenger_id ? "a" : me?.id === match.opponent_id ? "b" : null;
  const myPlayers = (myTeam === "a" ? match.team_a?.players : myTeam === "b" ? match.team_b?.players : [])?.filter(player=>!player.slot.startsWith("BENCH")) || [];
  const savedOrder = myTeam ? shootout?.orders?.[myTeam] || [] : [];
  const savedIds = savedOrder.map(player=>player.id);
  const orderReady = myTeam ? Boolean(shootout?.ready?.[myTeam]) : false;
  useEffect(()=>{
    if (!myTeam) return;
    setOrder(savedIds.length ? savedIds : myPlayers.map(player=>player.id));
  },[myTeam, savedIds.join("|"), myPlayers.map(player=>player.id).join("|")]);
  if (!shootout) return null;
  const next = shootout.next;
  const move=(index:number,delta:number)=>{
    const target=index+delta;
    if(target<0||target>=order.length) return;
    setOrder(current=>{
      const copy=[...current];
      [copy[index],copy[target]]=[copy[target],copy[index]];
      return copy;
    });
  };
  if (shootout.status === "setup") {
    return <div className="x1-shootout">
      <div className="x1-score"><span>{match.team_a?.name}</span><strong>0 : 0</strong><span>{match.team_b?.name}</span></div>
      <p className="muted">Antes das cobranças, cada time escolhe a ordem dos batedores.</p>
      {myTeam ? <>
        <strong>Sua ordem de cobrança</strong>
        <ol className="x1-penalty-order">
          {order.map((playerId,index)=>{
            const player=myPlayers.find(item=>item.id===playerId);
            return <li key={playerId}>
              <span>{index+1}. {player?.name || "Jogador"}</span>
              <div>
                <button className="btn btn-secondary" disabled={busy||index===0||orderReady} onClick={()=>move(index,-1)}>Subir</button>
                <button className="btn btn-secondary" disabled={busy||index===order.length-1||orderReady} onClick={()=>move(index,1)}>Descer</button>
              </div>
            </li>;
          })}
        </ol>
        <div className="x1-opponents">
          <button className="btn btn-primary" disabled={busy||order.length<5} onClick={()=>onSaveOrder(match.id,order)}>{orderReady ? "Ordem confirmada" : "Confirmar ordem"}</button>
          <button className="btn btn-secondary" disabled={busy||!orderReady} onClick={()=>onStart(match.id)}>Iniciar cobranças</button>
        </div>
      </> : <p className="muted">Aguardando os jogadores confirmarem a ordem.</p>}
      <p className="muted">Prontos: {shootout.ready?.a ? match.team_a?.name : "Time A pendente"} • {shootout.ready?.b ? match.team_b?.name : "Time B pendente"}</p>
    </div>;
  }
  if (!next) return null;
  const shooterId = next.team === "a" ? match.challenger_id : match.opponent_id;
  const keeperId = next.team === "a" ? match.opponent_id : match.challenger_id;
  const isShooter = me?.id === shooterId;
  const isKeeper = me?.id === keeperId;
  const actorLabel = next.player || (next.team === "a" ? match.team_a?.name : match.team_b?.name);
  return <div className="x1-shootout">
    <div className="x1-score"><span>{match.team_a?.name}</span><strong>{shootout.score.a} : {shootout.score.b}</strong><span>{match.team_b?.name}</span></div>
    <p className="muted">Pênaltis {next.suddenDeath ? "• morte súbita" : "• 5 cobranças"}</p>
    <strong>{actorLabel} vai bater agora.</strong>
    {(isShooter || isKeeper) ? <>
      <p className="muted">{isShooter ? "Escolha onde bater." : "Escolha para onde o goleiro vai pular."}</p>
      <div className="x1-directions">
        {directions.map(direction=><button key={direction.key} className="btn btn-secondary" disabled={busy} onClick={()=>onChoose(match.id,direction.key)}>{direction.label}</button>)}
      </div>
    </> : <p className="muted">Aguardando atacante e goleiro escolherem as direções.</p>}
    {shootout.kicks.length>0&&<ol className="x1-events">{shootout.kicks.map(kick=><li key={kick.index}><b>{kick.index}ª</b> {kick.player || (kick.team==='a'?match.team_a?.name:match.team_b?.name)}: {kick.goal?'Gol':'Defesa'}</li>)}</ol>}
  </div>;
}

export default function X1Arena({roomId,members,me}:{roomId:string;members:Member[];me:Member|null}) {
  const [matches,setMatches]=useState<Match[]>([]),[busy,setBusy]=useState(false),[error,setError]=useState('');
  const load=useCallback(async()=>{
    const {data,error}=await getSupabase().from('fa_x1_matches').select('*').eq('room_id',roomId).order('created_at',{ascending:false}).limit(100);
    if(error)throw error;setMatches(data||[]);
  },[roomId]);
  useEffect(()=>{let live=true;const refresh=()=>void load().catch(e=>{if(live)setError(e.message||'Não foi possível atualizar os desafios');});refresh();const timer=window.setInterval(refresh,3000);return()=>{live=false;window.clearInterval(timer);};},[load]);
  async function action(rpc:string,args:Record<string,unknown>){setBusy(true);setError('');try{const {error}=await getSupabase().rpc(rpc,args);if(error)throw error;await load();}catch(e){setError(e&&typeof e==='object'&&'message'in e?String(e.message):'Falha ao enviar desafio');}finally{setBusy(false);}}
  const choosePenalty=(matchId:string,direction:string)=>void action('fa_choose_x1_penalty',{p_match_id:matchId,p_direction:direction});
  const savePenaltyOrder=(matchId:string,playerIds:string[])=>void action('fa_set_x1_penalty_order',{p_match_id:matchId,p_player_ids:playerIds});
  const startPenalties=(matchId:string)=>void action('fa_start_x1_penalties',{p_match_id:matchId});
  const name=(id:string)=>members.find(m=>m.id===id)?.display_name||'Participante';
  return <section className="card x1-arena">
    <div className="topbar"><div><span className="special-badge card-type-badge">DUELO DOS CRIAS</span><h2>X1 entre elencos</h2></div><span className="muted">90 minutos, prorrogação e pênaltis se precisar.</span></div>
    {error&&<p role="alert" className="red">{error}</p>}
    {me&&!me.is_spectator&&<div className="x1-opponents">{!me.squad_finalized?<p>Finalize seu time para desafiar.</p>:members.filter(m=>m.id!==me.id&&!m.is_spectator&&m.squad_finalized).map(m=><button className="btn btn-primary" key={m.id} disabled={busy||matches.some(x=>['pending','shootout'].includes(x.status)&&[x.challenger_id,x.opponent_id].includes(me.id)&&[x.challenger_id,x.opponent_id].includes(m.id))} onClick={()=>void action('fa_challenge_x1',{p_room_id:roomId,p_opponent_id:m.id})}>Desafiar {m.display_name}</button>)}</div>}
    {matches.length===0&&<p className="muted">Os desafios e resultados desta sala aparecem aqui.</p>}
    {matches.map(match=><article className="x1-match" key={match.id}>
      {match.status==='completed'&&match.result?<MatchPlayback match={match}/>:match.status==='shootout'&&match.result?<>
        <strong>{name(match.challenger_id)} × {name(match.opponent_id)}</strong>
        <p className="muted">Empate após a prorrogação. Disputa de pênaltis em andamento.</p>
        <ShootoutPanel match={match} me={me} busy={busy} onChoose={choosePenalty} onSaveOrder={savePenaltyOrder} onStart={startPenalties}/>
      </>:<>
        <strong>{name(match.challenger_id)} × {name(match.opponent_id)}</strong>
        <p className="muted">{({pending:'Desafio aguardando resposta',declined:'Desafio recusado',cancelled:'Cancelado pela revanche'} as Record<string,string>)[match.status]}</p>
        {match.status==='pending'&&me?.id===match.opponent_id&&<div className="x1-opponents"><button className="btn btn-primary" disabled={busy} onClick={()=>void action('fa_respond_x1',{p_match_id:match.id,p_accept:true})}>Aceitar X1</button><button className="btn btn-secondary" disabled={busy} onClick={()=>void action('fa_respond_x1',{p_match_id:match.id,p_accept:false})}>Recusar</button></div>}
      </>}
    </article>)}
  </section>;
}
