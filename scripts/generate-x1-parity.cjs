// Generate deterministic fixtures to compare the TS engine with the SQL production engine.
// Run npm run test:simulator first, then node scripts/generate-x1-parity.cjs.
const fs=require('node:fs');const {simulateMatch}=require('../.test-build/match-simulator.js');
const slots=['GOL','LE','ZAG1','ZAG2','LD','VOL','MC','MEI','PE','ATA','PD','BENCH1','BENCH2'];
const fixtures=[];
for(let i=1;i<=120;i++){
 const team=id=>({id,name:id,players:(i%3===0?['GOL','FIXO','ALAE','ALAD','PIVO','BENCH1']:slots).map((slot,j)=>({id:slot,name:id+slot,slot,overall:88+(j*7+i)%10,penalty:slot.startsWith('BENCH')?0:(i+j)%5}))});
 const a=team('a'),b=team('b');b.players[0].overall=82;const seed=(i*134567)%2147483646+1;
 fixtures.push({a,b,seed,expected:simulateMatch(a,b,seed)});
}
const data=JSON.stringify(fixtures).replaceAll("'","''");
fs.writeFileSync('.test-build/x1-parity.sql',`with fixtures as(select value f from jsonb_array_elements('${data}'::jsonb)) select count(*) as total,count(*) filter(where private.fa_simulate_match_v1(f->'a',f->'b',(f->>'seed')::bigint)=f->'expected') as exact_matches from fixtures;\n`);
