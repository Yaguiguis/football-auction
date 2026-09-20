-- Licensed photos for previously empty catalog entries only.
-- Existing catalog and room photos are never overwritten. Safe to re-run.
begin;
with faces as (
  select * from jsonb_to_recordset($faces$
[
  {
    "id": "ligue1-hakimi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/56/Achraf_Hakimi_Morocco_v_Norway_7_June_2026-16.jpg/250px-Achraf_Hakimi_Morocco_v_Norway_7_June_2026-16.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Achraf_Hakimi_Morocco_v_Norway_7_June_2026-16.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Achraf_Hakimi_Morocco_v_Norway_7_June_2026-16.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Achraf_Hakimi_Morocco_v_Norway_7_June_2026-16.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-lookman",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b7/Ademola_Lookman_%282019%29_%28cropped%29.jpg/250px-Ademola_Lookman_%282019%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ademola_Lookman_(2019)_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Willibald11",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ademola_Lookman_(2019)_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Ademola_Lookman_(2019)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-rabiot",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/62/Adrien_Rabiot_France_v_Senegal_16_June_2026-253.jpg/250px-Adrien_Rabiot_France_v_Senegal_16_June_2026-253.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Adrien_Rabiot_France_v_Senegal_16_June_2026-253.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Adrien_Rabiot_France_v_Senegal_16_June_2026-253.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Adrien_Rabiot_France_v_Senegal_16_June_2026-253.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_alan_patrick",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/61/Alan_Patrick_2018.jpg/250px-Alan_Patrick_2018.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alan_Patrick_2018.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Олег Батрак",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alan_Patrick_2018.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Alan_Patrick_2018.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_aleix_garcia",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/89/Aleix_Garcia_Serrano_SBS_Cup_2015_%28cropped%29.jpg/250px-Aleix_Garcia_Serrano_SBS_Cup_2015_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Aleix_Garcia_Serrano_SBS_Cup_2015_(cropped).jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Tam Tam from Shizuoka, JAPAN",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Aleix_Garcia_Serrano_SBS_Cup_2015_(cropped).jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:Aleix_Garcia_Serrano_SBS_Cup_2015_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_alejandro_balde",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/93/Esapana-inglaterra-74_%2848899354493%29.jpg/250px-Esapana-inglaterra-74_%2848899354493%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Esapana-inglaterra-74_(48899354493).jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Pedro  Semitiel from Cehegín, España",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Esapana-inglaterra-74_(48899354493).jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:Esapana-inglaterra-74_(48899354493).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_aleksandar_pavlovic",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ed/Aleksandar_Pavlovic_Ecuador_v_Germany_25_June_2026-036.jpg/250px-Aleksandar_Pavlovic_Ecuador_v_Germany_25_June_2026-036.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Aleksandar_Pavlovic_Ecuador_v_Germany_25_June_2026-036.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Aleksandar_Pavlovic_Ecuador_v_Germany_25_June_2026-036.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Aleksandar_Pavlovic_Ecuador_v_Germany_25_June_2026-036.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_aleksandr_golovin",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e7/Aleksandr_Golovin.jpg/250px-Aleksandr_Golovin.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Aleksandr_Golovin.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Кирилл Венедиктов",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Aleksandr_Golovin.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Aleksandr_Golovin.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-bastoni",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/Norway_Italy_-_June_2025_A_36_%28cropped%29.jpg/250px-Norway_Italy_-_June_2025_A_36_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_36_(cropped).jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "MichaelEmilio",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_36_(cropped).jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Norway_Italy_-_June_2025_A_36_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_alessandro_buongiorno",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f0/Lens_-_Torino_FC_%2802-08-2023%29_47_%28cropped%29.jpg/250px-Lens_-_Torino_FC_%2802-08-2023%29_47_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Lens_-_Torino_FC_(02-08-2023)_47_(cropped).jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Supporterhéninois",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Lens_-_Torino_FC_(02-08-2023)_47_(cropped).jpg",
      "image_license": "CC0",
      "image_file": "File:Lens_-_Torino_FC_(02-08-2023)_47_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_alex_meret",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/66/Alex_Meret_%28cropped%29.jpg/250px-Alex_Meret_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alex_Meret_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Rapallo80",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alex_Meret_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alex_Meret_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-isak",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/32/Alexander_Isak_-_Sweden_-_Greece21_%28cropped%29.jpg/250px-Alexander_Isak_-_Sweden_-_Greece21_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alexander_Isak_-_Sweden_-_Greece21_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Mikael Hervestad",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alexander_Isak_-_Sweden_-_Greece21_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alexander_Isak_-_Sweden_-_Greece21_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_alexander_nubel",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/00/Alexander_Nubel_Ecuador_v_Germany_25_June_2026-154.jpg/250px-Alexander_Nubel_Ecuador_v_Germany_25_June_2026-154.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alexander_Nubel_Ecuador_v_Germany_25_June_2026-154.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alexander_Nubel_Ecuador_v_Germany_25_June_2026-154.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alexander_Nubel_Ecuador_v_Germany_25_June_2026-154.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_alexis_mac_allister",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/db/Alexis_Mac_Allister_Argentina_v_Spain_19_July_2026-162_%28cropped%29.jpg/250px-Alexis_Mac_Allister_Argentina_v_Spain_19_July_2026-162_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alexis_Mac_Allister_Argentina_v_Spain_19_July_2026-162_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alexis_Mac_Allister_Argentina_v_Spain_19_July_2026-162_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alexis_Mac_Allister_Argentina_v_Spain_19_July_2026-162_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-alisson",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Alisson_Becker_Brazil_V_Morocco_13_June_2026-117_%28cropped%29.jpg/250px-Alisson_Becker_Brazil_V_Morocco_13_June_2026-117_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alisson_Becker_Brazil_V_Morocco_13_June_2026-117_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alisson_Becker_Brazil_V_Morocco_13_June_2026-117_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alisson_Becker_Brazil_V_Morocco_13_June_2026-117_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-davies",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/27/Alphonso_Davies_Canada_v_Qatar_18_June_2026-007_%28cropped%29.jpg/250px-Alphonso_Davies_Canada_v_Qatar_18_June_2026-007_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alphonso_Davies_Canada_v_Qatar_18_June_2026-007_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alphonso_Davies_Canada_v_Qatar_18_June_2026-007_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alphonso_Davies_Canada_v_Qatar_18_June_2026-007_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_amad_diallo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1a/Amad_Diallo_Cote_D%27Ivoire_v_Ecuador_14_June_2026-256_%28cropped_2%29.jpg/250px-Amad_Diallo_Cote_D%27Ivoire_v_Ecuador_14_June_2026-256_%28cropped_2%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Amad_Diallo_Cote_D%27Ivoire_v_Ecuador_14_June_2026-256_(cropped_2).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Amad_Diallo_Cote_D%27Ivoire_v_Ecuador_14_June_2026-256_(cropped_2).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Amad_Diallo_Cote_D'Ivoire_v_Ecuador_14_June_2026-256_(cropped_2).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_amine_gouiri",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/96/Lens_-_Stade_Rennais_%2820-08-2023%29_22.jpg/250px-Lens_-_Stade_Rennais_%2820-08-2023%29_22.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Lens_-_Stade_Rennais_(20-08-2023)_22.jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Supporterhéninois",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Lens_-_Stade_Rennais_(20-08-2023)_22.jpg",
      "image_license": "CC0",
      "image_file": "File:Lens_-_Stade_Rennais_(20-08-2023)_22.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_angelo_stiller",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/17/Angelo_Stiller_Ecuador_v_Germany_25_June_2026-233_%28cropped%29.jpg/250px-Angelo_Stiller_Ecuador_v_Germany_25_June_2026-233_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Angelo_Stiller_Ecuador_v_Germany_25_June_2026-233_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Angelo_Stiller_Ecuador_v_Germany_25_June_2026-233_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Angelo_Stiller_Ecuador_v_Germany_25_June_2026-233_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_anthony_gordon",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/42/Team_England_England_v_Ghana_at_2026_Fifa_World_Cup_by_YantsImages_03_%28Anthony_Gordon%29.jpg/250px-Team_England_England_v_Ghana_at_2026_Fifa_World_Cup_by_YantsImages_03_%28Anthony_Gordon%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Team_England_England_v_Ghana_at_2026_Fifa_World_Cup_by_YantsImages_03_(Anthony_Gordon).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "YantsImages",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Team_England_England_v_Ghana_at_2026_Fifa_World_Cup_by_YantsImages_03_(Anthony_Gordon).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Team_England_England_v_Ghana_at_2026_Fifa_World_Cup_by_YantsImages_03_(Anthony_Gordon).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_antoine_griezmann",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6e/FRA-ARG_%2810%29_%28cropped%29.jpg/250px-FRA-ARG_%2810%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FRA-ARG_(10)_(cropped).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Антон Зайцев",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FRA-ARG_(10)_(cropped).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:FRA-ARG_(10)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-rudiger",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/72/Antonio_Rudiger_Ecuador_v_Germany_25_June_2026-055_%28cropped%29.jpg/250px-Antonio_Rudiger_Ecuador_v_Germany_25_June_2026-055_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Antonio_Rudiger_Ecuador_v_Germany_25_June_2026-055_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Antonio_Rudiger_Ecuador_v_Germany_25_June_2026-055_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Antonio_Rudiger_Ecuador_v_Germany_25_June_2026-055_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-tchouameni",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c0/Aurelien_Tchouameni_France_v_Senegal_16_June_2026-447_%28cropped%29.jpg/250px-Aurelien_Tchouameni_France_v_Senegal_16_June_2026-447_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Aurelien_Tchouameni_France_v_Senegal_16_June_2026-447_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Aurelien_Tchouameni_France_v_Senegal_16_June_2026-447_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Aurelien_Tchouameni_France_v_Senegal_16_June_2026-447_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_bastos",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b5/Bastos_2021.jpg/250px-Bastos_2021.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bastos_2021.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Анна Нэсси",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bastos_2021.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Bastos_2021.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_bernardo_silva",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d2/Bernardo_Silva_Croatia_v_Portugal_2_July_2026-238.jpg/250px-Bernardo_Silva_Croatia_v_Portugal_2_July_2026-238.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bernardo_Silva_Croatia_v_Portugal_2_July_2026-238.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bernardo_Silva_Croatia_v_Portugal_2_July_2026-238.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Bernardo_Silva_Croatia_v_Portugal_2_July_2026-238.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-barcola",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f6/Bradley_Barcola_France_v_Spain_7.24.26-112_%28cropped%29.jpg/250px-Bradley_Barcola_France_v_Spain_7.24.26-112_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bradley_Barcola_France_v_Spain_7.24.26-112_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bradley_Barcola_France_v_Spain_7.24.26-112_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Bradley_Barcola_France_v_Spain_7.24.26-112_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_brahim_diaz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/90/Brahim_Diaz_Morocco_v_Norway_7_June_2026-36_%28cropped_3-4%29.jpg/250px-Brahim_Diaz_Morocco_v_Norway_7_June_2026-36_%28cropped_3-4%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Brahim_Diaz_Morocco_v_Norway_7_June_2026-36_(cropped_3-4).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Brahim_Diaz_Morocco_v_Norway_7_June_2026-36_(cropped_3-4).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Brahim_Diaz_Morocco_v_Norway_7_June_2026-36_(cropped_3-4).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-bremer",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9a/Bremer_Brazil_V_Morocco_13_June_2026-143_%28cropped%29.jpg/250px-Bremer_Brazil_V_Morocco_13_June_2026-143_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bremer_Brazil_V_Morocco_13_June_2026-143_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bremer_Brazil_V_Morocco_13_June_2026-143_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Bremer_Brazil_V_Morocco_13_June_2026-143_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_bruno_guimaraes",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/70/Bruno_Guimaraes_Brazil_V_Morocco_13_June_2026-78_%28cropped%29.jpg/250px-Bruno_Guimaraes_Brazil_V_Morocco_13_June_2026-78_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bruno_Guimaraes_Brazil_V_Morocco_13_June_2026-78_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bruno_Guimaraes_Brazil_V_Morocco_13_June_2026-78_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Bruno_Guimaraes_Brazil_V_Morocco_13_June_2026-78_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_bruno_henrique",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/24/Bruno_Henrique.2019.jpg/250px-Bruno_Henrique.2019.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bruno_Henrique.2019.jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Segue o baile",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bruno_Henrique.2019.jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:Bruno Henrique.2019.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-saka",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2f/Bukayo_Saka_England_v_Ghana_23_June_2026-057_%28cropped%29.jpg/250px-Bukayo_Saka_England_v_Ghana_23_June_2026-057_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Bukayo_Saka_England_v_Ghana_23_June_2026-057_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Bukayo_Saka_England_v_Ghana_23_June_2026-057_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Bukayo_Saka_England_v_Ghana_23_June_2026-057_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_chris_fuhrich",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d9/Chris_fuehrich.jpg/250px-Chris_fuehrich.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Chris_fuehrich.jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Jeollo von VfB-exklusiv.de",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Chris_fuehrich.jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:Chris_fuehrich.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-pulisic",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/71/Christian_Pulisic_USMNT_v_Belgium_Mar_28_2026-73_%28cropped%29.jpg/250px-Christian_Pulisic_USMNT_v_Belgium_Mar_28_2026-73_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Christian_Pulisic_USMNT_v_Belgium_Mar_28_2026-73_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Christian_Pulisic_USMNT_v_Belgium_Mar_28_2026-73_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Christian_Pulisic_USMNT_v_Belgium_Mar_28_2026-73_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-palmer",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fb/Cole_Palmer_2025_FIFA_Club_World_Cup_Final.jpg/250px-Cole_Palmer_2025_FIFA_Club_World_Cup_Final.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Cole_Palmer_2025_FIFA_Club_World_Cup_Final.jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "The White House",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Cole_Palmer_2025_FIFA_Club_World_Cup_Final.jpg",
      "image_license": "Public domain",
      "image_file": "File:Cole_Palmer_2025_FIFA_Club_World_Cup_Final.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_corentin_tolisso",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f0/Tolisso_asse_ol_2425.png/250px-Tolisso_asse_ol_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Tolisso_asse_ol_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Tolisso_asse_ol_2425.png",
      "image_license": "CC0",
      "image_file": "File:Tolisso_asse_ol_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_cucurella",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8a/Marc_Cucurella_Argentina_v_Spain_19_July_2026-064_%28cropped%29.jpg/250px-Marc_Cucurella_Argentina_v_Spain_19_July_2026-064_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Marc_Cucurella_Argentina_v_Spain_19_July_2026-064_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Marc_Cucurella_Argentina_v_Spain_19_July_2026-064_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Marc_Cucurella_Argentina_v_Spain_19_July_2026-064_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_cassio",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/da/Cassio-Corinthians-Juventude-jul-2022.jpg/250px-Cassio-Corinthians-Juventude-jul-2022.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Cassio-Corinthians-Juventude-jul-2022.jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "SOCCER DIGITAL",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Cassio-Corinthians-Juventude-jul-2022.jpg",
      "image_license": "Public domain",
      "image_file": "File:Cassio-Corinthians-Juventude-jul-2022.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_dani_carvajal",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b6/UEFA_EURO_qualifiers_Sweden_vs_Spain_20191015_Dani_Carvajal_10_%28cropped%29.jpg/250px-UEFA_EURO_qualifiers_Sweden_vs_Spain_20191015_Dani_Carvajal_10_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:UEFA_EURO_qualifiers_Sweden_vs_Spain_20191015_Dani_Carvajal_10_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Rolandhino1",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:UEFA_EURO_qualifiers_Sweden_vs_Spain_20191015_Dani_Carvajal_10_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:UEFA_EURO_qualifiers_Sweden_vs_Spain_20191015_Dani_Carvajal_10_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_dani_olmo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/83/Dani_Olmo_France_v_Spain_7.24.26-176_%28cropped%29.jpg/250px-Dani_Olmo_France_v_Spain_7.24.26-176_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Dani_Olmo_France_v_Spain_7.24.26-176_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Dani_Olmo_France_v_Spain_7.24.26-176_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Dani_Olmo_France_v_Spain_7.24.26-176_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_dante",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b4/Dante_asse_ogcn_2425.png/250px-Dante_asse_ogcn_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Dante_asse_ogcn_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Dante_asse_ogcn_2425.png",
      "image_license": "CC0",
      "image_file": "File:Dante_asse_ogcn_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_david_raum",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/02/David_Raum_Ecuador_v_Germany_25_June_2026-117.jpg/250px-David_Raum_Ecuador_v_Germany_25_June_2026-117.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:David_Raum_Ecuador_v_Germany_25_June_2026-117.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:David_Raum_Ecuador_v_Germany_25_June_2026-117.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:David_Raum_Ecuador_v_Germany_25_June_2026-117.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_david_raya",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8a/David_Raya_Argentina_v_Spain_19_July_2026-003_%28cropped%29.jpg/250px-David_Raya_Argentina_v_Spain_19_July_2026-003_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:David_Raya_Argentina_v_Spain_19_July_2026-003_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:David_Raya_Argentina_v_Spain_19_July_2026-003_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:David_Raya_Argentina_v_Spain_19_July_2026-003_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-upamecano",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/ca/Dayot_Upamecano_France_v_Senegal_16_June_2026-402_%28cropped%29.jpg/250px-Dayot_Upamecano_France_v_Senegal_16_June_2026-402_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Dayot_Upamecano_France_v_Senegal_16_June_2026-402_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Dayot_Upamecano_France_v_Senegal_16_June_2026-402_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Dayot_Upamecano_France_v_Senegal_16_June_2026-402_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-rice",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/Declan_Rice_England_v_Ghana_23_June_2026-150.jpg/250px-Declan_Rice_England_v_Ghana_23_June_2026-150.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Declan_Rice_England_v_Ghana_23_June_2026-150.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Declan_Rice_England_v_Ghana_23_June_2026-150.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Declan_Rice_England_v_Ghana_23_June_2026-150.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_denis_zakaria",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0d/Zakaria_asse_asm_2425_%28cropped%29.png/250px-Zakaria_asse_asm_2425_%28cropped%29.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Zakaria_asse_asm_2425_(cropped).png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Zakaria_asse_asm_2425_(cropped).png",
      "image_license": "CC0",
      "image_file": "File:Zakaria_asse_asm_2425_(cropped).png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-undav",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/88/Deniz_Undav_Ecuador_v_Germany_25_June_2026-203_%28cropped%29.jpg/250px-Deniz_Undav_Ecuador_v_Germany_25_June_2026-203_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Deniz_Undav_Ecuador_v_Germany_25_June_2026-203_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Deniz_Undav_Ecuador_v_Germany_25_June_2026-203_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Deniz_Undav_Ecuador_v_Germany_25_June_2026-203_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_diogo_costa",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/45/Diogo_Costa_Croatia_v_Portugal_2_July_2026-188_%28cropped%29.jpg/250px-Diogo_Costa_Croatia_v_Portugal_2_July_2026-188_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Diogo_Costa_Croatia_v_Portugal_2_July_2026-188_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Diogo_Costa_Croatia_v_Portugal_2_July_2026-188_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Diogo_Costa_Croatia_v_Portugal_2_July_2026-188_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_dominik_szoboszlai",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/52/Dominik_Szoboszlai_04012026_%281%29.jpg/250px-Dominik_Szoboszlai_04012026_%281%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Dominik_Szoboszlai_04012026_(1).jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Timmy96",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Dominik_Szoboszlai_04012026_(1).jpg",
      "image_license": "CC0",
      "image_file": "File:Dominik_Szoboszlai_04012026_(1).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-vlahovic",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/0/0c/Du%C5%A1an_Vlahovi%C4%87.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Du%C5%A1an_Vlahovi%C4%87.jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "sportslivematchday",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Du%C5%A1an_Vlahovi%C4%87.jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Dušan_Vlahović.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_desire_doue",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/92/Desire_Doue_France_v_Senegal_16_June_2026-264.jpg/250px-Desire_Doue_France_v_Senegal_16_June_2026-264.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Desire_Doue_France_v_Senegal_16_June_2026-264.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Desire_Doue_France_v_Senegal_16_June_2026-264.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Desire_Doue_France_v_Senegal_16_June_2026-264.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-ederson",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/02/Ederson_Brazil_V_Morocco_13_June_2026-14_%28cropped%29.jpg/250px-Ederson_Brazil_V_Morocco_13_June_2026-14_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ederson_Brazil_V_Morocco_13_June_2026-14_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ederson_Brazil_V_Morocco_13_June_2026-14_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Ederson_Brazil_V_Morocco_13_June_2026-14_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_edmond_tapsoba",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/aa/Edmond_Tapsoba%2C_2022-07-31%2C_Saisoner%C3%B6ffnung_Bayer_04%2C_Leverkusen_%281%29_%28cropped%29.jpg/250px-Edmond_Tapsoba%2C_2022-07-31%2C_Saisoner%C3%B6ffnung_Bayer_04%2C_Leverkusen_%281%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Edmond_Tapsoba,_2022-07-31,_Saisoner%C3%B6ffnung_Bayer_04,_Leverkusen_(1)_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Pyaet",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Edmond_Tapsoba,_2022-07-31,_Saisoner%C3%B6ffnung_Bayer_04,_Leverkusen_(1)_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Edmond_Tapsoba,_2022-07-31,_Saisoneröffnung_Bayer_04,_Leverkusen_(1)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-camavinga",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/05/Ofrenda_de_la_Liga_y_la_Champions-13-L.Mill%C3%A1n_%2852109790215%29_%28cropped%29.jpg/250px-Ofrenda_de_la_Liga_y_la_Champions-13-L.Mill%C3%A1n_%2852109790215%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ofrenda_de_la_Liga_y_la_Champions-13-L.Mill%C3%A1n_(52109790215)_(cropped).jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Fotografías Archimadrid.es",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ofrenda_de_la_Liga_y_la_Champions-13-L.Mill%C3%A1n_(52109790215)_(cropped).jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:Ofrenda_de_la_Liga_y_la_Champions-13-L.Millán_(52109790215)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_enzo_fernandez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/10/Enzo_Fernandez_Argentina_v_Spain_19_July_2026-050_%28cropped%29.jpg/250px-Enzo_Fernandez_Argentina_v_Spain_19_July_2026-050_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Enzo_Fernandez_Argentina_v_Spain_19_July_2026-050_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Enzo_Fernandez_Argentina_v_Spain_19_July_2026-050_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Enzo_Fernandez_Argentina_v_Spain_19_July_2026-050_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_erick_pulgar",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/7/74/ErickPulgar.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:ErickPulgar.png",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "DSanchez17",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:ErickPulgar.png",
      "image_license": "CC BY 2.0",
      "image_file": "File:ErickPulgar.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_everson",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/a/a2/16_11_2019_Partida_de_futebol_Santos_e_S%C3%A3o_Paulo_Everson.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:16_11_2019_Partida_de_futebol_Santos_e_S%C3%A3o_Paulo_Everson.jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Palácio do Planalto from Brasilia, Brasil",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:16_11_2019_Partida_de_futebol_Santos_e_S%C3%A3o_Paulo_Everson.jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:16_11_2019_Partida_de_futebol_Santos_e_São_Paulo_Everson.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_everton_cebolinha",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/67/EvertonBenfica1.jpg/250px-EvertonBenfica1.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:EvertonBenfica1.jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Sport Lisboa e Benfica",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:EvertonBenfica1.jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:EvertonBenfica1.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_everton_ribeiro",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/80/EvertonRibeiroFlamengo2018.jpg/250px-EvertonRibeiroFlamengo2018.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:EvertonRibeiroFlamengo2018.jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Agencia de Noticias ANDES",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:EvertonRibeiroFlamengo2018.jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:EvertonRibeiroFlamengo2018.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-palacios",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fd/Exequiel_Palacios_Argentina_v_Spain_19_July_2026-022.jpg/250px-Exequiel_Palacios_Argentina_v_Spain_19_July_2026-022.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Exequiel_Palacios_Argentina_v_Spain_19_July_2026-022.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Exequiel_Palacios_Argentina_v_Spain_19_July_2026-022.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Exequiel_Palacios_Argentina_v_Spain_19_July_2026-022.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_fabian_ruiz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/88/Fabian_Ruiz_Argentina_v_Spain_19_July_2026-315.jpg/250px-Fabian_Ruiz_Argentina_v_Spain_19_July_2026-315.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Fabian_Ruiz_Argentina_v_Spain_19_July_2026-315.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Fabian_Ruiz_Argentina_v_Spain_19_July_2026-315.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Fabian_Ruiz_Argentina_v_Spain_19_July_2026-315.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_federico_dimarco",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/78/Norway_Italy_-_June_2025_A_26_%28cropped%29.jpg/250px-Norway_Italy_-_June_2025_A_26_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_26_(cropped).jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "MichaelEmilio",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_26_(cropped).jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Norway_Italy_-_June_2025_A_26_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-valverde",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/73/Federico_Valverde_2021_%28cropped%29.jpg/250px-Federico_Valverde_2021_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Federico_Valverde_2021_(cropped).jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Real Madrid",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Federico_Valverde_2021_(cropped).jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:Federico_Valverde_2021_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_felix_nmecha",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2d/Felix_Nmecha_Ecuador_v_Germany_25_June_2026-150.jpg/250px-Felix_Nmecha_Ecuador_v_Germany_25_June_2026-150.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Felix_Nmecha_Ecuador_v_Germany_25_June_2026-150.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Felix_Nmecha_Ecuador_v_Germany_25_June_2026-150.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Felix_Nmecha_Ecuador_v_Germany_25_June_2026-150.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_ferland_mendy",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a3/Ofrenda_de_la_Liga_y_la_Champions-49-L.Mill%C3%A1n_%2852109311048%29_%28Ferland_Mendy%29.jpg/250px-Ofrenda_de_la_Liga_y_la_Champions-49-L.Mill%C3%A1n_%2852109311048%29_%28Ferland_Mendy%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ofrenda_de_la_Liga_y_la_Champions-49-L.Mill%C3%A1n_(52109311048)_(Ferland_Mendy).jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Fotografías Archimadrid.es",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ofrenda_de_la_Liga_y_la_Champions-49-L.Mill%C3%A1n_(52109311048)_(Ferland_Mendy).jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:Ofrenda_de_la_Liga_y_la_Champions-49-L.Millán_(52109311048)_(Ferland_Mendy).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_ferran_torres",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1c/Ferran_Torres_France_v_Spain_7.24.26-237_%28cropped%29.jpg/250px-Ferran_Torres_France_v_Spain_7.24.26-237_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ferran_Torres_France_v_Spain_7.24.26-237_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ferran_Torres_France_v_Spain_7.24.26-237_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Ferran_Torres_France_v_Spain_7.24.26-237_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_fikayo_tomori",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/66/FC_Salzburg_vs._AC_Mailand_%28UEFA_Championsleague_2022-09-06%29_42.jpg/250px-FC_Salzburg_vs._AC_Mailand_%28UEFA_Championsleague_2022-09-06%29_42.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_vs._AC_Mailand_(UEFA_Championsleague_2022-09-06)_42.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_vs._AC_Mailand_(UEFA_Championsleague_2022-09-06)_42.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_Salzburg_vs._AC_Mailand_(UEFA_Championsleague_2022-09-06)_42.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_flaco_lopez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/00/Jose_Manuel_Lopez_Argentina_v_Spain_19_July_2026-272.jpg/250px-Jose_Manuel_Lopez_Argentina_v_Spain_19_July_2026-272.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jose_Manuel_Lopez_Argentina_v_Spain_19_July_2026-272.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jose_Manuel_Lopez_Argentina_v_Spain_19_July_2026-272.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Jose_Manuel_Lopez_Argentina_v_Spain_19_July_2026-272.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_florian_wirtz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/70/Florian_Wirtz_Ecuador_v_Germany_25_June_2026-181_%28cropped%29.jpg/250px-Florian_Wirtz_Ecuador_v_Germany_25_June_2026-181_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Florian_Wirtz_Ecuador_v_Germany_25_June_2026-181_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Florian_Wirtz_Ecuador_v_Germany_25_June_2026-181_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Florian_Wirtz_Ecuador_v_Germany_25_June_2026-181_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_folarin_balogun",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/51/Folarin_Balogun_Australia_v_USA_19_June_2026-64.jpg/250px-Folarin_Balogun_Australia_v_USA_19_June_2026-64.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Folarin_Balogun_Australia_v_USA_19_June_2026-64.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Folarin_Balogun_Australia_v_USA_19_June_2026-64.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Folarin_Balogun_Australia_v_USA_19_June_2026-64.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_francesco_acerbi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/78/Francesco_Acerbi_2021.jpg/250px-Francesco_Acerbi_2021.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Francesco_Acerbi_2021.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Антон Зайцев",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Francesco_Acerbi_2021.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Francesco_Acerbi_2021.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_frank_anguissa",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/78/ZAMBO_ANGUISSA.jpg/250px-ZAMBO_ANGUISSA.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:ZAMBO_ANGUISSA.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Happiraphael",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:ZAMBO_ANGUISSA.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:ZAMBO_ANGUISSA.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-dejong",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/38/Frenkie_De_Jong_%282025%29_%28cropped%29.png/250px-Frenkie_De_Jong_%282025%29_%28cropped%29.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Frenkie_De_Jong_(2025)_(cropped).png",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Unknown authorUnknown author",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Frenkie_De_Jong_(2025)_(cropped).png",
      "image_license": "CC BY 4.0",
      "image_file": "File:Frenkie_De_Jong_(2025)_(cropped).png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_fabio",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/04/F%C3%A1bio_Deivson_Lopes_Maciel_of_Cruzeiro_EC_%28cropped%29.jpg/250px-F%C3%A1bio_Deivson_Lopes_Maciel_of_Cruzeiro_EC_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:F%C3%A1bio_Deivson_Lopes_Maciel_of_Cruzeiro_EC_(cropped).jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Danielcuei.",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:F%C3%A1bio_Deivson_Lopes_Maciel_of_Cruzeiro_EC_(cropped).jpg",
      "image_license": "Public domain",
      "image_file": "File:Fábio_Deivson_Lopes_Maciel_of_Cruzeiro_EC_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_gabriel_brazao",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7a/Gabriel_Braz%C3%A3o_18-11-2024.png/250px-Gabriel_Braz%C3%A3o_18-11-2024.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Gabriel_Braz%C3%A3o_18-11-2024.png",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "BrazilianDude70",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Gabriel_Braz%C3%A3o_18-11-2024.png",
      "image_license": "CC BY 4.0",
      "image_file": "File:Gabriel_Brazão_18-11-2024.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-gabriel",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8e/Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_%28cropped%29.jpg/250px-Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Gabriel_Magalhaes_Brazil_V_Morocco_13_June_2026-132_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-gavi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4a/Gavi_Argentina_v_Spain_19_July_2026-013.jpg/250px-Gavi_Argentina_v_Spain_19_July_2026-013.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Gavi_Argentina_v_Spain_19_July_2026-013.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Gavi_Argentina_v_Spain_19_July_2026-013.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Gavi_Argentina_v_Spain_19_July_2026-013.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_geoffrey_kondogbia",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/30/Kondogbia_asse_om_2425.png/250px-Kondogbia_asse_om_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Kondogbia_asse_om_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Kondogbia_asse_om_2425.png",
      "image_license": "CC0",
      "image_file": "File:Kondogbia_asse_om_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_german_cano",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/7/75/GECano_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:GECano_(cropped).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Crismejia",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:GECano_(cropped).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:GECano_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_geronimo_rulli",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/cf/Geronimo_Rulli_Argentina_v_Spain_19_July_2026-267_%28cropped%29.jpg/250px-Geronimo_Rulli_Argentina_v_Spain_19_July_2026-267_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Geronimo_Rulli_Argentina_v_Spain_19_July_2026-267_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Geronimo_Rulli_Argentina_v_Spain_19_July_2026-267_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Geronimo_Rulli_Argentina_v_Spain_19_July_2026-267_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_gianluca_mancini",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a8/FC_Salzburg_gegen_AS_Roma_%28UEFA_Euroleague_play-off%2C_2023-02-16%29_15_%28cropped%29.jpg/250px-FC_Salzburg_gegen_AS_Roma_%28UEFA_Euroleague_play-off%2C_2023-02-16%29_15_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_AS_Roma_(UEFA_Euroleague_play-off,_2023-02-16)_15_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_AS_Roma_(UEFA_Euroleague_play-off,_2023-02-16)_15_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_Salzburg_gegen_AS_Roma_(UEFA_Euroleague_play-off,_2023-02-16)_15_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_arrascaeta",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1d/Giorgian_De_Arrascaeta_20171114_AUT_URU_4546_%28cropped%29.jpg/250px-Giorgian_De_Arrascaeta_20171114_AUT_URU_4546_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Giorgian_De_Arrascaeta_20171114_AUT_URU_4546_(cropped).jpg",
    "image_license": "CC BY-SA 3.0 at",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Ailura",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0/at/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Giorgian_De_Arrascaeta_20171114_AUT_URU_4546_(cropped).jpg",
      "image_license": "CC BY-SA 3.0 at",
      "image_file": "File:Giorgian_De_Arrascaeta_20171114_AUT_URU_4546_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_giovani_lo_celso",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c9/Giovani_Lo_Celso_Argentina_v_Spain_19_July_2026-058.jpg/250px-Giovani_Lo_Celso_Argentina_v_Spain_19_July_2026-058.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Giovani_Lo_Celso_Argentina_v_Spain_19_July_2026-058.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Giovani_Lo_Celso_Argentina_v_Spain_19_July_2026-058.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Giovani_Lo_Celso_Argentina_v_Spain_19_July_2026-058.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-dilorenzo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/86/Norway_Italy_-_June_2025_A_20_-_Giovanni_Di_Lorenzo.jpg/250px-Norway_Italy_-_June_2025_A_20_-_Giovanni_Di_Lorenzo.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_20_-_Giovanni_Di_Lorenzo.jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "MichaelEmilio",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_20_-_Giovanni_Di_Lorenzo.jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Norway_Italy_-_June_2025_A_20_-_Giovanni_Di_Lorenzo.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-ramos",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/ce/Gon%C3%A7alo_Ramos_USMNT_v_Portugal_Mar_31_2026-32_%28cropped%29.jpg/250px-Gon%C3%A7alo_Ramos_USMNT_v_Portugal_Mar_31_2026-32_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Gon%C3%A7alo_Ramos_USMNT_v_Portugal_Mar_31_2026-32_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Gon%C3%A7alo_Ramos_USMNT_v_Portugal_Mar_31_2026-32_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Gonçalo_Ramos_USMNT_v_Portugal_Mar_31_2026-32_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-kobel",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/30/2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_%28DFB-Pokal_2023-24%29_by_Sandro_Halank%E2%80%93090.jpg/250px-2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_%28DFB-Pokal_2023-24%29_by_Sandro_Halank%E2%80%93090.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank%E2%80%93090.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Sandro Halank, Wikimedia Commons",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank%E2%80%93090.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank–090.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_guilherme_arana",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/18/Guilherme_Arana_2017.jpg/250px-Guilherme_Arana_2017.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Guilherme_Arana_2017.jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Agencia de Noticias ANDES",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Guilherme_Arana_2017.jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:Guilherme_Arana_2017.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_gustavo_gomez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/59/Gustavo_Gomez_France_v_Paraguay_4_July_2026-029.jpg/250px-Gustavo_Gomez_France_v_Paraguay_4_July_2026-029.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Gustavo_Gomez_France_v_Paraguay_4_July_2026-029.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Gustavo_Gomez_France_v_Paraguay_4_July_2026-029.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Gustavo_Gomez_France_v_Paraguay_4_July_2026-029.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_gustavo_scarpa",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/58/Gustavo-Scarpa-Palmeiras-Athletico-jul-2022-2.jpg/250px-Gustavo-Scarpa-Palmeiras-Athletico-jul-2022-2.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Gustavo-Scarpa-Palmeiras-Athletico-jul-2022-2.jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "SOCCER DIGITAL",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Gustavo-Scarpa-Palmeiras-Athletico-jul-2022-2.jpg",
      "image_license": "Public domain",
      "image_file": "File:Gustavo-Scarpa-Palmeiras-Athletico-jul-2022-2.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-calhanoglu",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d7/AUT_vs._TUR_2016-03-29_%28342%29.jpg/250px-AUT_vs._TUR_2016-03-29_%28342%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:AUT_vs._TUR_2016-03-29_(342).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steindy (talk) 10:15, 11 April 2016 (UTC)",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:AUT_vs._TUR_2016-03-29_(342).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:AUT_vs._TUR_2016-03-29_(342).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_hugo_souza",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/09/Hugo_Souza_2025_%28cropped%29.jpg/250px-Hugo_Souza_2025_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Hugo_Souza_2025_(cropped).jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "TV Central do Timão",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Hugo_Souza_2025_(cropped).jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Hugo_Souza_2025_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_hulk",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Spar-Zen2015_%283%29.jpg/250px-Spar-Zen2015_%283%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Spar-Zen2015_(3).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Вячеслав Евдокимов",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Spar-Zen2015_(3).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Spar-Zen2015_(3).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_ibrahima_konate",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f2/Ibrahima_Konate_France_v_Senegal_16_June_2026-516_%28cropped%29.jpg/250px-Ibrahima_Konate_France_v_Senegal_16_June_2026-516_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ibrahima_Konate_France_v_Senegal_16_June_2026-516_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ibrahima_Konate_France_v_Senegal_16_June_2026-516_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Ibrahima_Konate_France_v_Senegal_16_June_2026-516_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_isco",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/32/Liver-RM_%285%29_%28cropped%29.jpg/250px-Liver-RM_%285%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Liver-RM_(5)_(cropped).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Антон Зайцев",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Liver-RM_(5)_(cropped).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Liver-RM_(5)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-musiala",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/44/Jamal_Musiala_Ecuador_v_Germany_25_June_2026-174_%28cropped%29.jpg/250px-Jamal_Musiala_Ecuador_v_Germany_25_June_2026-174_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jamal_Musiala_Ecuador_v_Germany_25_June_2026-174_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jamal_Musiala_Ecuador_v_Germany_25_June_2026-174_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Jamal_Musiala_Ecuador_v_Germany_25_June_2026-174_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-oblak",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a1/Jan_Oblak_2019.jpg/250px-Jan_Oblak_2019.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jan_Oblak_2019.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Анна Нэсси",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jan_Oblak_2019.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Jan_Oblak_2019.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_jean_lucas",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0b/Jean_Lucas_-_2019_%28cropped%29.jpg/250px-Jean_Lucas_-_2019_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jean_Lucas_-_2019_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jean_Lucas_-_2019_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Jean_Lucas_-_2019_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_savarino",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9b/USAvVEN_2019-06-09_-_Jefferson_Savarino_%2851169633652%29_%28cropped%29.jpg/250px-USAvVEN_2019-06-09_-_Jefferson_Savarino_%2851169633652%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:USAvVEN_2019-06-09_-_Jefferson_Savarino_(51169633652)_(cropped).jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Hayden Schiff from Cincinnati, USA",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:USAvVEN_2019-06-09_-_Jefferson_Savarino_(51169633652)_(cropped).jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:USAvVEN_2019-06-09_-_Jefferson_Savarino_(51169633652)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_jeremy_doku",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/06/J%C3%A9r%C3%A9my_Doku_USMNT_v_Belgium_Mar_28_2026-27_%28cropped%29.jpg/250px-J%C3%A9r%C3%A9my_Doku_USMNT_v_Belgium_Mar_28_2026-27_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:J%C3%A9r%C3%A9my_Doku_USMNT_v_Belgium_Mar_28_2026-27_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:J%C3%A9r%C3%A9my_Doku_USMNT_v_Belgium_Mar_28_2026-27_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Jérémy_Doku_USMNT_v_Belgium_Mar_28_2026-27_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_joan_garcia",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b0/P20260719DT-1994_President_Donald_J._Trump_and_First_Lady_Melania_Trump_attend_the_FIFA_World_Cup_Final_%28cropped%29.jpg/250px-P20260719DT-1994_President_Donald_J._Trump_and_First_Lady_Melania_Trump_attend_the_FIFA_World_Cup_Final_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:P20260719DT-1994_President_Donald_J._Trump_and_First_Lady_Melania_Trump_attend_the_FIFA_World_Cup_Final_(cropped).jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "The White House",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:P20260719DT-1994_President_Donald_J._Trump_and_First_Lady_Melania_Trump_attend_the_FIFA_World_Cup_Final_(cropped).jpg",
      "image_license": "Public domain",
      "image_file": "File:P20260719DT-1994_President_Donald_J._Trump_and_First_Lady_Melania_Trump_attend_the_FIFA_World_Cup_Final_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_joaquin_piquerez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e8/Joaquin-Piquerez-Palmeiras-Liverpool-abr24.jpg/250px-Joaquin-Piquerez-Palmeiras-Liverpool-abr24.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Joaquin-Piquerez-Palmeiras-Liverpool-abr24.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "NullReason",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Joaquin-Piquerez-Palmeiras-Liverpool-abr24.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Joaquin-Piquerez-Palmeiras-Liverpool-abr24.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_calleri",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e6/Calleri_%28cropped%29.jpg/250px-Calleri_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Calleri_(cropped).jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "SOCCER DIGITAL",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Calleri_(cropped).jpg",
      "image_license": "Public domain",
      "image_file": "File:Calleri_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_jonathan_clauss",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/60/Clauss_asse_ogcn_2425.png/250px-Clauss_asse_ogcn_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Clauss_asse_ogcn_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Clauss_asse_ogcn_2425.png",
      "image_license": "CC0",
      "image_file": "File:Clauss_asse_ogcn_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_jonathan_tah",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Jonathan_Tah_Ecuador_v_Germany_25_June_2026-116.jpg/250px-Jonathan_Tah_Ecuador_v_Germany_25_June_2026-116.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jonathan_Tah_Ecuador_v_Germany_25_June_2026-116.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jonathan_Tah_Ecuador_v_Germany_25_June_2026-116.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Jonathan_Tah_Ecuador_v_Germany_25_June_2026-116.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-kimmich",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/Joshua_Kimmich_Ecuador_v_Germany_25_June_2026-149.jpg/250px-Joshua_Kimmich_Ecuador_v_Germany_25_June_2026-149.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Joshua_Kimmich_Ecuador_v_Germany_25_June_2026-149.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Joshua_Kimmich_Ecuador_v_Germany_25_June_2026-149.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Joshua_Kimmich_Ecuador_v_Germany_25_June_2026-149.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_josko_gvardiol",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/58/Josko_Gvardiol_Croatia_v_Portugal_2_July_2026-262.jpg/250px-Josko_Gvardiol_Croatia_v_Portugal_2_July_2026-262.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Josko_Gvardiol_Croatia_v_Portugal_2_July_2026-262.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Josko_Gvardiol_Croatia_v_Portugal_2_July_2026-262.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Josko_Gvardiol_Croatia_v_Portugal_2_July_2026-262.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_jose_gimenez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/Jos%C3%A9_Mar%C3%ADa_Gim%C3%A9nez.jpg/250px-Jos%C3%A9_Mar%C3%ADa_Gim%C3%A9nez.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jos%C3%A9_Mar%C3%ADa_Gim%C3%A9nez.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Анна Нэсси",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jos%C3%A9_Mar%C3%ADa_Gim%C3%A9nez.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:José_María_Giménez.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-joao-neves",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/Joao_Neves_Croatia_v_Portugal_2_July_2026-102.jpg/250px-Joao_Neves_Croatia_v_Portugal_2_July_2026-102.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Joao_Neves_Croatia_v_Portugal_2_July_2026-102.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Joao_Neves_Croatia_v_Portugal_2_July_2026-102.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Joao_Neves_Croatia_v_Portugal_2_July_2026-102.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_joao_schmidt",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/52/Jo%C3%A3o_Schmidt_2024.png/250px-Jo%C3%A3o_Schmidt_2024.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jo%C3%A3o_Schmidt_2024.png",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "BrazilianDude70",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jo%C3%A3o_Schmidt_2024.png",
      "image_license": "CC BY 4.0",
      "image_file": "File:João_Schmidt_2024.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-kounde",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ee/Jules_Kounde_France_v_Senegal_16_June_2026-449_%28cropped%29.jpg/250px-Jules_Kounde_France_v_Senegal_16_June_2026-449_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Jules_Kounde_France_v_Senegal_16_June_2026-449_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Jules_Kounde_France_v_Senegal_16_June_2026-449_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Jules_Kounde_France_v_Senegal_16_June_2026-449_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-brandt",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/96/2019-06-11_Fu%C3%9Fball%2C_M%C3%A4nner%2C_L%C3%A4nderspiel%2C_Deutschland-Estland_StP_2066_LR10_by_Stepro.jpg/250px-2019-06-11_Fu%C3%9Fball%2C_M%C3%A4nner%2C_L%C3%A4nderspiel%2C_Deutschland-Estland_StP_2066_LR10_by_Stepro.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2019-06-11_Fu%C3%9Fball,_M%C3%A4nner,_L%C3%A4nderspiel,_Deutschland-Estland_StP_2066_LR10_by_Stepro.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2019-06-11_Fu%C3%9Fball,_M%C3%A4nner,_L%C3%A4nderspiel,_Deutschland-Estland_StP_2066_LR10_by_Stepro.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2019-06-11_Fußball,_Männer,_Länderspiel,_Deutschland-Estland_StP_2066_LR10_by_Stepro.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_julian_alvarez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0c/Julian_Alvarez_Argentina_v_Spain_19_July_2026-052_%28cropped%29.jpg/250px-Julian_Alvarez_Argentina_v_Spain_19_July_2026-052_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Julian_Alvarez_Argentina_v_Spain_19_July_2026-052_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Julian_Alvarez_Argentina_v_Spain_19_July_2026-052_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Julian_Alvarez_Argentina_v_Spain_19_July_2026-052_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_jurrien_timber",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9f/JURRIEN_TIMBER.jpg/250px-JURRIEN_TIMBER.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:JURRIEN_TIMBER.jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Carlo Bruil Fotografie",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:JURRIEN_TIMBER.jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:JURRIEN_TIMBER.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_kai_havertz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/76/Kai_Havertz_Ecuador_v_Germany_25_June_2026-118.jpg/250px-Kai_Havertz_Ecuador_v_Germany_25_June_2026-118.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Kai_Havertz_Ecuador_v_Germany_25_June_2026-118.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Kai_Havertz_Ecuador_v_Germany_25_June_2026-118.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Kai_Havertz_Ecuador_v_Germany_25_June_2026-118.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_kang_in_lee",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/Lee_Kang-in_-_2022_%2852551771501%29_%28cropped%29.jpg/250px-Lee_Kang-in_-_2022_%2852551771501%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Lee_Kang-in_-_2022_(52551771501)_(cropped).jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Republic of  Korea from Seoul, Republic of Korea",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Lee_Kang-in_-_2022_(52551771501)_(cropped).jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:Lee_Kang-in_-_2022_(52551771501)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_karim_adeyemi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/da/FC_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_%28Championsleague_Achtelfinale_Hinspiel_16._Februar_2022%29_63.jpg/250px-FC_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_%28Championsleague_Achtelfinale_Hinspiel_16._Februar_2022%29_63.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_(Championsleague_Achtelfinale_Hinspiel_16._Februar_2022)_63.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_(Championsleague_Achtelfinale_Hinspiel_16._Februar_2022)_63.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_Salzburg_gegen_FC_Bayern_München_(Championsleague_Achtelfinale_Hinspiel_16._Februar_2022)_63.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_khephren_thuram",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/06/RC_Lens_-_OGC_Nice_%2810-04-2022%29_6_%28cropped%29.jpg/250px-RC_Lens_-_OGC_Nice_%2810-04-2022%29_6_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:RC_Lens_-_OGC_Nice_(10-04-2022)_6_(cropped).jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Supporterhéninois",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:RC_Lens_-_OGC_Nice_(10-04-2022)_6_(cropped).jpg",
      "image_license": "CC0",
      "image_file": "File:RC_Lens_-_OGC_Nice_(10-04-2022)_6_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_kim_min_jae",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/80/FC_Red_Bull_Salzburg_gegen_Bayern_M%C3%BCnchen_%282025-01-06_Testspiel%29_26.jpg/250px-FC_Red_Bull_Salzburg_gegen_Bayern_M%C3%BCnchen_%282025-01-06_Testspiel%29_26.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Red_Bull_Salzburg_gegen_Bayern_M%C3%BCnchen_(2025-01-06_Testspiel)_26.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Red_Bull_Salzburg_gegen_Bayern_M%C3%BCnchen_(2025-01-06_Testspiel)_26.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_Red_Bull_Salzburg_gegen_Bayern_München_(2025-01-06_Testspiel)_26.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_kingsley_coman",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ef/Kingsley_Coman_%282019%29_%28cropped%29.jpg/250px-Kingsley_Coman_%282019%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Kingsley_Coman_(2019)_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Sven Mandel",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Kingsley_Coman_(2019)_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Kingsley_Coman_(2019)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_kobbie_mainoo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1f/Kobbie_Mainoo_England_v_Ghana_23_June_2026-042.jpg/250px-Kobbie_Mainoo_England_v_Ghana_23_June_2026-042.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Kobbie_Mainoo_England_v_Ghana_23_June_2026-042.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Kobbie_Mainoo_England_v_Ghana_23_June_2026-042.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Kobbie_Mainoo_England_v_Ghana_23_June_2026-042.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_koke",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/17/Koke_2019.jpg/250px-Koke_2019.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Koke_2019.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Анна Нэсси",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Koke_2019.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Koke_2019.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_konrad_laimer",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3d/2022-07-21_Fu%C3%9Fball%2C_M%C3%A4nner%2CFreundschaftsspiel%2C_RB_Leipzig_-_FC_Liverpool_1DX_2137_by_Stepro_%28cropped%29.jpg/250px-2022-07-21_Fu%C3%9Fball%2C_M%C3%A4nner%2CFreundschaftsspiel%2C_RB_Leipzig_-_FC_Liverpool_1DX_2137_by_Stepro_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2022-07-21_Fu%C3%9Fball,_M%C3%A4nner,Freundschaftsspiel,_RB_Leipzig_-_FC_Liverpool_1DX_2137_by_Stepro_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2022-07-21_Fu%C3%9Fball,_M%C3%A4nner,Freundschaftsspiel,_RB_Leipzig_-_FC_Liverpool_1DX_2137_by_Stepro_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2022-07-21_Fußball,_Männer,Freundschaftsspiel,_RB_Leipzig_-_FC_Liverpool_1DX_2137_by_Stepro_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-lautaro",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e9/Lautaro_Martinez_Argentina_v_Spain_19_July_2026-049_%28cropped%29.jpg/250px-Lautaro_Martinez_Argentina_v_Spain_19_July_2026-049_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Lautaro_Martinez_Argentina_v_Spain_19_July_2026-049_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Lautaro_Martinez_Argentina_v_Spain_19_July_2026-049_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Lautaro_Martinez_Argentina_v_Spain_19_July_2026-049_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-goretzka",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/68/Leon_Goretzka_Ecuador_v_Germany_25_June_2026-159.jpg/250px-Leon_Goretzka_Ecuador_v_Germany_25_June_2026-159.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Leon_Goretzka_Ecuador_v_Germany_25_June_2026-159.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Leon_Goretzka_Ecuador_v_Germany_25_June_2026-159.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Leon_Goretzka_Ecuador_v_Germany_25_June_2026-159.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-balerdi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/fa/Balerdi_asse_om_2425.png/250px-Balerdi_asse_om_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Balerdi_asse_om_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Balerdi_asse_om_2425.png",
      "image_license": "CC0",
      "image_file": "File:Balerdi_asse_om_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_lisandro_martinez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/6e/Lisandro_Martinez_Argentina_v_Egypt_7_July_2026-343_%28cropped%29.jpg/250px-Lisandro_Martinez_Argentina_v_Egypt_7_July_2026-343_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Lisandro_Martinez_Argentina_v_Egypt_7_July_2026-343_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Lisandro_Martinez_Argentina_v_Egypt_7_July_2026-343_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Lisandro_Martinez_Argentina_v_Egypt_7_July_2026-343_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_lorenzo_pellegrini",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d7/FC_Salzburg_gegen_AS_Roma_Pellegrini.jpg/250px-FC_Salzburg_gegen_AS_Roma_Pellegrini.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_AS_Roma_Pellegrini.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_AS_Roma_Pellegrini.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_Salzburg_gegen_AS_Roma_Pellegrini.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-chevalier",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a7/Chevalier_ASSE_losc_2425_%28cropped%29.jpg/250px-Chevalier_ASSE_losc_2425_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Chevalier_ASSE_losc_2425_(cropped).jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Chevalier_ASSE_losc_2425_(cropped).jpg",
      "image_license": "CC0",
      "image_file": "File:Chevalier_ASSE_losc_2425_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-lucas-hernandez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/27/Lucas_Hernandez_France_v_Senegal_16_June_2026-281.jpg/250px-Lucas_Hernandez_France_v_Senegal_16_June_2026-281.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Lucas_Hernandez_France_v_Senegal_16_June_2026-281.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Lucas_Hernandez_France_v_Senegal_16_June_2026-281.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Lucas_Hernandez_France_v_Senegal_16_June_2026-281.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_lucas_moura",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/26/2020-03-10_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League_Achtelfinale%2C_RB_Leipzig_-_Tottenham_Hotspur_1DX_3703_by_Stepro.jpg/250px-2020-03-10_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League_Achtelfinale%2C_RB_Leipzig_-_Tottenham_Hotspur_1DX_3703_by_Stepro.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2020-03-10_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League_Achtelfinale,_RB_Leipzig_-_Tottenham_Hotspur_1DX_3703_by_Stepro.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2020-03-10_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League_Achtelfinale,_RB_Leipzig_-_Tottenham_Hotspur_1DX_3703_by_Stepro.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2020-03-10_Fußball,_Männer,_UEFA_Champions_League_Achtelfinale,_RB_Leipzig_-_Tottenham_Hotspur_1DX_3703_by_Stepro.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_luciano",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bb/Luciano-Sao-Paulo-Juventude-jun-2022_%28cropped%29.jpg/250px-Luciano-Sao-Paulo-Juventude-jun-2022_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Luciano-Sao-Paulo-Juventude-jun-2022_(cropped).jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "SOCCER DIGITAL",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Luciano-Sao-Paulo-Juventude-jun-2022_(cropped).jpg",
      "image_license": "Public domain",
      "image_file": "File:Luciano-Sao-Paulo-Juventude-jun-2022_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_ludovic_blas",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/93/Blas_asse_srfc_2425.png/250px-Blas_asse_srfc_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Blas_asse_srfc_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Blas_asse_srfc_2425.png",
      "image_license": "CC0",
      "image_file": "File:Blas_asse_srfc_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_luis_diaz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c7/FC_RB_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_%282026-01-06_Testspiel%29_40_%28Luiz_D%C3%ADaz%29.jpg/250px-FC_RB_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_%282026-01-06_Testspiel%29_40_%28Luiz_D%C3%ADaz%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_RB_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_(2026-01-06_Testspiel)_40_(Luiz_D%C3%ADaz).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_RB_Salzburg_gegen_FC_Bayern_M%C3%BCnchen_(2026-01-06_Testspiel)_40_(Luiz_D%C3%ADaz).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_RB_Salzburg_gegen_FC_Bayern_München_(2026-01-06_Testspiel)_40_(Luiz_Díaz).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_leo_jardim",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/90/Chelsea_2_Lille_1_%2849203433301%29_Leo_Jardim.jpg/250px-Chelsea_2_Lille_1_%2849203433301%29_Leo_Jardim.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Chelsea_2_Lille_1_(49203433301)_Leo_Jardim.jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "@cfcunofficial (Chelsea Debs) London from London, UK",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Chelsea_2_Lille_1_(49203433301)_Leo_Jardim.jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:Chelsea_2_Lille_1_(49203433301)_Leo_Jardim.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_leo_pereira",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/db/Leo_Pereira_Brazil_V_Morocco_13_June_2026-136_%28cropped%29.jpg/250px-Leo_Pereira_Brazil_V_Morocco_13_June_2026-136_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Leo_Pereira_Brazil_V_Morocco_13_June_2026-136_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Leo_Pereira_Brazil_V_Morocco_13_June_2026-136_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Leo_Pereira_Brazil_V_Morocco_13_June_2026-136_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_maghnas_akliouche",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5a/Maghnes_Akliouche_France_v_Senegal_16_June_2026-512.jpg/250px-Maghnes_Akliouche_France_v_Senegal_16_June_2026-512.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Maghnes_Akliouche_France_v_Senegal_16_June_2026-512.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Maghnes_Akliouche_France_v_Senegal_16_June_2026-512.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Maghnes_Akliouche_France_v_Senegal_16_June_2026-512.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_manuel_akanji",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b3/2023-10-04_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League%2C_RB_Leipzig_-_Manchester_City_FC_1DX_2792_%28Manuel_Akanji%29.jpg/250px-2023-10-04_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League%2C_RB_Leipzig_-_Manchester_City_FC_1DX_2792_%28Manuel_Akanji%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-10-04_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2792_(Manuel_Akanji).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-10-04_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2792_(Manuel_Akanji).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2023-10-04_Fußball,_Männer,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2792_(Manuel_Akanji).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-locatelli",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7d/FC_Zenit_Saint_Petersburg_vs._Juventus%2C_20_October_2021_34_%28Manuel_Locatelli%29.jpg/250px-FC_Zenit_Saint_Petersburg_vs._Juventus%2C_20_October_2021_34_%28Manuel_Locatelli%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Zenit_Saint_Petersburg_vs._Juventus,_20_October_2021_34_(Manuel_Locatelli).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Kirill Venediktov",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Zenit_Saint_Petersburg_vs._Juventus,_20_October_2021_34_(Manuel_Locatelli).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:FC_Zenit_Saint_Petersburg_vs._Juventus,_20_October_2021_34_(Manuel_Locatelli).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-neuer",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b9/Manuel_Neuer_Ecuador_v_Germany_25_June_2026-148.jpg/250px-Manuel_Neuer_Ecuador_v_Germany_25_June_2026-148.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Manuel_Neuer_Ecuador_v_Germany_25_June_2026-148.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Manuel_Neuer_Ecuador_v_Germany_25_June_2026-148.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Manuel_Neuer_Ecuador_v_Germany_25_June_2026-148.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-ter-stegen",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/97/Marc-Andre_Ter_Stegen_ACCI_FCBARCELONA_Turisme_Catalunya_gira_pretemporada_CATPRESS.jpg/250px-Marc-Andre_Ter_Stegen_ACCI_FCBARCELONA_Turisme_Catalunya_gira_pretemporada_CATPRESS.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Marc-Andre_Ter_Stegen_ACCI_FCBARCELONA_Turisme_Catalunya_gira_pretemporada_CATPRESS.jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Government of Catalonia",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Marc-Andre_Ter_Stegen_ACCI_FCBARCELONA_Turisme_Catalunya_gira_pretemporada_CATPRESS.jpg",
      "image_license": "CC0",
      "image_file": "File:Marc-Andre_Ter_Stegen_ACCI_FCBARCELONA_Turisme_Catalunya_gira_pretemporada_CATPRESS.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_marcel_sabitzer",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0e/Marcel_Sabitzer_2020_%28cropped%29.jpg/250px-Marcel_Sabitzer_2020_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Marcel_Sabitzer_2020_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Marcel_Sabitzer_2020_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Marcel_Sabitzer_2020_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_marco_carnesecchi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/38/Norway_Italy_-_June_2025_A_19_%28cropped%29.jpg/250px-Norway_Italy_-_June_2025_A_19_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_19_(cropped).jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "MichaelEmilio",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_A_19_(cropped).jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Norway_Italy_-_June_2025_A_19_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_marcos_llorente",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/09/Marcos_Llorente_France_v_Spain_7.24.26-020.jpg/250px-Marcos_Llorente_France_v_Spain_7.24.26-020.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Marcos_Llorente_France_v_Spain_7.24.26-020.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Marcos_Llorente_France_v_Spain_7.24.26-020.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Marcos_Llorente_France_v_Spain_7.24.26-020.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-thuram",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0a/Marcus_Thuram_France_v_Senegal_16_June_2026-261_%28cropped%29.jpg/250px-Marcus_Thuram_France_v_Senegal_16_June_2026-261_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Marcus_Thuram_France_v_Senegal_16_June_2026-261_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Marcus_Thuram_France_v_Senegal_16_June_2026-261_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Marcus_Thuram_France_v_Senegal_16_June_2026-261_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_marlon_freitas",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/70/MarlonFreitasPe%C3%B1arolxBotafogo2024.jpg/250px-MarlonFreitasPe%C3%B1arolxBotafogo2024.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:MarlonFreitasPe%C3%B1arolxBotafogo2024.jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Jimmy Baikovicius",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:MarlonFreitasPe%C3%B1arolxBotafogo2024.jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:MarlonFreitasPeñarolxBotafogo2024.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-marquinhos",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4f/Marquinhos_Brazil_V_Morocco_13_June_2026-153_%28cropped%29.jpg/250px-Marquinhos_Brazil_V_Morocco_13_June_2026-153_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Marquinhos_Brazil_V_Morocco_13_June_2026-153_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Marquinhos_Brazil_V_Morocco_13_June_2026-153_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Marquinhos_Brazil_V_Morocco_13_June_2026-153_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_braithwaite",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0f/Martin_Braithwaite_Web_Summit_2021.jpg/250px-Martin_Braithwaite_Web_Summit_2021.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Martin_Braithwaite_Web_Summit_2021.jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Web Summit",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Martin_Braithwaite_Web_Summit_2021.jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:Martin_Braithwaite_Web_Summit_2021.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-odegaard",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/13/Martin_Odegaard_France_v_Norway_26_June_26-014.jpg/250px-Martin_Odegaard_France_v_Norway_26_June_26-014.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Martin_Odegaard_France_v_Norway_26_June_26-014.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Martin_Odegaard_France_v_Norway_26_June_26-014.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Martin_Odegaard_France_v_Norway_26_June_26-014.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-greenwood",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e6/Mason_Greenwood_11_Fenerbah%C3%A7e_20260805_%284%29_%28cropped%29_%28cropped%29.JPG/250px-Mason_Greenwood_11_Fenerbah%C3%A7e_20260805_%284%29_%28cropped%29_%28cropped%29.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Mason_Greenwood_11_Fenerbah%C3%A7e_20260805_(4)_(cropped)_(cropped).JPG",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "User:Zafer",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Mason_Greenwood_11_Fenerbah%C3%A7e_20260805_(4)_(cropped)_(cropped).JPG",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Mason_Greenwood_11_Fenerbahçe_20260805_(4)_(cropped)_(cropped).JPG",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_matheus_pereira",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bb/20190428_DFL_1._Bundesliga_FCN_-_FCB_DSC_7579.jpg/250px-20190428_DFL_1._Bundesliga_FCN_-_FCB_DSC_7579.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:20190428_DFL_1._Bundesliga_FCN_-_FCB_DSC_7579.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Granada",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:20190428_DFL_1._Bundesliga_FCN_-_FCB_DSC_7579.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:20190428_DFL_1._Bundesliga_FCN_-_FCB_DSC_7579.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_matteo_guendouzi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/85/Matt%C3%A9o_Guendouzi_6_Fenerbah%C3%A7e_20260805_%288%29_%28cropped%29.JPG/250px-Matt%C3%A9o_Guendouzi_6_Fenerbah%C3%A7e_20260805_%288%29_%28cropped%29.JPG?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Matt%C3%A9o_Guendouzi_6_Fenerbah%C3%A7e_20260805_(8)_(cropped).JPG",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "User:Zafer",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Matt%C3%A9o_Guendouzi_6_Fenerbah%C3%A7e_20260805_(8)_(cropped).JPG",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Mattéo_Guendouzi_6_Fenerbahçe_20260805_(8)_(cropped).JPG",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_mattia_zaccagni",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e2/Mattia_Zaccagni_2021.jpg/250px-Mattia_Zaccagni_2021.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Mattia_Zaccagni_2021.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Антон Зайцев",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Mattia_Zaccagni_2021.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Mattia_Zaccagni_2021.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_maximilian_mittelstadt",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/52/Maxi_mittelstaedt.jpg/250px-Maxi_mittelstaedt.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Maxi_mittelstaedt.jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Jeollo von VfB-exklusiv.de",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Maxi_mittelstaedt.jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Maxi_mittelstaedt.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_memphis_depay",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/1c/Memphis_Depay_2019.jpg/250px-Memphis_Depay_2019.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Memphis_Depay_2019.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Derivative work:  Joe Sins",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Memphis_Depay_2019.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Memphis_Depay_2019.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_michele_di_gregorio",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/77/Di_Gregorio%2C_Monza_v_Alessandria_%282021%29_%28cropped%29.jpg/250px-Di_Gregorio%2C_Monza_v_Alessandria_%282021%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Di_Gregorio,_Monza_v_Alessandria_(2021)_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Nehme1499",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Di_Gregorio,_Monza_v_Alessandria_(2021)_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Di_Gregorio,_Monza_v_Alessandria_(2021)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-maignan",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e1/Mike_Maignan_France_v_Norway_26_June_26-132_%28cropped%29.jpg/250px-Mike_Maignan_France_v_Norway_26_June_26-132_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Mike_Maignan_France_v_Norway_26_June_26-132_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Mike_Maignan_France_v_Norway_26_June_26-132_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Mike_Maignan_France_v_Norway_26_June_26-132_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_mikel_oyarzabal",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/20/Mikel_Oyarzabal_France_v_Spain_7.24.26-161_%28cropped%29.jpg/250px-Mikel_Oyarzabal_France_v_Spain_7.24.26-161_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Mikel_Oyarzabal_France_v_Spain_7.24.26-161_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Mikel_Oyarzabal_France_v_Spain_7.24.26-161_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Mikel_Oyarzabal_France_v_Spain_7.24.26-161_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_mile_svilar",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b5/Mile_Svilar_%28cropped%29.jpeg/250px-Mile_Svilar_%28cropped%29.jpeg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Mile_Svilar_(cropped).jpeg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Original:  LittleWhites / Derivative work:  Danyele",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Mile_Svilar_(cropped).jpeg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Mile_Svilar_(cropped).jpeg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-salah",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a6/Mohamed_Salah_Argentina_v_Egypt_7_July_2026-163_%28cropped%29.jpg/250px-Mohamed_Salah_Argentina_v_Egypt_7_July_2026-163_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Mohamed_Salah_Argentina_v_Egypt_7_July_2026-163_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Mohamed_Salah_Argentina_v_Egypt_7_July_2026-163_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Mohamed_Salah_Argentina_v_Egypt_7_July_2026-163_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_moise_kean",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0b/FC_Zenit_Saint_Petersburg_vs._Juventus%2C_20_October_2021_64_-_Moise_Kean_%28cropped%29.jpg/250px-FC_Zenit_Saint_Petersburg_vs._Juventus%2C_20_October_2021_64_-_Moise_Kean_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Zenit_Saint_Petersburg_vs._Juventus,_20_October_2021_64_-_Moise_Kean_(cropped).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Original:  Kirill Venediktov / Derivative work:  Danyele / FMSky",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Zenit_Saint_Petersburg_vs._Juventus,_20_October_2021_64_-_Moise_Kean_(cropped).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:FC_Zenit_Saint_Petersburg_vs._Juventus,_20_October_2021_64_-_Moise_Kean_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_moises_caicedo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0e/Moises_Caicedo_Ecuador_v_Germany_25_June_2026-051_%28cropped%29.jpg/250px-Moises_Caicedo_Ecuador_v_Germany_25_June_2026-051_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Moises_Caicedo_Ecuador_v_Germany_25_June_2026-051_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Moises_Caicedo_Ecuador_v_Germany_25_June_2026-051_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Moises_Caicedo_Ecuador_v_Germany_25_June_2026-051_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_murilo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a3/Murilo-Palmeiras-Athletico-jul-2022.jpg/250px-Murilo-Palmeiras-Athletico-jul-2022.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Murilo-Palmeiras-Athletico-jul-2022.jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "SOCCER DIGITAL",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Murilo-Palmeiras-Athletico-jul-2022.jpg",
      "image_license": "Public domain",
      "image_file": "File:Murilo-Palmeiras-Athletico-jul-2022.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-schlotterbeck",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/ba/2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_%28DFB-Pokal_2023-24%29_by_Sandro_Halank%E2%80%93069.jpg/250px-2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_%28DFB-Pokal_2023-24%29_by_Sandro_Halank%E2%80%93069.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank%E2%80%93069.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Sandro Halank, Wikimedia Commons",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank%E2%80%93069.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank–069.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_nico_williams",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/cf/Nico_Williams_Argentina_v_Spain_19_July_2026-196_%28cropped%29.jpg/250px-Nico_Williams_Argentina_v_Spain_19_July_2026-196_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Nico_Williams_Argentina_v_Spain_19_July_2026-196_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Nico_Williams_Argentina_v_Spain_19_July_2026-196_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Nico_Williams_Argentina_v_Spain_19_July_2026-196_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_nicolas_seiwald",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/35/Meisterteller%C3%BCbergabe_Saison_2021-22_%282022-05-21%29_49.jpg/250px-Meisterteller%C3%BCbergabe_Saison_2021-22_%282022-05-21%29_49.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Meisterteller%C3%BCbergabe_Saison_2021-22_(2022-05-21)_49.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Meisterteller%C3%BCbergabe_Saison_2021-22_(2022-05-21)_49.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Meistertellerübergabe_Saison_2021-22_(2022-05-21)_49.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_nicolas_tagliafico",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9d/Nicolas_Tagliafico_Argentina_v_Spain_19_July_2026-165.jpg/250px-Nicolas_Tagliafico_Argentina_v_Spain_19_July_2026-165.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Nicolas_Tagliafico_Argentina_v_Spain_19_July_2026-165.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Nicolas_Tagliafico_Argentina_v_Spain_19_July_2026-165.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Nicolas_Tagliafico_Argentina_v_Spain_19_July_2026-165.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_de_la_cruz",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/0c/Nicol%C3%A1s_de_la_Cruz.jpg/250px-Nicol%C3%A1s_de_la_Cruz.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Nicol%C3%A1s_de_la_Cruz.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Agencia de Noticias ANDES",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Nicol%C3%A1s_de_la_Cruz.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Nicolás_de_la_Cruz.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-barella",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/33/Nicol%C3%B2_Barella_in_2021_%28cropped_2%29.jpg/250px-Nicol%C3%B2_Barella_in_2021_%28cropped_2%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Nicol%C3%B2_Barella_in_2021_(cropped_2).jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Biser Todorov",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Nicol%C3%B2_Barella_in_2021_(cropped_2).jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Nicolò_Barella_in_2021_(cropped_2).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_oihan_sancet",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2a/ATHLETIC_-_OSASUNA_%282%29.jpg/250px-ATHLETIC_-_OSASUNA_%282%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:ATHLETIC_-_OSASUNA_(2).jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Maider Goikoetxea",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:ATHLETIC_-_OSASUNA_(2).jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:ATHLETIC_-_OSASUNA_(2).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-watkins",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4a/Ollie_Watkins_England_v_Ghana_23_June_2026-035.jpg/250px-Ollie_Watkins_England_v_Ghana_23_June_2026-035.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Ollie_Watkins_England_v_Ghana_23_June_2026-035.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Ollie_Watkins_England_v_Ghana_23_June_2026-035.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Ollie_Watkins_England_v_Ghana_23_June_2026-035.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_pablo_vegetti",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/11/Pablo_Vegetti_dando_uma_entrevista_em_2021_%28cropped%29.jpg/250px-Pablo_Vegetti_dando_uma_entrevista_em_2021_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Pablo_Vegetti_dando_uma_entrevista_em_2021_(cropped).jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Hablemos de Belgrano - Youtube",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Pablo_Vegetti_dando_uma_entrevista_em_2021_(cropped).jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:Pablo Vegetti dando uma entrevista em 2021 (cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_patrik_schick",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/71/2020-03-10_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League_Achtelfinale%2C_RB_Leipzig_-_Tottenham_Hotspur_1DX_3672_by_Stepro.jpg/250px-2020-03-10_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League_Achtelfinale%2C_RB_Leipzig_-_Tottenham_Hotspur_1DX_3672_by_Stepro.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2020-03-10_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League_Achtelfinale,_RB_Leipzig_-_Tottenham_Hotspur_1DX_3672_by_Stepro.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2020-03-10_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League_Achtelfinale,_RB_Leipzig_-_Tottenham_Hotspur_1DX_3672_by_Stepro.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2020-03-10_Fußball,_Männer,_UEFA_Champions_League_Achtelfinale,_RB_Leipzig_-_Tottenham_Hotspur_1DX_3672_by_Stepro.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_pau_cubarsi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/77/Pau_Cubarsi_Argentina_v_Spain_19_July_2026-181_%28cropped%29.jpg/250px-Pau_Cubarsi_Argentina_v_Spain_19_July_2026-181_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Pau_Cubarsi_Argentina_v_Spain_19_July_2026-181_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Pau_Cubarsi_Argentina_v_Spain_19_July_2026-181_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Pau_Cubarsi_Argentina_v_Spain_19_July_2026-181_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-dybala",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b3/%D0%9C%D0%B0%D1%82%D1%87_%C2%AB%D0%94%D0%B8%D0%BD%D0%B0%D0%BC%D0%BE%C2%BB_-_%C2%AB%D0%AE%D0%B2%D0%B5%D0%BD%D1%82%D1%83%D1%81%C2%BB_0-2._20_%D0%BE%D0%BA%D1%82%D1%8F%D0%B1%D1%80%D1%8F_2020_%D0%B3%D0%BE%D0%B4%D0%B0_%E2%80%94_1153905_%28cropped%29.jpg/250px-%D0%9C%D0%B0%D1%82%D1%87_%C2%AB%D0%94%D0%B8%D0%BD%D0%B0%D0%BC%D0%BE%C2%BB_-_%C2%AB%D0%AE%D0%B2%D0%B5%D0%BD%D1%82%D1%83%D1%81%C2%BB_0-2._20_%D0%BE%D0%BA%D1%82%D1%8F%D0%B1%D1%80%D1%8F_2020_%D0%B3%D0%BE%D0%B4%D0%B0_%E2%80%94_1153905_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:%D0%9C%D0%B0%D1%82%D1%87_%C2%AB%D0%94%D0%B8%D0%BD%D0%B0%D0%BC%D0%BE%C2%BB_-_%C2%AB%D0%AE%D0%B2%D0%B5%D0%BD%D1%82%D1%83%D1%81%C2%BB_0-2._20_%D0%BE%D0%BA%D1%82%D1%8F%D0%B1%D1%80%D1%8F_2020_%D0%B3%D0%BE%D0%B4%D0%B0_%E2%80%94_1153905_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Olga Shcherbytska",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:%D0%9C%D0%B0%D1%82%D1%87_%C2%AB%D0%94%D0%B8%D0%BD%D0%B0%D0%BC%D0%BE%C2%BB_-_%C2%AB%D0%AE%D0%B2%D0%B5%D0%BD%D1%82%D1%83%D1%81%C2%BB_0-2._20_%D0%BE%D0%BA%D1%82%D1%8F%D0%B1%D1%80%D1%8F_2020_%D0%B3%D0%BE%D0%B4%D0%B0_%E2%80%94_1153905_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Матч_«Динамо»_-_«Ювентус»_0-2._20_октября_2020_года_—_1153905_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_pedro",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/87/Pedro_in_a_match_for_Flamengo7658.png/250px-Pedro_in_a_match_for_Flamengo7658.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Pedro_in_a_match_for_Flamengo7658.png",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Jester77aa08",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Pedro_in_a_match_for_Flamengo7658.png",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Pedro_in_a_match_for_Flamengo7658.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-foden",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/53/2023-10-04_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League%2C_RB_Leipzig_-_Manchester_City_FC_1DX_2613%2C_Phil_Foden.jpg/250px-2023-10-04_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League%2C_RB_Leipzig_-_Manchester_City_FC_1DX_2613%2C_Phil_Foden.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-10-04_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2613,_Phil_Foden.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Steffen Prößdorf",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-10-04_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2613,_Phil_Foden.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2023-10-04_Fußball,_Männer,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2613,_Phil_Foden.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_philippe_coutinho",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/66/20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Philippe_Coutinho_850_1692.jpg/250px-20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Philippe_Coutinho_850_1692.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Philippe_Coutinho_850_1692.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Granada",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Philippe_Coutinho_850_1692.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Philippe_Coutinho_850_1692.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_piero_hincapie",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/19/Piero_Hincapie_Cote_D%27Ivoire_v_Ecuador_14_June_2026-247_%28cropped%29.jpg/250px-Piero_Hincapie_Cote_D%27Ivoire_v_Ecuador_14_June_2026-247_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Piero_Hincapie_Cote_D%27Ivoire_v_Ecuador_14_June_2026-247_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Piero_Hincapie_Cote_D%27Ivoire_v_Ecuador_14_June_2026-247_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Piero_Hincapie_Cote_D'Ivoire_v_Ecuador_14_June_2026-247_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_pierre_emile_hojbjerg",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/Pierre-Emile_H%C3%B8jbjerg.jpg/250px-Pierre-Emile_H%C3%B8jbjerg.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Pierre-Emile_H%C3%B8jbjerg.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Ardfern",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Pierre-Emile_H%C3%B8jbjerg.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Pierre-Emile_Højbjerg.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_piotr_zielinski",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/df/Piotr_Zielinski_2018_%28cropped%29.jpg/250px-Piotr_Zielinski_2018_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Piotr_Zielinski_2018_(cropped).jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Екатерина Лаут",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Piotr_Zielinski_2018_(cropped).jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Piotr_Zielinski_2018_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_presnel_kimpembe",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/81/Presnel_Kimpembe_2022.jpg/250px-Presnel_Kimpembe_2022.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Presnel_Kimpembe_2022.jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Miroslav Lelas/PIXSELL",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Presnel_Kimpembe_2022.jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:Presnel_Kimpembe_2022.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-leao",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/02/RafaelLe%C3%A3oPortugal23.jpg/250px-RafaelLe%C3%A3oPortugal23.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:RafaelLe%C3%A3oPortugal23.jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Agência Lusa",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:RafaelLe%C3%A3oPortugal23.jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:RafaelLeãoPortugal23.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_ramy_bensebaini",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5b/2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_%28DFB-Pokal_2023-24%29_by_Sandro_Halank%E2%80%93134.jpg/250px-2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_%28DFB-Pokal_2023-24%29_by_Sandro_Halank%E2%80%93134.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank%E2%80%93134.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Sandro Halank, Wikimedia Commons",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank%E2%80%93134.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2023-08-12_TSV_Schott_Mainz_gegen_Borussia_Dortmund_(DFB-Pokal_2023-24)_by_Sandro_Halank–134.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_raphael_veiga",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9d/Raphael-Veiga-Palmeiras-Criciuma-sep24-2.jpg/250px-Raphael-Veiga-Palmeiras-Criciuma-sep24-2.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Raphael-Veiga-Palmeiras-Criciuma-sep24-2.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "NullReason",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Raphael-Veiga-Palmeiras-Criciuma-sep24-2.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Raphael-Veiga-Palmeiras-Criciuma-sep24-2.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-raphinha",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b4/Raphinha_Brazil_V_Morocco_13_June_2026-133_%28cropped%29.jpg/250px-Raphinha_Brazil_V_Morocco_13_June_2026-133_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Raphinha_Brazil_V_Morocco_13_June_2026-133_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Raphinha_Brazil_V_Morocco_13_June_2026-133_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Raphinha_Brazil_V_Morocco_13_June_2026-133_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_rayan_cherki",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/97/Rayan_Cherki_France_v_Norway_26_June_26-114.jpg/250px-Rayan_Cherki_France_v_Norway_26_June_26-114.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Rayan_Cherki_France_v_Norway_26_June_26-114.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Rayan_Cherki_France_v_Norway_26_June_26-114.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Rayan_Cherki_France_v_Norway_26_June_26-114.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_reece_james",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3e/Reece_James_England_v_Ghana_23_June_2026-248_%28cropped%29.jpg/250px-Reece_James_England_v_Ghana_23_June_2026-248_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Reece_James_England_v_Ghana_23_June_2026-248_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Reece_James_England_v_Ghana_23_June_2026-248_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Reece_James_England_v_Ghana_23_June_2026-248_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_riccardo_calafiori",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e2/2024_Emirates_Cup_-_Riccardo_Calafiori_%282%29_%28cropped%29.jpg/250px-2024_Emirates_Cup_-_Riccardo_Calafiori_%282%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2024_Emirates_Cup_-_Riccardo_Calafiori_(2)_(cropped).jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Timmy96",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2024_Emirates_Cup_-_Riccardo_Calafiori_(2)_(cropped).jpg",
      "image_license": "CC0",
      "image_file": "File:2024_Emirates_Cup_-_Riccardo_Calafiori_(2)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_robert_andrich",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/92/Robert_Andrich%2C_2022-07-31%2C_Saisoner%C3%B6ffnung_Bayer_04%2C_Leverkusen_%281%29_%28cropped%29.jpg/250px-Robert_Andrich%2C_2022-07-31%2C_Saisoner%C3%B6ffnung_Bayer_04%2C_Leverkusen_%281%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Robert_Andrich,_2022-07-31,_Saisoner%C3%B6ffnung_Bayer_04,_Leverkusen_(1)_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Pyaet",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Robert_Andrich,_2022-07-31,_Saisoner%C3%B6ffnung_Bayer_04,_Leverkusen_(1)_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Robert_Andrich,_2022-07-31,_Saisoneröffnung_Bayer_04,_Leverkusen_(1)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_arboleda",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/7/76/Robert_Arboleda_-_16_de_setembro_de_2018.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Robert_Arboleda_-_16_de_setembro_de_2018.jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Douglas Teixeira from Santos, Brasil",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Robert_Arboleda_-_16_de_setembro_de_2018.jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:Robert_Arboleda_-_16_de_setembro_de_2018.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-lewandowski",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/26/2019147183134_2019-05-27_Fussball_1.FC_Kaiserslautern_vs_FC_Bayern_M%C3%BCnchen_-_Sven_-_1D_X_MK_II_-_0228_-_B70I8527_%28cropped%29.jpg/250px-2019147183134_2019-05-27_Fussball_1.FC_Kaiserslautern_vs_FC_Bayern_M%C3%BCnchen_-_Sven_-_1D_X_MK_II_-_0228_-_B70I8527_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2019147183134_2019-05-27_Fussball_1.FC_Kaiserslautern_vs_FC_Bayern_M%C3%BCnchen_-_Sven_-_1D_X_MK_II_-_0228_-_B70I8527_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Sven Mandel",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2019147183134_2019-05-27_Fussball_1.FC_Kaiserslautern_vs_FC_Bayern_M%C3%BCnchen_-_Sven_-_1D_X_MK_II_-_0228_-_B70I8527_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2019147183134_2019-05-27_Fussball_1.FC_Kaiserslautern_vs_FC_Bayern_München_-_Sven_-_1D_X_MK_II_-_0228_-_B70I8527_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_rodrigo_garro",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/67/Rodrigo_Garro_2025.jpg/250px-Rodrigo_Garro_2025.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Rodrigo_Garro_2025.jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "TV Central do Timão",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Rodrigo_Garro_2025.jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Rodrigo_Garro_2025.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-rodrygo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/0/05/Rodrygo_2023_%28cropped%29.jpg/250px-Rodrygo_2023_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Rodrygo_2023_(cropped).jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Junta de Andalucía",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Rodrygo_2023_(cropped).jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:Rodrygo_2023_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-araujo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/3f/FC_Red_Bull_Salzburg_gegen_CF_Barcelona_%28Testspiel_4._August_2021%29_45_%28cropped%29.jpg/250px-FC_Red_Bull_Salzburg_gegen_CF_Barcelona_%28Testspiel_4._August_2021%29_45_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Red_Bull_Salzburg_gegen_CF_Barcelona_(Testspiel_4._August_2021)_45_(cropped).jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Red_Bull_Salzburg_gegen_CF_Barcelona_(Testspiel_4._August_2021)_45_(cropped).jpg",
      "image_license": "CC0",
      "image_file": "File:FC_Red_Bull_Salzburg_gegen_CF_Barcelona_(Testspiel_4._August_2021)_45_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-ruben-dias",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/e/ea/RubenDiasPortugal.jpg/250px-RubenDiasPortugal.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:RubenDiasPortugal.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Creatina23",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:RubenDiasPortugal.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:RubenDiasPortugal.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl_sandro_tonali",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/f/f5/Norway_Italy_-_June_2025_B_03.jpg/250px-Norway_Italy_-_June_2025_B_03.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_B_03.jpg",
    "image_license": "CC BY 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "MichaelEmilio",
      "image_license_url": "https://creativecommons.org/licenses/by/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Norway_Italy_-_June_2025_B_03.jpg",
      "image_license": "CC BY 4.0",
      "image_file": "File:Norway_Italy_-_June_2025_B_03.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_santiago_gimenez",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d8/Santiago_Gim%C3%A9nez.png/250px-Santiago_Gim%C3%A9nez.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Santiago_Gim%C3%A9nez.png",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Selección Nacional de México",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Santiago_Gim%C3%A9nez.png",
      "image_license": "CC BY 3.0",
      "image_file": "File:Santiago_Giménez.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-mctominay",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/4/4d/Scott_McTominay_Scotland_v_Bolivia_6_June_2026-41.jpg/250px-Scott_McTominay_Scotland_v_Bolivia_6_June_2026-41.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Scott_McTominay_Scotland_v_Bolivia_6_June_2026-41.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Scott_McTominay_Scotland_v_Bolivia_6_June_2026-41.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Scott_McTominay_Scotland_v_Bolivia_6_June_2026-41.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_seko_fofana",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c6/Seko_Fofana_Cote_D%27Ivoire_v_Ecuador_14_June_2026-48.jpg/250px-Seko_Fofana_Cote_D%27Ivoire_v_Ecuador_14_June_2026-48.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Seko_Fofana_Cote_D%27Ivoire_v_Ecuador_14_June_2026-48.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Seko_Fofana_Cote_D%27Ivoire_v_Ecuador_14_June_2026-48.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Seko_Fofana_Cote_D'Ivoire_v_Ecuador_14_June_2026-48.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-gnabry",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/55/Serge_Gnabry_WC2022.jpg/250px-Serge_Gnabry_WC2022.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Serge_Gnabry_WC2022.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "حسین ظهروند",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Serge_Gnabry_WC2022.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Serge_Gnabry_WC2022.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_sergio_rochet",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/bc/Sergio_Rochet_%282022%29.jpg/250px-Sergio_Rochet_%282022%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Sergio_Rochet_(2022).jpg",
    "image_license": "CC BY-SA 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "jikatu",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Sergio_Rochet_(2022).jpg",
      "image_license": "CC BY-SA 2.0",
      "image_file": "File:Sergio_Rochet_(2022).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-guirassy",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d1/Serhou_Guirassy_2024_%28cropped%29.jpg/250px-Serhou_Guirassy_2024_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Serhou_Guirassy_2024_(cropped).jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "feguifoot",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Serhou_Guirassy_2024_(cropped).jpg",
      "image_license": "Public domain",
      "image_file": "File:Serhou_Guirassy_2024_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-son",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b0/BFA_2023_-2_Heung-Min_Son_%28cropped%29.jpg/250px-BFA_2023_-2_Heung-Min_Son_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:BFA_2023_-2_Heung-Min_Son_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Ujishadow",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:BFA_2023_-2_Heung-Min_Son_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:BFA_2023_-2_Heung-Min_Son_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_takefusa_kubo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/be/Takefusa_Kubo_2019.png/250px-Takefusa_Kubo_2019.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Takefusa_Kubo_2019.png",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Real Madrid",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Takefusa_Kubo_2019.png",
      "image_license": "CC BY 3.0",
      "image_file": "File:Takefusa_Kubo_2019.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1_takumi_minamino",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/16/Minamino_asse_asm_2425.png/250px-Minamino_asse_asm_2425.png?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Minamino_asse_asm_2425.png",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Paté kroute",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Minamino_asse_asm_2425.png",
      "image_license": "CC0",
      "image_file": "File:Minamino_asse_asm_2425.png",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_teun_koopmeiners",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/61/Teun_Koopmeiners_Manchester_United_v_Atalanta_BC%2C_20_October_2021_%2812%29_%28cropped%29.jpg/250px-Teun_Koopmeiners_Manchester_United_v_Atalanta_BC%2C_20_October_2021_%2812%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Teun_Koopmeiners_Manchester_United_v_Atalanta_BC,_20_October_2021_(12)_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Ardfern",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Teun_Koopmeiners_Manchester_United_v_Atalanta_BC,_20_October_2021_(12)_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Teun_Koopmeiners_Manchester_United_v_Atalanta_BC,_20_October_2021_(12)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-theo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/93/Theo_Hernandez_France_v_Senegal_16_June_2026-222_%28cropped%29.jpg/250px-Theo_Hernandez_France_v_Senegal_16_June_2026-222_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Theo_Hernandez_France_v_Senegal_16_June_2026-222_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Theo_Hernandez_France_v_Senegal_16_June_2026-222_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Theo_Hernandez_France_v_Senegal_16_June_2026-222_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_thiago_silva",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c8/20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Thiago_Silva_850_1582.jpg/250px-20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Thiago_Silva_850_1582.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Thiago_Silva_850_1582.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Granada",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Thiago_Silva_850_1582.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:20180610_FIFA_Friendly_Match_Austria_vs._Brazil_Thiago_Silva_850_1582.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga_unai_simon",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/53/Unai_Simon_Argentina_v_Spain_19_July_2026-078_%28cropped%29.jpg/250px-Unai_Simon_Argentina_v_Spain_19_July_2026-078_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Unai_Simon_Argentina_v_Spain_19_July_2026-078_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Unai_Simon_Argentina_v_Spain_19_July_2026-078_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Unai_Simon_Argentina_v_Spain_19_July_2026-078_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-boniface",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/81/Boniface_Jr.jpg/250px-Boniface_Jr.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Boniface_Jr.jpg",
    "image_license": "CC0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Yoroudhgd",
      "image_license_url": "http://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Boniface_Jr.jpg",
      "image_license": "CC0",
      "image_file": "File:Boniface_Jr.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ea27_viktor_gyokeres",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/73/Viktor_Gy%C3%B6keres_2026-06-04_1_%28cropped%29.jpg/250px-Viktor_Gy%C3%B6keres_2026-06-04_1_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Viktor_Gy%C3%B6keres_2026-06-04_1_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Mikael Hervestad",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Viktor_Gy%C3%B6keres_2026-06-04_1_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Viktor_Gyökeres_2026-06-04_1_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-vini",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/1/10/Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_%28cropped%29.jpg/250px-Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Vin%C3%ADcius_J%C3%BAnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Vinícius_Júnior_Brazil_V_Morocco_13_June_2026-207_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-van-dijk",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5d/20160604_AUT_NED_8876_%28cropped%29.jpg/250px-20160604_AUT_NED_8876_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:20160604_AUT_NED_8876_(cropped).jpg",
    "image_license": "CC BY-SA 3.0 at",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Ailura",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0/at/deed.en",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:20160604_AUT_NED_8876_(cropped).jpg",
      "image_license": "CC BY-SA 3.0 at",
      "image_file": "File:20160604_AUT_NED_8876_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_vitor_roque",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a3/Vitor-roque-palmeiras-internacional-sep2025.jpg/250px-Vitor-roque-palmeiras-internacional-sep2025.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Vitor-roque-palmeiras-internacional-sep2025.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "NullReason",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Vitor-roque-palmeiras-internacional-sep2025.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Vitor-roque-palmeiras-internacional-sep2025.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_vitao",
    "image_url": "https://upload.wikimedia.org/wikipedia/commons/c/cf/Vit%C3%A3o2020.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail_unscaled",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Vit%C3%A3o2020.jpg",
    "image_license": "CC BY-SA 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "football.ua",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Vit%C3%A3o2020.jpg",
      "image_license": "CC BY-SA 3.0",
      "image_file": "File:Vitão2020.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "ligue1-zaire-emery",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/2/2b/Warren_Zaire-Emery_France_v_Senegal_16_June_2026-279.jpg/250px-Warren_Zaire-Emery_France_v_Senegal_16_June_2026-279.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Warren_Zaire-Emery_France_v_Senegal_16_June_2026-279.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Warren_Zaire-Emery_France_v_Senegal_16_June_2026-279.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Warren_Zaire-Emery_France_v_Senegal_16_June_2026-279.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_weverton",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/d/da/Weverton_Brazil_V_Morocco_13_June_2026-67_%28cropped%29.jpg/250px-Weverton_Brazil_V_Morocco_13_June_2026-67_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Weverton_Brazil_V_Morocco_13_June_2026-67_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Weverton_Brazil_V_Morocco_13_June_2026-67_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Weverton_Brazil_V_Morocco_13_June_2026-67_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bundes_willi_orban",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/7/7a/2022-04-20_Fu%C3%9Fball%2C_M%C3%A4nner%2C_DFB-Pokal%2C_RB_Leipzig_-_1._FC_Union_Berlin_1DX_8250_by_Stepro_%28cropped%29.jpg/250px-2022-04-20_Fu%C3%9Fball%2C_M%C3%A4nner%2C_DFB-Pokal%2C_RB_Leipzig_-_1._FC_Union_Berlin_1DX_8250_by_Stepro_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2022-04-20_Fu%C3%9Fball,_M%C3%A4nner,_DFB-Pokal,_RB_Leipzig_-_1._FC_Union_Berlin_1DX_8250_by_Stepro_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "crop by FMSky",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2022-04-20_Fu%C3%9Fball,_M%C3%A4nner,_DFB-Pokal,_RB_Leipzig_-_1._FC_Union_Berlin_1DX_8250_by_Stepro_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2022-04-20 Fußball, Männer, DFB-Pokal, RB Leipzig - 1. FC Union Berlin 1DX 8250 by Stepro (cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "pl-saliba",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c2/William_Saliba_France_v_Senegal_16_June_2026-336_%28cropped%29.jpg/250px-William_Saliba_France_v_Senegal_16_June_2026-336_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:William_Saliba_France_v_Senegal_16_June_2026-336_(cropped).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:William_Saliba_France_v_Senegal_16_June_2026-336_(cropped).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:William_Saliba_France_v_Senegal_16_June_2026-336_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-xavi",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b2/2023-10-04_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League%2C_RB_Leipzig_-_Manchester_City_FC_1DX_2672_%28Xavi_Simons%29.jpg/250px-2023-10-04_Fu%C3%9Fball%2C_M%C3%A4nner%2C_UEFA_Champions_League%2C_RB_Leipzig_-_Manchester_City_FC_1DX_2672_%28Xavi_Simons%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-10-04_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2672_(Xavi_Simons).jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Original:  Steffen Prößdorf; Derivative work:  SonoGrazy",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:2023-10-04_Fu%C3%9Fball,_M%C3%A4nner,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2672_(Xavi_Simons).jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:2023-10-04_Fußball,_Männer,_UEFA_Champions_League,_RB_Leipzig_-_Manchester_City_FC_1DX_2672_(Xavi_Simons).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea-sommer",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/5/5a/FC_Salzburg_gegen_Inter_Mailand_%28Testspiel_2023-08-09%29_69.jpg/250px-FC_Salzburg_gegen_Inter_Mailand_%28Testspiel_2023-08-09%29_69.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_Inter_Mailand_(Testspiel_2023-08-09)_69.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Werner100359",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:FC_Salzburg_gegen_Inter_Mailand_(Testspiel_2023-08-09)_69.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:FC_Salzburg_gegen_Inter_Mailand_(Testspiel_2023-08-09)_69.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "seriea_youssouf_fofana",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/Youssouf_Fofana_%28footballer%2C_born_1999%29_%28cropped%29.jpg/250px-Youssouf_Fofana_%28footballer%2C_born_1999%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Youssouf_Fofana_(footballer,_born_1999)_(cropped).jpg",
    "image_license": "CC BY 2.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Pedro  Semitiel",
      "image_license_url": "https://creativecommons.org/licenses/by/2.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Youssouf_Fofana_(footballer,_born_1999)_(cropped).jpg",
      "image_license": "CC BY 2.0",
      "image_file": "File:Youssouf_Fofana_(footballer,_born_1999)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bra_yuri_alberto",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/89/Brasileir%C3%A3o_2022_Corinthians_2x0_Cuiab%C3%A1_%2852661306474%29_%28cropped%29.jpg/250px-Brasileir%C3%A3o_2022_Corinthians_2x0_Cuiab%C3%A1_%2852661306474%29_%28cropped%29.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Brasileir%C3%A3o_2022_Corinthians_2x0_Cuiab%C3%A1_(52661306474)_(cropped).jpg",
    "image_license": "Public domain",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "SOCCER DIGITAL",
      "image_license_url": "",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Brasileir%C3%A3o_2022_Corinthians_2x0_Cuiab%C3%A1_(52661306474)_(cropped).jpg",
      "image_license": "Public domain",
      "image_file": "File:Brasileirão_2022_Corinthians_2x0_Cuiabá_(52661306474)_(cropped).jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "bund-grimaldo",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/8/87/Alex_Grimaldo_Argentina_v_Spain_19_July_2026-314.jpg/250px-Alex_Grimaldo_Argentina_v_Spain_19_July_2026-314.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Alex_Grimaldo_Argentina_v_Spain_19_July_2026-314.jpg",
    "image_license": "CC BY-SA 4.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Bryan Berlin",
      "image_license_url": "https://creativecommons.org/licenses/by-sa/4.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Alex_Grimaldo_Argentina_v_Spain_19_July_2026-314.jpg",
      "image_license": "CC BY-SA 4.0",
      "image_file": "File:Alex_Grimaldo_Argentina_v_Spain_19_July_2026-314.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
      "image_display_changes": "Resized and circular framing in UI; source file unchanged"
    }
  },
  {
    "id": "laliga-militao",
    "image_url": "https://thumb.wikimedia.org/wikipedia/commons/thumb/3/38/Eder_Militao_2021.jpg/250px-Eder_Militao_2021.jpg?utm_source=commons.wikimedia.org&utm_campaign=imageinfo&utm_content=thumbnail",
    "image_source_url": "https://commons.wikimedia.org/wiki/File:Eder_Militao_2021.jpg",
    "image_license": "CC BY 3.0",
    "image_metadata": {
      "image_source": "Wikimedia Commons",
      "image_author": "Real Madrid",
      "image_license_url": "https://creativecommons.org/licenses/by/3.0",
      "image_source_url": "https://commons.wikimedia.org/wiki/File:Eder_Militao_2021.jpg",
      "image_license": "CC BY 3.0",
      "image_file": "File:Eder_Militao_2021.jpg",
      "image_checked_at": "2026-09-19",
      "image_policy": "licensed_or_public_domain_wikimedia",
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
