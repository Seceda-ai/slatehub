USE NS seceda DB core;

-- 🔐 ACCESS METHOD FOR PERSON SIGNUP & SIGNIN
DEFINE ACCESS user_access ON DATABASE TYPE RECORD
  SIGNUP (
    CREATE person SET
      username    = string::lowercase($username),
      password    = crypto::argon2::generate($password),
      emails      = [{ address: string::lowercase($email), is_primary: true }],
      global_role = "user"
  )
  SIGNIN (
    SELECT * FROM person
    WHERE username = string::lowercase($username)
      AND crypto::argon2::compare(password, $password)
  )
  DURATION FOR TOKEN 120m, FOR SESSION 14d;

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

DEFINE FIELD emails ON person TYPE array;
DEFINE FIELD emails.*.address ON person TYPE string
    ASSERT $value != NONE AND string::is::email($value);
DEFINE FIELD emails.*.primary ON person TYPE bool;

-- Ensure only one email is marked as primary
DEFINE FIELD emails ON person
    ASSERT (
        -- Count the number of primary emails (should be 0 or 1)
        array::len(array::filter($value, fn($email) => $email.primary)) <= 1;
    );

-- Full name field
DEFINE FIELD full_name ON person TYPE string
  DEFAULT"";

-- Location field
DEFINE FIELD location ON person TYPE string
  DEFAULT "";

-- Phone number fields
DEFINE FIELD phone ON person TYPE object
  DEFAULT { country_code: "", number: "" };
DEFINE FIELD phone.country_code ON person TYPE string
  DEFAULT "";
DEFINE FIELD phone.number ON person TYPE string
  DEFAULT "";

-- Social media handles
DEFINE FIELD social ON person TYPE object
  DEFAULT { discord: "", instagram: "" };
DEFINE FIELD social.discord ON person TYPE string
  DEFAULT "";
DEFINE FIELD social.instagram ON person TYPE string
  DEFAULT "";

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
DEFINE TABLE production SCHEMAFULL
PERMISSIONS
  FOR select, create WHERE $auth is not none;

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

-- Define the department table
DEFINE TABLE department SCHEMAFULL
PERMISSIONS
FOR select WHERE true,
FOR create, update, delete WHERE $auth.global_role = "admin";

DEFINE FIELD name ON department TYPE string;
DEFINE FIELD slug ON department TYPE string
  VALUE  string::slug(name)
  DEFAULT string::slug(name);
DEFINE FIELD created_at ON department TYPE datetime
    VALUE time::now() READONLY;

DEFINE FIELD updated_at ON department TYPE datetime
    VALUE time::now()
    DEFAULT ALWAYS time::now();
DEFINE INDEX department_name_idx ON department COLUMNS name UNIQUE;

-- Define the role table
DEFINE TABLE role SCHEMAFULL
PERMISSIONS
FOR select where true,
FOR create, update, delete WHERE $auth.global_role = "admin";
DEFINE FIELD name ON role TYPE string;
DEFINE FIELD slug ON role TYPE string
  VALUE  string::slug(name)
  DEFAULT string::slug(name);

DEFINE FIELD description ON role TYPE string;
DEFINE FIELD created_at ON role TYPE datetime
    VALUE time::now() READONLY;

DEFINE FIELD updated_at ON role TYPE datetime
    VALUE time::now()
    DEFAULT ALWAYS time::now();
DEFINE INDEX role_name_idx ON role COLUMNS name UNIQUE;
DEFINE INDEX role_slug_idx ON role COLUMNS slug UNIQUE;

-- Define role_belongs_to_department relation
DEFINE TABLE belongs_to_department SCHEMAFULL TYPE RELATION FROM role TO department
PERMISSIONS
FOR select WHERE true,
FOR create, update, delete WHERE $auth.global_role = "admin";



-- INVITATION EDGE
DEFINE TABLE invited SCHEMAFULL
  PERMISSIONS FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD invited_at ON invited TYPE datetime;

-- PERSON-ROLE RELATIONSHIP
DEFINE TABLE person_has_role SCHEMAFULL TYPE RELATION FROM person TO role
  PERMISSIONS
    FOR select WHERE true,
    FOR create, update, delete WHERE in = $auth.id;

DEFINE FIELD added_at ON person_has_role TYPE datetime VALUE time::now() READONLY;
DEFINE INDEX unique_person_role ON person_has_role FIELDS in, out UNIQUE;

-- IMAGE SYSTEM

-- Image table definition
DEFINE TABLE image SCHEMAFULL
  PERMISSIONS
    FOR create WHERE $auth.id IS NOT NONE,
    FOR update WHERE created_by = $auth.id,
    FOR delete WHERE created_by = $auth.id;

-- Image fields
DEFINE FIELD data ON image TYPE string;
DEFINE FIELD alt_text ON image TYPE string;
DEFINE FIELD mime_type ON image TYPE string DEFAULT "image/png";
DEFINE FIELD created_at ON image TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD created_by ON image TYPE record<person>;

-- Image relation table for graph connections
DEFINE TABLE has_image SCHEMAFULL
  PERMISSIONS
    FOR select WHERE true,
    FOR create WHERE $auth.id IS NOT NONE,
    FOR update WHERE out.created_by = $auth.id OR $auth.global_role = "admin",
    FOR delete WHERE out.created_by = $auth.id OR $auth.global_role = "admin";

-- Image relation fields
DEFINE FIELD in ON has_image TYPE record<person|organization|production>;
DEFINE FIELD out ON has_image TYPE record<image>;
DEFINE FIELD category ON has_image TYPE string DEFAULT "";

DEFINE INDEX has_image_category ON TABLE has_image COLUMNS category;
