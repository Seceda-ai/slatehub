USE NS seceda DB core;

-- 🔐 ACCESS METHOD FOR PERSON SIGNUP & SIGNIN
DEFINE ACCESS user_access ON DATABASE TYPE RECORD
  SIGNUP (
    CREATE person SET
      username    = string::lowercase($username),
      password    = crypto::argon2::generate($password),
      email       = string::lowercase($email),
      global_role = "user"
  )
  SIGNIN (
    SELECT * FROM person
    WHERE username = string::lowercase($username)
      AND crypto::argon2::compare(password, $password)
  )
  DURATION FOR TOKEN 15m, FOR SESSION 14d;

-- PERSON TABLE
DEFINE TABLE person SCHEMAFULL
  PERMISSIONS
    FOR select, update WHERE id = $auth.id OR $auth.global_role = "admin",
    FOR delete           WHERE $auth.global_role = "admin",
    FOR create NONE;

DEFINE FIELD username ON person TYPE string
  VALUE  string::lowercase($value)
  ASSERT $value = /^[a-z0-9_-]+$/ AND string::len($value) >= 3;

DEFINE FIELD password ON person TYPE string;

DEFINE FIELD email ON person TYPE string
  VALUE  string::lowercase($value)
  ASSERT string::is::email($value);

  --TODO SET PERMS
DEFINE FIELD global_role ON person TYPE string
  VALUE  $value ?? "user"
  ASSERT $value IN ["admin","user"];

  DEFINE FIELD created_at ON person TYPE datetime
      VALUE time::now() READONLY;

  DEFINE FIELD updated_at ON person TYPE datetime
      VALUE time::now()
      DEFAULT ALWAYS time::now();

DEFINE INDEX idx_person_username ON person COLUMNS username UNIQUE;
DEFINE INDEX idx_person_email    ON person COLUMNS email    UNIQUE;

-- ORGANIZATION TABLE
-- add persmissions
DEFINE TABLE organization SCHEMAFULL
   PERMISSIONS
     FOR select, create WHERE $auth is not none;

DEFINE FIELD name       ON organization TYPE string
  ASSERT $value != "";

DEFINE FIELD slug       ON organization TYPE string
  VALUE  string::slug(name)
  DEFAULT string::slug(name);

DEFINE FIELD created_at ON organization TYPE datetime
    VALUE time::now() READONLY;

DEFINE FIELD updated_at ON organization TYPE datetime
    VALUE time::now()
    DEFAULT ALWAYS time::now();

DEFINE INDEX idx_organization_slug ON organization COLUMNS slug UNIQUE;

-- PROJECT TABLE
DEFINE TABLE production SCHEMAFULL;

DEFINE FIELD title             ON production TYPE string
  ASSERT $value != "";

DEFINE FIELD slug             ON production TYPE string
  VALUE  string::slug(title)
  DEFAULT string::slug(title);

  DEFINE FIELD created_at ON production TYPE datetime
      VALUE time::now() READONLY;

  DEFINE FIELD updated_at ON production TYPE datetime
      VALUE time::now()
      DEFAULT ALWAYS time::now();

-- Unique slug per organization
DEFINE INDEX idx_production_org_slug ON production COLUMNS slug UNIQUE;

-- Define membership edge table
-- TODO Add Persmissions
DEFINE TABLE membership SCHEMAFULL TYPE RELATION FROM person|organization TO organization|production
PERMISSIONS
  FOR select, create WHERE $auth is not none;
DEFINE FIELD role ON membership TYPE string ASSERT $value IN ['owner', 'admin', 'editor', 'viewer'];
DEFINE FIELD joined_at ON membership TYPE datetime DEFAULT time::now();
DEFINE INDEX unique_membership ON membership FIELDS in, out UNIQUE;

-- Define the role table
DEFINE TABLE role SCHEMAFULL;
DEFINE FIELD role_id ON role TYPE string;
DEFINE FIELD standardized_title ON role TYPE string;
DEFINE FIELD aliases ON role TYPE array;
DEFINE FIELD aliases.* ON role TYPE string;
DEFINE FIELD department ON role TYPE string;
DEFINE FIELD description ON role TYPE string;
DEFINE FIELD reports_to ON role TYPE option<record<role>>;
DEFINE FIELD localizations ON role TYPE object;
DEFINE FIELD localizations.en ON role TYPE string;
DEFINE FIELD localizations.en_uk ON role TYPE string;
DEFINE FIELD localizations.de ON role TYPE string;
DEFINE FIELD localizations.fr ON role TYPE string;
DEFINE FIELD localizations.it ON role TYPE string;
DEFINE FIELD localizations.es ON role TYPE string;
DEFINE FIELD localizations.pt ON role TYPE string;
DEFINE FIELD localizations.nl ON role TYPE string;
DEFINE FIELD external_references ON role TYPE object;
DEFINE FIELD external_references.imdb ON role TYPE option<string>;
DEFINE FIELD external_references.tmdb ON role TYPE option<string>;
DEFINE INDEX role_id_index ON role FIELDS role_id UNIQUE;

-- INVITATION EDGE
DEFINE TABLE invited SCHEMAFULL
  PERMISSIONS FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD invited_at ON invited TYPE datetime;
