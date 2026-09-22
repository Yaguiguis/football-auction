const assert=require('node:assert/strict');
const {simulateMatch,teamStrength}=require('../.test-build/match-simulator.js');
const slots=['GOL','LE','ZAG1','ZAG2','LD','VOL','MC','MEI','PE','ATA','PD'];
const team=(id,rating)=>({id,name:id,players:slots.concat(['BENCH1','BENCH2']).map(slot=>({id:slot,name:slot,slot,overall:rating,penalty:0}))});
const a=team('a',94),b=team('b',90);
assert.deepEqual(simulateMatch(a,b,87324),simulateMatch(a,b,87324));
assert.throws(()=>simulateMatch(a,b,0));
assert.throws(()=>simulateMatch({...a,players:[]},b,1));
const misplaced=structuredClone(a);misplaced.players[0].penalty=12;
assert(teamStrength(misplaced).overall<teamStrength(a).overall);
const weakBench=structuredClone(a);weakBench.players.filter(p=>p.slot.startsWith('BENCH')).forEach(p=>p.overall=60);
assert(teamStrength(weakBench).overall<teamStrength(a).overall);
const results=[];
for(const [ra,rb] of [[94,90],[92,91],[90,90],[97,88]]){
 let win=0,draw=0,lose=0;const n=20000;
 for(let i=1;i<=n;i++){
  const r=simulateMatch(team('a',ra),team('b',rb),(i*104729)%2147483646+1);
  if(r.score.a>r.score.b)win++;else if(r.score.a===r.score.b)draw++;else lose++;
  assert.equal(r.events.filter(e=>e.kind==='goal'&&e.team==='a').length,r.score.a);
 }
 const row={scenario:`${ra} vs ${rb}`,matches:n,win:win/n,draw:draw/n,lose:lose/n};results.push(row);
 if(ra===94)assert(row.win>=.55&&row.win<=.62,JSON.stringify(row));
 if(ra===90)assert(Math.abs(row.win-row.lose)<.02);
 if(ra===92)assert(Math.abs(row.win-row.lose)<.12);
 if(ra===97)assert(row.win>.65&&row.win<.87&&row.lose>.07);
}
require('node:fs').writeFileSync('data/x1-balance-results.json',JSON.stringify(results,null,2)+'\n');
console.table(results);console.log('Determinism, validation, positions, bench and balance: passed');
