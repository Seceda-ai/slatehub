USE NS seceda DB core;

-- First, insert all unique departments
-- Departments

CREATE department:directing SET name = "Directing";
CREATE department:producing SET name = "Producing";
CREATE department:writing SET name = "Writing";
CREATE department:art SET name = "Art";
CREATE department:cinematography SET name = "Cinematography";
CREATE department:sound SET name = "Sound";
CREATE department:costume SET name = "Costume";
CREATE department:makeup_hair SET name = "Makeup/Hair";
CREATE department:casting SET name = "Casting";
CREATE department:acting SET name = "Acting";
CREATE department:stunts_choreography SET name = "Stunts/Choreography";
CREATE department:locations SET name = "Locations";
CREATE department:production_management SET name = "Production Management";
CREATE department:assistant_directing SET name = "Assistant Directing";
CREATE department:editing SET name = "Editing";
CREATE department:visual_effects SET name = "Visual Effects";
CREATE department:animation SET name = "Animation";
CREATE department:music SET name = "Music";
CREATE department:sound_post_production SET name = "Sound Post-Production";
CREATE department:marketing SET name = "Marketing";
CREATE department:publicity SET name = "Publicity";
CREATE department:social_media SET name = "Social Media";
CREATE department:distribution_sales SET name = "Distribution/Sales";
CREATE department:bts SET name = "BTS";
CREATE department:talent_representation SET name = "Talent Representation";
CREATE department:post_production_coordination SET name = "Post-Production Coordination";
CREATE department:legal_clearances SET name = "Legal/Clearances";
CREATE department:accounting SET name = "Accounting";
CREATE department:transportation SET name = "Transportation";
CREATE department:craft_catering SET name = "Craft/Catering";
CREATE department:safety_medical SET name = "Safety/Medical";
CREATE department:miscellaneous SET name = "Miscellaneous";
CREATE department:special_effects SET name = "Special Effects";
CREATE department:explosion SET name = "Explosion";

-- Then, insert all roles

-- Directing roles
CREATE role:creative_director SET name = "Creative Director", description = "Oversees the creative vision and direction of a production";
CREATE role:director SET name = "Director", description = "Directs the filming of a production";

-- Producing roles
CREATE role:producer SET name = "Producer", description = "Manages the production process";
CREATE role:executive_producer SET name = "Executive Producer", description = "Supervises the producers and secures financing";
CREATE role:co_concurrent_producer SET name = "Co.Concurrent Producer", description = "Works alongside other producers in a specific capacity";
CREATE role:associate_producer SET name = "Associate Producer", description = "Assists the producer with various production tasks";
CREATE role:supervising_producer SET name = "Supervising Producer", description = "Oversees specific aspects of production";
CREATE role:segment_producer SET name = "Segment Producer", description = "Produces individual segments of a larger production";
CREATE role:showrunner SET name = "Showrunner", description = "Manages all aspects of TV series production and creative direction";
CREATE role:development_executive SET name = "Development Executive", description = "Evaluates and develops potential projects";

-- Writing roles
CREATE role:screenwriter SET name = "Screenwriter", description = "Writes screenplays for films or TV shows";
CREATE role:script_consultant SET name = "Script Consultant", description = "Provides expert advice on script improvement";
CREATE role:story_editor SET name = "Story Editor", description = "Edits and improves the story elements of scripts";
CREATE role:script_coordinator SET name = "Script Coordinator", description = "Manages script versions and distribution";

-- Art roles
CREATE role:storyboard_artist SET name = "Storyboard Artist", description = "Creates visual sequences of a script";
CREATE role:concept_artist SET name = "Concept Artist", description = "Creates visual concepts for production design";
CREATE role:visual_development_artist SET name = "Visual Development Artist", description = "Develops the visual style and look of a production";
CREATE role:production_designer SET name = "Production Designer", description = "Responsible for the overall visual look of a production";
CREATE role:art_director SET name = "Art Director", description = "Manages the art department";
CREATE role:assistant_art_director SET name = "Assistant Art Director", description = "Assists the art director";
CREATE role:set_designer SET name = "Set Designer", description = "Designs and plans the sets";
CREATE role:set_decorator SET name = "Set Decorator", description = "Decorates and dresses the sets";
CREATE role:prop_master SET name = "Prop Master", description = "Manages all props used in production";
CREATE role:assistant_prop_master SET name = "Assistant Prop Master", description = "Assists the prop master";
CREATE role:prop_fabricator SET name = "Prop Fabricator", description = "Creates custom props";
CREATE role:leadman SET name = "Leadman", description = "Supervises the set dressing crew";
CREATE role:set_dresser SET name = "Set Dresser", description = "Places set dressing elements on set";
CREATE role:scenic_artist SET name = "Scenic Artist", description = "Creates painted backgrounds and set pieces";
CREATE role:greensman SET name = "Greensman", description = "Handles plants and foliage on set";

-- Cinematography roles
CREATE role:cinematographer SET name = "Cinematographer", description = "Responsible for the visual style and camera work";
CREATE role:director_of_photography SET name = "Director of Photography", description = "Oversees camera and lighting departments";
CREATE role:camera_operator SET name = "Camera Operator", description = "Operates the camera during filming";
CREATE role:first_assistant_camera SET name = "First Assistant Camera", description = "Manages focus and assists the camera operator";
CREATE role:second_assistant_camera SET name = "Second Assistant Camera", description = "Manages camera equipment and slates scenes";
CREATE role:camera_loader SET name = "Camera Loader", description = "Loads and unloads camera media";
CREATE role:steadicam_operator SET name = "Steadicam Operator", description = "Operates the stabilized camera system";
CREATE role:drone_operator SET name = "Drone Operator", description = "Operates camera drones for aerial photography";
CREATE role:gaffer SET name = "Gaffer", description = "Chief lighting technician";
CREATE role:best_boy_electric SET name = "Best Boy Electric", description = "Assistant chief lighting technician";
CREATE role:lighting_technician SET name = "Lighting Technician", description = "Sets up and operates lighting equipment";
CREATE role:key_grip SET name = "Key Grip", description = "Head of the grip department";
CREATE role:best_boy_grip SET name = "Best Boy Grip", description = "Assistant to the key grip";
CREATE role:dolly_grip SET name = "Dolly Grip", description = "Operates the camera dolly";
CREATE role:rigging_grip SET name = "Rigging Grip", description = "Sets up rigging equipment";
CREATE role:video_assist_operator SET name = "Video Assist Operator", description = "Operates the video playback system";
CREATE role:dit SET name = "DIT (Digital Imaging Technician)", description = "Manages digital image quality and data workflow";
CREATE role:data_wrangler SET name = "Data Wrangler", description = "Manages digital media data";

-- Sound roles
CREATE role:sound_designer SET name = "Sound Designer", description = "Creates the sound concept and design";
CREATE role:production_sound_mixer SET name = "Production Sound Mixer", description = "Records sound on set";
CREATE role:boom_operator SET name = "Boom Operator", description = "Positions microphones during shooting";
CREATE role:utility_sound_technician SET name = "Utility Sound Technician", description = "Assists the sound department";
CREATE role:sound_assistant SET name = "Sound Assistant", description = "Provides general assistance to the sound department";

-- Costume roles
CREATE role:costume_designer SET name = "Costume Designer", description = "Designs the costumes for a production";
CREATE role:costume_supervisor SET name = "Costume Supervisor", description = "Oversees the costume department";
CREATE role:wardrobe_stylist SET name = "Wardrobe Stylist", description = "Styles costumes for characters";
CREATE role:costume_assistant SET name = "Costume Assistant", description = "Assists with costume preparation and maintenance";
CREATE role:seamstress SET name = "Seamstress", description = "Sews and alters costumes";

-- Makeup/Hair roles
CREATE role:makeup_artist SET name = "Makeup Artist", description = "Applies makeup to performers";
CREATE role:special_effects_makeup_artist SET name = "Special Effects Makeup Artist", description = "Creates special makeup effects";
CREATE role:prosthetics_designer SET name = "Prosthetics Designer", description = "Designs and creates prosthetic makeup pieces";
CREATE role:hair_stylist SET name = "Hair Stylist", description = "Styles hair for performers";
CREATE role:hair_assistant SET name = "Hair Assistant", description = "Assists with hair styling";

-- Casting roles
CREATE role:casting_director SET name = "Casting Director", description = "Manages the casting process";
CREATE role:casting_associate SET name = "Casting Associate", description = "Assists with casting operations";

-- Acting roles
CREATE role:actor SET name = "Actor", description = "Performs roles in a production";
CREATE role:background_actor SET name = "Background Actor", description = "Performs in non-speaking background roles";
CREATE role:voice_actor SET name = "Voice Actor", description = "Provides voice performances";

-- Stunts/Choreography roles
CREATE role:stunt_coordinator SET name = "Stunt Coordinator", description = "Plans and coordinates stunt sequences";
CREATE role:stunt_performer SET name = "Stunt Performer", description = "Performs stunts";
CREATE role:fight_choreographer SET name = "Fight Choreographer", description = "Choreographs fight sequences";
CREATE role:dance_choreographer SET name = "Dance Choreographer", description = "Choreographs dance sequences";

-- Locations roles
CREATE role:location_manager SET name = "Location Manager", description = "Finds and manages filming locations";
CREATE role:location_scout SET name = "Location Scout", description = "Searches for potential filming locations";
CREATE role:location_assistant SET name = "Location Assistant", description = "Assists with location management";

-- Production Management roles
CREATE role:production_manager SET name = "Production Manager", description = "Manages the production operations";
CREATE role:unit_production_manager SET name = "Unit Production Manager", description = "Manages a specific production unit";
CREATE role:line_producer SET name = "Line Producer", description = "Manages the budget and daily operations";
CREATE role:production_coordinator SET name = "Production Coordinator", description = "Coordinates production logistics";
CREATE role:assistant_production_coordinator SET name = "Assistant Production Coordinator", description = "Assists the production coordinator";

-- Assistant Directing roles
CREATE role:first_assistant_director SET name = "First Assistant Director", description = "Primary assistant to the director";
CREATE role:second_assistant_director SET name = "Second Assistant Director", description = "Assists the first AD and manages background actors";
CREATE role:second_second_assistant_director SET name = "Second Second Assistant Director", description = "Assists the second AD";
CREATE role:script_supervisor SET name = "Script Supervisor", description = "Maintains continuity";
CREATE role:continuity_supervisor SET name = "Continuity Supervisor", description = "Ensures visual continuity between shots";
CREATE role:crowd_ad SET name = "Crowd AD", description = "Directs crowd scenes";

-- Editing roles
CREATE role:editor SET name = "Editor", description = "Edits and assembles footage";
CREATE role:assistant_editor SET name = "Assistant Editor", description = "Assists the editor";
CREATE role:online_editor SET name = "Online Editor", description = "Finalizes the edit for delivery";
CREATE role:colorist SET name = "Colorist", description = "Performs color grading";
CREATE role:color_assistant SET name = "Color Assistant", description = "Assists the colorist";

-- Visual Effects roles
CREATE role:visual_effects_supervisor SET name = "Visual Effects Supervisor", description = "Oversees all visual effects work";
CREATE role:vfx_producer SET name = "VFX Producer", description = "Manages VFX production";
CREATE role:vfx_coordinator SET name = "VFX Coordinator", description = "Coordinates VFX operations";
CREATE role:vfx_artist SET name = "VFX Artist", description = "Creates visual effects";
CREATE role:compositor SET name = "Compositor", description = "Combines visual elements from different sources";
CREATE role:matte_painter SET name = "Matte Painter", description = "Creates digital backgrounds";
CREATE role:rotoscope_artist SET name = "Rotoscope Artist", description = "Traces over footage frame by frame";
CREATE role:motion_graphics_designer SET name = "Motion Graphics Designer", description = "Creates animated graphic design elements";
CREATE role:title_designer SET name = "Title Designer", description = "Designs opening and closing credits";

-- Animation roles
CREATE role:animator SET name = "Animator", description = "Creates animation";
CREATE role:3d_animator SET name = "3D Animator", description = "Creates 3D animation";
CREATE role:2d_animator SET name = "2D Animator", description = "Creates 2D animation";
CREATE role:animation_director SET name = "Animation Director", description = "Directs the animation process";
CREATE role:animation_supervisor SET name = "Animation Supervisor", description = "Supervises the animation team";
CREATE role:rigging_artist SET name = "Rigging Artist", description = "Creates character rigs for animation";
CREATE role:texture_artist SET name = "Texture Artist", description = "Creates textures for 3D models";
CREATE role:lighting_artist SET name = "Lighting Artist", description = "Creates lighting for 3D scenes";
CREATE role:render_wrangler SET name = "Render Wrangler", description = "Manages the rendering process";
CREATE role:background_artist SET name = "Background Artist", description = "Creates backgrounds for animation";
CREATE role:storyboard_revisionist SET name = "Storyboard Revisionist", description = "Revises storyboards";
CREATE role:stop_motion_animator SET name = "Stop-Motion Animator", description = "Creates stop-motion animation";

-- Character Designer in Explosion department
CREATE role:character_designer SET name = "Character Designer", description = "Designs characters for animation";

-- Music roles
CREATE role:composer SET name = "Composer", description = "Creates original music";
CREATE role:music_supervisor SET name = "Music Supervisor", description = "Oversees all music aspects";
CREATE role:music_editor SET name = "Music Editor", description = "Edits and places music in the production";
CREATE role:score_coordinator SET name = "Score Coordinator", description = "Coordinates orchestral recordings";

-- Sound Post-Production roles
CREATE role:sound_editor SET name = "Sound Editor", description = "Edits sound elements";
CREATE role:dialogue_editor SET name = "Dialogue Editor", description = "Edits dialogue recordings";
CREATE role:sound_effects_editor SET name = "Sound Effects Editor", description = "Edits sound effects";
CREATE role:foley_artist SET name = "Foley Artist", description = "Creates custom sound effects";
CREATE role:foley_mixer SET name = "Foley Mixer", description = "Records foley performances";
CREATE role:re_recording_mixer SET name = "Re-recording Mixer", description = "Mixes final audio track";
CREATE role:adr_supervisor SET name = "ADR Supervisor", description = "Supervises automated dialogue replacement";
CREATE role:adr_mixer SET name = "ADR Mixer", description = "Records ADR sessions";
CREATE role:dubbing_director SET name = "Dubbing Director", description = "Directs voice actors for foreign language versions";

-- Marketing roles
CREATE role:marketing_manager SET name = "Marketing Manager", description = "Manages marketing campaigns";
CREATE role:graphic_designer SET name = "Graphic Designer", description = "Creates graphic design materials";
CREATE role:poster_designer SET name = "Poster Designer", description = "Designs promotional posters";
CREATE role:trailer_editor SET name = "Trailer Editor", description = "Edits promotional trailers";
CREATE role:promotional_video_editor SET name = "Promotional Video Editor", description = "Edits promotional videos";
CREATE role:media_buyer SET name = "Media Buyer", description = "Purchases advertising space";
CREATE role:advertising_coordinator SET name = "Advertising Coordinator", description = "Coordinates advertising campaigns";
CREATE role:product_placement_coordinator SET name = "Product Placement Coordinator", description = "Manages product placement deals";
CREATE role:brand_integration_specialist SET name = "Brand Integration Specialist", description = "Integrates brands into content";
CREATE role:merchandise_coordinator SET name = "Merchandise Coordinator", description = "Manages merchandise production and sales";

-- Publicity roles
CREATE role:publicity_manager SET name = "Publicity Manager", description = "Manages publicity efforts";
CREATE role:film_publicist SET name = "Film Publicist", description = "Generates publicity for films";
CREATE role:pr_coordinator SET name = "PR Coordinator", description = "Coordinates public relations activities";

-- Social Media roles
CREATE role:social_media_manager SET name = "Social Media Manager", description = "Manages social media presence";
CREATE role:digital_content_strategist SET name = "Digital Content Strategist", description = "Develops digital content strategy";
CREATE role:content_creator SET name = "Content Creator", description = "Creates content for digital platforms";
CREATE role:community_manager SET name = "Community Manager", description = "Manages online communities";
CREATE role:influencer_manager SET name = "Influencer Manager", description = "Manages relationships with influencers";
CREATE role:data_analyst SET name = "Data Analyst", description = "Analyzes performance data";
CREATE role:seo_specialist SET name = "SEO Specialist", description = "Optimizes content for search engines";
CREATE role:fan_engagement_coordinator SET name = "Fan Engagement Coordinator", description = "Creates fan engagement strategies";
CREATE role:website_developer SET name = "Website Developer", description = "Develops promotional websites";
CREATE role:app_developer SET name = "App Developer", description = "Develops promotional apps";

-- Distribution/Sales roles
CREATE role:distribution_manager SET name = "Distribution Manager", description = "Manages content distribution";
CREATE role:sales_agent SET name = "Sales Agent", description = "Sells content rights";
CREATE role:international_sales_agent SET name = "International Sales Agent", description = "Sells content rights internationally";
CREATE role:film_sales_executive SET name = "Film Sales Executive", description = "Executes film sales strategies";
CREATE role:acquisitions_executive SET name = "Acquisitions Executive", description = "Acquires content for distribution";
CREATE role:festival_programmer SET name = "Festival Programmer", description = "Selects films for festivals";
CREATE role:film_programmer SET name = "Film Programmer", description = "Programs film screenings";

-- BTS roles
CREATE role:bts_director SET name = "BTS Director", description = "Directs behind-the-scenes content";
CREATE role:bts_videographer SET name = "BTS Videographer", description = "Films behind-the-scenes content";
CREATE role:bts_photographer SET name = "BTS Photographer", description = "Photographs behind-the-scenes";
CREATE role:bts_editor SET name = "BTS Editor", description = "Edits behind-the-scenes content";
CREATE role:bts_producer SET name = "BTS Producer", description = "Produces behind-the-scenes content";
CREATE role:still_photographer SET name = "Still Photographer", description = "Takes production stills";
CREATE role:epk_producer SET name = "EPK Producer", description = "Produces electronic press kits";

-- Talent Representation roles
CREATE role:talent_agent SET name = "Talent Agent", description = "Represents talent to employers";
CREATE role:manager SET name = "Manager", description = "Manages talent careers";
CREATE role:booking_agent SET name = "Booking Agent", description = "Books appearances for talent";

-- Post-Production Coordination roles
CREATE role:subtitler SET name = "Subtitler", description = "Creates subtitles";
CREATE role:captioner SET name = "Captioner", description = "Creates captions";
CREATE role:quality_control_technician SET name = "Quality Control Technician", description = "Performs quality control checks";
CREATE role:delivery_coordinator SET name = "Delivery Coordinator", description = "Coordinates content delivery";
CREATE role:archivist SET name = "Archivist", description = "Manages content archives";
CREATE role:post_production_supervisor SET name = "Post-Production Supervisor", description = "Supervises post-production";
CREATE role:post_production_coordinator SET name = "Post-Production Coordinator", description = "Coordinates post-production";
CREATE role:transcriptionist SET name = "Transcriptionist", description = "Creates transcripts";
CREATE role:localization_manager SET name = "Localization Manager", description = "Manages content localization";

-- Legal/Clearances roles
CREATE role:legal_counsel SET name = "Legal Counsel", description = "Provides legal advice";
CREATE role:clearances_coordinator SET name = "Clearances Coordinator", description = "Obtains clearances for content use";
CREATE role:music_clearances_specialist SET name = "Music Clearances Specialist", description = "Obtains music clearances";

-- Accounting roles
CREATE role:production_accountant SET name = "Production Accountant", description = "Manages production finances";
CREATE role:payroll_accountant SET name = "Payroll Accountant", description = "Manages production payroll";
CREATE role:accounting_clerk SET name = "Accounting Clerk", description = "Assists with accounting tasks";

-- Transportation roles
CREATE role:transportation_coordinator SET name = "Transportation Coordinator", description = "Coordinates transportation";
CREATE role:transportation_captain SET name = "Transportation Captain", description = "Manages transportation crew";
CREATE role:driver SET name = "Driver", description = "Drives production vehicles";

-- Craft/Catering roles
CREATE role:craft_services SET name = "Craft Services", description = "Provides food and beverages on set";
CREATE role:catering_coordinator SET name = "Catering Coordinator", description = "Coordinates catering services";

-- Safety/Medical roles
CREATE role:on_set_medic SET name = "On-Set Medic", description = "Provides medical assistance on set";
CREATE role:safety_coordinator SET name = "Safety Coordinator", description = "Ensures set safety";

-- Miscellaneous roles
CREATE role:animal_wrangler SET name = "Animal Wrangler", description = "Handles animals on set";
CREATE role:child_actor_supervisor SET name = "Child Actor Supervisor", description = "Supervises child actors";
CREATE role:audience_coordinator SET name = "Audience Coordinator", description = "Coordinates studio audiences";
CREATE role:warm_up_comedian SET name = "Warm-Up Comedian", description = "Entertains studio audiences";
CREATE role:technical_director SET name = "Technical Director", description = "Directs technical aspects of production";
CREATE role:broadcast_engineer SET name = "Broadcast Engineer", description = "Manages broadcast equipment";
CREATE role:playback_operator SET name = "Playback Operator", description = "Operates playback for set";
CREATE role:teleprompter_operator SET name = "Teleprompter Operator", description = "Operates teleprompter";
CREATE role:studio_teacher SET name = "Studio Teacher", description = "Teaches child actors on set";
CREATE role:intimacy_coordinator SET name = "Intimacy Coordinator", description = "Coordinates intimate scenes";
CREATE role:sustainability_coordinator SET name = "Sustainability Coordinator", description = "Ensures sustainable practices";
CREATE role:armorer SET name = "Armorer", description = "Manages firearms on set";

-- Special Effects roles
CREATE role:pyrotechnician SET name = "Pyrotechnician", description = "Manages pyrotechnic effects";
CREATE role:special_effects_coordinator SET name = "Special Effects Coordinator", description = "Coordinates special effects";
CREATE role:special_effects_technician SET name = "Special Effects Technician", description = "Operates special effects";
CREATE role:model_maker SET name = "Model Maker", description = "Creates physical models";
CREATE role:puppeteer SET name = "Puppeteer", description = "Operates puppets";

-- Create relationships between roles and departments
RELATE role:creative_director->belongs_to_department->department:directing;
RELATE role:director->belongs_to_department->department:directing;

RELATE role:producer->belongs_to_department->department:producing;
RELATE role:executive_producer->belongs_to_department->department:producing;
RELATE role:co_concurrent_producer->belongs_to_department->department:producing;
RELATE role:associate_producer->belongs_to_department->department:producing;
RELATE role:supervising_producer->belongs_to_department->department:producing;
RELATE role:segment_producer->belongs_to_department->department:producing;
RELATE role:showrunner->belongs_to_department->department:producing;
RELATE role:development_executive->belongs_to_department->department:producing;

RELATE role:screenwriter->belongs_to_department->department:writing;
RELATE role:script_consultant->belongs_to_department->department:writing;
RELATE role:story_editor->belongs_to_department->department:writing;
RELATE role:script_coordinator->belongs_to_department->department:writing;

RELATE role:storyboard_artist->belongs_to_department->department:art;
RELATE role:concept_artist->belongs_to_department->department:art;
RELATE role:visual_development_artist->belongs_to_department->department:art;
RELATE role:production_designer->belongs_to_department->department:art;
RELATE role:art_director->belongs_to_department->department:art;
RELATE role:assistant_art_director->belongs_to_department->department:art;
RELATE role:set_designer->belongs_to_department->department:art;
RELATE role:set_decorator->belongs_to_department->department:art;
RELATE role:prop_master->belongs_to_department->department:art;
RELATE role:assistant_prop_master->belongs_to_department->department:art;
RELATE role:prop_fabricator->belongs_to_department->department:art;
RELATE role:leadman->belongs_to_department->department:art;
RELATE role:set_dresser->belongs_to_department->department:art;
RELATE role:scenic_artist->belongs_to_department->department:art;
RELATE role:greensman->belongs_to_department->department:art;

RELATE role:cinematographer->belongs_to_department->department:cinematography;
RELATE role:director_of_photography->belongs_to_department->department:cinematography;
RELATE role:camera_operator->belongs_to_department->department:cinematography;
RELATE role:first_assistant_camera->belongs_to_department->department:cinematography;
RELATE role:second_assistant_camera->belongs_to_department->department:cinematography;
RELATE role:camera_loader->belongs_to_department->department:cinematography;
RELATE role:steadicam_operator->belongs_to_department->department:cinematography;
RELATE role:drone_operator->belongs_to_department->department:cinematography;
RELATE role:gaffer->belongs_to_department->department:cinematography;
RELATE role:best_boy_electric->belongs_to_department->department:cinematography;
RELATE role:lighting_technician->belongs_to_department->department:cinematography;
RELATE role:key_grip->belongs_to_department->department:cinematography;
RELATE role:best_boy_grip->belongs_to_department->department:cinematography;
RELATE role:dolly_grip->belongs_to_department->department:cinematography;
RELATE role:rigging_grip->belongs_to_department->department:cinematography;
RELATE role:video_assist_operator->belongs_to_department->department:cinematography;
RELATE role:dit->belongs_to_department->department:cinematography;
RELATE role:data_wrangler->belongs_to_department->department:cinematography;

-- Sound department relationships
RELATE role:sound_designer->belongs_to_department->department:sound;
RELATE role:production_sound_mixer->belongs_to_department->department:sound;
RELATE role:boom_operator->belongs_to_department->department:sound;
RELATE role:utility_sound_technician->belongs_to_department->department:sound;
RELATE role:sound_assistant->belongs_to_department->department:sound;

-- Costume department relationships
RELATE role:costume_designer->belongs_to_department->department:costume;
RELATE role:costume_supervisor->belongs_to_department->department:costume;
RELATE role:wardrobe_stylist->belongs_to_department->department:costume;
RELATE role:costume_assistant->belongs_to_department->department:costume;
RELATE role:seamstress->belongs_to_department->department:costume;

-- Makeup/Hair department relationships
RELATE role:makeup_artist->belongs_to_department->department:makeup_hair;
RELATE role:special_effects_makeup_artist->belongs_to_department->department:makeup_hair;
RELATE role:prosthetics_designer->belongs_to_department->department:makeup_hair;
RELATE role:hair_stylist->belongs_to_department->department:makeup_hair;
RELATE role:hair_assistant->belongs_to_department->department:makeup_hair;

-- Casting department relationships
RELATE role:casting_director->belongs_to_department->department:casting;
RELATE role:casting_associate->belongs_to_department->department:casting;

-- Acting department relationships
RELATE role:actor->belongs_to_department->department:acting;
RELATE role:background_actor->belongs_to_department->department:acting;
RELATE role:voice_actor->belongs_to_department->department:acting;

-- Stunts/Choreography department relationships
RELATE role:stunt_coordinator->belongs_to_department->department:stunts_choreography;
RELATE role:stunt_performer->belongs_to_department->department:stunts_choreography;
RELATE role:fight_choreographer->belongs_to_department->department:stunts_choreography;
RELATE role:dance_choreographer->belongs_to_department->department:stunts_choreography;

-- Locations department relationships
RELATE role:location_manager->belongs_to_department->department:locations;
RELATE role:location_scout->belongs_to_department->department:locations;
RELATE role:location_assistant->belongs_to_department->department:locations;

-- Production Management department relationships
RELATE role:production_manager->belongs_to_department->department:production_management;
RELATE role:unit_production_manager->belongs_to_department->department:production_management;
RELATE role:line_producer->belongs_to_department->department:production_management;
RELATE role:production_coordinator->belongs_to_department->department:production_management;
RELATE role:assistant_production_coordinator->belongs_to_department->department:production_management;

-- Assistant Directing department relationships
RELATE role:first_assistant_director->belongs_to_department->department:assistant_directing;
RELATE role:second_assistant_director->belongs_to_department->department:assistant_directing;
RELATE role:second_second_assistant_director->belongs_to_department->department:assistant_directing;
RELATE role:script_supervisor->belongs_to_department->department:assistant_directing;
RELATE role:continuity_supervisor->belongs_to_department->department:assistant_directing;
RELATE role:crowd_ad->belongs_to_department->department:assistant_directing;

-- Editing department relationships
RELATE role:editor->belongs_to_department->department:editing;
RELATE role:assistant_editor->belongs_to_department->department:editing;
RELATE role:online_editor->belongs_to_department->department:editing;
RELATE role:colorist->belongs_to_department->department:editing;
RELATE role:color_assistant->belongs_to_department->department:editing;

-- Visual Effects department relationships
RELATE role:visual_effects_supervisor->belongs_to_department->department:visual_effects;
RELATE role:vfx_producer->belongs_to_department->department:visual_effects;
RELATE role:vfx_coordinator->belongs_to_department->department:visual_effects;
RELATE role:vfx_artist->belongs_to_department->department:visual_effects;
RELATE role:compositor->belongs_to_department->department:visual_effects;
RELATE role:matte_painter->belongs_to_department->department:visual_effects;
RELATE role:rotoscope_artist->belongs_to_department->department:visual_effects;
RELATE role:motion_graphics_designer->belongs_to_department->department:visual_effects;
RELATE role:title_designer->belongs_to_department->department:visual_effects;

-- Animation department relationships
RELATE role:animator->belongs_to_department->department:animation;
RELATE role:3d_animator->belongs_to_department->department:animation;
RELATE role:2d_animator->belongs_to_department->department:animation;
RELATE role:animation_director->belongs_to_department->department:animation;
RELATE role:animation_supervisor->belongs_to_department->department:animation;
RELATE role:rigging_artist->belongs_to_department->department:animation;
RELATE role:texture_artist->belongs_to_department->department:animation;
RELATE role:lighting_artist->belongs_to_department->department:animation;
RELATE role:render_wrangler->belongs_to_department->department:animation;
RELATE role:background_artist->belongs_to_department->department:animation;
RELATE role:storyboard_revisionist->belongs_to_department->department:animation;
RELATE role:stop_motion_animator->belongs_to_department->department:animation;

-- Character Designer in Explosion department
RELATE role:character_designer->belongs_to_department->department:explosion;

-- Music department relationships
RELATE role:composer->belongs_to_department->department:music;
RELATE role:music_supervisor->belongs_to_department->department:music;
RELATE role:music_editor->belongs_to_department->department:music;
RELATE role:score_coordinator->belongs_to_department->department:music;

-- Sound Post-Production department relationships
RELATE role:sound_editor->belongs_to_department->department:sound_post_production;
RELATE role:dialogue_editor->belongs_to_department->department:sound_post_production;
RELATE role:sound_effects_editor->belongs_to_department->department:sound_post_production;
RELATE role:foley_artist->belongs_to_department->department:sound_post_production;
RELATE role:foley_mixer->belongs_to_department->department:sound_post_production;
RELATE role:re_recording_mixer->belongs_to_department->department:sound_post_production;
RELATE role:adr_supervisor->belongs_to_department->department:sound_post_production;
RELATE role:adr_mixer->belongs_to_department->department:sound_post_production;
RELATE role:dubbing_director->belongs_to_department->department:sound_post_production;

-- Marketing department relationships
RELATE role:marketing_manager->belongs_to_department->department:marketing;
RELATE role:graphic_designer->belongs_to_department->department:marketing;
RELATE role:poster_designer->belongs_to_department->department:marketing;
RELATE role:trailer_editor->belongs_to_department->department:marketing;
RELATE role:promotional_video_editor->belongs_to_department->department:marketing;
RELATE role:media_buyer->belongs_to_department->department:marketing;
RELATE role:advertising_coordinator->belongs_to_department->department:marketing;
RELATE role:product_placement_coordinator->belongs_to_department->department:marketing;
RELATE role:brand_integration_specialist->belongs_to_department->department:marketing;
RELATE role:merchandise_coordinator->belongs_to_department->department:marketing;

-- Publicity department relationships
RELATE role:publicity_manager->belongs_to_department->department:publicity;
RELATE role:film_publicist->belongs_to_department->department:publicity;
RELATE role:pr_coordinator->belongs_to_department->department:publicity;

-- Social Media department relationships
RELATE role:social_media_manager->belongs_to_department->department:social_media;
RELATE role:digital_content_strategist->belongs_to_department->department:social_media;
RELATE role:content_creator->belongs_to_department->department:social_media;
RELATE role:community_manager->belongs_to_department->department:social_media;
RELATE role:influencer_manager->belongs_to_department->department:social_media;
RELATE role:data_analyst->belongs_to_department->department:social_media;
RELATE role:seo_specialist->belongs_to_department->department:social_media;
RELATE role:fan_engagement_coordinator->belongs_to_department->department:social_media;
RELATE role:website_developer->belongs_to_department->department:social_media;
RELATE role:app_developer->belongs_to_department->department:social_media;

-- Distribution/Sales department relationships
RELATE role:distribution_manager->belongs_to_department->department:distribution_sales;
RELATE role:sales_agent->belongs_to_department->department:distribution_sales;
RELATE role:international_sales_agent->belongs_to_department->department:distribution_sales;
RELATE role:film_sales_executive->belongs_to_department->department:distribution_sales;
RELATE role:acquisitions_executive->belongs_to_department->department:distribution_sales;
RELATE role:festival_programmer->belongs_to_department->department:distribution_sales;
RELATE role:film_programmer->belongs_to_department->department:distribution_sales;

-- BTS department relationships
RELATE role:bts_director->belongs_to_department->department:bts;
RELATE role:bts_videographer->belongs_to_department->department:bts;
RELATE role:bts_photographer->belongs_to_department->department:bts;
RELATE role:bts_editor->belongs_to_department->department:bts;
RELATE role:bts_producer->belongs_to_department->department:bts;
RELATE role:still_photographer->belongs_to_department->department:bts;
RELATE role:epk_producer->belongs_to_department->department:bts;

-- Talent Representation department relationships
RELATE role:talent_agent->belongs_to_department->department:talent_representation;
RELATE role:manager->belongs_to_department->department:talent_representation;
RELATE role:booking_agent->belongs_to_department->department:talent_representation;

-- Post-Production Coordination department relationships
RELATE role:subtitler->belongs_to_department->department:post_production_coordination;
RELATE role:captioner->belongs_to_department->department:post_production_coordination;
RELATE role:quality_control_technician->belongs_to_department->department:post_production_coordination;
RELATE role:delivery_coordinator->belongs_to_department->department:post_production_coordination;
RELATE role:archivist->belongs_to_department->department:post_production_coordination;
RELATE role:post_production_supervisor->belongs_to_department->department:post_production_coordination;
RELATE role:post_production_coordinator->belongs_to_department->department:post_production_coordination;
RELATE role:transcriptionist->belongs_to_department->department:post_production_coordination;
RELATE role:localization_manager->belongs_to_department->department:post_production_coordination;

-- Legal/Clearances department relationships
RELATE role:legal_counsel->belongs_to_department->department:legal_clearances;
RELATE role:clearances_coordinator->belongs_to_department->department:legal_clearances;
RELATE role:music_clearances_specialist->belongs_to_department->department:legal_clearances;

-- Accounting department relationships
RELATE role:production_accountant->belongs_to_department->department:accounting;
RELATE role:payroll_accountant->belongs_to_department->department:accounting;
RELATE role:accounting_clerk->belongs_to_department->department:accounting;

-- Transportation department relationships
RELATE role:transportation_coordinator->belongs_to_department->department:transportation;
RELATE role:transportation_captain->belongs_to_department->department:transportation;
RELATE role:driver->belongs_to_department->department:transportation;

-- Craft/Catering department relationships
RELATE role:craft_services->belongs_to_department->department:craft_catering;
RELATE role:catering_coordinator->belongs_to_department->department:craft_catering;

-- Safety/Medical department relationships
RELATE role:on_set_medic->belongs_to_department->department:safety_medical;
RELATE role:safety_coordinator->belongs_to_department->department:safety_medical;

-- Miscellaneous department relationships
RELATE role:animal_wrangler->belongs_to_department->department:miscellaneous;
RELATE role:child_actor_supervisor->belongs_to_department->department:miscellaneous;
RELATE role:audience_coordinator->belongs_to_department->department:miscellaneous;
RELATE role:warm_up_comedian->belongs_to_department->department:miscellaneous;
RELATE role:technical_director->belongs_to_department->department:miscellaneous;
RELATE role:broadcast_engineer->belongs_to_department->department:miscellaneous;
RELATE role:playback_operator->belongs_to_department->department:miscellaneous;
RELATE role:teleprompter_operator->belongs_to_department->department:miscellaneous;
RELATE role:studio_teacher->belongs_to_department->department:miscellaneous;
RELATE role:intimacy_coordinator->belongs_to_department->department:miscellaneous;
RELATE role:sustainability_coordinator->belongs_to_department->department:miscellaneous;
RELATE role:armorer->belongs_to_department->department:miscellaneous;

-- Special Effects department relationships
RELATE role:pyrotechnician->belongs_to_department->department:special_effects;
RELATE role:special_effects_coordinator->belongs_to_department->department:special_effects;
RELATE role:special_effects_technician->belongs_to_department->department:special_effects;
RELATE role:model_maker->belongs_to_department->department:special_effects;
RELATE role:puppeteer->belongs_to_department->department:special_effects;