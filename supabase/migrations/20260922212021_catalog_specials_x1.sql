-- Catalog-only changes: room player snapshots and auction history remain untouched.
alter table public.fa_catalog_players drop constraint fa_catalog_players_player_type_check;
alter table public.fa_catalog_players add constraint fa_catalog_players_player_type_check check (player_type in ('ACTIVE','ICON','SPECIAL'));
alter table public.fa_players drop constraint fa_players_player_type_check;
alter table public.fa_players add constraint fa_players_player_type_check check (player_type in ('ACTIVE','ICON','SPECIAL'));
alter table public.fa_catalog_players add column canonical_key text, add column slug text, add column season_year integer, add column version_label text;
update public.fa_catalog_players set canonical_key='ea:235212',slug='ligue1-hakimi' where id='ligue1-hakimi';
update public.fa_catalog_players set canonical_key='person:ademola-lookman:nigeria',slug='seriea-lookman' where id='seriea-lookman';
update public.fa_catalog_players set canonical_key='person:adrien-rabiot:france',slug='ligue1-rabiot' where id='ligue1-rabiot';
update public.fa_catalog_players set canonical_key='person:agustin-rossi:argentina',slug='bra_agustin_rossi' where id='bra_agustin_rossi';
update public.fa_catalog_players set canonical_key='person:alan-patrick:brazil',slug='bra_alan_patrick' where id='bra_alan_patrick';
update public.fa_catalog_players set canonical_key='person:aleix-garcia:spain',slug='bundes_aleix_garcia' where id='bundes_aleix_garcia';
update public.fa_catalog_players set canonical_key='person:alejandro-balde:spain',slug='laliga_alejandro_balde' where id='laliga_alejandro_balde';
update public.fa_catalog_players set canonical_key='person:aleksandar-pavlovic:germany',slug='bundes_aleksandar_pavlovic' where id='bundes_aleksandar_pavlovic';
update public.fa_catalog_players set canonical_key='person:aleksandr-golovin:russia',slug='ligue1_aleksandr_golovin' where id='ligue1_aleksandr_golovin';
update public.fa_catalog_players set canonical_key='ea:237383',slug='seriea-bastoni' where id='seriea-bastoni';
update public.fa_catalog_players set canonical_key='person:alessandro-buongiorno:italy',slug='seriea_alessandro_buongiorno' where id='seriea_alessandro_buongiorno';
update public.fa_catalog_players set canonical_key='person:alex-grimaldo:spain',slug='bund-grimaldo' where id='bund-grimaldo';
update public.fa_catalog_players set canonical_key='person:alex-meret:italy',slug='seriea_alex_meret' where id='seriea_alex_meret';
update public.fa_catalog_players set canonical_key='ea:233731',slug='pl-isak' where id='pl-isak';
update public.fa_catalog_players set canonical_key='person:alexander-nubel:germany',slug='bundes_alexander_nubel' where id='bundes_alexander_nubel';
update public.fa_catalog_players set canonical_key='person:alexis-mac-allister:argentina',slug='pl_alexis_mac_allister' where id='pl_alexis_mac_allister';
update public.fa_catalog_players set canonical_key='ea:212831',slug='pl-alisson' where id='pl-alisson';
update public.fa_catalog_players set canonical_key='person:alphonso-davies:canada',slug='bund-davies' where id='bund-davies';
update public.fa_catalog_players set canonical_key='person:amad-diallo:ivory-coast',slug='pl_amad_diallo' where id='pl_amad_diallo';
update public.fa_catalog_players set canonical_key='person:amine-gouiri:algeria',slug='ligue1_amine_gouiri' where id='ligue1_amine_gouiri';
update public.fa_catalog_players set canonical_key='person:andrea-cambiaso:italy',slug='seriea_andrea_cambiaso' where id='seriea_andrea_cambiaso';
update public.fa_catalog_players set canonical_key='person:angelo-stiller:germany',slug='bundes_angelo_stiller' where id='bundes_angelo_stiller';
update public.fa_catalog_players set canonical_key='person:anthony-gordon:england',slug='pl_anthony_gordon' where id='pl_anthony_gordon';
update public.fa_catalog_players set canonical_key='person:antoine-griezmann:france',slug='laliga_antoine_griezmann' where id='laliga_antoine_griezmann';
update public.fa_catalog_players set canonical_key='person:antonio-rudiger:germany',slug='laliga-rudiger' where id='laliga-rudiger';
update public.fa_catalog_players set canonical_key='person:aurelien-tchouameni:france',slug='laliga-tchouameni' where id='laliga-tchouameni';
update public.fa_catalog_players set canonical_key='person:bastos:angola',slug='bra_bastos' where id='bra_bastos';
update public.fa_catalog_players set canonical_key='person:bernardo-silva:portugal',slug='pl_bernardo_silva' where id='pl_bernardo_silva';
update public.fa_catalog_players set canonical_key='person:bradley-barcola:france',slug='ligue1-barcola' where id='ligue1-barcola';
update public.fa_catalog_players set canonical_key='person:brahim-diaz:morocco',slug='laliga_brahim_diaz' where id='laliga_brahim_diaz';
update public.fa_catalog_players set canonical_key='ea:239580',slug='seriea-bremer' where id='seriea-bremer';
update public.fa_catalog_players set canonical_key='ea:212198',slug='pl-bruno' where id='pl-bruno';
update public.fa_catalog_players set canonical_key='ea:247851',slug='pl_bruno_guimaraes' where id='pl_bruno_guimaraes';
update public.fa_catalog_players set canonical_key='person:bruno-henrique:brazil',slug='bra_bruno_henrique' where id='bra_bruno_henrique';
update public.fa_catalog_players set canonical_key='ea:246669',slug='pl-saka' where id='pl-saka';
update public.fa_catalog_players set canonical_key='person:cassio:brazil',slug='bra_cassio' where id='bra_cassio';
update public.fa_catalog_players set canonical_key='person:cauly:brazil',slug='bra_cauly' where id='bra_cauly';
update public.fa_catalog_players set canonical_key='person:chris-fuhrich:germany',slug='bundes_chris_fuhrich' where id='bundes_chris_fuhrich';
update public.fa_catalog_players set canonical_key='person:christian-pulisic:united-states',slug='seriea-pulisic' where id='seriea-pulisic';
update public.fa_catalog_players set canonical_key='person:cole-palmer:england',slug='pl-palmer' where id='pl-palmer';
update public.fa_catalog_players set canonical_key='person:corentin-tolisso:france',slug='ligue1_corentin_tolisso' where id='ligue1_corentin_tolisso';
update public.fa_catalog_players set canonical_key='ea:239231',slug='ea27_cucurella' where id='ea27_cucurella';
update public.fa_catalog_players set canonical_key='person:dani-carvajal:spain',slug='laliga_dani_carvajal' where id='laliga_dani_carvajal';
update public.fa_catalog_players set canonical_key='person:dani-olmo:spain',slug='laliga_dani_olmo' where id='laliga_dani_olmo';
update public.fa_catalog_players set canonical_key='person:dani-vivian:spain',slug='laliga_dani_vivian' where id='laliga_dani_vivian';
update public.fa_catalog_players set canonical_key='person:dante:brazil',slug='ligue1_dante' where id='ligue1_dante';
update public.fa_catalog_players set canonical_key='person:david-raum:germany',slug='bundes_david_raum' where id='bundes_david_raum';
update public.fa_catalog_players set canonical_key='ea:220901',slug='pl_david_raya' where id='pl_david_raya';
update public.fa_catalog_players set canonical_key='ea:229558',slug='bund-upamecano' where id='bund-upamecano';
update public.fa_catalog_players set canonical_key='ea:234378',slug='pl-rice' where id='pl-rice';
update public.fa_catalog_players set canonical_key='person:denis-zakaria:switzerland',slug='ligue1_denis_zakaria' where id='ligue1_denis_zakaria';
update public.fa_catalog_players set canonical_key='person:deniz-undav:germany',slug='bund-undav' where id='bund-undav';
update public.fa_catalog_players set canonical_key='ea:271421',slug='ligue1_desire_doue' where id='ligue1_desire_doue';
update public.fa_catalog_players set canonical_key='ea:234577',slug='ea27_diogo_costa' where id='ea27_diogo_costa';
update public.fa_catalog_players set canonical_key='ea:236772',slug='pl_dominik_szoboszlai' where id='pl_dominik_szoboszlai';
update public.fa_catalog_players set canonical_key='person:dusan-vlahovic:serbia',slug='seriea-vlahovic' where id='seriea-vlahovic';
update public.fa_catalog_players set canonical_key='person:eder-militao:brazil',slug='laliga-militao' where id='laliga-militao';
update public.fa_catalog_players set canonical_key='person:ederson:brazil',slug='pl-ederson' where id='pl-ederson';
update public.fa_catalog_players set canonical_key='person:edmond-tapsoba:burkina-faso',slug='bundes_edmond_tapsoba' where id='bundes_edmond_tapsoba';
update public.fa_catalog_players set canonical_key='person:eduardo-camavinga:france',slug='laliga-camavinga' where id='laliga-camavinga';
update public.fa_catalog_players set canonical_key='ea:247090',slug='pl_enzo_fernandez' where id='pl_enzo_fernandez';
update public.fa_catalog_players set canonical_key='person:erick-pulgar:chile',slug='bra_erick_pulgar' where id='bra_erick_pulgar';
update public.fa_catalog_players set canonical_key='ea:239085',slug='pl-haaland' where id='pl-haaland';
update public.fa_catalog_players set canonical_key='person:everson:brazil',slug='bra_everson' where id='bra_everson';
update public.fa_catalog_players set canonical_key='person:everton-cebolinha:brazil',slug='bra_everton_cebolinha' where id='bra_everton_cebolinha';
update public.fa_catalog_players set canonical_key='person:everton-ribeiro:brazil',slug='bra_everton_ribeiro' where id='bra_everton_ribeiro';
update public.fa_catalog_players set canonical_key='person:exequiel-palacios:argentina',slug='bund-palacios' where id='bund-palacios';
update public.fa_catalog_players set canonical_key='ea:226271',slug='ligue1_fabian_ruiz' where id='ligue1_fabian_ruiz';
update public.fa_catalog_players set canonical_key='person:fabio:brazil',slug='bra_fabio' where id='bra_fabio';
update public.fa_catalog_players set canonical_key='person:fabricio-bruno:brazil',slug='bra_fabricio_bruno' where id='bra_fabricio_bruno';
update public.fa_catalog_players set canonical_key='ea:226268',slug='seriea_federico_dimarco' where id='seriea_federico_dimarco';
update public.fa_catalog_players set canonical_key='ea:239053',slug='laliga-valverde' where id='laliga-valverde';
update public.fa_catalog_players set canonical_key='person:felix-nmecha:germany',slug='bundes_felix_nmecha' where id='bundes_felix_nmecha';
update public.fa_catalog_players set canonical_key='person:ferland-mendy:france',slug='laliga_ferland_mendy' where id='laliga_ferland_mendy';
update public.fa_catalog_players set canonical_key='person:ferran-torres:spain',slug='laliga_ferran_torres' where id='laliga_ferran_torres';
update public.fa_catalog_players set canonical_key='person:fikayo-tomori:england',slug='seriea_fikayo_tomori' where id='seriea_fikayo_tomori';
update public.fa_catalog_players set canonical_key='person:flaco-lopez:argentina',slug='bra_flaco_lopez' where id='bra_flaco_lopez';
update public.fa_catalog_players set canonical_key='ea:256630',slug='ea27_florian_wirtz' where id='ea27_florian_wirtz';
update public.fa_catalog_players set canonical_key='person:folarin-balogun:united-states',slug='ligue1_folarin_balogun' where id='ligue1_folarin_balogun';
update public.fa_catalog_players set canonical_key='person:francesco-acerbi:italy',slug='seriea_francesco_acerbi' where id='seriea_francesco_acerbi';
update public.fa_catalog_players set canonical_key='person:frank-anguissa:cameroon',slug='seriea_frank_anguissa' where id='seriea_frank_anguissa';
update public.fa_catalog_players set canonical_key='person:frenkie-de-jong:netherlands',slug='laliga-dejong' where id='laliga-dejong';
update public.fa_catalog_players set canonical_key='ea:232580',slug='ea27_gabriel' where id='ea27_gabriel';
update public.fa_catalog_players set canonical_key='person:gabriel-brazao:brazil',slug='bra_gabriel_brazao' where id='bra_gabriel_brazao';
update public.fa_catalog_players set canonical_key='ea:232580',slug='pl-gabriel' where id='pl-gabriel';
update public.fa_catalog_players set canonical_key='person:gavi:spain',slug='laliga-gavi' where id='laliga-gavi';
update public.fa_catalog_players set canonical_key='person:geoffrey-kondogbia:central-african-republic',slug='ligue1_geoffrey_kondogbia' where id='ligue1_geoffrey_kondogbia';
update public.fa_catalog_players set canonical_key='person:german-cano:argentina',slug='bra_german_cano' where id='bra_german_cano';
update public.fa_catalog_players set canonical_key='person:geronimo-rulli:argentina',slug='ligue1_geronimo_rulli' where id='ligue1_geronimo_rulli';
update public.fa_catalog_players set canonical_key='person:gianluca-mancini:italy',slug='seriea_gianluca_mancini' where id='seriea_gianluca_mancini';
update public.fa_catalog_players set canonical_key='ea:230621',slug='ea27_gianluigi_donnarumma' where id='ea27_gianluigi_donnarumma';
update public.fa_catalog_players set canonical_key='person:giorgian-de-arrascaeta:uruguay',slug='bra_arrascaeta' where id='bra_arrascaeta';
update public.fa_catalog_players set canonical_key='person:giovani-lo-celso:argentina',slug='laliga_giovani_lo_celso' where id='laliga_giovani_lo_celso';
update public.fa_catalog_players set canonical_key='person:giovanni-di-lorenzo:italy',slug='seriea-dilorenzo' where id='seriea-dilorenzo';
update public.fa_catalog_players set canonical_key='person:goncalo-ramos:portugal',slug='ligue1-ramos' where id='ligue1-ramos';
update public.fa_catalog_players set canonical_key='ea:235073',slug='bund-kobel' where id='bund-kobel';
update public.fa_catalog_players set canonical_key='person:guilherme-arana:brazil',slug='bra_guilherme_arana' where id='bra_guilherme_arana';
update public.fa_catalog_players set canonical_key='person:gustavo-gomez:paraguay',slug='bra_gustavo_gomez' where id='bra_gustavo_gomez';
update public.fa_catalog_players set canonical_key='person:gustavo-scarpa:brazil',slug='bra_gustavo_scarpa' where id='bra_gustavo_scarpa';
update public.fa_catalog_players set canonical_key='person:hakan-calhanoglu:turkiye',slug='seriea-calhanoglu' where id='seriea-calhanoglu';
update public.fa_catalog_players set canonical_key='ea:202126',slug='bund-kane' where id='bund-kane';
update public.fa_catalog_players set canonical_key='person:hugo-souza:brazil',slug='bra_hugo_souza' where id='bra_hugo_souza';
update public.fa_catalog_players set canonical_key='person:hulk:brazil',slug='bra_hulk' where id='bra_hulk';
update public.fa_catalog_players set canonical_key='person:ibrahima-konate:france',slug='pl_ibrahima_konate' where id='pl_ibrahima_konate';
update public.fa_catalog_players set canonical_key='person:isco:spain',slug='laliga_isco' where id='laliga_isco';
update public.fa_catalog_players set canonical_key='ea:256790',slug='bund-musiala' where id='bund-musiala';
update public.fa_catalog_players set canonical_key='ea:200389',slug='laliga-oblak' where id='laliga-oblak';
update public.fa_catalog_players set canonical_key='person:jean-lucas:brazil',slug='bra_jean_lucas' where id='bra_jean_lucas';
update public.fa_catalog_players set canonical_key='person:jefferson-savarino:venezuela',slug='bra_savarino' where id='bra_savarino';
update public.fa_catalog_players set canonical_key='person:jeremy-doku:belgium',slug='pl_jeremy_doku' where id='pl_jeremy_doku';
update public.fa_catalog_players set canonical_key='ea:259532',slug='ea27_joan_garcia' where id='ea27_joan_garcia';
update public.fa_catalog_players set canonical_key='ea:272834',slug='ligue1-joao-neves' where id='ligue1-joao-neves';
update public.fa_catalog_players set canonical_key='person:joao-ricardo:brazil',slug='bra_joao_ricardo' where id='bra_joao_ricardo';
update public.fa_catalog_players set canonical_key='person:joao-schmidt:brazil',slug='bra_joao_schmidt' where id='bra_joao_schmidt';
update public.fa_catalog_players set canonical_key='person:joaquin-piquerez:uruguay',slug='bra_joaquin_piquerez' where id='bra_joaquin_piquerez';
update public.fa_catalog_players set canonical_key='person:jonathan-calleri:argentina',slug='bra_calleri' where id='bra_calleri';
update public.fa_catalog_players set canonical_key='person:jonathan-clauss:france',slug='ligue1_jonathan_clauss' where id='ligue1_jonathan_clauss';
update public.fa_catalog_players set canonical_key='ea:213331',slug='ea27_jonathan_tah' where id='ea27_jonathan_tah';
update public.fa_catalog_players set canonical_key='person:jose-maria-gimenez:uruguay',slug='laliga_jose_gimenez' where id='laliga_jose_gimenez';
update public.fa_catalog_players set canonical_key='ea:212622',slug='bund-kimmich' where id='bund-kimmich';
update public.fa_catalog_players set canonical_key='person:josko-gvardiol:croatia',slug='pl_josko_gvardiol' where id='pl_josko_gvardiol';
update public.fa_catalog_players set canonical_key='person:juan-martin-lucero:argentina',slug='bra_lucero' where id='bra_lucero';
update public.fa_catalog_players set canonical_key='ea:252371',slug='laliga-bellingham' where id='laliga-bellingham';
update public.fa_catalog_players set canonical_key='person:jules-kounde:france',slug='laliga-kounde' where id='laliga-kounde';
update public.fa_catalog_players set canonical_key='ea:246191',slug='laliga_julian_alvarez' where id='laliga_julian_alvarez';
update public.fa_catalog_players set canonical_key='person:julian-brandt:germany',slug='bund-brandt' where id='bund-brandt';
update public.fa_catalog_players set canonical_key='person:jurrien-timber:netherlands',slug='pl_jurrien_timber' where id='pl_jurrien_timber';
update public.fa_catalog_players set canonical_key='person:kai-havertz:germany',slug='pl_kai_havertz' where id='pl_kai_havertz';
update public.fa_catalog_players set canonical_key='person:kaio-jorge:brazil',slug='bra_kaio_jorge' where id='bra_kaio_jorge';
update public.fa_catalog_players set canonical_key='person:kang-in-lee:south-korea',slug='ligue1_kang_in_lee' where id='ligue1_kang_in_lee';
update public.fa_catalog_players set canonical_key='person:karim-adeyemi:germany',slug='bundes_karim_adeyemi' where id='bundes_karim_adeyemi';
update public.fa_catalog_players set canonical_key='person:kenan-yldz:turkiye',slug='seriea-yildiz' where id='seriea-yildiz';
update public.fa_catalog_players set canonical_key='person:khephren-thuram:france',slug='seriea_khephren_thuram' where id='seriea_khephren_thuram';
update public.fa_catalog_players set canonical_key='ea:247635',slug='ligue1-kvara' where id='ligue1-kvara';
update public.fa_catalog_players set canonical_key='person:kim-min-jae:south-korea',slug='bundes_kim_min_jae' where id='bundes_kim_min_jae';
update public.fa_catalog_players set canonical_key='person:kingsley-coman:france',slug='bundes_kingsley_coman' where id='bundes_kingsley_coman';
update public.fa_catalog_players set canonical_key='person:kobbie-mainoo:england',slug='pl_kobbie_mainoo' where id='pl_kobbie_mainoo';
update public.fa_catalog_players set canonical_key='person:koke:spain',slug='laliga_koke' where id='laliga_koke';
update public.fa_catalog_players set canonical_key='person:konrad-laimer:austria',slug='bundes_konrad_laimer' where id='bundes_konrad_laimer';
update public.fa_catalog_players set canonical_key='ea:231747',slug='laliga-mbappe' where id='laliga-mbappe';
update public.fa_catalog_players set canonical_key='ea:277643',slug='laliga-yamal' where id='laliga-yamal';
update public.fa_catalog_players set canonical_key='ea:231478',slug='seriea-lautaro' where id='seriea-lautaro';
update public.fa_catalog_players set canonical_key='person:leo-jardim:brazil',slug='bra_leo_jardim' where id='bra_leo_jardim';
update public.fa_catalog_players set canonical_key='person:leo-pereira:brazil',slug='bra_leo_pereira' where id='bra_leo_pereira';
update public.fa_catalog_players set canonical_key='person:leon-goretzka:germany',slug='bund-goretzka' where id='bund-goretzka';
update public.fa_catalog_players set canonical_key='person:leonardo-balerdi:argentina',slug='ligue1-balerdi' where id='ligue1-balerdi';
update public.fa_catalog_players set canonical_key='ea:158023',slug='ea27_lionel_messi' where id='ea27_lionel_messi';
update public.fa_catalog_players set canonical_key='person:lisandro-martinez:argentina',slug='pl_lisandro_martinez' where id='pl_lisandro_martinez';
update public.fa_catalog_players set canonical_key='person:lorenzo-pellegrini:italy',slug='seriea_lorenzo_pellegrini' where id='seriea_lorenzo_pellegrini';
update public.fa_catalog_players set canonical_key='person:lucas-chevalier:france',slug='ligue1-chevalier' where id='ligue1-chevalier';
update public.fa_catalog_players set canonical_key='person:lucas-hernandez:france',slug='ligue1-lucas-hernandez' where id='ligue1-lucas-hernandez';
update public.fa_catalog_players set canonical_key='person:lucas-moura:brazil',slug='bra_lucas_moura' where id='bra_lucas_moura';
update public.fa_catalog_players set canonical_key='person:luciano:brazil',slug='bra_luciano' where id='bra_luciano';
update public.fa_catalog_players set canonical_key='person:ludovic-blas:france',slug='ligue1_ludovic_blas' where id='ligue1_ludovic_blas';
update public.fa_catalog_players set canonical_key='ea:241084',slug='ea27_luis_diaz' where id='ea27_luis_diaz';
update public.fa_catalog_players set canonical_key='person:maghnes-akliouche:france',slug='ligue1_maghnas_akliouche' where id='ligue1_maghnas_akliouche';
update public.fa_catalog_players set canonical_key='person:manuel-akanji:switzerland',slug='pl_manuel_akanji' where id='pl_manuel_akanji';
update public.fa_catalog_players set canonical_key='person:manuel-locatelli:italy',slug='seriea-locatelli' where id='seriea-locatelli';
update public.fa_catalog_players set canonical_key='person:manuel-neuer:germany',slug='bund-neuer' where id='bund-neuer';
update public.fa_catalog_players set canonical_key='person:marc-andre-ter-stegen:germany',slug='laliga-ter-stegen' where id='laliga-ter-stegen';
update public.fa_catalog_players set canonical_key='person:marcel-sabitzer:austria',slug='bundes_marcel_sabitzer' where id='bundes_marcel_sabitzer';
update public.fa_catalog_players set canonical_key='ea:252154',slug='ea27_marco_carnesecchi' where id='ea27_marco_carnesecchi';
update public.fa_catalog_players set canonical_key='person:marcos-llorente:spain',slug='laliga_marcos_llorente' where id='laliga_marcos_llorente';
update public.fa_catalog_players set canonical_key='person:marcus-thuram:france',slug='seriea-thuram' where id='seriea-thuram';
update public.fa_catalog_players set canonical_key='person:marlon-freitas:brazil',slug='bra_marlon_freitas' where id='bra_marlon_freitas';
update public.fa_catalog_players set canonical_key='ea:207865',slug='ligue1-marquinhos' where id='ligue1-marquinhos';
update public.fa_catalog_players set canonical_key='person:martin-braithwaite:denmark',slug='bra_braithwaite' where id='bra_braithwaite';
update public.fa_catalog_players set canonical_key='ea:222665',slug='pl-odegaard' where id='pl-odegaard';
update public.fa_catalog_players set canonical_key='person:mason-greenwood:england',slug='ligue1-greenwood' where id='ligue1-greenwood';
update public.fa_catalog_players set canonical_key='person:matheus-pereira:brazil',slug='bra_matheus_pereira' where id='bra_matheus_pereira';
update public.fa_catalog_players set canonical_key='person:mathias-villasanti:paraguay',slug='bra_villasanti' where id='bra_villasanti';
update public.fa_catalog_players set canonical_key='person:matteo-guendouzi:france',slug='seriea_matteo_guendouzi' where id='seriea_matteo_guendouzi';
update public.fa_catalog_players set canonical_key='person:matteo-politano:italy',slug='seriea_matteo_politano' where id='seriea_matteo_politano';
update public.fa_catalog_players set canonical_key='person:mattia-zaccagni:italy',slug='seriea_mattia_zaccagni' where id='seriea_mattia_zaccagni';
update public.fa_catalog_players set canonical_key='person:maximilian-mittelstadt:germany',slug='bundes_maximilian_mittelstadt' where id='bundes_maximilian_mittelstadt';
update public.fa_catalog_players set canonical_key='person:memphis-depay:netherlands',slug='bra_memphis_depay' where id='bra_memphis_depay';
update public.fa_catalog_players set canonical_key='ea:247827',slug='bund-olise' where id='bund-olise';
update public.fa_catalog_players set canonical_key='person:michele-di-gregorio:italy',slug='seriea_michele_di_gregorio' where id='seriea_michele_di_gregorio';
update public.fa_catalog_players set canonical_key='ea:215698',slug='seriea-maignan' where id='seriea-maignan';
update public.fa_catalog_players set canonical_key='person:mikel-oyarzabal:spain',slug='laliga_mikel_oyarzabal' where id='laliga_mikel_oyarzabal';
update public.fa_catalog_players set canonical_key='person:mile-svilar:serbia',slug='seriea_mile_svilar' where id='seriea_mile_svilar';
update public.fa_catalog_players set canonical_key='ea:209331',slug='pl-salah' where id='pl-salah';
update public.fa_catalog_players set canonical_key='person:moise-kean:italy',slug='seriea_moise_kean' where id='seriea_moise_kean';
update public.fa_catalog_players set canonical_key='ea:256079',slug='pl_moises_caicedo' where id='pl_moises_caicedo';
update public.fa_catalog_players set canonical_key='person:murilo:brazil',slug='bra_murilo' where id='bra_murilo';
update public.fa_catalog_players set canonical_key='ea:247819',slug='bund-schlotterbeck' where id='bund-schlotterbeck';
update public.fa_catalog_players set canonical_key='person:nico-williams:spain',slug='laliga_nico_williams' where id='laliga_nico_williams';
update public.fa_catalog_players set canonical_key='person:nicolas-de-la-cruz:uruguay',slug='bra_de_la_cruz' where id='bra_de_la_cruz';
update public.fa_catalog_players set canonical_key='person:nicolas-seiwald:austria',slug='bundes_nicolas_seiwald' where id='bundes_nicolas_seiwald';
update public.fa_catalog_players set canonical_key='person:nicolas-tagliafico:argentina',slug='ligue1_nicolas_tagliafico' where id='ligue1_nicolas_tagliafico';
update public.fa_catalog_players set canonical_key='ea:224232',slug='seriea-barella' where id='seriea-barella';
update public.fa_catalog_players set canonical_key='ea:252145',slug='ligue1-nuno' where id='ligue1-nuno';
update public.fa_catalog_players set canonical_key='person:oihan-sancet:spain',slug='laliga_oihan_sancet' where id='laliga_oihan_sancet';
update public.fa_catalog_players set canonical_key='person:ollie-watkins:england',slug='pl-watkins' where id='pl-watkins';
update public.fa_catalog_players set canonical_key='ea:231443',slug='ligue1-dembele' where id='ligue1-dembele';
update public.fa_catalog_players set canonical_key='person:pablo-vegetti:argentina',slug='bra_pablo_vegetti' where id='bra_pablo_vegetti';
update public.fa_catalog_players set canonical_key='person:patrik-schick:czech-republic',slug='bundes_patrik_schick' where id='bundes_patrik_schick';
update public.fa_catalog_players set canonical_key='ea:278046',slug='laliga_pau_cubarsi' where id='laliga_pau_cubarsi';
update public.fa_catalog_players set canonical_key='person:paulo-dybala:argentina',slug='seriea-dybala' where id='seriea-dybala';
update public.fa_catalog_players set canonical_key='ea:251854',slug='laliga-pedri' where id='laliga-pedri';
update public.fa_catalog_players set canonical_key='person:pedro:brazil',slug='bra_pedro' where id='bra_pedro';
update public.fa_catalog_players set canonical_key='person:phil-foden:england',slug='pl-foden' where id='pl-foden';
update public.fa_catalog_players set canonical_key='person:philippe-coutinho:brazil',slug='bra_philippe_coutinho' where id='bra_philippe_coutinho';
update public.fa_catalog_players set canonical_key='person:piero-hincapie:ecuador',slug='bundes_piero_hincapie' where id='bundes_piero_hincapie';
update public.fa_catalog_players set canonical_key='person:pierre-emile-hjbjerg:denmark',slug='ligue1_pierre_emile_hojbjerg' where id='ligue1_pierre_emile_hojbjerg';
update public.fa_catalog_players set canonical_key='person:piotr-zielinski:poland',slug='seriea_piotr_zielinski' where id='seriea_piotr_zielinski';
update public.fa_catalog_players set canonical_key='person:presnel-kimpembe:france',slug='ligue1_presnel_kimpembe' where id='ligue1_presnel_kimpembe';
update public.fa_catalog_players set canonical_key='person:rafael:brazil',slug='bra_rafael' where id='bra_rafael';
update public.fa_catalog_players set canonical_key='person:rafael-leao:portugal',slug='seriea-leao' where id='seriea-leao';
update public.fa_catalog_players set canonical_key='person:ramy-bensebaini:algeria',slug='bundes_ramy_bensebaini' where id='bundes_ramy_bensebaini';
update public.fa_catalog_players set canonical_key='person:raphael-veiga:brazil',slug='bra_raphael_veiga' where id='bra_raphael_veiga';
update public.fa_catalog_players set canonical_key='ea:233419',slug='laliga-raphinha' where id='laliga-raphinha';
update public.fa_catalog_players set canonical_key='ea:251570',slug='ea27_rayan_cherki' where id='ea27_rayan_cherki';
update public.fa_catalog_players set canonical_key='person:reece-james:england',slug='pl_reece_james' where id='pl_reece_james';
update public.fa_catalog_players set canonical_key='person:riccardo-calafiori:italy',slug='pl_riccardo_calafiori' where id='pl_riccardo_calafiori';
update public.fa_catalog_players set canonical_key='person:robert-andrich:germany',slug='bundes_robert_andrich' where id='bundes_robert_andrich';
update public.fa_catalog_players set canonical_key='person:robert-arboleda:ecuador',slug='bra_arboleda' where id='bra_arboleda';
update public.fa_catalog_players set canonical_key='person:robert-lewandowski:poland',slug='laliga-lewandowski' where id='laliga-lewandowski';
update public.fa_catalog_players set canonical_key='ea:231866',slug='pl-rodri' where id='pl-rodri';
update public.fa_catalog_players set canonical_key='person:rodrigo-garro:argentina',slug='bra_rodrigo_garro' where id='bra_rodrigo_garro';
update public.fa_catalog_players set canonical_key='person:rodrygo:brazil',slug='laliga-rodrygo' where id='laliga-rodrygo';
update public.fa_catalog_players set canonical_key='person:ronald-araujo:uruguay',slug='laliga-araujo' where id='laliga-araujo';
update public.fa_catalog_players set canonical_key='ea:239818',slug='pl-ruben-dias' where id='pl-ruben-dias';
update public.fa_catalog_players set canonical_key='person:sandro-tonali:italy',slug='pl_sandro_tonali' where id='pl_sandro_tonali';
update public.fa_catalog_players set canonical_key='person:santiago-gimenez:mexico',slug='seriea_santiago_gimenez' where id='seriea_santiago_gimenez';
update public.fa_catalog_players set canonical_key='ea:237238',slug='seriea-mctominay' where id='seriea-mctominay';
update public.fa_catalog_players set canonical_key='person:seko-fofana:ivory-coast',slug='ligue1_seko_fofana' where id='ligue1_seko_fofana';
update public.fa_catalog_players set canonical_key='person:serge-gnabry:germany',slug='bund-gnabry' where id='bund-gnabry';
update public.fa_catalog_players set canonical_key='person:sergio-rochet:uruguay',slug='bra_sergio_rochet' where id='bra_sergio_rochet';
update public.fa_catalog_players set canonical_key='person:serhou-guirassy:guinea',slug='bund-guirassy' where id='bund-guirassy';
update public.fa_catalog_players set canonical_key='person:son-heung-min:south-korea',slug='pl-son' where id='pl-son';
update public.fa_catalog_players set canonical_key='person:takefusa-kubo:japan',slug='laliga_takefusa_kubo' where id='laliga_takefusa_kubo';
update public.fa_catalog_players set canonical_key='person:takumi-minamino:japan',slug='ligue1_takumi_minamino' where id='ligue1_takumi_minamino';
update public.fa_catalog_players set canonical_key='person:teun-koopmeiners:netherlands',slug='seriea_teun_koopmeiners' where id='seriea_teun_koopmeiners';
update public.fa_catalog_players set canonical_key='person:theo-hernandez:france',slug='seriea-theo' where id='seriea-theo';
update public.fa_catalog_players set canonical_key='person:thiago-silva:brazil',slug='bra_thiago_silva' where id='bra_thiago_silva';
update public.fa_catalog_players set canonical_key='ea:192119',slug='laliga-courtois' where id='laliga-courtois';
update public.fa_catalog_players set canonical_key='person:tomas-pochettino:argentina',slug='bra_pochettino' where id='bra_pochettino';
update public.fa_catalog_players set canonical_key='person:unai-simon:spain',slug='laliga_unai_simon' where id='laliga_unai_simon';
update public.fa_catalog_players set canonical_key='person:victor-boniface:nigeria',slug='bund-boniface' where id='bund-boniface';
update public.fa_catalog_players set canonical_key='ea:241651',slug='ea27_viktor_gyokeres' where id='ea27_viktor_gyokeres';
update public.fa_catalog_players set canonical_key='ea:238794',slug='ea27_vinicius' where id='ea27_vinicius';
update public.fa_catalog_players set canonical_key='ea:238794',slug='laliga-vini' where id='laliga-vini';
update public.fa_catalog_players set canonical_key='ea:203376',slug='pl-van-dijk' where id='pl-van-dijk';
update public.fa_catalog_players set canonical_key='person:vitao:brazil',slug='bra_vitao' where id='bra_vitao';
update public.fa_catalog_players set canonical_key='ea:255253',slug='ligue1-vitinha' where id='ligue1-vitinha';
update public.fa_catalog_players set canonical_key='person:vitor-roque:brazil',slug='bra_vitor_roque' where id='bra_vitor_roque';
update public.fa_catalog_players set canonical_key='person:warren-zaire-emery:france',slug='ligue1-zaire-emery' where id='ligue1-zaire-emery';
update public.fa_catalog_players set canonical_key='person:weverton:brazil',slug='bra_weverton' where id='bra_weverton';
update public.fa_catalog_players set canonical_key='person:willi-orban:hungary',slug='bundes_willi_orban' where id='bundes_willi_orban';
update public.fa_catalog_players set canonical_key='ea:243715',slug='pl-saliba' where id='pl-saliba';
update public.fa_catalog_players set canonical_key='ea:256196',slug='ligue1_willian_pacho' where id='ligue1_willian_pacho';
update public.fa_catalog_players set canonical_key='person:xavi-simons:netherlands',slug='bund-xavi' where id='bund-xavi';
update public.fa_catalog_players set canonical_key='person:yann-sommer:switzerland',slug='seriea-sommer' where id='seriea-sommer';
update public.fa_catalog_players set canonical_key='person:youssouf-fofana:france',slug='seriea_youssouf_fofana' where id='seriea_youssouf_fofana';
update public.fa_catalog_players set canonical_key='person:yuri-alberto:brazil',slug='bra_yuri_alberto' where id='bra_yuri_alberto';
update public.fa_catalog_players set canonical_key='person:andrea-pirlo:italy',slug='icon-pirlo' where id='icon-pirlo';
update public.fa_catalog_players set canonical_key='person:andres-iniesta:spain',slug='icon-iniesta' where id='icon-iniesta';
update public.fa_catalog_players set canonical_key='person:cafu:brazil',slug='icon-cafu' where id='icon-cafu';
update public.fa_catalog_players set canonical_key='person:carlos-valderrama:colombia',slug='icon-valderrama' where id='icon-valderrama';
update public.fa_catalog_players set canonical_key='person:carlos-vela:mexico',slug='icon-carlos-vela' where id='icon-carlos-vela';
update public.fa_catalog_players set canonical_key='person:clint-dempsey:united-states',slug='icon-dempsey' where id='icon-dempsey';
update public.fa_catalog_players set canonical_key='person:cristiano-ronaldo-2017:portugal',slug='icon_cristiano_ronaldo_2017' where id='icon_cristiano_ronaldo_2017';
update public.fa_catalog_players set canonical_key='person:david-beckham:england',slug='icon-beckham' where id='icon-beckham';
update public.fa_catalog_players set canonical_key='person:diego-forlan:uruguay',slug='icon-forlan' where id='icon-forlan';
update public.fa_catalog_players set canonical_key='person:diego-maradona:argentina',slug='icon-maradona' where id='icon-maradona';
update public.fa_catalog_players set canonical_key='person:eusebio:portugal',slug='icon-eusebio' where id='icon-eusebio';
update public.fa_catalog_players set canonical_key='person:frank-lampard:england',slug='icon-lampard' where id='icon-lampard';
update public.fa_catalog_players set canonical_key='person:franz-beckenbauer:germany',slug='icon-beckenbauer' where id='icon-beckenbauer';
update public.fa_catalog_players set canonical_key='person:gabriel-batistuta:argentina',slug='icon-batistuta' where id='icon-batistuta';
update public.fa_catalog_players set canonical_key='person:gianluigi-buffon:italy',slug='icon-buffon' where id='icon-buffon';
update public.fa_catalog_players set canonical_key='person:hugo-sanchez:mexico',slug='icon-hugo-sanchez' where id='icon-hugo-sanchez';
update public.fa_catalog_players set canonical_key='person:iker-casillas:spain',slug='icon-casillas' where id='icon-casillas';
update public.fa_catalog_players set canonical_key='person:javier-zanetti:argentina',slug='icon-zanetti' where id='icon-zanetti';
update public.fa_catalog_players set canonical_key='person:johan-cruyff:netherlands',slug='icon-cruyff' where id='icon-cruyff';
update public.fa_catalog_players set canonical_key='person:jorge-campos:mexico',slug='icon-jorge-campos' where id='icon-jorge-campos';
update public.fa_catalog_players set canonical_key='person:juan-roman-riquelme:argentina',slug='icon-riquelme' where id='icon-riquelme';
update public.fa_catalog_players set canonical_key='person:kaka:brazil',slug='icon-kaka' where id='icon-kaka';
update public.fa_catalog_players set canonical_key='person:keylor-navas:costa-rica',slug='icon-keylor' where id='icon-keylor';
update public.fa_catalog_players set canonical_key='person:landon-donovan:united-states',slug='icon-donovan' where id='icon-donovan';
update public.fa_catalog_players set canonical_key='person:marco-van-basten:netherlands',slug='icon-vanbasten' where id='icon-vanbasten';
update public.fa_catalog_players set canonical_key='person:neymar-jr:brazil',slug='bra_neymar' where id='bra_neymar';
update public.fa_catalog_players set canonical_key='person:paolo-maldini:italy',slug='icon-maldini' where id='icon-maldini';
update public.fa_catalog_players set canonical_key='person:pele:brazil',slug='icon-pele' where id='icon-pele';
update public.fa_catalog_players set canonical_key='person:rafael-marquez:mexico',slug='icon-rafa-marquez' where id='icon-rafa-marquez';
update public.fa_catalog_players set canonical_key='person:rivaldo:brazil',slug='icon-rivaldo' where id='icon-rivaldo';
update public.fa_catalog_players set canonical_key='person:roberto-carlos:brazil',slug='icon-roberto-carlos' where id='icon-roberto-carlos';
update public.fa_catalog_players set canonical_key='person:romario:brazil',slug='icon-romario' where id='icon-romario';
update public.fa_catalog_players set canonical_key='person:ronaldinho:brazil',slug='icon-ronaldinho' where id='icon-ronaldinho';
update public.fa_catalog_players set canonical_key='person:ronaldo-nazario:brazil',slug='icon-ronaldo' where id='icon-ronaldo';
update public.fa_catalog_players set canonical_key='person:steven-gerrard:england',slug='icon-gerrard' where id='icon-gerrard';
update public.fa_catalog_players set canonical_key='person:thierry-henry:france',slug='icon-henry' where id='icon-henry';
update public.fa_catalog_players set canonical_key='person:tim-howard:united-states',slug='icon-howard' where id='icon-howard';
update public.fa_catalog_players set canonical_key='person:xavi:spain',slug='icon-xavi' where id='icon-xavi';
update public.fa_catalog_players set canonical_key='person:zico:brazil',slug='icon-zico' where id='icon-zico';
update public.fa_catalog_players set canonical_key='person:zinedine-zidane:france',slug='icon-zidane' where id='icon-zidane';
update public.fa_catalog_players set enabled=false,metadata=metadata||jsonb_build_object('duplicate_of','ea27_vinicius','deduplicated_at','2026-09-22') where id='laliga-vini';
update public.fa_catalog_players set enabled=false,metadata=metadata||jsonb_build_object('duplicate_of','ea27_gabriel','deduplicated_at','2026-09-22') where id='pl-gabriel';
update public.fa_catalog_players set name='Vinícius Jr.' where id='ea27_vinicius';
update public.fa_catalog_players set name='Gabriel Magalhães' where id='ea27_gabriel';
update public.fa_catalog_players set overall=85,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='bund-grimaldo';
update public.fa_catalog_players set overall=85,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='laliga-tchouameni';
update public.fa_catalog_players set overall=84,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='ligue1-barcola';
update public.fa_catalog_players set overall=87,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='pl-palmer';
update public.fa_catalog_players set overall=84,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='laliga-camavinga';
update public.fa_catalog_players set overall=86,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='seriea-calhanoglu';
update public.fa_catalog_players set overall=86,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='laliga-kounde';
update public.fa_catalog_players set overall=85,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='bund-neuer';
update public.fa_catalog_players set overall=86,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='pl-foden';
update public.fa_catalog_players set overall=86,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='seriea-leao';
update public.fa_catalog_players set overall=87,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='laliga-lewandowski';
update public.fa_catalog_players set overall=86,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='laliga-rodrygo';
update public.fa_catalog_players set overall=86,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='seriea-theo';
update public.fa_catalog_players set overall=84,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='bund-xavi';
update public.fa_catalog_players set overall=90,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='icon-pirlo';
update public.fa_catalog_players set overall=90,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='icon-cafu';
update public.fa_catalog_players set overall=90,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='icon-dempsey';
update public.fa_catalog_players set overall=90,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='icon-casillas';
update public.fa_catalog_players set overall=90,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='icon-maldini';
update public.fa_catalog_players set overall=90,metadata=metadata||jsonb_build_object('previous_overall',overall,'previous_rating_source',metadata->>'rating_source','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_reviewed_at','2026-09-22') where id='icon-ronaldinho';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-garrincha','Garrincha','Botafogo','LEGENDS','Brazil','PD',array['PE']::text[],96,'ICON','person:garrincha:brazil','icon-garrincha',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-ferenc-puskas','Ferenc Puskás','Real Madrid','LEGENDS','Hungary','ATA',array['MEI']::text[],96,'ICON','person:ferenc-puskas:hungary','icon-ferenc-puskas',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-lev-yashin','Lev Yashin','Dynamo Moscow','LEGENDS','Russia','GOL',array[]::text[],95,'ICON','person:lev-yashin:russia','icon-lev-yashin',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-lothar-matthaus','Lothar Matthäus','Bayern München','LEGENDS','Germany','MC',array['VOL','ZAG']::text[],95,'ICON','person:lothar-matthaus:germany','icon-lothar-matthaus',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-roberto-baggio','Roberto Baggio','Juventus','LEGENDS','Italy','MEI',array['ATA']::text[],94,'ICON','person:roberto-baggio:italy','icon-roberto-baggio',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-alessandro-nesta','Alessandro Nesta','Milan','LEGENDS','Italy','ZAG',array[]::text[],93,'ICON','person:alessandro-nesta:italy','icon-alessandro-nesta',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-luis-figo','Luís Figo','Real Madrid','LEGENDS','Portugal','PD',array['PE','MEI']::text[],93,'ICON','person:luis-figo:portugal','icon-luis-figo',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-didier-drogba','Didier Drogba','Chelsea','LEGENDS','Côte d’Ivoire','ATA',array[]::text[],92,'ICON','person:didier-drogba:cote-divoire','icon-didier-drogba',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-eric-cantona','Eric Cantona','Manchester United','LEGENDS','France','ATA',array['MEI']::text[],93,'ICON','person:eric-cantona:france','icon-eric-cantona',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-andriy-shevchenko','Andriy Shevchenko','Milan','LEGENDS','Ukraine','ATA',array[]::text[],93,'ICON','person:andriy-shevchenko:ukraine','icon-andriy-shevchenko',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-wayne-rooney','Wayne Rooney','Manchester United','LEGENDS','England','ATA',array['MEI']::text[],92,'ICON','person:wayne-rooney:england','icon-wayne-rooney',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-franco-baresi','Franco Baresi','Milan','LEGENDS','Italy','ZAG',array['VOL']::text[],95,'ICON','person:franco-baresi:italy','icon-franco-baresi',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-clarence-seedorf','Clarence Seedorf','Milan','LEGENDS','Netherlands','MC',array['MEI','VOL']::text[],92,'ICON','person:clarence-seedorf:netherlands','icon-clarence-seedorf',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-ruud-gullit','Ruud Gullit','Milan','LEGENDS','Netherlands','MEI',array['MC','ATA']::text[],95,'ICON','person:ruud-gullit:netherlands','icon-ruud-gullit',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-frank-rijkaard','Frank Rijkaard','Milan','LEGENDS','Netherlands','VOL',array['ZAG','MC']::text[],93,'ICON','person:frank-rijkaard:netherlands','icon-frank-rijkaard',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-paul-scholes','Paul Scholes','Manchester United','LEGENDS','England','MC',array['MEI']::text[],92,'ICON','person:paul-scholes:england','icon-paul-scholes',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-dennis-bergkamp','Dennis Bergkamp','Arsenal','LEGENDS','Netherlands','MEI',array['ATA']::text[],93,'ICON','person:dennis-bergkamp:netherlands','icon-dennis-bergkamp',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-kenny-dalglish','Kenny Dalglish','Liverpool','LEGENDS','Scotland','ATA',array['MEI']::text[],93,'ICON','person:kenny-dalglish:scotland','icon-kenny-dalglish',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-samuel-etoo','Samuel Eto’o','Barcelona','LEGENDS','Cameroon','ATA',array['PD']::text[],93,'ICON','person:samuel-etoo:cameroon','icon-samuel-etoo',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,metadata) values ('icon-miroslav-klose','Miroslav Klose','Bayern München','LEGENDS','Germany','ATA',array[]::text[],91,'ICON','person:miroslav-klose:germany','icon-miroslav-klose',jsonb_build_object('rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'catalog_batch','icons_20260922'));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('cristiano-ronaldo-2008-special','Cristiano Ronaldo','Manchester United','Premier League','Portugal','PE',array['PD','ATA']::text[],96,'SPECIAL','person:cristiano-ronaldo:portugal','cristiano-ronaldo-2008-special',2008,'2008',jsonb_build_object('season_year',2008,'version_label','2008','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='cristiano-ronaldo-2008-special' and source.id='icon_cristiano_ronaldo_2017';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('cristiano-ronaldo-2014-special','Cristiano Ronaldo','Real Madrid','La Liga','Portugal','PE',array['ATA']::text[],98,'SPECIAL','person:cristiano-ronaldo:portugal','cristiano-ronaldo-2014-special',2014,'2014',jsonb_build_object('season_year',2014,'version_label','2014','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='cristiano-ronaldo-2014-special' and source.id='icon_cristiano_ronaldo_2017';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('cristiano-ronaldo-2017-special','Cristiano Ronaldo','Real Madrid','La Liga','Portugal','ATA',array['PE']::text[],96,'SPECIAL','person:cristiano-ronaldo:portugal','cristiano-ronaldo-2017-special',2017,'2017',jsonb_build_object('season_year',2017,'version_label','2017','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='cristiano-ronaldo-2017-special' and source.id='icon_cristiano_ronaldo_2017';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('lionel-messi-2009-special','Lionel Messi','Barcelona','La Liga','Argentina','PD',array['ATA']::text[],96,'SPECIAL','ea:158023','lionel-messi-2009-special',2009,'2009',jsonb_build_object('season_year',2009,'version_label','2009','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='lionel-messi-2009-special' and source.id='ea27_lionel_messi';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('lionel-messi-2012-special','Lionel Messi','Barcelona','La Liga','Argentina','ATA',array['PD','MEI']::text[],99,'SPECIAL','ea:158023','lionel-messi-2012-special',2012,'2012',jsonb_build_object('season_year',2012,'version_label','2012','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='lionel-messi-2012-special' and source.id='ea27_lionel_messi';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('lionel-messi-2014-special','Lionel Messi','Barcelona','La Liga','Argentina','ATA',array['PD','MEI']::text[],97,'SPECIAL','ea:158023','lionel-messi-2014-special',2014,'2014',jsonb_build_object('season_year',2014,'version_label','2014','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='lionel-messi-2014-special' and source.id='ea27_lionel_messi';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('lionel-messi-2015-special','Lionel Messi','Barcelona','La Liga','Argentina','PD',array['ATA','MEI']::text[],98,'SPECIAL','ea:158023','lionel-messi-2015-special',2015,'2015',jsonb_build_object('season_year',2015,'version_label','2015','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='lionel-messi-2015-special' and source.id='ea27_lionel_messi';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('neymar-2011-special','Neymar','Santos FC','Brasileirão','Brazil','PE',array['ATA']::text[],94,'SPECIAL','person:neymar-jr:brazil','neymar-2011-special',2011,'2011',jsonb_build_object('season_year',2011,'version_label','2011','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='neymar-2011-special' and source.id='bra_neymar';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('neymar-2015-special','Neymar','Barcelona','La Liga','Brazil','PE',array['ATA','MEI']::text[],96,'SPECIAL','person:neymar-jr:brazil','neymar-2015-special',2015,'2015',jsonb_build_object('season_year',2015,'version_label','2015','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='neymar-2015-special' and source.id='bra_neymar';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('neymar-2020-special','Neymar','Paris SG','Ligue 1','Brazil','MEI',array['PE','ATA']::text[],95,'SPECIAL','person:neymar-jr:brazil','neymar-2020-special',2020,'2020',jsonb_build_object('season_year',2020,'version_label','2020','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='neymar-2020-special' and source.id='bra_neymar';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('ronaldinho-2005-special','Ronaldinho','Barcelona','La Liga','Brazil','PE',array['MEI']::text[],97,'SPECIAL','person:ronaldinho:brazil','ronaldinho-2005-special',2005,'2005',jsonb_build_object('season_year',2005,'version_label','2005','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='ronaldinho-2005-special' and source.id='icon-ronaldinho';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('kaka-2007-special','Kaká','Milan','Serie A','Brazil','MEI',array['ATA']::text[],96,'SPECIAL','person:kaka:brazil','kaka-2007-special',2007,'2007',jsonb_build_object('season_year',2007,'version_label','2007','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='kaka-2007-special' and source.id='icon-kaka';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('ronaldo-nazario-2002-special','Ronaldo Nazário','Real Madrid / Brasil','La Liga','Brazil','ATA',array[]::text[],97,'SPECIAL','person:ronaldo-nazario:brazil','ronaldo-nazario-2002-special',2002,'2002',jsonb_build_object('season_year',2002,'version_label','2002','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='ronaldo-nazario-2002-special' and source.id='icon-ronaldo';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('romario-1994-special','Romário','Barcelona / Brasil','La Liga','Brazil','ATA',array[]::text[],96,'SPECIAL','person:romario:brazil','romario-1994-special',1994,'1994',jsonb_build_object('season_year',1994,'version_label','1994','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='romario-1994-special' and source.id='icon-romario';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('rivaldo-2002-special','Rivaldo','Brasil / Milan','Serie A','Brazil','MEI',array['ATA','PE']::text[],95,'SPECIAL','person:rivaldo:brazil','rivaldo-2002-special',2002,'2002',jsonb_build_object('season_year',2002,'version_label','2002','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='rivaldo-2002-special' and source.id='icon-rivaldo';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('thierry-henry-2004-special','Thierry Henry','Arsenal','Premier League','France','ATA',array['PE']::text[],95,'SPECIAL','person:thierry-henry:france','thierry-henry-2004-special',2004,'2004',jsonb_build_object('season_year',2004,'version_label','2004','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='thierry-henry-2004-special' and source.id='icon-henry';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('luis-suarez-2015-special','Luis Suárez','Barcelona','La Liga','Uruguay','ATA',array[]::text[],95,'SPECIAL','person:luis-suarez:uruguay','luis-suarez-2015-special',2015,'2015/16',jsonb_build_object('season_year',2015,'version_label','2015/16','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('gareth-bale-2014-special','Gareth Bale','Real Madrid','La Liga','Wales','PD',array['PE']::text[],94,'SPECIAL','person:gareth-bale:wales','gareth-bale-2014-special',2014,'2014',jsonb_build_object('season_year',2014,'version_label','2014','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('luka-modric-2018-special','Luka Modrić','Real Madrid','La Liga','Croatia','MC',array['MEI']::text[],94,'SPECIAL','person:luka-modric:croatia','luka-modric-2018-special',2018,'2018',jsonb_build_object('season_year',2018,'version_label','2018','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('xavi-2011-special','Xavi','Barcelona','La Liga','Spain','MC',array['VOL','MEI']::text[],95,'SPECIAL','person:xavi:spain','xavi-2011-special',2011,'2011',jsonb_build_object('season_year',2011,'version_label','2011','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='xavi-2011-special' and source.id='icon-xavi';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('andres-iniesta-2010-special','Andrés Iniesta','Barcelona','La Liga','Spain','MC',array['MEI','PE']::text[],95,'SPECIAL','person:andres-iniesta:spain','andres-iniesta-2010-special',2010,'2010',jsonb_build_object('season_year',2010,'version_label','2010','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='andres-iniesta-2010-special' and source.id='icon-iniesta';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('kylian-mbappe-2022-special','Kylian Mbappé','Paris SG / França','Ligue 1','France','ATA',array['PE']::text[],96,'SPECIAL','ea:231747','kylian-mbappe-2022-special',2022,'2022',jsonb_build_object('season_year',2022,'version_label','2022','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='kylian-mbappe-2022-special' and source.id='laliga-mbappe';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('mohamed-salah-2018-special','Mohamed Salah','Liverpool','Premier League','Egypt','PD',array['ATA']::text[],94,'SPECIAL','ea:209331','mohamed-salah-2018-special',2018,'2018',jsonb_build_object('season_year',2018,'version_label','2018','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='mohamed-salah-2018-special' and source.id='pl-salah';
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('eden-hazard-2018-special','Eden Hazard','Chelsea','Premier League','Belgium','PE',array['MEI']::text[],94,'SPECIAL','person:eden-hazard:belgium','eden-hazard-2018-special',2018,'2018',jsonb_build_object('season_year',2018,'version_label','2018','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
insert into public.fa_catalog_players(id,name,club,league,nationality,primary_position,secondary_positions,overall,player_type,canonical_key,slug,season_year,version_label,metadata) values ('robert-lewandowski-2020-special','Robert Lewandowski','Bayern München','Bundesliga','Poland','ATA',array[]::text[],96,'SPECIAL','person:robert-lewandowski:poland','robert-lewandowski-2020-special',2020,'2020',jsonb_build_object('season_year',2020,'version_label','2020','theme','world-stars','rating_source','Football Auction game design','rating_status','custom_game_design','not_official_ea_fc27',true,'rating_source_url',null,'image_era_verified',false));
update public.fa_catalog_players target set image_url=source.image_url,image_source_url=source.image_source_url,image_license=source.image_license,metadata=source.metadata||target.metadata||jsonb_build_object('image_reused_from',source.id,'image_note','Portrait reused; not claimed to depict the historical season') from public.fa_catalog_players source where target.id='robert-lewandowski-2020-special' and source.id='laliga-lewandowski';
alter table public.fa_catalog_players alter column canonical_key set not null,alter column slug set not null;
create unique index fa_catalog_slug_unique on public.fa_catalog_players(slug);
create unique index fa_catalog_identity_version_unique on public.fa_catalog_players(canonical_key,player_type,coalesce(season_year,0)) where enabled;
create unique index fa_catalog_base_external_unique on public.fa_catalog_players((metadata->>'ea_fc27_id')) where enabled and player_type='ACTIVE' and metadata->>'ea_fc27_id' is not null;
alter table public.fa_catalog_players add constraint fa_catalog_special_year check(player_type<>'SPECIAL' or (season_year between 1900 and 2100 and version_label is not null));
alter table public.fa_catalog_players add constraint fa_catalog_icon_minimum check(player_type<>'ICON' or overall>=90);
-- A canonical ID is mandatory. Names are never a uniqueness key (homonyms exist).
-- Existing rooms opt out; newly created rooms opt in via v3.
alter table public.fa_rooms add column allow_base boolean not null default true,add column allow_specials boolean not null default false;
CREATE OR REPLACE FUNCTION private.fa_catalog_allowed_for_room(p_room_id uuid, p_catalog_id text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select exists(
    select 1
    from public.fa_rooms r
    join public.fa_catalog_players c on c.id=p_catalog_id
    where r.id=p_room_id
      and c.enabled=true
      and c.overall between r.min_overall and r.max_overall
      and (r.allow_icons or c.player_type<>'ICON')
      and (r.allow_base or c.player_type<>'ACTIVE')
      and (r.allow_specials or c.player_type<>'SPECIAL')
      and (not r.active_only or c.player_type='ACTIVE')
      and (r.allowed_leagues is null or c.league=any(r.allowed_leagues))
  );
$function$;

CREATE OR REPLACE FUNCTION public.fa_start_next_auction(p_room_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_catalog public.fa_catalog_players%rowtype;
  v_room_player_id text;
  v_auction public.fa_auctions%rowtype;
  v_member public.fa_room_members%rowtype;
  v_slot text;
  v_incomplete_rosters integer;
  v_roster_target integer;
  v_total integer;
  v_auto_added integer:=0;
  v_has_missing_starters boolean;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  update public.fa_room_members
  set last_seen_at=now()
  where room_id=p_room_id and user_id=v_user;

  perform private.fa_cleanup_inactive_room(p_room_id);

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.host_user_id<>v_user then raise exception 'host only'; end if;

  if exists(
    select 1
    from public.fa_auctions a
    where a.room_id=p_room_id and a.status in('interest','bidding')
  ) then
    raise exception 'an auction is already active';
  end if;

  if (
    select count(*)
    from public.fa_room_members m
    where m.room_id=p_room_id
      and not m.is_spectator
      and m.kicked_at is null
  )<2 then
    raise exception 'at least two players are required';
  end if;

  v_roster_target:=(case when v_room.mode='futsal' then 5 else 11 end)+v_room.reserve_count;

  select count(*) into v_incomplete_rosters
  from public.fa_room_members m
  where m.room_id=p_room_id
    and not m.is_spectator
    and m.kicked_at is null
    and (
      v_room.disconnect_mode='bot'
      or m.last_seen_at>=now()-interval '30 seconds'
    )
    and (
      select count(*) from public.fa_squad_players s where s.member_id=m.id
    )<v_roster_target;

  if v_incomplete_rosters=0 then
    return jsonb_build_object(
      'waiting_for_lineups',true,
      'message','All active rosters are complete. Organize the board and finalize.'
    );
  end if;

  if v_incomplete_rosters=1 then
    select m.* into v_member
    from public.fa_room_members m
    where m.room_id=p_room_id
      and not m.is_spectator
      and m.kicked_at is null
      and (
        v_room.disconnect_mode='bot'
        or m.last_seen_at>=now()-interval '30 seconds'
      )
      and (
        select count(*) from public.fa_squad_players s where s.member_id=m.id
      )<v_roster_target
    order by m.joined_at
    limit 1
    for update;

    loop
      select count(*) into v_total
      from public.fa_squad_players s
      where s.member_id=v_member.id;

      exit when v_total>=v_roster_target;

      if not private.fa_member_starting_complete(v_member.id) then
        select c.* into v_catalog
        from public.fa_catalog_players c
        where private.fa_catalog_allowed_for_room(p_room_id,c.id)
          and not exists(
            select 1
            from public.fa_players p
            where p.room_id=p_room_id and p.catalog_id=c.id
          )
          and private.fa_member_needs_starting_position(v_member.id,c.primary_position)
        order by random()
        limit 1;
      else
        select c.* into v_catalog
        from public.fa_catalog_players c
        where private.fa_catalog_allowed_for_room(p_room_id,c.id)
          and not exists(
            select 1
            from public.fa_players p
            where p.room_id=p_room_id and p.catalog_id=c.id
          )
          and private.fa_member_can_take_position(v_member.id,c.primary_position)
        order by random()
        limit 1;
      end if;

      if v_catalog.id is null then
        raise exception 'not enough eligible catalog players for room settings';
      end if;

      v_slot:=private.fa_slot_for_position(v_member.id,v_catalog.primary_position);
      if v_slot is null then raise exception 'no eligible slot available'; end if;

      v_room_player_id:=extensions.gen_random_uuid()::text;

      insert into public.fa_players(
        id,room_id,created_by,catalog_id,name,short_name,club,league,nationality,
        primary_position,secondary_positions,overall,player_type,image_url,metadata
      )
      values(
        v_room_player_id,p_room_id,v_user,v_catalog.id,v_catalog.name,v_catalog.name,
        v_catalog.club,v_catalog.league,v_catalog.nationality,v_catalog.primary_position,
        v_catalog.secondary_positions,v_catalog.overall,v_catalog.player_type,v_catalog.image_url,
        v_catalog.metadata || jsonb_build_object(
          'catalog_id',v_catalog.id,
          'legend_region',v_catalog.legend_region,
          'rating_status',v_catalog.metadata->>'rating_status',
          'auto_assigned',true,
          'auto_assignment_reason','last_incomplete_roster'
        )
      );

      insert into public.fa_squad_players(member_id,player_id,slot_key,is_bench)
      values(v_member.id,v_room_player_id,v_slot,v_slot like 'BENCH%');

      v_auto_added:=v_auto_added+1;
      v_catalog:=null;
    end loop;

    return jsonb_build_object(
      'auto_completed_last',true,
      'member_id',v_member.id,
      'players_added',v_auto_added,
      'lineup_ready',private.fa_member_starting_complete(v_member.id),
      'roster_ready',true,
      'requires_manual_finalize',true
    );
  end if;

  select exists(
    select 1
    from public.fa_room_members m
    where m.room_id=p_room_id
      and not m.is_spectator
      and m.kicked_at is null
      and (
        v_room.disconnect_mode='bot'
        or m.last_seen_at>=now()-interval '30 seconds'
      )
      and (
        select count(*) from public.fa_squad_players s where s.member_id=m.id
      )<v_roster_target
      and not private.fa_member_starting_complete(m.id)
  ) into v_has_missing_starters;

  if v_has_missing_starters then
    select c.* into v_catalog
    from public.fa_catalog_players c
    where private.fa_catalog_allowed_for_room(p_room_id,c.id)
      and not exists(
        select 1 from public.fa_players p
        where p.room_id=p_room_id and p.catalog_id=c.id
      )
      and exists(
        select 1
        from public.fa_room_members m
        where m.room_id=p_room_id
          and not m.is_spectator
          and m.kicked_at is null
          and (
            v_room.disconnect_mode='bot'
            or m.last_seen_at>=now()-interval '30 seconds'
          )
          and (
            select count(*) from public.fa_squad_players s where s.member_id=m.id
          )<v_roster_target
          and private.fa_member_needs_starting_position(m.id,c.primary_position)
      )
    order by random()
    limit 1;
  else
    select c.* into v_catalog
    from public.fa_catalog_players c
    where private.fa_catalog_allowed_for_room(p_room_id,c.id)
      and not exists(
        select 1 from public.fa_players p
        where p.room_id=p_room_id and p.catalog_id=c.id
      )
      and exists(
        select 1
        from public.fa_room_members m
        where m.room_id=p_room_id
          and not m.is_spectator
          and m.kicked_at is null
          and (
            v_room.disconnect_mode='bot'
            or m.last_seen_at>=now()-interval '30 seconds'
          )
          and (
            select count(*) from public.fa_squad_players s where s.member_id=m.id
          )<v_roster_target
          and private.fa_member_can_take_position(m.id,c.primary_position)
      )
    order by random()
    limit 1;
  end if;

  if v_catalog.id is null then
    return jsonb_build_object(
      'waiting_for_lineups',true,
      'message','No eligible players remain for the room settings.'
    );
  end if;

  v_room_player_id:=extensions.gen_random_uuid()::text;

  insert into public.fa_players(
    id,room_id,created_by,catalog_id,name,short_name,club,league,nationality,
    primary_position,secondary_positions,overall,player_type,image_url,metadata
  )
  values(
    v_room_player_id,p_room_id,v_user,v_catalog.id,v_catalog.name,v_catalog.name,
    v_catalog.club,v_catalog.league,v_catalog.nationality,v_catalog.primary_position,
    v_catalog.secondary_positions,v_catalog.overall,v_catalog.player_type,v_catalog.image_url,
    v_catalog.metadata || jsonb_build_object(
      'catalog_id',v_catalog.id,
      'legend_region',v_catalog.legend_region,
      'rating_status',v_catalog.metadata->>'rating_status'
    )
  );

  update public.fa_rooms set status='auction' where id=p_room_id;

  insert into public.fa_auctions(room_id,player_id)
  values(p_room_id,v_room_player_id)
  returning * into v_auction;

  insert into public.fa_player_interest(auction_id,member_id,wants)
  select v_auction.id,m.id,false
  from public.fa_room_members m
  where m.room_id=p_room_id
    and (
      m.is_spectator
      or m.kicked_at is not null
      or not private.fa_member_can_take_position(m.id,v_catalog.primary_position)
      or (
        v_room.disconnect_mode='skip'
        and m.last_seen_at<now()-interval '30 seconds'
      )
    )
  on conflict do nothing;

  -- Em BOT, responde imediatamente pelos desconectados elegíveis.
  if v_room.disconnect_mode='bot' then
    perform private.fa_cleanup_inactive_room(p_room_id);
  end if;

  return(select to_jsonb(a) from public.fa_auctions a where a.id=v_auction.id);
end;
$function$;

CREATE OR REPLACE FUNCTION public.fa_create_room_v3(p_display_name text, p_mode text, p_budget integer, p_reserve_count integer DEFAULT NULL::integer, p_allow_icons boolean DEFAULT true, p_min_overall integer DEFAULT 1, p_max_overall integer DEFAULT 100, p_active_only boolean DEFAULT false, p_allowed_leagues text[] DEFAULT NULL::text[], p_disconnect_mode text DEFAULT 'skip'::text, p_spectators_allowed boolean DEFAULT true, p_password text DEFAULT NULL::text, p_allow_base boolean DEFAULT true, p_allow_specials boolean DEFAULT true)
 RETURNS TABLE(room_id uuid, room_code text, member_id uuid)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user uuid:=auth.uid();
  v_room_id uuid;
  v_member_id uuid;
  v_code text;
  v_reserves integer;
  v_password_hash text;
begin
  if not (coalesce(p_allow_base,false) or (coalesce(p_allow_icons,false) and not p_active_only) or (coalesce(p_allow_specials,false) and not p_active_only)) then raise exception 'Select at least one card type'; end if;
  if v_user is null then raise exception 'authentication required'; end if;
  if p_mode not in ('football','futsal') then raise exception 'invalid mode'; end if;
  if p_budget<1 or p_budget>100000 then raise exception 'invalid budget'; end if;
  if char_length(trim(p_display_name))<1 or char_length(trim(p_display_name))>24 then
    raise exception 'invalid display name';
  end if;
  if p_min_overall<1 or p_max_overall>100 or p_min_overall>p_max_overall then
    raise exception 'invalid overall range';
  end if;
  if p_disconnect_mode not in ('skip','bot') then raise exception 'invalid disconnect mode'; end if;

  v_reserves:=coalesce(p_reserve_count,case when p_mode='futsal' then 2 else 5 end);
  if v_reserves<0 or v_reserves>5 then raise exception 'invalid reserve count'; end if;

  if p_password is not null and trim(p_password)<>'' then
    if char_length(p_password)>32 then raise exception 'password too long'; end if;
    v_password_hash:=extensions.crypt(p_password,extensions.gen_salt('bf'));
  end if;

  loop
    v_code:=upper(substr(encode(extensions.gen_random_bytes(6),'hex'),1,6));
    exit when not exists(select 1 from public.fa_rooms r where r.code=v_code);
  end loop;

  insert into public.fa_rooms(
    code,host_user_id,mode,budget,max_players,reserve_count,allow_icons,
    min_overall,max_overall,active_only,allowed_leagues,disconnect_mode,
    spectators_allowed,password_hash,allow_base,allow_specials
  )
  values(
    v_code,v_user,p_mode,p_budget,2147483647,v_reserves,p_allow_icons,
    p_min_overall,p_max_overall,p_active_only,
    case when p_allowed_leagues is null or cardinality(p_allowed_leagues)=0 then null else p_allowed_leagues end,
    p_disconnect_mode,p_spectators_allowed,v_password_hash,p_allow_base,p_allow_specials
  )
  returning id into v_room_id;

  insert into public.fa_room_members(
    room_id,user_id,display_name,balance,is_host,ready,is_spectator,last_seen_at
  )
  values(v_room_id,v_user,trim(p_display_name),p_budget,true,false,false,now())
  returning id into v_member_id;

  return query select v_room_id,v_code,v_member_id;
end;
$function$;

revoke all on function public.fa_create_room_v3(text,text,integer,integer,boolean,integer,integer,boolean,text[],text,boolean,text,boolean,boolean) from public,anon;
grant execute on function public.fa_create_room_v3(text,text,integer,integer,boolean,integer,integer,boolean,text[],text,boolean,text,boolean,boolean) to authenticated;
-- Private functions have no client EXECUTE grants. All writes go through checked RPCs.
create function private.fa_x1_penalty(pos text, slot text, mode text) returns integer language plpgsql immutable set search_path='' as $$
begin
 pos:=case upper(trim(pos)) when 'MD' then 'PD' when 'ME' then 'PE' when 'SA' then 'ATA' else upper(trim(pos)) end;
 if slot like 'BENCH%' then return 0; end if;
 if mode='futsal' then
  if slot='GOL' then return case when pos='GOL' then 0 else 12 end; end if;
  if pos='GOL' then return 12; end if;
  if slot='FIXO' then return case when pos in ('ZAG','VOL','LD','LE','MC') then 0 when pos in ('MEI','PD','PE') then 2 else 3 end; end if;
  if slot='ALAE' then return case when pos in ('PE','LE','MC','MEI') then 0 when pos in ('PD','LD','VOL') then 2 else 3 end; end if;
  if slot='ALAD' then return case when pos in ('PD','LD','MC','MEI') then 0 when pos in ('PE','LE','VOL') then 2 else 3 end; end if;
  if slot='PIVO' then return case when pos in ('ATA','MEI') then 0 when pos in ('PD','PE','MC') then 2 else 4 end; end if;
  return 4;
 end if;
 if pos=slot or (pos='ZAG' and slot in ('ZAG1','ZAG2')) then return 0; end if;
 if slot in ('ZAG1','ZAG2') then slot:='ZAG'; end if;
 if (pos in ('LD','LE','ZAG','VOL') and slot in ('LD','LE','ZAG','VOL')) or (pos in ('VOL','MC','MEI') and slot in ('VOL','MC','MEI')) or (pos in ('MEI','PD','PE','ATA') and slot in ('MEI','PD','PE','ATA')) then return 2; end if;
 return 4;
end $$;

create function private.fa_x1_snapshot(p_member uuid) returns jsonb language sql stable set search_path='' as $$
 select jsonb_build_object('id',m.id,'name',m.display_name,'players',coalesce((
  select jsonb_agg(jsonb_build_object('id',p.id,'name',p.name||case when p.player_type='SPECIAL' then ' '||coalesce(p.metadata->>'version_label','') else '' end,
   'slot',s.slot_key,'overall',p.overall,'penalty',private.fa_x1_penalty(p.primary_position,s.slot_key,r.mode)) order by s.slot_key collate "C")
  from public.fa_squad_players s join public.fa_players p on p.id=s.player_id where s.member_id=m.id),'[]'::jsonb))
 from public.fa_room_members m join public.fa_rooms r on r.id=m.room_id where m.id=p_member;
$$;

create function private.fa_x1_strength(t jsonb) returns jsonb language plpgsql immutable set search_path='' as $$
declare av double precision; atk double precision; def double precision; mid double precision; gk double precision; bench double precision; fit double precision; strength double precision; cnt integer;
begin
 select count(*),avg(greatest(1,(p->>'overall')::double precision-(p->>'penalty')::double precision)),
 avg(greatest(1,(p->>'overall')::double precision-3*(p->>'penalty')::double precision)) into cnt,av,fit from jsonb_array_elements(t->'players') p where p->>'slot' not like 'BENCH%';
 if cnt not in (5,11) then raise exception 'Incomplete starting lineup'; end if;
 select avg(greatest(1,(p->>'overall')::double precision-(p->>'penalty')::double precision)) into atk from jsonb_array_elements(t->'players') p where p->>'slot' in ('ATA','PE','PD','MEI','PIVO','ALAE','ALAD');
 select avg(greatest(1,(p->>'overall')::double precision-(p->>'penalty')::double precision)) into def from jsonb_array_elements(t->'players') p where p->>'slot' in ('LE','LD','ZAG1','ZAG2','VOL','FIXO');
 select avg(greatest(1,(p->>'overall')::double precision-(p->>'penalty')::double precision)) into mid from jsonb_array_elements(t->'players') p where p->>'slot' in ('MC','VOL','MEI','ALAE','ALAD');
 select greatest(1,(p->>'overall')::double precision-(p->>'penalty')::double precision) into gk from jsonb_array_elements(t->'players') p where p->>'slot'='GOL';
 if gk is null then raise exception 'Missing goalkeeper'; end if;
 select avg((p->>'overall')::double precision) into bench from jsonb_array_elements(t->'players') p where p->>'slot' like 'BENCH%';
 atk:=coalesce(atk,av); def:=coalesce(def,av); mid:=coalesce(mid,av); bench:=coalesce(bench,av);
 strength:=.56*av+.14*fit+.10*least(atk,def,mid)+.08*bench+.12*gk;
 return jsonb_build_object('overall',round(strength::numeric,4),'attack',round((.7*strength+.3*atk)::numeric,4),'defense',round((.7*strength+.2*def+.1*gk)::numeric,4),'keeper',round(gk::numeric,4),'bench',round(bench::numeric,4),'fit',round(fit::numeric,4));
end $$;

create function private.fa_simulate_match_v1(a jsonb,b jsonb,seed bigint) returns jsonb language plpgsql immutable set search_path='' as $$
declare sa jsonb:=private.fa_x1_strength(a); sb jsonb:=private.fa_x1_strength(b); state bigint:=seed; fa double precision; fb double precision; xa double precision; xb double precision; chance double precision; choice double precision; minute integer; side text; opposite text; goalsa integer:=0; goalsb integer:=0; events jsonb:='[]'; poola jsonb; poolb jsonb; pool jsonb; scorer text; gka text; gkb text;
begin
 if seed<1 or seed>=2147483647 then raise exception 'Invalid seed'; end if;
 state:=(state*48271)%2147483647; fa:=(state::double precision/2147483647-.5)*4;
 state:=(state*48271)%2147483647; fb:=(state::double precision/2147483647-.5)*4;
 xa:=round(least(5,greatest(.35,1.55*exp(.065*((sa->>'attack')::double precision-(sb->>'defense')::double precision+fa-fb))))::numeric,4);
 xb:=round(least(5,greatest(.35,1.55*exp(.065*((sb->>'attack')::double precision-(sa->>'defense')::double precision+fb-fa))))::numeric,4);
 select jsonb_agg(p order by p->>'slot' collate "C") into poola from jsonb_array_elements(a->'players') p where p->>'slot' not like 'BENCH%' and p->>'slot'<>'GOL';
 select jsonb_agg(p order by p->>'slot' collate "C") into poolb from jsonb_array_elements(b->'players') p where p->>'slot' not like 'BENCH%' and p->>'slot'<>'GOL';
 select p->>'name' into gka from jsonb_array_elements(a->'players') p where p->>'slot'='GOL';
 select p->>'name' into gkb from jsonb_array_elements(b->'players') p where p->>'slot'='GOL';
 for minute in 1..90 loop
  foreach side in array array['a','b'] loop
   state:=(state*48271)%2147483647; chance:=state::double precision/2147483647;
   state:=(state*48271)%2147483647; choice:=state::double precision/2147483647;
   if chance<(case when side='a' then xa else xb end)/90 then
    if side='a' then goalsa:=goalsa+1; pool:=poola; else goalsb:=goalsb+1;pool:=poolb;end if;
    scorer:=pool->floor(choice*jsonb_array_length(pool))::integer->>'name';
    events:=events||jsonb_build_array(jsonb_build_object('minute',minute,'team',side,'kind','goal','player',scorer));
   elsif chance<(case when side='a' then xa else xb end)/90+.012 then
    opposite:=case when side='a' then 'b' else 'a' end;
    events:=events||jsonb_build_array(jsonb_build_object('minute',minute,'team',opposite,'kind','save','player',case when side='a' then gkb else gka end));
   end if;
  end loop;
 end loop;
 return jsonb_build_object('version','x1-v1','seed',seed,'score',jsonb_build_object('a',goalsa,'b',goalsb),'winner',case when goalsa=goalsb then null when goalsa>goalsb then a->>'id' else b->>'id' end,'events',events,'strength',jsonb_build_object('a',sa,'b',sb),'xg',jsonb_build_object('a',xa,'b',xb));
end $$;

create table public.fa_x1_matches (
 id uuid primary key default extensions.gen_random_uuid(),
 room_id uuid not null references public.fa_rooms(id),
 challenger_id uuid not null references public.fa_room_members(id),
 opponent_id uuid not null references public.fa_room_members(id),
 status text not null default 'pending' check(status in ('pending','declined','completed','cancelled')),
 seed bigint check(seed between 1 and 2147483646),
 team_a jsonb, team_b jsonb, result jsonb,
 created_at timestamptz not null default now(), responded_at timestamptz,
 check(challenger_id<>opponent_id),
 check(status<>'completed' or (seed is not null and team_a is not null and team_b is not null and result is not null))
);
create index fa_x1_room_created on public.fa_x1_matches(room_id,created_at desc);
create index fa_x1_opponent on public.fa_x1_matches(opponent_id);
create unique index fa_x1_pending_pair on public.fa_x1_matches(room_id,least(challenger_id,opponent_id),greatest(challenger_id,opponent_id)) where status='pending';
alter table public.fa_x1_matches enable row level security;
revoke all on public.fa_x1_matches from anon,authenticated;
grant select on public.fa_x1_matches to authenticated;
create policy fa_x1_room_read on public.fa_x1_matches for select to authenticated using(exists(select 1 from public.fa_room_members m where m.room_id=fa_x1_matches.room_id and m.user_id=(select auth.uid()) and m.kicked_at is null));

create function public.fa_challenge_x1(p_room_id uuid,p_opponent_id uuid) returns uuid language plpgsql security definer set search_path='' as $$
declare me public.fa_room_members; opponent public.fa_room_members; match_id uuid; room public.fa_rooms;
begin
 if auth.uid() is null then raise exception 'authentication required';end if;
 select * into room from public.fa_rooms where id=p_room_id for update;
 if not found or room.status not in ('auction','squads','finished') then raise exception 'Times ainda não estão disponíveis';end if;
 select * into me from public.fa_room_members where room_id=p_room_id and user_id=auth.uid() for update;
 if not found or me.is_spectator or me.kicked_at is not null or not me.squad_finalized then raise exception 'Finalize seu time antes de desafiar';end if;
 select * into opponent from public.fa_room_members where id=p_opponent_id and room_id=p_room_id for update;
 if not found or opponent.is_spectator or opponent.kicked_at is not null or not opponent.squad_finalized or me.id=opponent.id then raise exception 'Adversário indisponível';end if;
 if exists(select 1 from public.fa_x1_matches where challenger_id=me.id and created_at>now()-interval '10 seconds') then raise exception 'Aguarde alguns segundos para desafiar novamente';end if;
 if (select count(*) from public.fa_x1_matches where challenger_id=me.id and status='pending')>=5 then raise exception 'Você já tem cinco desafios pendentes';end if;
 insert into public.fa_x1_matches(room_id,challenger_id,opponent_id) values(p_room_id,me.id,opponent.id) returning id into match_id;
 return match_id;
end $$;

create function public.fa_respond_x1(p_match_id uuid,p_accept boolean) returns jsonb language plpgsql security definer set search_path='' as $$
declare match public.fa_x1_matches; room public.fa_rooms; me public.fa_room_members; rival public.fa_room_members; a jsonb; b jsonb; v_seed bigint; v_result jsonb;
begin
 if auth.uid() is null or p_accept is null then raise exception 'authentication required';end if;
 select * into match from public.fa_x1_matches where id=p_match_id;
 if not found then raise exception 'Desafio não encontrado';end if;
 -- Same lock order as challenge/replay, preventing a snapshot from crossing rounds.
 select * into room from public.fa_rooms where id=match.room_id for update;
 select * into match from public.fa_x1_matches where id=p_match_id for update;
 select * into me from public.fa_room_members where id=match.opponent_id;
 if me.user_id is distinct from auth.uid() or me.kicked_at is not null or me.is_spectator then raise exception 'Somente o adversário pode responder';end if;
 if match.status<>'pending' then return to_jsonb(match);end if;
 if not p_accept then
  update public.fa_x1_matches set status='declined',responded_at=now() where id=p_match_id returning * into match;
  return to_jsonb(match);
 end if;
 select * into rival from public.fa_room_members where id=match.challenger_id;
 if room.status not in ('auction','squads','finished') or not me.squad_finalized or not rival.squad_finalized or rival.kicked_at is not null or rival.is_spectator then raise exception 'Os dois times precisam estar finalizados';end if;
 a:=private.fa_x1_snapshot(rival.id);b:=private.fa_x1_snapshot(me.id);
 v_seed:=(('x'||encode(extensions.gen_random_bytes(4),'hex'))::bit(32)::bigint % 2147483646)+1;
 v_result:=private.fa_simulate_match_v1(a,b,v_seed);
 update public.fa_x1_matches set status='completed',team_a=a,team_b=b,seed=v_seed,result=v_result,responded_at=now() where id=p_match_id returning * into match;
 return to_jsonb(match);
end $$;
revoke all on function private.fa_x1_penalty(text,text,text),private.fa_x1_snapshot(uuid),private.fa_x1_strength(jsonb),private.fa_simulate_match_v1(jsonb,jsonb,bigint) from public,anon,authenticated;
revoke all on function public.fa_challenge_x1(uuid,uuid),public.fa_respond_x1(uuid,boolean) from public,anon;
grant execute on function public.fa_challenge_x1(uuid,uuid),public.fa_respond_x1(uuid,boolean) to authenticated;

create table public.fa_round_archives (
 id uuid primary key default extensions.gen_random_uuid(),
 room_id uuid not null references public.fa_rooms(id),
 snapshot jsonb not null, created_at timestamptz not null default now()
);
create index fa_round_archives_room on public.fa_round_archives(room_id,created_at desc);
alter table public.fa_round_archives enable row level security;
revoke all on public.fa_round_archives from anon,authenticated;
grant select on public.fa_round_archives to authenticated;
create policy fa_round_archives_read on public.fa_round_archives for select to authenticated using(exists(select 1 from public.fa_room_members m where m.room_id=fa_round_archives.room_id and m.user_id=(select auth.uid()) and m.kicked_at is null));
CREATE OR REPLACE FUNCTION public.fa_request_replay(p_room_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_user uuid:=auth.uid();
  v_room public.fa_rooms%rowtype;
  v_member public.fa_room_members%rowtype;
  v_requests integer;
  v_total integer;
begin
  if v_user is null then raise exception 'authentication required'; end if;

  select * into v_room
  from public.fa_rooms
  where id=p_room_id
  for update;

  if not found then raise exception 'room not found'; end if;
  if v_room.status<>'squads' then raise exception 'replay is only available after everyone finishes'; end if;

  select * into v_member
  from public.fa_room_members
  where room_id=p_room_id and user_id=v_user
  for update;

  if not found then raise exception 'not a room member'; end if;
  if v_member.is_spectator then raise exception 'spectators cannot request replay'; end if;

  update public.fa_room_members
  set replay_requested=true,last_seen_at=now()
  where id=v_member.id;

  select count(*) into v_requests
  from public.fa_room_members
  where room_id=p_room_id
    and not is_spectator
    and replay_requested;

  select count(*) into v_total
  from public.fa_room_members
  where room_id=p_room_id and not is_spectator;

  if v_room.host_user_id<>v_user then
    return jsonb_build_object(
      'restarted',false,
      'waiting_for_host',true,
      'requests',v_requests,
      'total',v_total
    );
  end if;

  -- Archive complete round before resetting live auction tables. X1 snapshots remain immutable.
  insert into public.fa_round_archives(room_id,snapshot) values(p_room_id,jsonb_build_object(
    'players',(select coalesce(jsonb_agg(to_jsonb(p)),'[]'::jsonb) from public.fa_players p where p.room_id=p_room_id),
    'auctions',(select coalesce(jsonb_agg(to_jsonb(a)),'[]'::jsonb) from public.fa_auctions a where a.room_id=p_room_id),
    'bids',(select coalesce(jsonb_agg(to_jsonb(b)),'[]'::jsonb) from public.fa_bids b join public.fa_auctions a on a.id=b.auction_id where a.room_id=p_room_id),
    'squads',(select coalesce(jsonb_agg(to_jsonb(s)),'[]'::jsonb) from public.fa_squad_players s join public.fa_room_members m on m.id=s.member_id where m.room_id=p_room_id),
    'members',(select coalesce(jsonb_agg(jsonb_build_object('id',m.id,'display_name',m.display_name,'balance',m.balance)),'[]'::jsonb) from public.fa_room_members m where m.room_id=p_room_id)
  ));
  update public.fa_x1_matches set status='cancelled',responded_at=now() where room_id=p_room_id and status='pending';

  delete from public.fa_squad_players s
  using public.fa_room_members m
  where s.member_id=m.id and m.room_id=p_room_id;

  delete from public.fa_auctions where room_id=p_room_id;
  -- Preserve prior match results across replays.
  delete from public.fa_players where room_id=p_room_id;

  update public.fa_room_members
  set balance=case when is_spectator then 0 else v_room.budget end,
      squad_finalized=false,
      finalized_at=null,
      replay_requested=false,
      ready=false,
      last_seen_at=case when user_id=v_user then now() else last_seen_at end
  where room_id=p_room_id;

  update public.fa_rooms set status='lobby' where id=p_room_id;

  return jsonb_build_object(
    'restarted',true,
    'waiting_for_host',false,
    'requests',0,
    'total',v_total
  );
end;
$function$;
