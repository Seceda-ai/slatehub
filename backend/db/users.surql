-- USERS TABLE
DEFINE TABLE users SCHEMAFULL
  PERMISSIONS
    FOR select, update WHERE id = $auth.id,
    FOR create WHERE true,
    FOR delete NONE;

DEFINE FIELD username ON TABLE users TYPE string
  ASSERT $value != ""
  ASSERT string::len($value) >= 3;

DEFINE INDEX idx_users_username ON TABLE users COLUMNS username UNIQUE;

DEFINE FIELD password ON TABLE users TYPE string
  ASSERT string::len($value) >= 8;

DEFINE FIELD emails ON TABLE users TYPE array<string>
  ASSERT array::all($value, function ($v) {
    return string::is::email($v);
  });

DEFINE FIELD created_at ON TABLE users TYPE datetime;

-- ORGANIZATIONS TABLE
DEFINE TABLE organizations SCHEMAFULL
  PERMISSIONS
    FOR select, create, update, delete WHERE $auth.id IN members;

DEFINE FIELD name ON TABLE organizations TYPE string
  ASSERT $value != "";

DEFINE INDEX idx_organizations_name ON TABLE organizations COLUMNS name UNIQUE;

DEFINE FIELD owner_id ON TABLE organizations TYPE record<users>;
DEFINE FIELD members ON TABLE organizations TYPE array<record<users>>;
DEFINE FIELD created_at ON TABLE organizations TYPE datetime;

-- PROJECTS TABLE
DEFINE TABLE projects SCHEMAFULL
  PERMISSIONS
    FOR select, create, update, delete WHERE $auth.id IN members;

DEFINE FIELD name ON TABLE projects TYPE string
  ASSERT $value != "";

DEFINE INDEX idx_projects_name ON TABLE projects COLUMNS name UNIQUE;

DEFINE FIELD organization_id ON TABLE projects TYPE record<organizations>;
DEFINE FIELD members ON TABLE projects TYPE array<record<users>>;
DEFINE FIELD created_at ON TABLE projects TYPE datetime;

-- INVITES TABLE
DEFINE TABLE invites SCHEMAFULL
  PERMISSIONS
    FOR select, create, delete WHERE $auth.id != NONE;

DEFINE FIELD email ON TABLE invites TYPE string
  ASSERT string::is::email($value);

DEFINE FIELD organization_id ON TABLE invites TYPE option<record<organizations>>;
DEFINE FIELD project_id ON TABLE invites TYPE option<record<projects>>;
DEFINE FIELD role ON TABLE invites TYPE string;
DEFINE FIELD created_by_id ON TABLE invites TYPE record<users>;
DEFINE FIELD status ON TABLE invites TYPE string;
DEFINE FIELD created_at ON TABLE invites TYPE datetime;
