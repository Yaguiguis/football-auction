-- Licensed photos for previously empty catalog entries only.
-- Existing catalog and room photos are never overwritten. Safe to re-run.
begin;
with faces as (
  select * from jsonb_to_recordset($faces$
[
  {
    "id": "bra_joao_ricardo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Jo%C3%A3o_Ricardo_%28cropped%29.jpg/250px-Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Jo%C3%A3o_Ricardo_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Jo%C3%A3o_Ricardo_(cropped).jpg",
    "image_license": "Public domain (PDM-owner)",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Fabio Giannelli / SOCCER DIGITAL",
      "image_license_url": "https://creativecommons.org/publicdomain/mark/1.0/",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Jo%C3%A3o_Ricardo_(cropped).jpg",
      "image_license": "Public domain (PDM-owner)",
      "image_file": "File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_João_Ricardo_(cropped).jpg",
      "image_checked_at": "2026-09-20",
      "image_permission_source_url": "https://www.flickr.com/photos/soccerdigital/53553783097/",
      "image_permission_review": "Photographer Flickr photo page explicitly marks the work Public Domain; Commons file uses PDMark-owner.",
      "image_policy": "explicit_permission_or_public_domain",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_lucero",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_%2853554835408%29_%28cropped%29.jpg/250px-Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_%2853554835408%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_(53554835408)_(cropped).jpg",
    "image_license": "Public domain (PDM-owner)",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Fabio Giannelli / SOCCER DIGITAL",
      "image_license_url": "https://creativecommons.org/publicdomain/mark/1.0/",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_(53554835408)_(cropped).jpg",
      "image_license": "Public domain (PDM-owner)",
      "image_file": "File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_(53554835408)_(cropped).jpg",
      "image_checked_at": "2026-09-20",
      "image_permission_source_url": "https://www.flickr.com/photos/soccerdigital/53554835408/",
      "image_permission_review": "Photographer Flickr photo page explicitly marks the work Public Domain; Commons file uses PDMark-owner.",
      "image_policy": "explicit_permission_or_public_domain",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-yildiz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e0/Kenan_Y%C4%B1ld%C4%B1z_in_the_international_match_%28March_2025%29_%28cropped%29.jpg/250px-Kenan_Y%C4%B1ld%C4%B1z_in_the_international_match_%28March_2025%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Kenan_Y%C4%B1ld%C4%B1z_in_the_international_match_(March_2025)_(cropped).jpg",
    "image_license": "Attribution (MLSZ)",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Original:  mlsz.hu – the official website of the Hungarian Football Federation / Derivative work:  Danyele",
      "image_license_url": "https://en.mlsz.hu/imprint",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Kenan_Y%C4%B1ld%C4%B1z_in_the_international_match_(March_2025)_(cropped).jpg",
      "image_license": "Attribution (MLSZ)",
      "image_file": "File:Kenan_Yıldız_in_the_international_match_(March_2025)_(cropped).jpg",
      "image_checked_at": "2026-09-20",
      "image_permission_source_url": "https://en.mlsz.hu/imprint",
      "image_permission_review": "MLSZ expressly permits reuse of photos with source attribution; Commons Attribution template confirms any-purpose reuse.",
      "image_policy": "explicit_permission_or_public_domain",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_pochettino",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b0/Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Tom%C3%A1s_Pochettino_%28cropped%29.jpg/250px-Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Tom%C3%A1s_Pochettino_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Tom%C3%A1s_Pochettino_(cropped).jpg",
    "image_license": "Public domain (PDM-owner)",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Fabio Giannelli / SOCCER DIGITAL",
      "image_license_url": "https://creativecommons.org/publicdomain/mark/1.0/",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Tom%C3%A1s_Pochettino_(cropped).jpg",
      "image_license": "Public domain (PDM-owner)",
      "image_file": "File:Sulamericana_CUP_2023_Semifinal_-_Corinthians_x_Fortaleza-CE_-_Tomás_Pochettino_(cropped).jpg",
      "image_checked_at": "2026-09-20",
      "image_permission_source_url": "https://www.flickr.com/photos/soccerdigital/53553783087/",
      "image_permission_review": "Photographer Flickr photo page explicitly marks the work Public Domain; Commons file uses PDMark-owner.",
      "image_policy": "explicit_permission_or_public_domain",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  }
]
$faces$::jsonb) as f(id text, image_url text, image_source_url text, image_license text, image_metadata jsonb)
), catalog_updated as (
  update public.fa_catalog_players c
  set image_url=f.image_url, image_source_url=f.image_source_url,
      image_license=f.image_license,
      metadata=coalesce(c.metadata,'{}'::jsonb) || f.image_metadata
  from faces f
  where c.id=f.id and nullif(btrim(c.image_url),'') is null
  returning c.id,c.image_url,c.image_source_url,c.image_license
), rooms_updated as (
  update public.fa_players p
  set image_url=c.image_url,
      metadata=coalesce(p.metadata,'{}'::jsonb) || f.image_metadata
  from catalog_updated c join faces f on f.id=c.id
  where p.catalog_id=c.id and nullif(btrim(p.image_url),'') is null
  returning p.id
)
select (select count(*) from catalog_updated) as added_catalog_faces,
       (select count(*) from rooms_updated) as updated_room_players;
commit;
