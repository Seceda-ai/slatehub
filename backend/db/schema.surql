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
DEFINE TABLE project SCHEMAFULL
  PERMISSIONS
    FOR select, update, delete WHERE
      $auth.global_role = "admin"
      OR $auth.id IN (SELECT in FROM member_of_project WHERE out = $auth.id),
    FOR create WHERE $auth.id != NONE;

DEFINE FIELD name             ON project TYPE string
  ASSERT $value != "";

DEFINE FIELD slug             ON project TYPE string
  VALUE  string::slug(name)
  DEFAULT string::slug(name);

DEFINE FIELD updated_at ON project TYPE datetime
    VALUE time::now()
    DEFAULT ALWAYS time::now();

-- Unique slug per organization
DEFINE INDEX idx_project_org_slug ON project COLUMNS slug UNIQUE;

-- Define membership edge table
-- TODO Add Persmissions
DEFINE TABLE membership SCHEMAFULL TYPE RELATION FROM person|organization TO organization|project
PERMISSIONS
  FOR select, create WHERE $auth is not none;
DEFINE FIELD role ON membership TYPE string ASSERT $value IN ['owner', 'admin', 'editor', 'viewer'];
DEFINE FIELD joined_at ON membership TYPE datetime DEFAULT time::now();
DEFINE INDEX unique_membership ON membership FIELDS in, out UNIQUE;



-- INVITATION EDGE
DEFINE TABLE invited SCHEMAFULL
  PERMISSIONS FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD invited_at ON invited TYPE datetime;
