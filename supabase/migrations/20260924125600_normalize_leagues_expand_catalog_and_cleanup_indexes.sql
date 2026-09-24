
update public.fa_catalog_players set league='La Liga' where league='LALIGA EA SPORTS';
update public.fa_catalog_players set league='Ligue 1' where league='Ligue 1 McDonald''s';
update public.fa_catalog_players set league='Serie A' where league='Serie A Enilive';

update public.fa_rooms r
set allowed_leagues = (
  select array_agg(distinct mapped order by mapped)
  from (
    select case value
      when 'LALIGA EA SPORTS' then 'La Liga'
      when 'Ligue 1 McDonald''s' then 'Ligue 1'
      when 'Serie A Enilive' then 'Serie A'
      else value
    end as mapped
    from unnest(r.allowed_leagues) value
  ) x
)
where r.allowed_leagues is not null
  and r.allowed_leagues && array['LALIGA EA SPORTS','Ligue 1 McDonald''s','Serie A Enilive'];

drop index if exists public.fa_squad_member_slot_unique;
drop index if exists public.fa_squad_players_member_id_idx;

update public.fa_catalog_players
set overall=90,
    league='La Liga',
    club='FC Barcelona',
    primary_position='PD',
    secondary_positions=array['PE','MEI']::text[],
    metadata=metadata || jsonb_build_object(
      'rating_source','Football Auction game design',
      'rating_status','custom_game_design',
      'not_official_ea_fc27',true,
      'requested_game_rating',true
    )
where id='laliga-yamal';

with cards(
  id,name,league,nationality,primary_position,secondary_positions,overall,player_type,club,season_year,version_label
) as (
values
('exp-zico-1981-special','Zico','Brasileirão','Brazil','MEI',array['MC']::text[],97,'SPECIAL','Flamengo',1981,'1981'),
('exp-socrates-1982-special','Sócrates','Brasileirão','Brazil','MEI',array['MC']::text[],95,'SPECIAL','Corinthians',1982,'1982'),
('exp-rogerio-ceni-2005-special','Rogério Ceni','Brasileirão','Brazil','GOL',array[]::text[],94,'SPECIAL','São Paulo',2005,'2005'),
('exp-marcelinho-carioca-1999-special','Marcelinho Carioca','Brasileirão','Brazil','MEI',array['PD']::text[],93,'SPECIAL','Corinthians',1999,'1999'),
('exp-juninho-pernambucano-2000-special','Juninho Pernambucano','Brasileirão','Brazil','MC',array['MEI']::text[],94,'SPECIAL','Vasco da Gama',2000,'2000'),
('exp-alex-2003-special','Alex','Brasileirão','Brazil','MEI',array['MC']::text[],94,'SPECIAL','Cruzeiro',2003,'2003'),
('exp-renato-gaucho-1983-special','Renato Gaúcho','Brasileirão','Brazil','PD',array['ATA']::text[],93,'SPECIAL','Grêmio',1983,'1983'),
('exp-edmundo-1997-special','Edmundo','Brasileirão','Brazil','ATA',array['PD']::text[],94,'SPECIAL','Vasco da Gama',1997,'1997'),
('exp-dudu-2016-special','Dudu','Brasileirão','Brazil','PE',array['PD','MEI']::text[],92,'SPECIAL','Palmeiras',2016,'2016'),
('exp-gabigol-2019-special','Gabigol','Brasileirão','Brazil','ATA',array['PD']::text[],94,'SPECIAL','Flamengo',2019,'2019'),

('exp-lahm-2013-special','Philipp Lahm','Bundesliga','Germany','LD',array['VOL']::text[],96,'SPECIAL','Bayern München',2013,'2013'),
('exp-robben-2013-special','Arjen Robben','Bundesliga','Netherlands','PD',array['PE']::text[],96,'SPECIAL','Bayern München',2013,'2013'),
('exp-ribery-2013-special','Franck Ribéry','Bundesliga','France','PE',array['MEI']::text[],96,'SPECIAL','Bayern München',2013,'2013'),
('exp-schweinsteiger-2014-special','Bastian Schweinsteiger','Bundesliga','Germany','MC',array['VOL']::text[],95,'SPECIAL','Bayern München',2014,'2014'),
('exp-reus-2012-special','Marco Reus','Bundesliga','Germany','MEI',array['PE','ATA']::text[],94,'SPECIAL','Borussia Dortmund',2012,'2012'),
('exp-hummels-2013-special','Mats Hummels','Bundesliga','Germany','ZAG',array[]::text[],94,'SPECIAL','Borussia Dortmund',2013,'2013'),
('exp-kahn-2001-special','Oliver Kahn','Bundesliga','Germany','GOL',array[]::text[],96,'SPECIAL','Bayern München',2001,'2001'),
('exp-ballack-2002-special','Michael Ballack','Bundesliga','Germany','MC',array['MEI']::text[],95,'SPECIAL','Bayer Leverkusen',2002,'2002'),
('exp-klose-2007-special','Miroslav Klose','Bundesliga','Germany','ATA',array[]::text[],94,'SPECIAL','Bayern München',2007,'2007'),
('exp-gotze-2014-special','Mario Götze','Bundesliga','Germany','MEI',array['ATA']::text[],94,'SPECIAL','Bayern München',2014,'2014'),

('exp-ramos-2017-special','Sergio Ramos','La Liga','Spain','ZAG',array[]::text[],96,'SPECIAL','Real Madrid',2017,'2017'),
('exp-marcelo-2017-special','Marcelo','La Liga','Brazil','LE',array['PE']::text[],95,'SPECIAL','Real Madrid',2017,'2017'),
('exp-kroos-2017-special','Toni Kroos','La Liga','Germany','MC',array['VOL']::text[],95,'SPECIAL','Real Madrid',2017,'2017'),
('exp-benzema-2022-special','Karim Benzema','La Liga','France','ATA',array['MEI']::text[],97,'SPECIAL','Real Madrid',2022,'2022'),
('exp-suarez-2016-special','Luis Suárez','La Liga','Uruguay','ATA',array[]::text[],96,'SPECIAL','FC Barcelona',2016,'2016'),
('exp-busquets-2011-special','Sergio Busquets','La Liga','Spain','VOL',array['MC']::text[],95,'SPECIAL','FC Barcelona',2011,'2011'),
('exp-puyol-2009-special','Carles Puyol','La Liga','Spain','ZAG',array['LD']::text[],95,'SPECIAL','FC Barcelona',2009,'2009'),
('exp-griezmann-2016-special','Antoine Griezmann','La Liga','France','ATA',array['MEI']::text[],94,'SPECIAL','Atlético de Madrid',2016,'2016'),
('exp-courtois-2022-special','Thibaut Courtois','La Liga','Belgium','GOL',array[]::text[],95,'SPECIAL','Real Madrid',2022,'2022'),
('exp-david-villa-2010-special','David Villa','La Liga','Spain','ATA',array['PE']::text[],95,'SPECIAL','FC Barcelona',2010,'2010'),

('exp-ibrahimovic-2015-special','Zlatan Ibrahimović','Ligue 1','Sweden','ATA',array[]::text[],96,'SPECIAL','Paris Saint-Germain',2015,'2015'),
('exp-cavani-2017-special','Edinson Cavani','Ligue 1','Uruguay','ATA',array[]::text[],94,'SPECIAL','Paris Saint-Germain',2017,'2017'),
('exp-thiago-silva-2015-special','Thiago Silva','Ligue 1','Brazil','ZAG',array[]::text[],94,'SPECIAL','Paris Saint-Germain',2015,'2015'),
('exp-verratti-2019-special','Marco Verratti','Ligue 1','Italy','MC',array['VOL']::text[],93,'SPECIAL','Paris Saint-Germain',2019,'2019'),
('exp-di-maria-2020-special','Ángel Di María','Ligue 1','Argentina','PD',array['MEI']::text[],94,'SPECIAL','Paris Saint-Germain',2020,'2020'),
('exp-juninho-2006-special','Juninho','Ligue 1','Brazil','MC',array['MEI']::text[],95,'SPECIAL','Lyon',2006,'2006'),
('exp-benzema-2007-special','Karim Benzema','Ligue 1','France','ATA',array[]::text[],92,'SPECIAL','Lyon',2007,'2007'),
('exp-pauleta-2006-special','Pauleta','Ligue 1','Portugal','ATA',array[]::text[],92,'SPECIAL','Paris Saint-Germain',2006,'2006'),
('exp-hazard-lille-2011-special','Eden Hazard','Ligue 1','Belgium','PE',array['MEI']::text[],93,'SPECIAL','Lille',2011,'2011'),
('exp-lloris-2012-special','Hugo Lloris','Ligue 1','France','GOL',array[]::text[],93,'SPECIAL','Lyon',2012,'2012'),

('exp-rooney-2010-special','Wayne Rooney','Premier League','England','ATA',array['MEI']::text[],96,'SPECIAL','Manchester United',2010,'2010'),
('exp-drogba-2010-special','Didier Drogba','Premier League','Ivory Coast','ATA',array[]::text[],95,'SPECIAL','Chelsea',2010,'2010'),
('exp-lampard-2009-special','Frank Lampard','Premier League','England','MC',array['MEI']::text[],95,'SPECIAL','Chelsea',2009,'2009'),
('exp-gerrard-2009-special','Steven Gerrard','Premier League','England','MC',array['MEI','VOL']::text[],95,'SPECIAL','Liverpool',2009,'2009'),
('exp-terry-2005-special','John Terry','Premier League','England','ZAG',array[]::text[],95,'SPECIAL','Chelsea',2005,'2005'),
('exp-cech-2005-special','Petr Čech','Premier League','Czech Republic','GOL',array[]::text[],95,'SPECIAL','Chelsea',2005,'2005'),
('exp-yaya-2014-special','Yaya Touré','Premier League','Ivory Coast','MC',array['VOL','MEI']::text[],95,'SPECIAL','Manchester City',2014,'2014'),
('exp-aguero-2019-special','Sergio Agüero','Premier League','Argentina','ATA',array[]::text[],95,'SPECIAL','Manchester City',2019,'2019'),
('exp-van-persie-2012-special','Robin van Persie','Premier League','Netherlands','ATA',array['PD']::text[],95,'SPECIAL','Arsenal',2012,'2012'),
('exp-de-bruyne-2020-special','Kevin De Bruyne','Premier League','Belgium','MEI',array['MC']::text[],96,'SPECIAL','Manchester City',2020,'2020'),

('exp-buffon-2003-special','Gianluigi Buffon','Serie A','Italy','GOL',array[]::text[],95,'SPECIAL','Juventus',2003,'2003'),
('exp-cannavaro-2006-special','Fabio Cannavaro','Serie A','Italy','ZAG',array[]::text[],97,'SPECIAL','Juventus',2006,'2006'),
('exp-nesta-2003-seriea-special','Alessandro Nesta','Serie A','Italy','ZAG',array[]::text[],95,'SPECIAL','AC Milan',2003,'2003'),
('exp-pirlo-2012-special','Andrea Pirlo','Serie A','Italy','MC',array['VOL']::text[],95,'SPECIAL','Juventus',2012,'2012'),
('exp-totti-2007-special','Francesco Totti','Serie A','Italy','MEI',array['ATA']::text[],96,'SPECIAL','Roma',2007,'2007'),
('exp-del-piero-1998-special','Alessandro Del Piero','Serie A','Italy','ATA',array['MEI']::text[],96,'SPECIAL','Juventus',1998,'1998'),
('exp-shevchenko-2004-special','Andriy Shevchenko','Serie A','Ukraine','ATA',array[]::text[],96,'SPECIAL','AC Milan',2004,'2004'),
('exp-zanetti-2010-special','Javier Zanetti','Serie A','Argentina','LD',array['VOL']::text[],95,'SPECIAL','Inter',2010,'2010'),
('exp-sneijder-2010-special','Wesley Sneijder','Serie A','Netherlands','MEI',array['MC']::text[],95,'SPECIAL','Inter',2010,'2010'),
('exp-chiellini-2017-special','Giorgio Chiellini','Serie A','Italy','ZAG',array['LE']::text[],94,'SPECIAL','Juventus',2017,'2017'),

('exp-deco-2004-special','Deco','Liga Portugal','Portugal','MEI',array['MC']::text[],95,'SPECIAL','FC Porto',2004,'2004'),
('exp-falcao-2011-special','Radamel Falcao','Liga Portugal','Colombia','ATA',array[]::text[],95,'SPECIAL','FC Porto',2011,'2011'),
('exp-hulk-2011-special','Hulk','Liga Portugal','Brazil','ATA',array['PD']::text[],94,'SPECIAL','FC Porto',2011,'2011'),
('exp-pepe-2021-special','Pepe','Liga Portugal','Portugal','ZAG',array[]::text[],93,'SPECIAL','FC Porto',2021,'2021'),
('exp-rui-patricio-2012-special','Rui Patrício','Liga Portugal','Portugal','GOL',array[]::text[],92,'SPECIAL','Sporting CP',2012,'2012'),
('exp-moutinho-2011-special','João Moutinho','Liga Portugal','Portugal','MC',array['VOL']::text[],92,'SPECIAL','FC Porto',2011,'2011'),
('exp-luis-diaz-2021-special','Luis Díaz','Liga Portugal','Colombia','PE',array['PD']::text[],93,'SPECIAL','FC Porto',2021,'2021'),
('exp-darwin-2022-special','Darwin Núñez','Liga Portugal','Uruguay','ATA',array['PE']::text[],93,'SPECIAL','Benfica',2022,'2022'),
('exp-enzo-2022-special','Enzo Fernández','Liga Portugal','Argentina','MC',array['VOL']::text[],93,'SPECIAL','Benfica',2022,'2022'),
('exp-joao-felix-2019-special','João Félix','Liga Portugal','Portugal','MEI',array['ATA']::text[],94,'SPECIAL','Benfica',2019,'2019'),

('exp-beckham-2011-special','David Beckham','MLS','England','MC',array['PD']::text[],93,'SPECIAL','LA Galaxy',2011,'2011'),
('exp-henry-2012-mls-special','Thierry Henry','MLS','France','ATA',array['PE']::text[],94,'SPECIAL','New York Red Bulls',2012,'2012'),
('exp-donovan-2010-special','Landon Donovan','MLS','United States','ATA',array['PD','MEI']::text[],93,'SPECIAL','LA Galaxy',2010,'2010'),
('exp-vela-2019-special','Carlos Vela','MLS','Mexico','PD',array['ATA']::text[],94,'SPECIAL','LAFC',2019,'2019'),
('exp-josef-2018-special','Josef Martínez','MLS','Venezuela','ATA',array[]::text[],93,'SPECIAL','Atlanta United',2018,'2018'),
('exp-giovinco-2015-special','Sebastian Giovinco','MLS','Italy','MEI',array['ATA']::text[],94,'SPECIAL','Toronto FC',2015,'2015'),
('exp-dempsey-2014-special','Clint Dempsey','MLS','United States','ATA',array['MEI']::text[],92,'SPECIAL','Seattle Sounders',2014,'2014'),
('exp-howard-2016-special','Tim Howard','MLS','United States','GOL',array[]::text[],92,'SPECIAL','Colorado Rapids',2016,'2016'),
('exp-zlatan-2019-mls-special','Zlatan Ibrahimović','MLS','Sweden','ATA',array[]::text[],94,'SPECIAL','LA Galaxy',2019,'2019'),
('exp-messi-2024-mls-special','Lionel Messi','MLS','Argentina','MEI',array['PD','ATA']::text[],95,'SPECIAL','Inter Miami',2024,'2024'),

('exp-hagi-2000-special','Gheorghe Hagi','Trendyol Süper Lig','Romania','MEI',array['MC']::text[],96,'SPECIAL','Galatasaray',2000,'2000'),
('exp-drogba-2013-superlig-special','Didier Drogba','Trendyol Süper Lig','Ivory Coast','ATA',array[]::text[],93,'SPECIAL','Galatasaray',2013,'2013'),
('exp-sneijder-2013-superlig-special','Wesley Sneijder','Trendyol Süper Lig','Netherlands','MEI',array['MC']::text[],93,'SPECIAL','Galatasaray',2013,'2013'),
('exp-alex-2011-superlig-special','Alex','Trendyol Süper Lig','Brazil','MEI',array['MC']::text[],95,'SPECIAL','Fenerbahçe',2011,'2011'),
('exp-muslera-2019-special','Fernando Muslera','Trendyol Süper Lig','Uruguay','GOL',array[]::text[],92,'SPECIAL','Galatasaray',2019,'2019'),
('exp-quaresma-2016-special','Ricardo Quaresma','Trendyol Süper Lig','Portugal','PD',array['PE']::text[],92,'SPECIAL','Beşiktaş',2016,'2016'),
('exp-van-persie-2016-superlig-special','Robin van Persie','Trendyol Süper Lig','Netherlands','ATA',array['PD']::text[],92,'SPECIAL','Fenerbahçe',2016,'2016'),
('exp-mario-gomez-2016-special','Mario Gómez','Trendyol Süper Lig','Germany','ATA',array[]::text[],93,'SPECIAL','Beşiktaş',2016,'2016'),
('exp-talisca-2017-special','Talisca','Trendyol Süper Lig','Brazil','MEI',array['ATA']::text[],92,'SPECIAL','Beşiktaş',2017,'2017'),
('exp-burak-2013-special','Burak Yılmaz','Trendyol Süper Lig','Turkey','ATA',array[]::text[],92,'SPECIAL','Galatasaray',2013,'2013'),

('exp-icon-george-best','George Best','LEGENDS','Northern Ireland','PD',array['PE','ATA']::text[],96,'ICON',null,null,'ICON'),
('exp-icon-bobby-charlton','Bobby Charlton','LEGENDS','England','MEI',array['MC','ATA']::text[],96,'ICON',null,null,'ICON'),
('exp-icon-carlos-alberto','Carlos Alberto Torres','LEGENDS','Brazil','LD',array['ZAG']::text[],96,'ICON',null,null,'ICON'),
('exp-icon-peter-schmeichel','Peter Schmeichel','LEGENDS','Denmark','GOL',array[]::text[],95,'ICON',null,null,'ICON'),
('exp-icon-didier-deschamps','Didier Deschamps','LEGENDS','France','VOL',array['MC']::text[],93,'ICON',null,null,'ICON'),
('exp-icon-gordon-banks','Gordon Banks','LEGENDS','England','GOL',array[]::text[],95,'ICON',null,null,'ICON'),
('exp-icon-dino-zoff','Dino Zoff','LEGENDS','Italy','GOL',array[]::text[],95,'ICON',null,null,'ICON'),
('exp-icon-giacinto-facchetti','Giacinto Facchetti','LEGENDS','Italy','LE',array['ZAG']::text[],95,'ICON',null,null,'ICON'),
('exp-icon-jairzinho','Jairzinho','LEGENDS','Brazil','PD',array['ATA']::text[],96,'ICON',null,null,'ICON'),
('exp-icon-raymond-kopa','Raymond Kopa','LEGENDS','France','MEI',array['PD']::text[],94,'ICON',null,null,'ICON')
)
insert into public.fa_catalog_players(
  id,name,league,nationality,primary_position,secondary_positions,player_type,overall,enabled,
  metadata,image_url,image_source_url,image_license,club,canonical_key,slug,season_year,version_label
)
select
  id,name,league,nationality,primary_position,secondary_positions,player_type,overall,true,
  jsonb_build_object(
    'catalog_batch','league_expansion_20260924',
    'theme',case when player_type='ICON' then 'icons' else 'world-stars' end,
    'season_year',season_year,
    'version_label',version_label,
    'rating_source','Football Auction game design',
    'rating_status','custom_game_design',
    'not_official_ea_fc27',true
  ),
  null,null,null,club,
  'expansion:'||id,
  id,
  season_year,
  version_label
from cards
on conflict(id) do update set
  name=excluded.name,
  league=excluded.league,
  nationality=excluded.nationality,
  primary_position=excluded.primary_position,
  secondary_positions=excluded.secondary_positions,
  player_type=excluded.player_type,
  overall=excluded.overall,
  enabled=true,
  metadata=excluded.metadata,
  club=excluded.club,
  season_year=excluded.season_year,
  version_label=excluded.version_label;

with best_source as (
  select distinct on (lower(name))
    lower(name) as lname,
    image_url,
    image_source_url,
    image_license
  from public.fa_catalog_players
  where image_url is not null
    and coalesce(metadata->>'catalog_batch','')<>'league_expansion_20260924'
  order by lower(name),
           case when player_type='ACTIVE' then 0 else 1 end,
           created_at
)
update public.fa_catalog_players target
set image_url=source.image_url,
    image_source_url=source.image_source_url,
    image_license=source.image_license
from best_source source
where target.metadata->>'catalog_batch'='league_expansion_20260924'
  and target.image_url is null
  and lower(target.name)=source.lname;
