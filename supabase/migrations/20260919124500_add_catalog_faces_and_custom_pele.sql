alter table public.fa_catalog_players drop constraint if exists fa_catalog_players_overall_check;
alter table public.fa_catalog_players add constraint fa_catalog_players_overall_check check (overall is null or (overall >= 1 and overall <= 100));

alter table public.fa_players drop constraint if exists fa_players_overall_check;
alter table public.fa_players add constraint fa_players_overall_check check (overall >= 1 and overall <= 100);

with face_data(id, player_name, image_url, image_source_url, image_license, image_file) as (
  values
    ('icon-pirlo', 'Andrea Pirlo', 'https://upload.wikimedia.org/wikipedia/commons/6/6e/20150616_-_Portugal_-_Italie_-_Gen%C3%A8ve_-_Andrea_Pirlo_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:20150616_-_Portugal_-_Italie_-_Gen%C3%A8ve_-_Andrea_Pirlo_(cropped).jpg', 'CC BY-SA 3.0', '20150616_-_Portugal_-_Italie_-_Genève_-_Andrea_Pirlo_(cropped).jpg'),
    ('icon-iniesta', 'Andrés Iniesta', 'https://upload.wikimedia.org/wikipedia/commons/a/ac/Andr%C3%A9s_Iniesta_Argentina_v_Spain_19_July_2026-034_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Andr%C3%A9s_Iniesta_Argentina_v_Spain_19_July_2026-034_(cropped).jpg', 'CC BY-SA 4.0', 'Andrés_Iniesta_Argentina_v_Spain_19_July_2026-034_(cropped).jpg'),
    ('icon-cafu', 'Cafu', 'https://upload.wikimedia.org/wikipedia/commons/6/64/Cafu_-_26.02.2026_-_Cerim%C3%B4nia_de_apresenta%C3%A7%C3%A3o_das_ta%C3%A7as_da_Copa_do_Mundo_de_2026.jpg', 'https://commons.wikimedia.org/wiki/File:Cafu_-_26.02.2026_-_Cerim%C3%B4nia_de_apresenta%C3%A7%C3%A3o_das_ta%C3%A7as_da_Copa_do_Mundo_de_2026.jpg', 'CC BY-SA 4.0', 'Cafu_-_26.02.2026_-_Cerimônia_de_apresentação_das_taças_da_Copa_do_Mundo_de_2026.jpg'),
    ('icon-valderrama', 'Carlos Valderrama', 'https://upload.wikimedia.org/wikipedia/commons/a/a1/Pibe_Valderrama_2022.jpg', 'https://commons.wikimedia.org/wiki/File:Pibe_Valderrama_2022.jpg', 'CC BY 3.0', 'Pibe_Valderrama_2022.jpg'),
    ('icon-carlos-vela', 'Carlos Vela', 'https://upload.wikimedia.org/wikipedia/commons/6/6d/Mex-Kor_%2821%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Mex-Kor_(21)_(cropped).jpg', 'CC BY-SA 3.0', 'Mex-Kor_(21)_(cropped).jpg'),
    ('icon-dempsey', 'Clint Dempsey', 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Clint_Dempsey_%2826347615912%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Clint_Dempsey_(26347615912)_(cropped).jpg', 'CC BY 2.0', 'Clint_Dempsey_(26347615912)_(cropped).jpg'),
    ('icon-beckham', 'David Beckham', 'https://upload.wikimedia.org/wikipedia/commons/7/73/David_Beckham_UNICEF_%28cropped2%29.jpg', 'https://commons.wikimedia.org/wiki/File:David_Beckham_UNICEF_(cropped2).jpg', 'CC BY 3.0', 'David_Beckham_UNICEF_(cropped2).jpg'),
    ('icon-forlan', 'Diego Forlán', 'https://upload.wikimedia.org/wikipedia/commons/f/f3/U10_Diego_Forl%C3%A1n_7524.jpg', 'https://commons.wikimedia.org/wiki/File:U10_Diego_Forl%C3%A1n_7524.jpg', 'CC BY-SA 3.0 at', 'U10_Diego_Forlán_7524.jpg'),
    ('icon-maradona', 'Diego Maradona', 'https://upload.wikimedia.org/wikipedia/commons/4/48/Argentina_celebrando_copa_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Argentina_celebrando_copa_(cropped).jpg', 'Public domain', 'Argentina_celebrando_copa_(cropped).jpg'),
    ('icon-eusebio', 'Eusébio', 'https://upload.wikimedia.org/wikipedia/commons/5/55/Eusebio_en_1973.jpg', 'https://commons.wikimedia.org/wiki/File:Eusebio_en_1973.jpg', 'Public domain', 'Eusebio_en_1973.jpg'),
    ('icon-lampard', 'Frank Lampard', 'https://upload.wikimedia.org/wikipedia/commons/8/8c/Frank_Lampard_2019.jpg', 'https://commons.wikimedia.org/wiki/File:Frank_Lampard_2019.jpg', 'CC BY 4.0', 'Frank_Lampard_2019.jpg'),
    ('icon-beckenbauer', 'Franz Beckenbauer', 'https://upload.wikimedia.org/wikipedia/commons/5/56/Franz_Beckenbauer_%281975%29.jpg', 'https://commons.wikimedia.org/wiki/File:Franz_Beckenbauer_(1975).jpg', 'Public domain', 'Franz_Beckenbauer_(1975).jpg'),
    ('icon-batistuta', 'Gabriel Batistuta', 'https://upload.wikimedia.org/wikipedia/commons/1/13/Omar_Batistuta_%282%29.jpg', 'https://commons.wikimedia.org/wiki/File:Omar_Batistuta_(2).jpg', 'CC BY-SA 3.0', 'Omar_Batistuta_(2).jpg'),
    ('icon-buffon', 'Gianluigi Buffon', 'https://upload.wikimedia.org/wikipedia/commons/d/d7/Norway_Italy_-_June_2025_A_44_%28Gianluigi_Buffon%29.jpg', 'https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_44_(Gianluigi_Buffon).jpg', 'CC BY 4.0', 'Norway_Italy_-_June_2025_A_44_(Gianluigi_Buffon).jpg'),
    ('icon-hugo-sanchez', 'Hugo Sánchez', 'https://upload.wikimedia.org/wikipedia/commons/9/9e/Huguito.jpg', 'https://commons.wikimedia.org/wiki/File:Huguito.jpg', 'CC BY-SA 3.0', 'Huguito.jpg'),
    ('icon-casillas', 'Iker Casillas', 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Iker-Casillas-SportsTrade-2021-cropped.jpg', 'https://commons.wikimedia.org/wiki/File:Iker-Casillas-SportsTrade-2021-cropped.jpg', 'CC BY 2.0', 'Iker-Casillas-SportsTrade-2021-cropped.jpg'),
    ('icon-zanetti', 'Javier Zanetti', 'https://upload.wikimedia.org/wikipedia/commons/e/e7/Metalist-Inter_%282%29.jpg', 'https://commons.wikimedia.org/wiki/File:Metalist-Inter_(2).jpg', 'CC BY-SA 3.0', 'Metalist-Inter_(2).jpg'),
    ('icon-cruyff', 'Johan Cruyff', 'https://upload.wikimedia.org/wikipedia/commons/c/cb/Johan_Cruijff_%281974%29.jpg', 'https://commons.wikimedia.org/wiki/File:Johan_Cruijff_(1974).jpg', 'CC0', 'Johan_Cruijff_(1974).jpg'),
    ('icon-jorge-campos', 'Jorge Campos', 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Jorge_Campos_en_2018.jpg', 'https://commons.wikimedia.org/wiki/File:Jorge_Campos_en_2018.jpg', 'CC BY 4.0', 'Jorge_Campos_en_2018.jpg'),
    ('icon-riquelme', 'Juan Román Riquelme', 'https://upload.wikimedia.org/wikipedia/commons/b/ba/Juan_Rom%C3%A1n_Riquelme_-_2019.jpg', 'https://commons.wikimedia.org/wiki/File:Juan_Rom%C3%A1n_Riquelme_-_2019.jpg', 'CC BY 3.0', 'Juan_Román_Riquelme_-_2019.jpg'),
    ('icon-kaka', 'Kaká', 'https://upload.wikimedia.org/wikipedia/commons/6/6d/Kak%C3%A1_visited_Stadium_St._Petersburg.jpg', 'https://commons.wikimedia.org/wiki/File:Kak%C3%A1_visited_Stadium_St._Petersburg.jpg', 'CC BY-SA 3.0', 'Kaká_visited_Stadium_St._Petersburg.jpg'),
    ('icon-keylor', 'Keylor Navas', 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Keylor_Navas_2018_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Keylor_Navas_2018_(cropped).jpg', 'CC BY-SA 3.0', 'Keylor_Navas_2018_(cropped).jpg'),
    ('icon-donovan', 'Landon Donovan', 'https://upload.wikimedia.org/wikipedia/commons/6/6f/NC_Courage_vs_SD_Wave_%28Oct_2024%29_045.jpg', 'https://commons.wikimedia.org/wiki/File:NC_Courage_vs_SD_Wave_(Oct_2024)_045.jpg', 'CC BY-SA 4.0', 'NC_Courage_vs_SD_Wave_(Oct_2024)_045.jpg'),
    ('icon-vanbasten', 'Marco van Basten', 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Marco_van_Basten_%282%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Marco_van_Basten_(2)_(cropped).jpg', 'CC BY 2.5', 'Marco_van_Basten_(2)_(cropped).jpg'),
    ('bra_neymar', 'Neymar Jr.', 'https://upload.wikimedia.org/wikipedia/commons/c/c0/Neymar_Junior_Brazil_V_Morocco_13_June_2026-40.jpg', 'https://commons.wikimedia.org/wiki/File:Neymar_Junior_Brazil_V_Morocco_13_June_2026-40.jpg', 'CC BY-SA 4.0', 'Neymar_Junior_Brazil_V_Morocco_13_June_2026-40.jpg'),
    ('icon-maldini', 'Paolo Maldini', 'https://upload.wikimedia.org/wikipedia/commons/0/0a/Paolo_Maldini_AC_Milan_Technical_director_2018.jpg', 'https://commons.wikimedia.org/wiki/File:Paolo_Maldini_AC_Milan_Technical_director_2018.jpg', 'CC BY 3.0', 'Paolo_Maldini_AC_Milan_Technical_director_2018.jpg'),
    ('icon-pele', 'Pelé', 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Pele_con_brasil_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Pele_con_brasil_(cropped).jpg', 'Public domain', 'Pele_con_brasil_(cropped).jpg'),
    ('icon-rafa-marquez', 'Rafael Márquez', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Rafael_M%C3%A1rquez_2014.jpg', 'https://commons.wikimedia.org/wiki/File:Rafael_M%C3%A1rquez_2014.jpg', 'CC BY 2.0', 'Rafael_Márquez_2014.jpg'),
    ('icon-rivaldo', 'Rivaldo', 'https://upload.wikimedia.org/wikipedia/commons/8/8e/Rivaldo.jpg', 'https://commons.wikimedia.org/wiki/File:Rivaldo.jpg', 'CC BY 3.0 br', 'Rivaldo.jpg'),
    ('icon-roberto-carlos', 'Roberto Carlos', 'https://upload.wikimedia.org/wikipedia/commons/a/a8/LS3_1288_%2853332367864%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:LS3_1288_(53332367864)_(cropped).jpg', 'CC BY 2.0', 'LS3_1288_(53332367864)_(cropped).jpg'),
    ('icon-romario', 'Romário', 'https://upload.wikimedia.org/wikipedia/commons/a/ad/Senadores_da_57%C2%AA_Legislatura_%2852689451805%29.jpg', 'https://commons.wikimedia.org/wiki/File:Senadores_da_57%C2%AA_Legislatura_(52689451805).jpg', 'CC BY 2.0', 'Senadores_da_57ª_Legislatura_(52689451805).jpg'),
    ('icon-ronaldinho', 'Ronaldinho', 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Ronaldinho_in_2019.jpg', 'https://commons.wikimedia.org/wiki/File:Ronaldinho_in_2019.jpg', 'CC BY 2.0', 'Ronaldinho_in_2019.jpg'),
    ('icon-ronaldo', 'Ronaldo Nazário', 'https://upload.wikimedia.org/wikipedia/commons/3/36/12.12.2025_%E2%80%93_Cerim%C3%B4nia_de_lan%C3%A7amento_do_SBT_News_-_54980664160_%28cropped2%29.jpg', 'https://commons.wikimedia.org/wiki/File:12.12.2025_%E2%80%93_Cerim%C3%B4nia_de_lan%C3%A7amento_do_SBT_News_-_54980664160_(cropped2).jpg', 'CC BY-SA 4.0', '12.12.2025_–_Cerimônia_de_lançamento_do_SBT_News_-_54980664160_(cropped2).jpg'),
    ('icon-gerrard', 'Steven Gerrard', 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Steven_Gerrard_2018.jpg', 'https://commons.wikimedia.org/wiki/File:Steven_Gerrard_2018.jpg', 'CC BY-SA 3.0', 'Steven_Gerrard_2018.jpg'),
    ('icon-henry', 'Thierry Henry', 'https://upload.wikimedia.org/wikipedia/commons/b/b9/Thierry_Henry_%2851649035951%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Thierry_Henry_(51649035951)_(cropped).jpg', 'CC BY 2.0', 'Thierry_Henry_(51649035951)_(cropped).jpg'),
    ('icon-howard', 'Tim Howard', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Tim_Howard_2023.jpg', 'https://commons.wikimedia.org/wiki/File:Tim_Howard_2023.jpg', 'CC BY-SA 2.0', 'Tim_Howard_2023.jpg'),
    ('icon-xavi', 'Xavi', 'https://upload.wikimedia.org/wikipedia/commons/a/aa/Xavi_Hern%C3%A1ndez_-_002_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Xavi_Hern%C3%A1ndez_-_002_(cropped).jpg', 'Public domain', 'Xavi_Hernández_-_002_(cropped).jpg'),
    ('icon-zico', 'Zico', 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Zico_2012_3.jpg', 'https://commons.wikimedia.org/wiki/File:Zico_2012_3.jpg', 'CC BY 2.0', 'Zico_2012_3.jpg'),
    ('icon-zidane', 'Zinedine Zidane', 'https://upload.wikimedia.org/wikipedia/commons/f/f3/Zinedine_Zidane_by_Tasnim_03.jpg', 'https://commons.wikimedia.org/wiki/File:Zinedine_Zidane_by_Tasnim_03.jpg', 'CC BY 4.0', 'Zinedine_Zidane_by_Tasnim_03.jpg'),
    ('pl-haaland', 'Erling Haaland', 'https://upload.wikimedia.org/wikipedia/commons/4/43/Erling_Haaland_Morocco_v_Norway_7_June_2026-51.jpg', 'https://commons.wikimedia.org/wiki/File:Erling_Haaland_Morocco_v_Norway_7_June_2026-51.jpg', 'CC BY-SA 4.0', 'Erling_Haaland_Morocco_v_Norway_7_June_2026-51.jpg'),
    ('laliga-mbappe', 'Kylian Mbappé', 'https://upload.wikimedia.org/wikipedia/commons/9/95/Kylian_Mbappe_France_v_Senegal_16_June_2026-391_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Kylian_Mbappe_France_v_Senegal_16_June_2026-391_(cropped).jpg', 'CC BY-SA 4.0', 'Kylian_Mbappe_France_v_Senegal_16_June_2026-391_(cropped).jpg'),
    ('bund-kane', 'Harry Kane', 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Harry_Kane_England_v_Ghana_23_June_2026-219_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Harry_Kane_England_v_Ghana_23_June_2026-219_(cropped).jpg', 'CC BY-SA 4.0', 'Harry_Kane_England_v_Ghana_23_June_2026-219_(cropped).jpg'),
    ('laliga-bellingham', 'Jude Bellingham', 'https://upload.wikimedia.org/wikipedia/commons/2/23/Jude_Bellingham_England_v_Ghana_23_June_2026-061_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Jude_Bellingham_England_v_Ghana_23_June_2026-061_(cropped).jpg', 'CC BY-SA 4.0', 'Jude_Bellingham_England_v_Ghana_23_June_2026-061_(cropped).jpg'),
    ('laliga-yamal', 'Lamine Yamal', 'https://upload.wikimedia.org/wikipedia/commons/1/13/Lamine_Yamal_France_v_Spain_7.24.26-142.jpg', 'https://commons.wikimedia.org/wiki/File:Lamine_Yamal_France_v_Spain_7.24.26-142.jpg', 'CC BY-SA 4.0', 'Lamine_Yamal_France_v_Spain_7.24.26-142.jpg'),
    ('bund-olise', 'Michael Olise', 'https://upload.wikimedia.org/wikipedia/commons/0/04/Michael_Olise_France_v_Senegal_16_June_2026-307_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Michael_Olise_France_v_Senegal_16_June_2026-307_(cropped).jpg', 'CC BY-SA 4.0', 'Michael_Olise_France_v_Senegal_16_June_2026-307_(cropped).jpg'),
    ('ligue1-dembele', 'Ousmane Dembélé', 'https://upload.wikimedia.org/wikipedia/commons/6/69/Ousmane_Dembele_France_v_Senegal_16_June_2026-341_%28cropped%29_2.jpg', 'https://commons.wikimedia.org/wiki/File:Ousmane_Dembele_France_v_Senegal_16_June_2026-341_(cropped)_2.jpg', 'CC BY-SA 4.0', 'Ousmane_Dembele_France_v_Senegal_16_June_2026-341_(cropped)_2.jpg'),
    ('laliga-pedri', 'Pedri', 'https://upload.wikimedia.org/wikipedia/commons/1/1c/Pedri_France_v_Spain_7.24.26-245.jpg', 'https://commons.wikimedia.org/wiki/File:Pedri_France_v_Spain_7.24.26-245.jpg', 'CC BY-SA 4.0', 'Pedri_France_v_Spain_7.24.26-245.jpg'),
    ('pl-rodri', 'Rodri', 'https://upload.wikimedia.org/wikipedia/commons/7/7a/Rodri_Argentina_v_Spain_19_July_2026-187_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Rodri_Argentina_v_Spain_19_July_2026-187_(cropped).jpg', 'CC BY-SA 4.0', 'Rodri_Argentina_v_Spain_19_July_2026-187_(cropped).jpg'),
    ('laliga-courtois', 'Thibaut Courtois', 'https://upload.wikimedia.org/wikipedia/commons/f/f7/Thibaut_Courtois_at_the_2018_World_Cup_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Thibaut_Courtois_at_the_2018_World_Cup_(cropped).jpg', 'CC BY-SA 3.0', 'Thibaut_Courtois_at_the_2018_World_Cup_(cropped).jpg'),
    ('ligue1-vitinha', 'Vitinha', 'https://upload.wikimedia.org/wikipedia/commons/4/44/Vitinha_USMNT_v_Portugal_Mar_31_2026-50_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Vitinha_USMNT_v_Portugal_Mar_31_2026-50_(cropped).jpg', 'CC BY-SA 4.0', 'Vitinha_USMNT_v_Portugal_Mar_31_2026-50_(cropped).jpg'),
    ('pl-bruno', 'Bruno Fernandes', 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Bruno_Fernandes_USMNT_v_Portugal_Mar_31_2026-27_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Bruno_Fernandes_USMNT_v_Portugal_Mar_31_2026-27_(cropped).jpg', 'CC BY-SA 4.0', 'Bruno_Fernandes_USMNT_v_Portugal_Mar_31_2026-27_(cropped).jpg'),
    ('ea27_gabriel', 'Gabriel', 'https://upload.wikimedia.org/wikipedia/commons/8/8e/Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg', 'CC BY-SA 4.0', 'Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg'),
    ('ea27_gianluigi_donnarumma', 'Gianluigi Donnarumma', 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Norway_Italy_-_June_2025_A_17_%28Gianluigi_Donnarumma%29.jpg', 'https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_17_(Gianluigi_Donnarumma).jpg', 'CC BY 4.0', 'Norway_Italy_-_June_2025_A_17_(Gianluigi_Donnarumma).jpg'),
    ('ligue1-kvara', 'Khvicha Kvaratskhelia', 'https://upload.wikimedia.org/wikipedia/commons/4/4a/Kvaratskhelia_asse_psg_2425.png', 'https://commons.wikimedia.org/wiki/File:Kvaratskhelia_asse_psg_2425.png', 'CC0', 'Kvaratskhelia_asse_psg_2425.png'),
    ('ea27_lionel_messi', 'Lionel Messi', 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Leo_Messi_Argentina_v_Egypt_7_July_2026-1.jpg', 'https://commons.wikimedia.org/wiki/File:Leo_Messi_Argentina_v_Egypt_7_July_2026-1.jpg', 'CC BY-SA 4.0', 'Leo_Messi_Argentina_v_Egypt_7_July_2026-1.jpg'),
    ('ligue1-nuno', 'Nuno Mendes', 'https://upload.wikimedia.org/wikipedia/commons/c/c0/Nuno_Mendes_Croatia_v_Portugal_2_July_2026-135_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Nuno_Mendes_Croatia_v_Portugal_2_July_2026-135_(cropped).jpg', 'CC BY-SA 4.0', 'Nuno_Mendes_Croatia_v_Portugal_2_July_2026-135_(cropped).jpg'),
    ('ea27_vinicius', 'Vini Jr.', 'https://upload.wikimedia.org/wikipedia/commons/1/10/Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg', 'CC BY-SA 4.0', 'Vinícius_Júnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg'),
    ('ligue1_willian_pacho', 'Willian Pacho', 'https://upload.wikimedia.org/wikipedia/commons/8/86/Willian_Pacho_Ecuador_v_Germany_25_June_2026-228.jpg', 'https://commons.wikimedia.org/wiki/File:Willian_Pacho_Ecuador_v_Germany_25_June_2026-228.jpg', 'CC BY-SA 4.0', 'Willian_Pacho_Ecuador_v_Germany_25_June_2026-228.jpg')
)
update public.fa_catalog_players c
set image_url = f.image_url,
    image_source_url = f.image_source_url,
    image_license = f.image_license,
    metadata = coalesce(c.metadata, '{}'::jsonb) || jsonb_build_object(
      'image_source', 'Wikimedia Commons',
      'image_file', f.image_file,
      'image_checked_at', '2026-09-19',
      'image_policy', 'licensed_or_public_domain_wikimedia',
      'image_note', 'No EA proprietary assets were used.'
    )
from face_data f
where c.id = f.id;

insert into public.fa_catalog_players (
  id, name, club, league, nationality, primary_position, secondary_positions,
  overall, player_type, legend_region, enabled, image_url, image_source_url, image_license, metadata
)
values (
  'icon-pele',
  'Pelé',
  'Santos FC',
  'LEGENDS',
  'Brazil',
  'ATA',
  array['MEI','PE','PD']::text[],
  100,
  'ICON',
  'SOUTH_AMERICA',
  true,
  'https://upload.wikimedia.org/wikipedia/commons/5/5e/Pele_con_brasil_%28cropped%29.jpg',
  'https://commons.wikimedia.org/wiki/File:Pele_con_brasil_(cropped).jpg',
  'Public domain',
  jsonb_build_object(
    'rating_source', 'Football Auction custom card',
    'rating_status', 'custom_special',
    'rating_source_url', null,
    'special_card', 'Football Auction ICON',
    'special_club', 'Santos FC',
    'not_official_ea_fc27', true,
    'rating_review_note', 'Carta especial/custom do Football Auction: Pelé GER 100. Não representa GER oficial do EA SPORTS FC 27.',
    'rating_reviewed_at', '2026-09-19',
    'image_source', 'Wikimedia Commons',
    'image_file', 'Pele_con_brasil_(cropped).jpg',
    'image_checked_at', '2026-09-19',
    'image_policy', 'licensed_or_public_domain_wikimedia',
    'image_note', 'No EA proprietary assets were used.'
  )
)
on conflict (id) do update
set name = excluded.name,
    club = excluded.club,
    league = excluded.league,
    nationality = excluded.nationality,
    primary_position = excluded.primary_position,
    secondary_positions = excluded.secondary_positions,
    overall = excluded.overall,
    player_type = excluded.player_type,
    legend_region = excluded.legend_region,
    enabled = excluded.enabled,
    image_url = excluded.image_url,
    image_source_url = excluded.image_source_url,
    image_license = excluded.image_license,
    metadata = coalesce(public.fa_catalog_players.metadata, '{}'::jsonb) || excluded.metadata;

with face_data(id, player_name, image_url, image_source_url, image_license, image_file) as (
  values
    ('icon-pirlo', 'Andrea Pirlo', 'https://upload.wikimedia.org/wikipedia/commons/6/6e/20150616_-_Portugal_-_Italie_-_Gen%C3%A8ve_-_Andrea_Pirlo_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:20150616_-_Portugal_-_Italie_-_Gen%C3%A8ve_-_Andrea_Pirlo_(cropped).jpg', 'CC BY-SA 3.0', '20150616_-_Portugal_-_Italie_-_Genève_-_Andrea_Pirlo_(cropped).jpg'),
    ('icon-iniesta', 'Andrés Iniesta', 'https://upload.wikimedia.org/wikipedia/commons/a/ac/Andr%C3%A9s_Iniesta_Argentina_v_Spain_19_July_2026-034_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Andr%C3%A9s_Iniesta_Argentina_v_Spain_19_July_2026-034_(cropped).jpg', 'CC BY-SA 4.0', 'Andrés_Iniesta_Argentina_v_Spain_19_July_2026-034_(cropped).jpg'),
    ('icon-cafu', 'Cafu', 'https://upload.wikimedia.org/wikipedia/commons/6/64/Cafu_-_26.02.2026_-_Cerim%C3%B4nia_de_apresenta%C3%A7%C3%A3o_das_ta%C3%A7as_da_Copa_do_Mundo_de_2026.jpg', 'https://commons.wikimedia.org/wiki/File:Cafu_-_26.02.2026_-_Cerim%C3%B4nia_de_apresenta%C3%A7%C3%A3o_das_ta%C3%A7as_da_Copa_do_Mundo_de_2026.jpg', 'CC BY-SA 4.0', 'Cafu_-_26.02.2026_-_Cerimônia_de_apresentação_das_taças_da_Copa_do_Mundo_de_2026.jpg'),
    ('icon-valderrama', 'Carlos Valderrama', 'https://upload.wikimedia.org/wikipedia/commons/a/a1/Pibe_Valderrama_2022.jpg', 'https://commons.wikimedia.org/wiki/File:Pibe_Valderrama_2022.jpg', 'CC BY 3.0', 'Pibe_Valderrama_2022.jpg'),
    ('icon-carlos-vela', 'Carlos Vela', 'https://upload.wikimedia.org/wikipedia/commons/6/6d/Mex-Kor_%2821%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Mex-Kor_(21)_(cropped).jpg', 'CC BY-SA 3.0', 'Mex-Kor_(21)_(cropped).jpg'),
    ('icon-dempsey', 'Clint Dempsey', 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Clint_Dempsey_%2826347615912%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Clint_Dempsey_(26347615912)_(cropped).jpg', 'CC BY 2.0', 'Clint_Dempsey_(26347615912)_(cropped).jpg'),
    ('icon-beckham', 'David Beckham', 'https://upload.wikimedia.org/wikipedia/commons/7/73/David_Beckham_UNICEF_%28cropped2%29.jpg', 'https://commons.wikimedia.org/wiki/File:David_Beckham_UNICEF_(cropped2).jpg', 'CC BY 3.0', 'David_Beckham_UNICEF_(cropped2).jpg'),
    ('icon-forlan', 'Diego Forlán', 'https://upload.wikimedia.org/wikipedia/commons/f/f3/U10_Diego_Forl%C3%A1n_7524.jpg', 'https://commons.wikimedia.org/wiki/File:U10_Diego_Forl%C3%A1n_7524.jpg', 'CC BY-SA 3.0 at', 'U10_Diego_Forlán_7524.jpg'),
    ('icon-maradona', 'Diego Maradona', 'https://upload.wikimedia.org/wikipedia/commons/4/48/Argentina_celebrando_copa_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Argentina_celebrando_copa_(cropped).jpg', 'Public domain', 'Argentina_celebrando_copa_(cropped).jpg'),
    ('icon-eusebio', 'Eusébio', 'https://upload.wikimedia.org/wikipedia/commons/5/55/Eusebio_en_1973.jpg', 'https://commons.wikimedia.org/wiki/File:Eusebio_en_1973.jpg', 'Public domain', 'Eusebio_en_1973.jpg'),
    ('icon-lampard', 'Frank Lampard', 'https://upload.wikimedia.org/wikipedia/commons/8/8c/Frank_Lampard_2019.jpg', 'https://commons.wikimedia.org/wiki/File:Frank_Lampard_2019.jpg', 'CC BY 4.0', 'Frank_Lampard_2019.jpg'),
    ('icon-beckenbauer', 'Franz Beckenbauer', 'https://upload.wikimedia.org/wikipedia/commons/5/56/Franz_Beckenbauer_%281975%29.jpg', 'https://commons.wikimedia.org/wiki/File:Franz_Beckenbauer_(1975).jpg', 'Public domain', 'Franz_Beckenbauer_(1975).jpg'),
    ('icon-batistuta', 'Gabriel Batistuta', 'https://upload.wikimedia.org/wikipedia/commons/1/13/Omar_Batistuta_%282%29.jpg', 'https://commons.wikimedia.org/wiki/File:Omar_Batistuta_(2).jpg', 'CC BY-SA 3.0', 'Omar_Batistuta_(2).jpg'),
    ('icon-buffon', 'Gianluigi Buffon', 'https://upload.wikimedia.org/wikipedia/commons/d/d7/Norway_Italy_-_June_2025_A_44_%28Gianluigi_Buffon%29.jpg', 'https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_44_(Gianluigi_Buffon).jpg', 'CC BY 4.0', 'Norway_Italy_-_June_2025_A_44_(Gianluigi_Buffon).jpg'),
    ('icon-hugo-sanchez', 'Hugo Sánchez', 'https://upload.wikimedia.org/wikipedia/commons/9/9e/Huguito.jpg', 'https://commons.wikimedia.org/wiki/File:Huguito.jpg', 'CC BY-SA 3.0', 'Huguito.jpg'),
    ('icon-casillas', 'Iker Casillas', 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Iker-Casillas-SportsTrade-2021-cropped.jpg', 'https://commons.wikimedia.org/wiki/File:Iker-Casillas-SportsTrade-2021-cropped.jpg', 'CC BY 2.0', 'Iker-Casillas-SportsTrade-2021-cropped.jpg'),
    ('icon-zanetti', 'Javier Zanetti', 'https://upload.wikimedia.org/wikipedia/commons/e/e7/Metalist-Inter_%282%29.jpg', 'https://commons.wikimedia.org/wiki/File:Metalist-Inter_(2).jpg', 'CC BY-SA 3.0', 'Metalist-Inter_(2).jpg'),
    ('icon-cruyff', 'Johan Cruyff', 'https://upload.wikimedia.org/wikipedia/commons/c/cb/Johan_Cruijff_%281974%29.jpg', 'https://commons.wikimedia.org/wiki/File:Johan_Cruijff_(1974).jpg', 'CC0', 'Johan_Cruijff_(1974).jpg'),
    ('icon-jorge-campos', 'Jorge Campos', 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Jorge_Campos_en_2018.jpg', 'https://commons.wikimedia.org/wiki/File:Jorge_Campos_en_2018.jpg', 'CC BY 4.0', 'Jorge_Campos_en_2018.jpg'),
    ('icon-riquelme', 'Juan Román Riquelme', 'https://upload.wikimedia.org/wikipedia/commons/b/ba/Juan_Rom%C3%A1n_Riquelme_-_2019.jpg', 'https://commons.wikimedia.org/wiki/File:Juan_Rom%C3%A1n_Riquelme_-_2019.jpg', 'CC BY 3.0', 'Juan_Román_Riquelme_-_2019.jpg'),
    ('icon-kaka', 'Kaká', 'https://upload.wikimedia.org/wikipedia/commons/6/6d/Kak%C3%A1_visited_Stadium_St._Petersburg.jpg', 'https://commons.wikimedia.org/wiki/File:Kak%C3%A1_visited_Stadium_St._Petersburg.jpg', 'CC BY-SA 3.0', 'Kaká_visited_Stadium_St._Petersburg.jpg'),
    ('icon-keylor', 'Keylor Navas', 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Keylor_Navas_2018_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Keylor_Navas_2018_(cropped).jpg', 'CC BY-SA 3.0', 'Keylor_Navas_2018_(cropped).jpg'),
    ('icon-donovan', 'Landon Donovan', 'https://upload.wikimedia.org/wikipedia/commons/6/6f/NC_Courage_vs_SD_Wave_%28Oct_2024%29_045.jpg', 'https://commons.wikimedia.org/wiki/File:NC_Courage_vs_SD_Wave_(Oct_2024)_045.jpg', 'CC BY-SA 4.0', 'NC_Courage_vs_SD_Wave_(Oct_2024)_045.jpg'),
    ('icon-vanbasten', 'Marco van Basten', 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Marco_van_Basten_%282%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Marco_van_Basten_(2)_(cropped).jpg', 'CC BY 2.5', 'Marco_van_Basten_(2)_(cropped).jpg'),
    ('bra_neymar', 'Neymar Jr.', 'https://upload.wikimedia.org/wikipedia/commons/c/c0/Neymar_Junior_Brazil_V_Morocco_13_June_2026-40.jpg', 'https://commons.wikimedia.org/wiki/File:Neymar_Junior_Brazil_V_Morocco_13_June_2026-40.jpg', 'CC BY-SA 4.0', 'Neymar_Junior_Brazil_V_Morocco_13_June_2026-40.jpg'),
    ('icon-maldini', 'Paolo Maldini', 'https://upload.wikimedia.org/wikipedia/commons/0/0a/Paolo_Maldini_AC_Milan_Technical_director_2018.jpg', 'https://commons.wikimedia.org/wiki/File:Paolo_Maldini_AC_Milan_Technical_director_2018.jpg', 'CC BY 3.0', 'Paolo_Maldini_AC_Milan_Technical_director_2018.jpg'),
    ('icon-pele', 'Pelé', 'https://upload.wikimedia.org/wikipedia/commons/5/5e/Pele_con_brasil_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Pele_con_brasil_(cropped).jpg', 'Public domain', 'Pele_con_brasil_(cropped).jpg'),
    ('icon-rafa-marquez', 'Rafael Márquez', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Rafael_M%C3%A1rquez_2014.jpg', 'https://commons.wikimedia.org/wiki/File:Rafael_M%C3%A1rquez_2014.jpg', 'CC BY 2.0', 'Rafael_Márquez_2014.jpg'),
    ('icon-rivaldo', 'Rivaldo', 'https://upload.wikimedia.org/wikipedia/commons/8/8e/Rivaldo.jpg', 'https://commons.wikimedia.org/wiki/File:Rivaldo.jpg', 'CC BY 3.0 br', 'Rivaldo.jpg'),
    ('icon-roberto-carlos', 'Roberto Carlos', 'https://upload.wikimedia.org/wikipedia/commons/a/a8/LS3_1288_%2853332367864%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:LS3_1288_(53332367864)_(cropped).jpg', 'CC BY 2.0', 'LS3_1288_(53332367864)_(cropped).jpg'),
    ('icon-romario', 'Romário', 'https://upload.wikimedia.org/wikipedia/commons/a/ad/Senadores_da_57%C2%AA_Legislatura_%2852689451805%29.jpg', 'https://commons.wikimedia.org/wiki/File:Senadores_da_57%C2%AA_Legislatura_(52689451805).jpg', 'CC BY 2.0', 'Senadores_da_57ª_Legislatura_(52689451805).jpg'),
    ('icon-ronaldinho', 'Ronaldinho', 'https://upload.wikimedia.org/wikipedia/commons/e/e8/Ronaldinho_in_2019.jpg', 'https://commons.wikimedia.org/wiki/File:Ronaldinho_in_2019.jpg', 'CC BY 2.0', 'Ronaldinho_in_2019.jpg'),
    ('icon-ronaldo', 'Ronaldo Nazário', 'https://upload.wikimedia.org/wikipedia/commons/3/36/12.12.2025_%E2%80%93_Cerim%C3%B4nia_de_lan%C3%A7amento_do_SBT_News_-_54980664160_%28cropped2%29.jpg', 'https://commons.wikimedia.org/wiki/File:12.12.2025_%E2%80%93_Cerim%C3%B4nia_de_lan%C3%A7amento_do_SBT_News_-_54980664160_(cropped2).jpg', 'CC BY-SA 4.0', '12.12.2025_–_Cerimônia_de_lançamento_do_SBT_News_-_54980664160_(cropped2).jpg'),
    ('icon-gerrard', 'Steven Gerrard', 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Steven_Gerrard_2018.jpg', 'https://commons.wikimedia.org/wiki/File:Steven_Gerrard_2018.jpg', 'CC BY-SA 3.0', 'Steven_Gerrard_2018.jpg'),
    ('icon-henry', 'Thierry Henry', 'https://upload.wikimedia.org/wikipedia/commons/b/b9/Thierry_Henry_%2851649035951%29_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Thierry_Henry_(51649035951)_(cropped).jpg', 'CC BY 2.0', 'Thierry_Henry_(51649035951)_(cropped).jpg'),
    ('icon-howard', 'Tim Howard', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Tim_Howard_2023.jpg', 'https://commons.wikimedia.org/wiki/File:Tim_Howard_2023.jpg', 'CC BY-SA 2.0', 'Tim_Howard_2023.jpg'),
    ('icon-xavi', 'Xavi', 'https://upload.wikimedia.org/wikipedia/commons/a/aa/Xavi_Hern%C3%A1ndez_-_002_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Xavi_Hern%C3%A1ndez_-_002_(cropped).jpg', 'Public domain', 'Xavi_Hernández_-_002_(cropped).jpg'),
    ('icon-zico', 'Zico', 'https://upload.wikimedia.org/wikipedia/commons/e/e3/Zico_2012_3.jpg', 'https://commons.wikimedia.org/wiki/File:Zico_2012_3.jpg', 'CC BY 2.0', 'Zico_2012_3.jpg'),
    ('icon-zidane', 'Zinedine Zidane', 'https://upload.wikimedia.org/wikipedia/commons/f/f3/Zinedine_Zidane_by_Tasnim_03.jpg', 'https://commons.wikimedia.org/wiki/File:Zinedine_Zidane_by_Tasnim_03.jpg', 'CC BY 4.0', 'Zinedine_Zidane_by_Tasnim_03.jpg'),
    ('pl-haaland', 'Erling Haaland', 'https://upload.wikimedia.org/wikipedia/commons/4/43/Erling_Haaland_Morocco_v_Norway_7_June_2026-51.jpg', 'https://commons.wikimedia.org/wiki/File:Erling_Haaland_Morocco_v_Norway_7_June_2026-51.jpg', 'CC BY-SA 4.0', 'Erling_Haaland_Morocco_v_Norway_7_June_2026-51.jpg'),
    ('laliga-mbappe', 'Kylian Mbappé', 'https://upload.wikimedia.org/wikipedia/commons/9/95/Kylian_Mbappe_France_v_Senegal_16_June_2026-391_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Kylian_Mbappe_France_v_Senegal_16_June_2026-391_(cropped).jpg', 'CC BY-SA 4.0', 'Kylian_Mbappe_France_v_Senegal_16_June_2026-391_(cropped).jpg'),
    ('bund-kane', 'Harry Kane', 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Harry_Kane_England_v_Ghana_23_June_2026-219_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Harry_Kane_England_v_Ghana_23_June_2026-219_(cropped).jpg', 'CC BY-SA 4.0', 'Harry_Kane_England_v_Ghana_23_June_2026-219_(cropped).jpg'),
    ('laliga-bellingham', 'Jude Bellingham', 'https://upload.wikimedia.org/wikipedia/commons/2/23/Jude_Bellingham_England_v_Ghana_23_June_2026-061_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Jude_Bellingham_England_v_Ghana_23_June_2026-061_(cropped).jpg', 'CC BY-SA 4.0', 'Jude_Bellingham_England_v_Ghana_23_June_2026-061_(cropped).jpg'),
    ('laliga-yamal', 'Lamine Yamal', 'https://upload.wikimedia.org/wikipedia/commons/1/13/Lamine_Yamal_France_v_Spain_7.24.26-142.jpg', 'https://commons.wikimedia.org/wiki/File:Lamine_Yamal_France_v_Spain_7.24.26-142.jpg', 'CC BY-SA 4.0', 'Lamine_Yamal_France_v_Spain_7.24.26-142.jpg'),
    ('bund-olise', 'Michael Olise', 'https://upload.wikimedia.org/wikipedia/commons/0/04/Michael_Olise_France_v_Senegal_16_June_2026-307_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Michael_Olise_France_v_Senegal_16_June_2026-307_(cropped).jpg', 'CC BY-SA 4.0', 'Michael_Olise_France_v_Senegal_16_June_2026-307_(cropped).jpg'),
    ('ligue1-dembele', 'Ousmane Dembélé', 'https://upload.wikimedia.org/wikipedia/commons/6/69/Ousmane_Dembele_France_v_Senegal_16_June_2026-341_%28cropped%29_2.jpg', 'https://commons.wikimedia.org/wiki/File:Ousmane_Dembele_France_v_Senegal_16_June_2026-341_(cropped)_2.jpg', 'CC BY-SA 4.0', 'Ousmane_Dembele_France_v_Senegal_16_June_2026-341_(cropped)_2.jpg'),
    ('laliga-pedri', 'Pedri', 'https://upload.wikimedia.org/wikipedia/commons/1/1c/Pedri_France_v_Spain_7.24.26-245.jpg', 'https://commons.wikimedia.org/wiki/File:Pedri_France_v_Spain_7.24.26-245.jpg', 'CC BY-SA 4.0', 'Pedri_France_v_Spain_7.24.26-245.jpg'),
    ('pl-rodri', 'Rodri', 'https://upload.wikimedia.org/wikipedia/commons/7/7a/Rodri_Argentina_v_Spain_19_July_2026-187_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Rodri_Argentina_v_Spain_19_July_2026-187_(cropped).jpg', 'CC BY-SA 4.0', 'Rodri_Argentina_v_Spain_19_July_2026-187_(cropped).jpg'),
    ('laliga-courtois', 'Thibaut Courtois', 'https://upload.wikimedia.org/wikipedia/commons/f/f7/Thibaut_Courtois_at_the_2018_World_Cup_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Thibaut_Courtois_at_the_2018_World_Cup_(cropped).jpg', 'CC BY-SA 3.0', 'Thibaut_Courtois_at_the_2018_World_Cup_(cropped).jpg'),
    ('ligue1-vitinha', 'Vitinha', 'https://upload.wikimedia.org/wikipedia/commons/4/44/Vitinha_USMNT_v_Portugal_Mar_31_2026-50_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Vitinha_USMNT_v_Portugal_Mar_31_2026-50_(cropped).jpg', 'CC BY-SA 4.0', 'Vitinha_USMNT_v_Portugal_Mar_31_2026-50_(cropped).jpg'),
    ('pl-bruno', 'Bruno Fernandes', 'https://upload.wikimedia.org/wikipedia/commons/c/c7/Bruno_Fernandes_USMNT_v_Portugal_Mar_31_2026-27_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Bruno_Fernandes_USMNT_v_Portugal_Mar_31_2026-27_(cropped).jpg', 'CC BY-SA 4.0', 'Bruno_Fernandes_USMNT_v_Portugal_Mar_31_2026-27_(cropped).jpg'),
    ('ea27_gabriel', 'Gabriel', 'https://upload.wikimedia.org/wikipedia/commons/8/8e/Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg', 'CC BY-SA 4.0', 'Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg'),
    ('ea27_gianluigi_donnarumma', 'Gianluigi Donnarumma', 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Norway_Italy_-_June_2025_A_17_%28Gianluigi_Donnarumma%29.jpg', 'https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_17_(Gianluigi_Donnarumma).jpg', 'CC BY 4.0', 'Norway_Italy_-_June_2025_A_17_(Gianluigi_Donnarumma).jpg'),
    ('ligue1-kvara', 'Khvicha Kvaratskhelia', 'https://upload.wikimedia.org/wikipedia/commons/4/4a/Kvaratskhelia_asse_psg_2425.png', 'https://commons.wikimedia.org/wiki/File:Kvaratskhelia_asse_psg_2425.png', 'CC0', 'Kvaratskhelia_asse_psg_2425.png'),
    ('ea27_lionel_messi', 'Lionel Messi', 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Leo_Messi_Argentina_v_Egypt_7_July_2026-1.jpg', 'https://commons.wikimedia.org/wiki/File:Leo_Messi_Argentina_v_Egypt_7_July_2026-1.jpg', 'CC BY-SA 4.0', 'Leo_Messi_Argentina_v_Egypt_7_July_2026-1.jpg'),
    ('ligue1-nuno', 'Nuno Mendes', 'https://upload.wikimedia.org/wikipedia/commons/c/c0/Nuno_Mendes_Croatia_v_Portugal_2_July_2026-135_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Nuno_Mendes_Croatia_v_Portugal_2_July_2026-135_(cropped).jpg', 'CC BY-SA 4.0', 'Nuno_Mendes_Croatia_v_Portugal_2_July_2026-135_(cropped).jpg'),
    ('ea27_vinicius', 'Vini Jr.', 'https://upload.wikimedia.org/wikipedia/commons/1/10/Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_%28cropped%29.jpg', 'https://commons.wikimedia.org/wiki/File:Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg', 'CC BY-SA 4.0', 'Vinícius_Júnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg'),
    ('ligue1_willian_pacho', 'Willian Pacho', 'https://upload.wikimedia.org/wikipedia/commons/8/86/Willian_Pacho_Ecuador_v_Germany_25_June_2026-228.jpg', 'https://commons.wikimedia.org/wiki/File:Willian_Pacho_Ecuador_v_Germany_25_June_2026-228.jpg', 'CC BY-SA 4.0', 'Willian_Pacho_Ecuador_v_Germany_25_June_2026-228.jpg')
)
update public.fa_players p
set image_url = f.image_url,
    metadata = coalesce(p.metadata, '{}'::jsonb) || jsonb_build_object(
      'image_source', 'Wikimedia Commons',
      'image_file', f.image_file,
      'image_checked_at', '2026-09-19',
      'image_policy', 'licensed_or_public_domain_wikimedia'
    )
from face_data f
where p.catalog_id = f.id;

update public.fa_players p
set name = c.name,
    short_name = c.name,
    club = c.club,
    league = c.league,
    nationality = c.nationality,
    primary_position = c.primary_position,
    secondary_positions = c.secondary_positions,
    overall = c.overall,
    player_type = c.player_type,
    image_url = c.image_url,
    metadata = coalesce(p.metadata, '{}'::jsonb) || jsonb_build_object(
      'catalog_id', c.id,
      'legend_region', c.legend_region,
      'rating_status', c.metadata->>'rating_status',
      'special_card', c.metadata->>'special_card',
      'not_official_ea_fc27', true
    )
from public.fa_catalog_players c
where c.id = 'icon-pele'
  and p.catalog_id = c.id;
