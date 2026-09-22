"use client";
import {useEffect,useState} from 'react';
import {getSupabase} from '../lib/supabase';
import CardBadge,{cardClass,type CardIdentity} from './CardBadge';
type Archive={id:string;created_at:string;snapshot:{players:(CardIdentity&{id:string;name:string;overall:number})[];auctions:{id:string;player_id:string;status:string;final_price:number|null;winner_member_id:string|null}[];members:{id:string;display_name:string}[]}};
export default function RoundArchive({roomId}:{roomId:string}){
 const [rounds,setRounds]=useState<Archive[]>([]),[error,setError]=useState('');
 useEffect(()=>{let live=true;void getSupabase().from('fa_round_archives').select('*').eq('room_id',roomId).order('created_at',{ascending:false}).limit(30).then(({data,error})=>{if(!live)return;if(error)setError('Não foi possível carregar as rodadas arquivadas.');else setRounds(data||[]);});return()=>{live=false;};},[roomId]);
 if(!rounds.length&&!error)return null;
 return <section className="card" style={{marginTop:20}}><h2>Rodadas anteriores</h2>{error&&<p role="alert">{error}</p>}{rounds.map(round=><details key={round.id} style={{margin:'12px 0'}}><summary>Rodada arquivada em {new Date(round.created_at).toLocaleString('pt-BR')}</summary><div className="history-list">{round.snapshot.auctions.map(auction=>{const player=round.snapshot.players.find(p=>p.id===auction.player_id);const owner=round.snapshot.members.find(m=>m.id===auction.winner_member_id);return <div key={auction.id} className={`history-row ${cardClass(player)}`}><div>{player&&<CardBadge player={player}/>} <strong>{player?.name||'Jogador'}</strong> • GER {player?.overall||'—'}</div><span>{auction.status==='sold'?`${owner?.display_name||'Participante'} • ${auction.final_price||0} créditos`:'Sem dono'}</span></div>;})}</div></details>)}</section>;
}
