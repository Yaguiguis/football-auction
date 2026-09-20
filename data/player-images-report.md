# Expansão das faces — 19/09/2026

Estado inicial: 295 jogadores ativos, 58 com imagem e 237 sem imagem.
Novas faces aprovadas: 224. Pendentes: 13.
Todas as novas imagens vêm do Wikimedia Commons; nenhum asset da EA.
As 58 imagens preexistentes não fazem parte da atualização.

## Licenças

- CC BY 2.0: 10
- CC BY 3.0: 9
- CC BY 4.0: 14
- CC BY-SA 2.0: 9
- CC BY-SA 3.0: 18
- CC BY-SA 3.0 at: 2
- CC BY-SA 4.0: 135
- CC0: 17
- Public domain: 10

## Pendentes

- Agustín Rossi: Não foi encontrada foto adequada com licença confirmada.
- Andrea Cambiaso: Não foi encontrada foto adequada com licença confirmada.
- Cauly: Não foi encontrada foto adequada com licença confirmada.
- Dani Vivian: Não foi encontrada foto adequada com licença confirmada.
- Fabrício Bruno: Não foi encontrada foto adequada com licença confirmada.
- João Ricardo: Atribuição/licença específica ainda requer revisão.
- Juan Martín Lucero: Atribuição/licença específica ainda requer revisão.
- Kaio Jorge: Não foi encontrada foto adequada com licença confirmada.
- Kenan Yıldız: Foto alternativa sem rosto visível; outra fonte com licença específica ainda requer revisão.
- Mathías Villasanti: Não foi encontrada foto adequada com licença confirmada.
- Matteo Politano: Não foi encontrada foto adequada com licença confirmada.
- Rafael: Não foi encontrada foto adequada com licença confirmada.
- Tomás Pochettino: Atribuição/licença específica ainda requer revisão.

## Rastreabilidade e verificação

- `data/player-image-credits.json`: jogador, autor, arquivo, URL de origem e licença de cada nova imagem.
- `/creditos`: atribuição acessível pelo rodapé das telas.
- Arquivos baixados e decodificados; retratos revisados visualmente.
- A função existente `fa_start_next_auction` já copia `image_url` do catálogo para novos jogadores de sala.
- A atualização preenche também fotos vazias de jogadores de salas existentes.
- `PlayerFace` é usado no leilão, na prancheta compartilhada de futebol/futsal e na tela final; fallback de iniciais preservado.
- Build de produção e renderização do componente nos tamanhos 124, 38 e 34 pixels, com teste do fallback sem imagem.
- Verificação visual de uma partida em produção não concluída: a URL de deploy exige login da Vercel neste ambiente.

## Revisão adicional — 20/09/2026

Mais 4 faces adicionadas: João Ricardo, Juan Martín Lucero, Tomás Pochettino e Kenan Yıldız. Total do catálogo: 286 com face e 9 sem face.

- Fabio Giannelli / SOCCER DIGITAL: 3 fotos marcadas Public Domain nas páginas originais do Flickr, com PDMark-owner no Commons.
- MLSZ / Danyele: 1 foto com permissão explícita de uso mediante atribuição, confirmada em https://en.mlsz.hu/imprint.
- URLs das permissões armazenadas no metadata e créditos atualizados.
- Pesquisas complementares: categorias Commons, Wikipedia em português/italiano/espanhol/alemão e imagens P18 do Wikidata.
- Pendentes: Agustín Rossi, Andrea Cambiaso, Cauly, Dani Vivian, Fabrício Bruno, Kaio Jorge, Mathías Villasanti, Matteo Politano, Rafael.
