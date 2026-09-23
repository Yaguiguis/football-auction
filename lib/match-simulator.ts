/** Versioned deterministic football engine. SQL production implementation is parity-tested.
 * Independent of rooms/UI; tournament rounds can reuse snapshots + seed.
 * No rarity bonus and no home advantage. Normal-time draws are intentional.
 */
export const ENGINE_VERSION = 'x1-v2';
export type MatchPlayer = { id: string; name: string; slot: string; overall: number; penalty: number };
export type TeamSnapshot = { id: string; name: string; players: MatchPlayer[] };
export type TeamStrength = { overall: number; attack: number; defense: number; keeper: number; bench: number; fit: number };
export type MatchEvent = { minute: number; team: 'a' | 'b'; kind: 'goal' | 'save'; player: string };
export type ShootoutKick = { index: number; team: 'a' | 'b'; shot: string; keeper: string; goal: boolean };
export type ShootoutState = { score: { a: number; b: number }; kicks: ShootoutKick[]; next?: { index: number; team: 'a' | 'b'; suddenDeath: boolean }; status: 'pending' | 'completed' };
export type MatchResult = {
  version: string;
  seed: number;
  score: { a: number; b: number };
  extra_time?: { score: { a: number; b: number } };
  penalties?: { a: number; b: number };
  penalty_shootout?: ShootoutState;
  decided_by?: 'normal_time' | 'extra_time' | 'penalties';
  winner: string | null;
  events: MatchEvent[];
  strength: { a: TeamStrength; b: TeamStrength };
  xg: { a: number; b: number };
};
const mean = (values: number[], fallback = 0) => values.length ? values.reduce((a,b) => a+b,0)/values.length : fallback;
const round = (n: number) => Math.round(n*10000)/10000;
export function teamStrength(team: TeamSnapshot): TeamStrength {
  const starters = team.players.filter(p=>!p.slot.startsWith('BENCH'));
  if (![5,11].includes(starters.length) || new Set(starters.map(p=>p.slot)).size !== starters.length || !starters.some(p=>p.slot==='GOL')) throw new Error('Incomplete starting lineup');
  if (team.players.some(p=>!Number.isFinite(p.overall)||p.overall<1||p.overall>100||!Number.isFinite(p.penalty)||p.penalty<0||p.penalty>12)) throw new Error('Invalid player rating');
  const effective=(p:MatchPlayer)=>Math.max(1,p.overall-p.penalty);
  const average=mean(starters.map(effective));
  const attack=mean(starters.filter(p=>['ATA','PE','PD','MEI','PIVO','ALAE','ALAD'].includes(p.slot)).map(effective),average);
  const defense=mean(starters.filter(p=>['LE','LD','ZAG1','ZAG2','VOL','FIXO'].includes(p.slot)).map(effective),average);
  const midfield=mean(starters.filter(p=>['MC','VOL','MEI','ALAE','ALAD'].includes(p.slot)).map(effective),average);
  const keeper=effective(starters.find(p=>p.slot==='GOL')!);
  const bench=mean(team.players.filter(p=>p.slot.startsWith('BENCH')).map(p=>p.overall),average);
  const fit=mean(starters.map(p=>Math.max(1,p.overall-3*p.penalty)));
  const overall=.56*average+.14*fit+.10*Math.min(attack,defense,midfield)+.08*bench+.12*keeper;
  return {overall:round(overall),attack:round(.7*overall+.3*attack),defense:round(.7*overall+.2*defense+.1*keeper),keeper:round(keeper),bench:round(bench),fit:round(fit)};
}
function simulatePeriod(args:{a:TeamSnapshot;b:TeamSnapshot;rng:()=>number;xa:number;xb:number;from:number;to:number;score:{a:number;b:number};events:MatchEvent[]}) {
  const {a,b,rng,xa,xb,from,to,score,events}=args;
  const scorers=(t:TeamSnapshot)=>t.players.filter(p=>!p.slot.startsWith('BENCH')&&p.slot!=='GOL').sort((a,b)=>a.slot.localeCompare(b.slot,'en'));
  const scorera=scorers(a),scorerb=scorers(b);
  for(let minute=from;minute<=to;minute++) {
    for(const side of ['a','b'] as const){
      const chance=rng(), choice=rng();
      const periodLength=to-from+1;
      if(chance<(side==='a'?xa:xb)/periodLength){
        score[side]++;
        const pool=side==='a'?scorera:scorerb;
        events.push({minute,team:side,kind:'goal',player:pool[Math.floor(choice*pool.length)].name});
      } else if(chance< (side==='a'?xa:xb)/periodLength+.012){
        const opposite=side==='a'?'b':'a';
        events.push({minute,team:opposite,kind:'save',player:(side==='a'?b:a).players.find(p=>p.slot==='GOL')!.name});
      }
    }
  }
}

export function simulateMatch(a:TeamSnapshot,b:TeamSnapshot,seed:number):MatchResult {
  if(!Number.isSafeInteger(seed)||seed<1||seed>=2147483647)throw new Error('Invalid seed');
  const sa=teamStrength(a), sb=teamStrength(b);
  let state=seed;
  const rng=()=>{state=(state*48271)%2147483647;return state/2147483647;};
  const formA=(rng()-.5)*4, formB=(rng()-.5)*4;
  const xa=round(Math.min(5,Math.max(.35,1.55*Math.exp(.065*(sa.attack-sb.defense+formA-formB)))));
  const xb=round(Math.min(5,Math.max(.35,1.55*Math.exp(.065*(sb.attack-sa.defense+formB-formA)))));
  const events:MatchEvent[]=[]; const score={a:0,b:0};
  simulatePeriod({a,b,rng,xa,xb,from:1,to:90,score,events});
  return {version:ENGINE_VERSION,seed,score,winner:score.a===score.b?null:score.a>score.b?a.id:b.id,events,strength:{a:sa,b:sb},xg:{a:xa,b:xb},decided_by:score.a===score.b?undefined:'normal_time'};
}

export function simulateKnockoutMatch(a:TeamSnapshot,b:TeamSnapshot,seed:number,withAutoShootout=false):MatchResult {
  const result=simulateMatch(a,b,seed);
  let state=seed;
  const rng=()=>{state=(state*48271)%2147483647;return state/2147483647;};
  for(let i=0;i<200;i++) rng();
  if(result.winner) return result;

  const extraScore={a:0,b:0};
  const extraXa=round(result.xg.a/3);
  const extraXb=round(result.xg.b/3);
  simulatePeriod({a,b,rng,xa:extraXa,xb:extraXb,from:91,to:120,score:extraScore,events:result.events});
  result.extra_time={score:extraScore};
  result.score={a:result.score.a+extraScore.a,b:result.score.b+extraScore.b};
  if(result.score.a!==result.score.b) {
    result.winner=result.score.a>result.score.b?a.id:b.id;
    result.decided_by='extra_time';
    return result;
  }

  result.decided_by='penalties';
  result.penalty_shootout={score:{a:0,b:0},kicks:[],next:{index:1,team:'a',suddenDeath:false},status:'pending'};
  if(withAutoShootout) {
    const directions=['left','center','right'];
    while(result.penalty_shootout.status==='pending') {
      const next=result.penalty_shootout.next!;
      const shot=directions[Math.floor(rng()*directions.length)];
      const keeper=directions[Math.floor(rng()*directions.length)];
      applyShootoutKick(result,next.team,shot,keeper,a.id,b.id);
    }
  }
  return result;
}

export function applyShootoutKick(result:MatchResult,team:'a'|'b',shot:string,keeper:string,aId:string,bId:string) {
  const shootout=result.penalty_shootout;
  if(!shootout?.next||shootout.status==='completed') return result;
  const goal=shot!==keeper;
  shootout.kicks.push({index:shootout.next.index,team,shot,keeper,goal});
  if(goal) shootout.score[team]++;
  const aTaken=shootout.kicks.filter(k=>k.team==='a').length;
  const bTaken=shootout.kicks.filter(k=>k.team==='b').length;
  const remainingA=Math.max(0,5-aTaken);
  const remainingB=Math.max(0,5-bTaken);
  if((aTaken>=5&&bTaken>=5&&shootout.score.a!==shootout.score.b)||(shootout.score.a>shootout.score.b+remainingB)||(shootout.score.b>shootout.score.a+remainingA)) {
    shootout.status='completed';
    delete shootout.next;
    result.penalties={...shootout.score};
    result.winner=shootout.score.a>shootout.score.b?aId:bId;
    return result;
  }
  const nextTeam=team==='a'?'b':'a';
  shootout.next={index:shootout.kicks.length+1,team:nextTeam,suddenDeath:aTaken>=5&&bTaken>=5};
  return result;
}
