-- =============================================================================
-- SlateHub SurrealDB Schema v2.0
-- A single, comprehensive schema file for the media production platform.
--
-- Key Changes in v2.0:
-- - A project can now be owned by either a `person` or an `org`.
-- - A `contributes` edge defines a person's role on a project,
--   with distinct platform roles (admin, crew, cast) for permissions.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Section 1: Database and Namespace Initialization
-- -----------------------------------------------------------------------------

DEFINE DATABASE slatehub;
USE NS production;
USE DB slatehub;

-- -----------------------------------------------------------------------------
-- Section 2: Authentication Scope
-- -----------------------------------------------------------------------------
-- Defines user signup and signin logic.

DEFINE SCOPE session_scope
    SESSION 7d
    SIGNUP (
        CREATE person SET
            email = $email,
            username = string::lowercase($username),
            pass = crypto::argon2::generate($pass),
            created_at = time::now(),
            updated_at = time::now()
    )
    SIGNIN (
        SELECT * FROM person WHERE username = string::lowercase($username) AND crypto::argon2::compare(pass, $pass)
    );

-- -----------------------------------------------------------------------------
-- Section 3: Taxonomy and Seeded Data Tables
-- -----------------------------------------------------------------------------
-- These tables provide controlled vocabularies for data consistency.

-- A list of reserved usernames to prevent conflicts.
DEFINE TABLE username_blacklist SCHEMAFULL;
DEFINE FIELD name ON TABLE username_blacklist TYPE string;
DEFINE INDEX unique_name ON TABLE username_blacklist COLUMNS name UNIQUE;

-- A comprehensive list of production and post-production roles.
DEFINE TABLE crew_role SCHEMAFULL;
DEFINE FIELD name ON TABLE crew_role TYPE string;
DEFINE FIELD department ON TABLE crew_role TYPE option<string>;
DEFINE INDEX unique_role_name ON TABLE crew_role COLUMNS name UNIQUE;

-- A list of organization types.
DEFINE TABLE organization_type SCHEMAFULL;
DEFINE FIELD name ON TABLE organization_type TYPE string;
DEFINE INDEX unique_org_type_name ON TABLE organization_type COLUMNS name UNIQUE;


-- -----------------------------------------------------------------------------
-- Section 4: Core Entity Tables (The Nodes)
-- -----------------------------------------------------------------------------

-- The `person` table represents an individual user of the platform.
DEFINE TABLE person SCHEMAFULL
    PERMISSIONS
        FOR select WHERE is_public = true OR id = $scope.id
        FOR create NONE -- Handled by SIGNUP scope
        FOR update, delete WHERE id = $scope.id;

DEFINE FIELD pass ON TABLE person TYPE string;
DEFINE FIELD email ON TABLE person TYPE string ASSERT string::is::email($value);
DEFINE FIELD username ON TABLE person TYPE string
    ASSERT $value != NONE AND (SELECT count() FROM username_blacklist WHERE name = $value) = 0;
DEFINE INDEX unique_email ON TABLE person COLUMNS email UNIQUE;
DEFINE INDEX unique_username ON TABLE person COLUMNS username UNIQUE;
DEFINE FIELD first_name ON TABLE person TYPE option<string>;
DEFINE FIELD last_name ON TABLE person TYPE option<string>;
DEFINE FIELD headline ON TABLE person TYPE option<string>;
DEFINE FIELD summary ON TABLE person TYPE option<text>;
DEFINE FIELD location ON TABLE person TYPE option<string>;
DEFINE FIELD is_public ON TABLE person TYPE bool DEFAULT true;
DEFINE FIELD created_at ON TABLE person TYPE datetime VALUE $before OR time::now();
DEFINE FIELD updated_at ON TABLE person TYPE datetime VALUE time::now();

-- The `organization` table represents a company or group.
DEFINE TABLE organization SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create WHERE $scope.id != NONE
        FOR update WHERE
            -- The person who owns the org can update it.
            owner = $scope.id OR
            -- An admin of the org can update it.
            $scope.id IN (<-manages[WHERE role = 'admin'].in FROM id)
        FOR delete WHERE owner = $scope.id;

DEFINE FIELD name ON TABLE organization TYPE string;
DEFINE FIELD username ON TABLE organization TYPE string
    ASSERT $value != NONE AND (SELECT count() FROM username_blacklist WHERE name = $value) = 0;
DEFINE INDEX unique_org_username ON TABLE organization COLUMNS username UNIQUE;
DEFINE FIELD description ON TABLE organization TYPE option<text>;
DEFINE FIELD website ON TABLE organization TYPE option<string> ASSERT $value == NONE OR string::is::url($value);
DEFINE FIELD owner ON TABLE organization TYPE record<person>;
DEFINE FIELD org_type ON TABLE organization TYPE record<organization_type>;
DEFINE FIELD created_at ON TABLE organization TYPE datetime VALUE $before OR time::now();
DEFINE FIELD updated_at ON TABLE organization TYPE datetime VALUE time::now();

-- The `project` table is the central hub for a creative work.
DEFINE TABLE project SCHEMAFULL
    PERMISSIONS
        FOR select FULL
        FOR create WHERE $scope.id != NONE
        FOR update WHERE
            -- If owner is a person, they can update.
            owner = $scope.id OR
            -- If owner is an org, the org's owner can update.
            (SELECT VALUE owner FROM owner WHERE meta::tb(owner) = 'organization' AND owner = $scope.id) OR
            -- A person who is an 'admin' on the project can update.
            $scope.id IN (<-contributes[WHERE platform_role = 'admin'].in FROM id)
        FOR delete WHERE
            owner = $scope.id OR
            (SELECT VALUE owner FROM owner WHERE meta::tb(owner) = 'organization' AND owner = $scope.id);

DEFINE FIELD title ON TABLE project TYPE string;
DEFINE FIELD logline ON TABLE project TYPE option<string>;
DEFINE FIELD status ON TABLE project TYPE string
    ASSERT $value IN ['IN_DEVELOPMENT', 'PRE_PRODUCTION', 'PRODUCTION', 'POST_PRODUCTION', 'RELEASED', 'CANCELED']
    DEFAULT 'IN_DEVELOPMENT';
-- A project can be owned by a person OR an organization.
DEFINE FIELD owner ON TABLE project TYPE record<person | organization>;
DEFINE FIELD created_at ON TABLE project TYPE datetime VALUE $before OR time::now();
DEFINE FIELD updated_at ON TABLE project TYPE datetime VALUE time::now();


-- -----------------------------------------------------------------------------
-- Section 5: Graph Relationship Tables (The Edges)
-- -----------------------------------------------------------------------------

-- Defines a person's membership and role within an organization.
DEFINE TABLE manages SCHEMAFULL;
DEFINE FIELD in ON TABLE manages TYPE record<person>;
DEFINE FIELD out ON TABLE manages TYPE record<organization>;
DEFINE FIELD role ON TABLE manages TYPE string ASSERT $value IN ['admin', 'member', 'client'] DEFAULT 'member';
DEFINE FIELD created_at ON TABLE manages TYPE datetime VALUE time::now();
DEFINE INDEX person_org_role ON TABLE manages COLUMNS in, out, role UNIQUE;

-- Defines a person's contribution and role on a project.
DEFINE TABLE contributes SCHEMAFULL;
DEFINE FIELD in ON TABLE contributes TYPE record<person>;
DEFINE FIELD out ON TABLE contributes TYPE record<project>;
-- The platform-level role (for permissions).
DEFINE FIELD platform_role ON TABLE contributes TYPE string ASSERT $value IN ['admin', 'crew', 'cast', 'member'] DEFAULT 'member';
-- The specific job role on the project (e.g., Director, Actor).
DEFINE FIELD job_role ON TABLE contributes TYPE record<crew_role>;
DEFINE FIELD created_at ON TABLE contributes TYPE datetime VALUE time::now();
DEFINE INDEX contributor_project_role ON TABLE contributes COLUMNS in, out, job_role UNIQUE;


-- -----------------------------------------------------------------------------
-- Section 6: Database Events & Data Seeding
-- -----------------------------------------------------------------------------

-- Event to lowercase usernames on creation for consistency.
DEFINE EVENT lowercase_person_username ON TABLE person WHEN $event = "CREATE" THEN {
    UPDATE $after.id SET username = string::lowercase($after.username);
};
DEFINE EVENT lowercase_org_username ON TABLE organization WHEN $event = "CREATE" THEN {
    UPDATE $after.id SET username = string::lowercase($after.username);
};

-- Seed the username blacklist with common reserved words.
INSERT INTO username_blacklist (name) VALUES
    ('about'), ('abuse'), ('account'), ('admin'), ('api'), ('app'), ('assets'), ('auth'),
    ('billing'), ('blog'), ('bot'), ('careers'), ('cdn'), ('contact'), ('dashboard'),
    ('dev'), ('docs'), ('download'), ('email'), ('faq'), ('feedback'), ('files'), ('forum'),
    ('help'), ('home'), ('http'), ('https'), ('images'), ('info'), ('jobs'), ('legal'),
    ('login'), ('logout'), ('media'), ('new'), ('news'), ('notifications'), ('org'),
    ('pages'), ('password'), ('pricing'), ('privacy'), ('profile'), ('project'), ('public'),
    ('register'), ('search'), ('security'), ('settings'), ('signin'), ('signup'), ('site'),
    ('status'), ('store'), ('support'), ('system'), ('team'), ('terms'), ('user'), ('users');

-- Seed the production roles.
INSERT INTO crew_role (id, name, department) VALUES
    (crew_role:producer, 'Producer', 'Production'),
    (crew_role:director, 'Director', "Director's Team"),
    (crew_role:screenwriter, 'Screenwriter', 'Script'),
    (crew_role:dp, 'Director of Photography', 'Camera'),
    (crew_role:camera_operator, 'Camera Operator', 'Camera'),
    (crew_role:gaffer, 'Gaffer', 'Electric'),
    (crew_role:key_grip, 'Key Grip', 'Grip'),
    (crew_role:sound_mixer, 'Production Sound Mixer', 'Sound'),
    (crew_role:editor, 'Editor', 'Post-Production'),
    (crew_role:colorist, 'Colorist', 'Post-Production'),
    (crew_role:sound_designer, 'Sound Designer', 'Post-Production'),
    (crew_role:vfx_supervisor, 'VFX Supervisor', 'VFX'),
    (crew_role:actor, 'Actor', 'Cast'),
    (crew_role:voice_actor, 'Voice Actor', 'Cast'),
    (crew_role:stunt_coordinator, 'Stunt Coordinator', 'Stunts'),
    (crew_role:production_designer, 'Production Designer', 'Art Department');

-- Seed the organization types.
INSERT INTO organization_type (name) VALUES
    ('Production Company'), ('Studio'), ('Talent Agency'), ('Casting Agency'),
    ('Equipment Vendor'), ('Post-Production House'), ('Distributor');
