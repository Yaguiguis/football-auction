with cards(source_id,new_id,new_slug,new_name,new_overall,new_year,new_version,new_position,new_secondary) as (
  values
    ('icon-buffon','gianluigi-buffon-2006-special','gianluigi-buffon-2006-special','Gianluigi Buffon',96,2006,'2006','GOL',array[]::text[]),
    ('icon-casillas','iker-casillas-2010-special','iker-casillas-2010-special','Iker Casillas',95,2010,'2010','GOL',array[]::text[]),
    ('icon-jorge-campos','jorge-campos-1994-special','jorge-campos-1994-special','Jorge Campos',94,1994,'1994','GOL',array[]::text[]),
    ('icon-keylor','keylor-navas-2014-special','keylor-navas-2014-special','Keylor Navas',94,2014,'2014','GOL',array[]::text[]),
    ('icon-lev-yashin','lev-yashin-1963-special','lev-yashin-1963-special','Lev Yashin',97,1963,'1963','GOL',array[]::text[]),
    ('icon-howard','tim-howard-2014-special','tim-howard-2014-special','Tim Howard',94,2014,'2014','GOL',array[]::text[]),

    ('icon-maldini','paolo-maldini-1994-special','paolo-maldini-1994-special','Paolo Maldini',97,1994,'1994','ZAG',array['LE']::text[]),
    ('icon-franco-baresi','franco-baresi-1989-special','franco-baresi-1989-special','Franco Baresi',96,1989,'1989','ZAG',array['VOL']::text[]),
    ('icon-beckenbauer','franz-beckenbauer-1974-special','franz-beckenbauer-1974-special','Franz Beckenbauer',97,1974,'1974','ZAG',array['VOL']::text[]),
    ('icon-alessandro-nesta','alessandro-nesta-2003-special','alessandro-nesta-2003-special','Alessandro Nesta',95,2003,'2003','ZAG',array[]::text[]),
    ('icon-rafa-marquez','rafael-marquez-2006-special','rafael-marquez-2006-special','Rafael Márquez',94,2006,'2006','ZAG',array['VOL']::text[]),
    ('bra_thiago_silva','thiago-silva-2014-special','thiago-silva-2014-special','Thiago Silva',94,2014,'2014','ZAG',array[]::text[])
),
source_rows as (
  select
    c.*,
    s.league,
    s.nationality,
    s.legend_region,
    s.image_url,
    s.image_source_url,
    s.image_license,
    s.club,
    s.canonical_key,
    s.metadata as source_metadata
  from cards c
  join public.fa_catalog_players s on s.id=c.source_id
)
insert into public.fa_catalog_players(
  id,name,league,nationality,primary_position,player_type,legend_region,overall,enabled,
  metadata,image_url,image_source_url,image_license,club,secondary_positions,
  canonical_key,slug,season_year,version_label
)
select
  new_id,
  new_name,
  league,
  nationality,
  new_position,
  'SPECIAL',
  legend_region,
  new_overall,
  true,
  source_metadata
    || jsonb_build_object(
      'theme','world-stars',
      'season_year',new_year,
      'version_label',new_version,
      'rating_source','Football Auction game design',
      'rating_status','custom_game_design',
      'not_official_ea_fc27',true,
      'image_reused_from',source_id,
      'special_role',case when new_position='GOL' then 'goalkeeper' else 'defender' end
    ),
  image_url,
  image_source_url,
  image_license,
  club,
  new_secondary,
  canonical_key,
  new_slug,
  new_year,
  new_version
from source_rows
on conflict(id) do update set
  name=excluded.name,
  league=excluded.league,
  nationality=excluded.nationality,
  primary_position=excluded.primary_position,
  player_type='SPECIAL',
  legend_region=excluded.legend_region,
  overall=excluded.overall,
  enabled=true,
  metadata=excluded.metadata,
  image_url=excluded.image_url,
  image_source_url=excluded.image_source_url,
  image_license=excluded.image_license,
  club=excluded.club,
  secondary_positions=excluded.secondary_positions,
  canonical_key=excluded.canonical_key,
  slug=excluded.slug,
  season_year=excluded.season_year,
  version_label=excluded.version_label;
