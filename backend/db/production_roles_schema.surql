CREATE role:role_001 CONTENT {
  role_id: "role_001",
  standardized_title: "Producer",
  aliases: ["Executive Producer", "Line Producer", "Film Producer"],
  department: "Production",
  description: "Oversees project financing, hiring, and logistics; primary liaison with stakeholders.",
  reports_to: NONE,
  localizations: {
    en: "Producer",
    en_uk: "Producer",
    de: "Produzent",
    fr: "Producteur",
    it: "Produttore",
    es: "Productor",
    pt: "Produtor",
    nl: "Producent"
  },
  external_references: {
    imdb: "Producer",
    tmdb: "Producer"
  }
};

CREATE role:role_002 CONTENT {
  role_id: "role_002",
  standardized_title: "Executive Producer",
  aliases: ["EP", "Senior Producer"],
  department: "Production",
  description: "Provides high-level oversight or funding; may represent studio/client.",
  reports_to: NONE,
  localizations: {
    en: "Executive Producer",
    en_uk: "Executive Producer",
    de: "Ausführender Produzent",
    fr: "Producteur exécutif",
    it: "Produttore esecutivo",
    es: "Productor ejecutivo",
    pt: "Produtor executivo",
    nl: "Uitvoerend producent"
  },
  external_references: {
    imdb: "Executive Producer",
    tmdb: "Executive Producer"
  }
};

CREATE role:role_003 CONTENT {
  role_id: "role_003",
  standardized_title: "Line Producer",
  aliases: ["Production Manager", "Unit Production Manager", "UPM"],
  department: "Production",
  description: "Manages daily operations, budget, and schedule.",
  reports_to: role:role_001,
  localizations: {
    en: "Line Producer",
    en_uk: "Line Producer",
    de: "Line Producer",
    fr: "Producteur de ligne",
    it: "Produttore di linea",
    es: "Productor de línea",
    pt: "Produtor de linha",
    nl: "Lijnproducent"
  },
  external_references: {
    imdb: "Line Producer",
    tmdb: "Line Producer"
  }
};

CREATE role:role_004 CONTENT {
  role_id: "role_004",
  standardized_title: "Production Coordinator",
  aliases: ["Production Secretary", "Coordinator"],
  department: "Production",
  description: "Handles logistics, paperwork, and crew coordination.",
  reports_to: role:role_003,
  localizations: {
    en: "Production Coordinator",
    en_uk: "Production Coordinator",
    de: "Produktionskoordinator",
    fr: "Coordinateur de production",
    it: "Coordinatore di produzione",
    es: "Coordinador de producción",
    pt: "Coordenador de produção",
    nl: "Productiecoördinator"
  },
  external_references: {
    imdb: "Production Coordinator",
    tmdb: "Production Coordinator"
  }
};

CREATE role:role_005 CONTENT {
  role_id: "role_005",
  standardized_title: "Production Assistant",
  aliases: ["PA", "Runner", "Set PA"],
  department: "Production",
  description: "Entry-level role supporting all departments with miscellaneous tasks.",
  reports_to: role:role_004,
  localizations: {
    en: "Production Assistant",
    en_uk: "Production Assistant",
    de: "Produktionsassistent",
    fr: "Assistant de production",
    it: "Assistente di produzione",
    es: "Asistente de producción",
    pt: "Assistente de produção",
    nl: "Productieassistent"
  },
  external_references: {
    imdb: "Production Assistant",
    tmdb: NONE
  }
};

CREATE role:role_006 CONTENT {
  role_id: "role_006",
  standardized_title: "Director",
  aliases: ["Film Director", "Showrunner"],
  department: "Directing",
  description: "Controls creative vision, directs talent and crew.",
  reports_to: NONE,
  localizations: {
    en: "Director",
    en_uk: "Director",
    de: "Regisseur",
    fr: "Réalisateur",
    it: "Regista",
    es: "Director",
    pt: "Diretor",
    nl: "Regisseur"
  },
  external_references: {
    imdb: "Director",
    tmdb: "Director"
  }
};

CREATE role:role_007 CONTENT {
  role_id: "role_007",
  standardized_title: "First Assistant Director",
  aliases: ["1st AD", "First AD"],
  department: "Directing",
  description: "Manages set schedule and crew coordination.",
  reports_to: role:role_006,
  localizations: {
    en: "First Assistant Director",
    en_uk: "First Assistant Director",
    de: "Erster Regieassistent",
    fr: "Premier assistant réalisateur",
    it: "Primo assistente regista",
    es: "Primer asistente de dirección",
    pt: "Primeiro assistente de direção",
    nl: "Eerste regieassistent"
  },
  external_references: {
    imdb: "Assistant Director",
    tmdb: "Assistant Director"
  }
};

CREATE role:role_008 CONTENT {
  role_id: "role_008",
  standardized_title: "Second Assistant Director",
  aliases: ["2nd AD", "Second AD"],
  department: "Directing",
  description: "Supports 1st AD with call sheets and cast coordination.",
  reports_to: role:role_007,
  localizations: {
    en: "Second Assistant Director",
    en_uk: "Second Assistant Director",
    de: "Zweiter Regieassistent",
    fr: "Deuxième assistant réalisateur",
    it: "Secondo assistente regista",
    es: "Segundo asistente de dirección",
    pt: "Segundo assistente de direção",
    nl: "Tweede regieassistent"
  },
  external_references: {
    imdb: "Assistant Director",
    tmdb: "Assistant Director"
  }
};

CREATE role:role_009 CONTENT {
  role_id: "role_009",
  standardized_title: "Script Supervisor",
  aliases: ["Continuity Supervisor", "Scripty"],
  department: "Directing",
  description: "Tracks continuity in props, dialogue, and actions.",
  reports_to: role:role_006,
  localizations: {
    en: "Script Supervisor",
    en_uk: "Script Supervisor",
    de: "Script Supervisor",
    fr: "Script",
    it: "Supervisore della sceneggiatura",
    es: "Supervisor de guion",
    pt: "Supervisor de roteiro",
    nl: "Scriptsupervisor"
  },
  external_references: {
    imdb: "Script Supervisor",
    tmdb: "Script Supervisor"
  }
};

CREATE role:role_010 CONTENT {
  role_id: "role_010",
  standardized_title: "Director of Photography",
  aliases: ["DP", "Cinematographer", "DoP"],
  department: "Camera",
  description: "Designs visual style, oversees camera and lighting.",
  reports_to: role:role_006,
  localizations: {
    en: "Director of Photography",
    en_uk: "Director of Photography",
    de: "Kameramann",
    fr: "Directeur de la photographie",
    it: "Direttore della fotografia",
    es: "Director de fotografía",
    pt: "Diretor de fotografia",
    nl: "Cameraregisseur"
  },
  external_references: {
    imdb: "Cinematographer",
    tmdb: "Director of Photography"
  }
};

CREATE role:role_011 CONTENT {
  role_id: "role_011",
  standardized_title: "Camera Operator",
  aliases: ["Cameraman", "Steadicam Operator"],
  department: "Camera",
  description: "Physically operates the camera.",
  reports_to: role:role_010,
  localizations: {
    en: "Camera Operator",
    en_uk: "Camera Operator",
    de: "Kameraoperator",
    fr: "Opérateur caméra",
    it: "Operatore di macchina",
    es: "Operador de cámara",
    pt: "Operador de câmera",
    nl: "Cameraoperator"
  },
  external_references: {
    imdb: "Camera Operator",
    tmdb: "Camera Operator"
  }
};

CREATE role:role_012 CONTENT {
  role_id: "role_012",
  standardized_title: "First Assistant Camera",
  aliases: ["1st AC", "Focus Puller"],
  department: "Camera",
  description: "Maintains focus, manages camera equipment.",
  reports_to: role:role_010,
  localizations: {
    en: "First Assistant Camera",
    en_uk: "First Assistant Camera",
    de: "Erster Kameraassistent",
    fr: "Premier assistant caméra",
    it: "Primo assistente operatore",
    es: "Primer asistente de cámara",
    pt: "Primeiro assistente de câmera",
    nl: "Eerste camera-assistent"
  },
  external_references: {
    imdb: "Focus Puller",
    tmdb: "Assistant Camera"
  }
};

CREATE role:role_013 CONTENT {
  role_id: "role_013",
  standardized_title: "Second Assistant Camera",
  aliases: ["2nd AC", "Clapper Loader"],
  department: "Camera",
  description: "Runs slate, manages media transfer.",
  reports_to: role:role_012,
  localizations: {
    en: "Second Assistant Camera",
    en_uk: "Second Assistant Camera",
    de: "Zweiter Kameraassistent",
    fr: "Deuxième assistant caméra",
    it: "Secondo assistente operatore",
    es: "Segundo asistente de cámara",
    pt: "Segundo assistente de câmera",
    nl: "Tweede camera-assistent"
  },
  external_references: {
    imdb: "Clapper Loader",
    tmdb: "Assistant Camera"
  }
};

CREATE role:role_014 CONTENT {
  role_id: "role_014",
  standardized_title: "Digital Imaging Technician",
  aliases: ["DIT"],
  department: "Camera",
  description: "Ensures footage quality and color consistency.",
  reports_to: role:role_010,
  localizations: {
    en: "Digital Imaging Technician",
    en_uk: "Digital Imaging Technician",
    de: "Digitaler Bildtechniker",
    fr: "Technicien d'imagerie numérique",
    it: "Tecnico di imaging digitale",
    es: "Técnico de imagen digital",
    pt: "Técnico de imagem digital",
    nl: "Digitaal beeldtechnicus"
  },
  external_references: {
    imdb: "Digital Imaging Technician",
    tmdb: "Digital Imaging Technician"
  }
};

CREATE role:role_015 CONTENT {
  role_id: "role_015",
  standardized_title: "Gaffer",
  aliases: ["Chief Lighting Technician"],
  department: "Lighting",
  description: "Leads lighting team, implements DP's lighting plan.",
  reports_to: role:role_010,
  localizations: {
    en: "Gaffer",
    en_uk: "Gaffer",
    de: "Oberbeleuchter",
    fr: "Chef éclairagiste",
    it: "Capo elettricista",
    es: "Jefe de eléctricos",
    pt: "Chefe de iluminação",
    nl: "Hoofdverlichter"
  },
  external_references: {
    imdb: "Gaffer",
    tmdb: "Gaffer"
  }
};

CREATE role:role_016 CONTENT {
  role_id: "role_016",
  standardized_title: "Best Boy Electric",
  aliases: ["Best Boy Lighting"],
  department: "Lighting",
  description: "Assists gaffer with logistics and crew coordination.",
  reports_to: role:role_015,
  localizations: {
    en: "Best Boy Electric",
    en_uk: "Best Boy Electric",
    de: "Beleuchterassistent",
    fr: "Assistant chef éclairagiste",
    it: "Assistente capo elettricista",
    es: "Asistente de eléctricos",
    pt: "Assistente de iluminação",
    nl: "Assistent hoofdverlichter"
  },
  external_references: {
    imdb: "Best Boy Electric",
    tmdb: "Best Boy Electric"
  }
};

CREATE role:role_017 CONTENT {
  role_id: "role_017",
  standardized_title: "Key Grip",
  aliases: ["Chief Grip"],
  department: "Grip",
  description: "Oversees camera support and rigging equipment.",
  reports_to: role:role_010,
  localizations: {
    en: "Key Grip",
    en_uk: "Key Grip",
    de: "Obermaschinist",
    fr: "Chef machiniste",
    it: "Capo macchinista",
    es: "Jefe de maquinaria",
    pt: "Chefe de maquinaria",
    nl: "Hoofdgrip"
  },
  external_references: {
    imdb: "Key Grip",
    tmdb: "Key Grip"
  }
};

CREATE role:role_018 CONTENT {
  role_id: "role_018",
  standardized_title: "Best Boy Grip",
  aliases: ["Assistant Key Grip"],
  department: "Grip",
  description: "Supports key grip with equipment logistics.",
  reports_to: role:role_017,
  localizations: {
    en: "Best Boy Grip",
    en_uk: "Best Boy Grip",
    de: "Maschinistenassistent",
    fr: "Assistant chef machiniste",
    it: "Assistente capo macchinista",
    es: "Asistente de maquinaria",
    pt: "Assistente de maquinaria",
    nl: "Assistent hoofdgrip"
  },
  external_references: {
    imdb: "Best Boy Grip",
    tmdb: "Best Boy Grip"
  }
};

CREATE role:role_019 CONTENT {
  role_id: "role_019",
  standardized_title: "Sound Mixer",
  aliases: ["Production Sound Mixer", "Sound Recordist"],
  department: "Sound",
  description: "Records on-set audio, manages microphones.",
  reports_to: role:role_006,
  localizations: {
    en: "Sound Mixer",
    en_uk: "Sound Mixer",
    de: "Tonmeister",
    fr: "Ingénieur du son",
    it: "Tecnico del suono",
    es: "Mezclador de sonido",
    pt: "Misturador de som",
    nl: "Geluidsmixer"
  },
  external_references: {
    imdb: "Sound Mixer",
    tmdb: "Sound Mixer"
  }
};

CREATE role:role_020 CONTENT {
  role_id: "role_020",
  standardized_title: "Boom Operator",
  aliases: ["Boom Person", "Sound Assistant"],
  department: "Sound",
  description: "Positions microphones for optimal audio capture.",
  reports_to: role:role_019,
  localizations: {
    en: "Boom Operator",
    en_uk: "Boom Operator",
    de: "Tonangelassistent",
    fr: "Perchiste",
    it: "Operatore di microfono",
    es: "Operador de micro",
    pt: "Operador de microfone",
    nl: "Hengeloperator"
  },
  external_references: {
    imdb: "Boom Operator",
    tmdb: "Boom Operator"
  }
};

CREATE role:role_021 CONTENT {
  role_id: "role_021",
  standardized_title: "Production Designer",
  aliases: ["Art Director"],
  department: "Art",
  description: "Oversees set design, props, and visual aesthetics.",
  reports_to: role:role_006,
  localizations: {
    en: "Production Designer",
    en_uk: "Production Designer",
    de: "Szenenbildner",
    fr: "Chef décorateur",
    it: "Scenografo",
    es: "Diseñador de producción",
    pt: "Designer de produção",
    nl: "Productieontwerper"
  },
  external_references: {
    imdb: "Production Designer",
    tmdb: "Production Designer"
  }
};

CREATE role:role_022 CONTENT {
  role_id: "role_022",
  standardized_title: "Art Director",
  aliases: ["Supervising Art Director"],
  department: "Art",
  description: "Manages art department logistics under production designer.",
  reports_to: role:role_021,
  localizations: {
    en: "Art Director",
    en_uk: "Art Director",
    de: "Kunstleiter",
    fr: "Directeur artistique",
    it: "Direttore artistico",
    es: "Director de arte",
    pt: "Diretor de arte",
    nl: "Artdirector"
  },
  external_references: {
    imdb: "Art Director",
    tmdb: "Art Director"
  }
};

CREATE role:role_023 CONTENT {
  role_id: "role_023",
  standardized_title: "Set Decorator",
  aliases: ["Set Dresser"],
  department: "Art",
  description: "Furnishes and decorates sets.",
  reports_to: role:role_021,
  localizations: {
    en: "Set Decorator",
    en_uk: "Set Decorator",
    de: "Setdekorateur",
    fr: "Décorateur de plateau",
    it: "Arredatore di scena",
    es: "Decorador de sets",
    pt: "Decorador de cenários",
    nl: "Setdecorateur"
  },
  external_references: {
    imdb: "Set Decorator",
    tmdb: "Set Decoration"
  }
};

CREATE role:role_024 CONTENT {
  role_id: "role_024",
  standardized_title: "Costume Designer",
  aliases: ["Wardrobe Designer"],
  department: "Costume",
  description: "Designs and sources costumes for characters.",
  reports_to: role:role_006,
  localizations: {
    en: "Costume Designer",
    en_uk: "Costume Designer",
    de: "Kostümbildner",
    fr: "Costumier",
    it: "Costumista",
    es: "Diseñador de vestuario",
    pt: "Designer de figurinos",
    nl: "Kostuumontwerper"
  },
  external_references: {
    imdb: "Costume Designer",
    tmdb: "Costume Designer"
  }
};

CREATE role:role_025 CONTENT {
  role_id: "role_025",
  standardized_title: "Makeup Artist",
  aliases: ["Key Makeup Artist"],
  department: "Makeup",
  description: "Applies makeup, including special effects makeup.",
  reports_to: role:role_006,
  localizations: {
    en: "Makeup Artist",
    en_uk: "Makeup Artist",
    de: "Maskenbildner",
    fr: "Maquilleur",
    it: "Truccatore",
    es: "Maquillador",
    pt: "Maquiador",
    nl: "Visagist"
  },
  external_references: {
    imdb: "Makeup Artist",
    tmdb: "Makeup Artist"
  }
};

CREATE role:role_026 CONTENT {
  role_id: "role_026",
  standardized_title: "Hair Stylist",
  aliases: ["Key Hair Stylist"],
  department: "Makeup",
  description: "Designs and maintains hairstyles.",
  reports_to: role:role_006,
  localizations: {
    en: "Hair Stylist",
    en_uk: "Hair Stylist",
    de: "Friseur",
    fr: "Coiffeur",
    it: "Parrucchiere",
    es: "Peluquero",
    pt: "Cabeleireiro",
    nl: "Kapper"
  },
  external_references: {
    imdb: "Hair Stylist",
    tmdb: "Hairstylist"
  }
};

CREATE role:role_027 CONTENT {
  role_id: "role_027",
  standardized_title: "Editor",
  aliases: ["Film Editor", "Video Editor"],
  department: "Post-Production",
  description: "Assembles footage, refines narrative and pacing.",
  reports_to: NONE,
  localizations: {
    en: "Editor",
    en_uk: "Editor",
    de: "Cutter",
    fr: "Monteur",
    it: "Montatore",
    es: "Editor",
    pt: "Editor",
    nl: "Editor"
  },
  external_references: {
    imdb: "Editor",
    tmdb: "Editor"
  }
};

CREATE role:role_028 CONTENT {
  role_id: "role_028",
  standardized_title: "Visual Effects Supervisor",
  aliases: ["VFX Supervisor"],
  department: "Visual Effects",
  description: "Oversees creation and integration of visual effects.",
  reports_to: NONE,
  localizations: {
    en: "Visual Effects Supervisor",
    en_uk: "Visual Effects Supervisor",
    de: "Supervisor für visuelle Effekte",
    fr: "Supervisieur des effets visuels",
    it: "Supervisore degli effetti visivi",
    es: "Supervisor de efectos visuales",
    pt: "Supervisor de efeitos visuais",
    nl: "Supervisor visuele effecten"
  },
  external_references: {
    imdb: "Visual Effects Supervisor",
    tmdb: "Visual Effects Supervisor"
  }
};

CREATE role:role_029 CONTENT {
  role_id: "role_029",
  standardized_title: "Sound Designer",
  aliases: ["Sound Editor"],
  department: "Post-Production",
  description: "Creates and edits soundscapes, including effects and ambiance.",
  reports_to: NONE,
  localizations: {
    en: "Sound Designer",
    en_uk: "Sound Designer",
    de: "Sound Designer",
    fr: "Concepteur sonore",
    it: "Progettista del suono",
    es: "Diseñador de sonido",
    pt: "Designer de som",
    nl: "Geluidsontwerper"
  },
  external_references: {
    imdb: "Sound Designer",
    tmdb: "Sound Designer"
  }
};

CREATE role:role_030 CONTENT {
  role_id: "role_030",
  standardized_title: "Colorist",
  aliases: ["Color Grader"],
  department: "Post-Production",
  description: "Adjusts footage color for aesthetic consistency.",
  reports_to: NONE,
  localizations: {
    en: "Colorist",
    en_uk: "Colourist",
    de: "Colorist",
    fr: "Coloriste",
    it: "Colorista",
    es: "Colorista",
    pt: "Colorista",
    nl: "Colorist"
  },
  external_references: {
    imdb: "Colorist",
    tmdb: "Colorist"
  }
};

CREATE role:role_031 CONTENT {
  role_id: "role_031",
  standardized_title: "Content Creator",
  aliases: ["Influencer", "Social Media Producer"],
  department: "Creative",
  description: "Develops and produces content for social platforms.",
  reports_to: NONE,
  localizations: {
    en: "Content Creator",
    en_uk: "Content Creator",
    de: "Content Creator",
    fr: "Créateur de contenu",
    it: "Creatore di contenuti",
    es: "Creador de contenido",
    pt: "Criador de conteúdo",
    nl: "Contentcreator"
  },
  external_references: {
    imdb: NONE,
    tmdb: NONE
  }
};

CREATE role:role_032 CONTENT {
  role_id: "role_032",
  standardized_title: "Creative Director",
  aliases: ["Brand Director"],
  department: "Creative",
  description: "Shapes brand-driven visual and narrative style.",
  reports_to: NONE,
  localizations: {
    en: "Creative Director",
    en_uk: "Creative Director",
    de: "Kreativdirektor",
    fr: "Directeur créatif",
    it: "Direttore creativo",
    es: "Director creativo",
    pt: "Diretor criativo",
    nl: "Creatief directeur"
  },
  external_references: {
    imdb: "Creative Director",
    tmdb: NONE
  }
};

CREATE role:role_033 CONTENT {
  role_id: "role_033",
  standardized_title: "Stunt Coordinator",
  aliases: ["Stunt Director"],
  department: "Stunts",
  description: "Coordinates and designs stunt sequences.",
  reports_to: role:role_006,
  localizations: {
    en: "Stunt Coordinator",
    en_uk: "Stunt Coordinator",
    de: "Stuntkoordinator",
    fr: "Coordinateur de cascades",
    it: "Coordinatore degli stunt",
    es: "Coordinador de acrobacias",
    pt: "Coordenador de acrobacias",
    nl: "Stuntcoördinator"
  },
  external_references: {
    imdb: "Stunt Coordinator",
    tmdb: "Stunt Coordinator"
  }
};

CREATE role:role_034 CONTENT {
  role_id: "role_034",
  standardized_title: "Casting Director",
  aliases: ["Casting Agent"],
  department: "Casting",
  description: "Selects and auditions actors for roles.",
  reports_to: role:role_006,
  localizations: {
    en: "Casting Director",
    en_uk: "Casting Director",
    de: "Casting-Direktor",
    fr: "Directeur de casting",
    it: "Direttore del casting",
    es: "Director de casting",
    pt: "Diretor de elenco",
    nl: "Castingdirector"
  },
  external_references: {
    imdb: "Casting Director",
    tmdb: "Casting Director"
  }
};

CREATE role:role_035 CONTENT {
  role_id: "role_035",
  standardized_title: "Location Manager",
  aliases: ["Location Scout"],
  department: "Production",
  description: "Secures and manages filming locations.",
  reports_to: role:role_003,
  localizations: {
    en: "Location Manager",
    en_uk: "Location Manager",
    de: "Location Manager",
    fr: "Responsable des lieux",
    it: "Responsabile delle location",
    es: "Gerente de locaciones",
    pt: "Gerente de locações",
    nl: "Locatiemanager"
  },
  external_references: {
    imdb: "Location Manager",
    tmdb: "Location Manager"
  }
};