# Catálogo SPECIAL e X1 — 22/09/2026

## Implementação

- Base de código auditada: `7ea43a8`, incluindo lobby, chat, espectadores, reconexão e filtros de ligas.
- 339 cartas habilitadas: 254 BASE (`ACTIVE` no banco), 60 ICONS e 25 SPECIALS.
- Duas duplicatas BASE desativadas, sem excluir snapshots ou referências: `laliga-vini` → `ea27_vinicius`; `pl-gabriel` → `ea27_gabriel`.
- Identidade canônica, slug e índices únicos por identidade/tipo/ano. IDs externos EA usados apenas como identificador quando já presentes. Homônimos não são mesclados automaticamente. Novas importações precisam resolver a identidade existente.
- Índice antigo por nome de jogador na sala substituído por identidade da carta. Messi de anos diferentes pode aparecer na mesma sala.
- Todos os ICONS têm GER >= 90. Pelé permanece 100, custom.
- Novos valores e ajustes são game design do Football Auction, não notas oficiais da EA.
- SPECIAL: identidade original preto/ciano, badge e ano, reveal, prancheta, banco, histórico e resultado final.
- 18 SPECIALS reutilizam fotos já licenciadas do catálogo, com fonte/licença; 7 ficam com iniciais. Os 20 novos ICONS usam fallback. Não foram inventadas URLs nem usados assets EA/Soccer Aid. Fotos reutilizadas não são apresentadas como retratos daquele ano.
- Filtros BASE/ICON/SPECIAL independentes nas novas salas. Salas anteriores mantêm SPECIAL desligado; filtros antigos e RPCs v1/v2 preservados.
- X1 não altera saldo, não cobra entrada e não concede prêmio. Créditos do leilão são apenas orçamento fictício de formação de elenco.

## Migrations aplicadas

- `20260922212021_catalog_specials_x1.sql`: catálogo, filtros, RPC v3, motor X1, desafios, RLS e arquivo de rodadas.
- `20260922212336_card_version_identity.sql`: unicidade por versão na sala e identidade CR7.
- `20260922212846_historical_card_positions.sql`: CR7 2008 como PD, secundárias PE/ATA.

## GERs ajustados

| Nome | Tipo | Antes | Depois |
|---|---|---:|---:|
| Álex Grimaldo | ACTIVE | 79 | 85 |
| Aurélien Tchouaméni | ACTIVE | 79 | 85 |
| Bradley Barcola | ACTIVE | 78 | 84 |
| Cole Palmer | ACTIVE | 79 | 87 |
| Eduardo Camavinga | ACTIVE | 78 | 84 |
| Hakan Çalhanoğlu | ACTIVE | 79 | 86 |
| Jules Koundé | ACTIVE | 78 | 86 |
| Manuel Neuer | ACTIVE | 78 | 85 |
| Phil Foden | ACTIVE | 83 | 86 |
| Rafael Leão | ACTIVE | 78 | 86 |
| Robert Lewandowski | ACTIVE | 83 | 87 |
| Rodrygo | ACTIVE | 80 | 86 |
| Theo Hernández | ACTIVE | 81 | 86 |
| Xavi Simons | ACTIVE | 80 | 84 |
| Andrea Pirlo | ICON | 88 | 90 |
| Cafu | ICON | 89 | 90 |
| Clint Dempsey | ICON | 88 | 90 |
| Iker Casillas | ICON | 89 | 90 |
| Paolo Maldini | ICON | 89 | 90 |
| Ronaldinho | ICON | 89 | 90 |

## 20 novos ICONS

| Nome | GER |
|---|---:|
| Garrincha | 96 |
| Ferenc Puskás | 96 |
| Lev Yashin | 95 |
| Lothar Matthäus | 95 |
| Roberto Baggio | 94 |
| Alessandro Nesta | 93 |
| Luís Figo | 93 |
| Didier Drogba | 92 |
| Eric Cantona | 93 |
| Andriy Shevchenko | 93 |
| Wayne Rooney | 92 |
| Franco Baresi | 95 |
| Clarence Seedorf | 92 |
| Ruud Gullit | 95 |
| Frank Rijkaard | 93 |
| Paul Scholes | 92 |
| Dennis Bergkamp | 93 |
| Kenny Dalglish | 93 |
| Samuel Eto’o | 93 |
| Miroslav Klose | 91 |

## 25 SPECIALS

| Nome | Ano | GER |
|---|---|---:|
| Cristiano Ronaldo | 2008 | 96 |
| Cristiano Ronaldo | 2014 | 98 |
| Cristiano Ronaldo | 2017 | 96 |
| Lionel Messi | 2009 | 96 |
| Lionel Messi | 2012 | 99 |
| Lionel Messi | 2014 | 97 |
| Lionel Messi | 2015 | 98 |
| Neymar | 2011 | 94 |
| Neymar | 2015 | 96 |
| Neymar | 2020 | 95 |
| Ronaldinho | 2005 | 97 |
| Kaká | 2007 | 96 |
| Ronaldo Nazário | 2002 | 97 |
| Romário | 1994 | 96 |
| Rivaldo | 2002 | 95 |
| Thierry Henry | 2004 | 95 |
| Luis Suárez | 2015/16 | 95 |
| Gareth Bale | 2014 | 94 |
| Luka Modrić | 2018 | 94 |
| Xavi | 2011 | 95 |
| Andrés Iniesta | 2010 | 95 |
| Kylian Mbappé | 2022 | 96 |
| Mohamed Salah | 2018 | 94 |
| Eden Hazard | 2018 | 94 |
| Robert Lewandowski | 2020 | 96 |

## Motor e segurança

`lib/match-simulator.ts` é independente da UI. `private.fa_simulate_match_v1` executa a mesma versão no servidor; 120 fixtures tiveram igualdade JSON exata (futebol e futsal, banco e penalidades). Alterações futuras exigem atualizar ambas as implementações e repetir essa comparação.

Força: 56% média efetiva dos titulares, 14% encaixe (penalidade ampliada), 10% menor setor defesa/meio/ataque, 8% banco e 12% goleiro. Pequena forma aleatória altera as expectativas de gols. Ataque e defesa derivam da força e dos respectivos setores. Sem bônus por raridade e sem mando de campo.

RNG Park–Miller, seed criada no servidor, expectativa de gols exponencial e oportunidades a cada minuto (aproximação discreta de Poisson). Empate permitido. Snapshots, versão, seed, forças, eventos, placar e vencedor ficam persistidos. Aceitar novamente não refaz o sorteio. RPCs validam usuário e participantes; clientes têm somente SELECT sujeito a RLS. O motor pode alimentar futuras fases de torneio; prorrogação/pênaltis e chaveamento não foram implementados.

Revanche arquiva jogadores, compras, lances e escalações antes de limpar a rodada corrente. Resultados X1 e `fa_matches` permanecem; desafios pendentes são cancelados. Histórico anterior à implantação não pode ser recuperado se já tiver sido apagado pela implementação antiga.

## Testes de balanceamento

20.000 seeds por cenário, 80.000 partidas no total. Times com mesmos encaixes/banco e GER uniforme; não são garantias para toda escalação real.

| Cenário | Vitória do primeiro | Empate | Derrota do primeiro |
|---|---:|---:|---:|
| 94 vs 90 | 55.72% | 21.57% | 22.71% |
| 92 vs 91 | 42.34% | 23.67% | 33.98% |
| 90 vs 90 | 38.02% | 23.75% | 38.23% |
| 97 vs 88 | 77.09% | 13.66% | 9.25% |

## Validação

- TypeScript e build Next.js: passaram localmente.
- `npm run test:simulator`: passou; determinismo, entrada inválida, penalidades, banco, placar/eventos e faixas de balanceamento.
- `tests/database-integration.sql`: passou no Supabase, com usuários/salas sintéticos dentro de transação revertida. Abrange filtros, sorteio SPECIAL, QUERO/PASSAR, lances sequenciais, desistência, chat, finalização, X1 aceite/recusa, idempotência, acesso negado a terceiros, RLS, impedimento de adulteração, arquivo da revanche e índice anti-duplicata.
- 120/120 fixtures TypeScript/SQL idênticas. Reproduzir: `npm run test:simulator`, `node scripts/generate-x1-parity.cjs`, executar `.test-build/x1-parity.sql` no banco como administrador.
- Advisors revisados: novas tabelas com RLS; três RPCs autenticadas SECURITY DEFINER intencionais, com checagens de usuário. Alertas antigos de outras tabelas do projeto não foram alterados. Referência: https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable
- Revisão visual em navegador pendente: a revisão automática bloqueou a abertura do site por classificá-lo como apostas. Não houve teste visual desktop/mobile nesta entrega.
- CI e Vercel: consultar o PR/commit desta entrega; status final informado na conversa.

## Arquivos principais

- `lib/match-simulator.ts`, `components/X1Arena.tsx`, `components/RoundArchive.tsx`, `components/CardBadge.tsx`.
- `components/AuctionGame.tsx`, `app/criar-sala/page.tsx`, `app/sala/[code]/elenco/page.tsx`, `app/sala/[code]/times/page.tsx`, `app/globals.css`, `lib/squad-board.ts`.
- Três migrations em `supabase/migrations`, testes em `tests`, gerador de fixtures em `scripts`.
- Relatórios em `data/catalog-expansion-report.json`, `data/special-image-report.json`, `data/x1-balance-results.json`.
- `package.json`, `.github/workflows/ci.yml` e `.gitignore`.
