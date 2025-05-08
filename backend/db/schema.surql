USE NS seceda DB core;

-- 🔐 ACCESS METHOD FOR PERSON SIGNUP & SIGNIN
DEFINE ACCESS user_access ON DATABASE TYPE RECORD
  SIGNUP (
    CREATE person SET
      username    = string::lowercase($username),
      password    = crypto::argon2::generate($password),
      email       = string::lowercase($email),
      global_role = "user",
      created_at  = time::now()
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

DEFINE FIELD global_role ON person TYPE string
  VALUE  $value ?? "user"
  ASSERT $value IN ["admin","user"];

DEFINE FIELD created_at ON person TYPE datetime;

DEFINE INDEX idx_person_username ON person COLUMNS username UNIQUE;
DEFINE INDEX idx_person_email    ON person COLUMNS email    UNIQUE;

-- ORGANIZATION TABLE
DEFINE TABLE organization SCHEMAFULL
  PERMISSIONS
    FOR select, update, delete WHERE
      $auth.global_role = "admin"
      OR $auth.id IN (SELECT in FROM member_of_org WHERE out = $auth.id),
    FOR create WHERE $auth.id != NONE;

DEFINE FIELD name       ON organization TYPE string
  ASSERT $value != "";

DEFINE FIELD slug       ON organization TYPE string
  VALUE  string::slug(name)
  ASSERT $value = /^[a-z0-9_-]+$/;

DEFINE FIELD created_at ON organization TYPE datetime;

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
  ASSERT $value = /^[a-z0-9_-]+$/;

DEFINE FIELD organization_id  ON project TYPE record<organization>;
DEFINE FIELD created_at       ON project TYPE datetime;

-- Unique slug per organization
DEFINE INDEX idx_project_org_slug ON project COLUMNS organization_id, slug UNIQUE;

-- ORG MEMBERSHIP EDGE
DEFINE TABLE member_of_org SCHEMAFULL
  PERMISSIONS FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD role      ON member_of_org TYPE string
  ASSERT $value IN ["owner","admin","editor","viewer"];

DEFINE FIELD joined_at ON member_of_org TYPE datetime;

-- PROJECT MEMBERSHIP EDGE
DEFINE TABLE member_of_project SCHEMAFULL
  PERMISSIONS FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD role      ON member_of_project TYPE string
  ASSERT $value IN ["owner","admin","editor","viewer"];

DEFINE FIELD joined_at ON member_of_project TYPE datetime;

-- INVITATION EDGE
DEFINE TABLE invited SCHEMAFULL
  PERMISSIONS FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD invited_at ON invited TYPE datetime;
