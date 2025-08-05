-- SlateHub Consolidated Schema
-- Version: 1.1
-- Description: Defines the complete initial schema including tables, fields,
-- indexes, auth scopes, permissions, events, and functions.

-- ============================================================================
-- Person Table
-- ============================================================================

DEFINE TABLE person SCHEMAFULL
  PERMISSIONS
    -- Public profile data is selectable by anyone.
    FOR select FULL
    -- Creation is handled exclusively by the SIGNUP scope.
    FOR create NONE
    -- A user can only update their own record.
    FOR update WHERE id = $auth.id
    -- A user can only delete their own record.
    FOR delete WHERE id = $auth.id;

-- Fields
DEFINE FIELD username ON TABLE person TYPE string
  ASSERT $value != NONE AND string::len($value) >= 3 AND string::len($value) <= 50
  VALUE string::lowercase($value);

DEFINE FIELD email ON TABLE person TYPE string
  ASSERT $value != NONE AND string::is::email($value)
  VALUE string::lowercase($value);

DEFINE FIELD password ON TABLE person TYPE string
  ASSERT $value != NONE;

DEFINE FIELD name ON TABLE person TYPE option<string>
  ASSERT $value = NONE OR string::len($value) <= 100;

DEFINE FIELD stage_name ON TABLE person TYPE option<string>
  ASSERT $value = NONE OR string::len($value) <= 100;

DEFINE FIELD profile_image_id ON TABLE person TYPE option<record<image>>;

DEFINE FIELD verification_level ON TABLE person TYPE number
  DEFAULT 1
  ASSERT $value >= 1 AND $value <= 3;

DEFINE FIELD created_at ON TABLE person TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE person TYPE datetime DEFAULT time::now();

-- Indexes
DEFINE INDEX username_unique ON TABLE person COLUMNS username UNIQUE;
DEFINE INDEX email_unique ON TABLE person COLUMNS email UNIQUE;
DEFINE INDEX created_at_idx ON TABLE person COLUMNS created_at;

-- ============================================================================
-- Image Table
-- ============================================================================

DEFINE TABLE image SCHEMAFULL
  PERMISSIONS
    -- Anyone can view images.
    FOR select FULL
    -- Authenticated users can only create images for themselves.
    FOR create WHERE person_id = $auth.id
    -- Users can only update their own images.
    FOR update WHERE person_id = $auth.id
    -- Users can only delete their own images.
    FOR delete WHERE person_id = $auth.id;

-- Fields
DEFINE FIELD person_id ON TABLE image TYPE record<person>
  ASSERT $value != NONE;

DEFINE FIELD filename ON TABLE image TYPE string
  ASSERT $value != NONE;

DEFINE FIELD content_type ON TABLE image TYPE string
  ASSERT $value != NONE AND ($value = "image/jpeg" OR $value = "image/png" OR $value = "image/webp");

DEFINE FIELD size ON TABLE image TYPE number
  ASSERT $value != NONE AND $value > 0 AND $value <= 10485760; -- Max 10MB

DEFINE FIELD storage_path ON TABLE image TYPE string
  ASSERT $value != NONE;

DEFINE FIELD created_at ON TABLE image TYPE datetime DEFAULT time::now();

-- Indexes
DEFINE INDEX person_images ON TABLE image COLUMNS person_id, created_at;
DEFINE INDEX storage_path_unique ON TABLE image COLUMNS storage_path UNIQUE;

-- ============================================================================
-- Authentication
-- ============================================================================

DEFINE SCOPE user
  SESSION 24h
  SIGNUP (
    CREATE person SET
      username = $username,
      email = $email,
      password = crypto::argon2::generate($password),
      name = $name,
      stage_name = $stage_name
  )
  SIGNIN (
    SELECT * FROM person
    WHERE username = $username
    AND crypto::argon2::compare(password, $password)
  );

-- ============================================================================
-- Events
-- ============================================================================

DEFINE EVENT update_person_timestamp ON TABLE person WHEN $event = "UPDATE" THEN (
  UPDATE $after.id SET updated_at = time::now()
);

-- ============================================================================
-- Functions
-- ============================================================================

DEFINE FUNCTION fn::get_profile_with_images($user_id: record<person>) {
  LET $profile = (SELECT * FROM person WHERE id = $user_id)[0];
  LET $images = SELECT * FROM image WHERE person_id = $user_id ORDER BY created_at DESC;
  LET $profile_image = IF $profile.profile_image_id != NONE THEN
    (SELECT * FROM image WHERE id = $profile.profile_image_id)[0]
  ELSE
    NONE
  END;

  RETURN {
    profile: $profile,
    images: $images,
    profile_image: $profile_image
  };
};

DEFINE FUNCTION fn::get_public_profile($username: string) {
  LET $profile = (SELECT id, username, name, stage_name, profile_image_id, created_at
                  FROM person WHERE username = $username)[0];

  IF $profile = NONE THEN
    RETURN NONE;
  END;

  LET $profile_image = IF $profile.profile_image_id != NONE THEN
    (SELECT * FROM image WHERE id = $profile.profile_image_id)[0]
  ELSE
    NONE
  END;

  RETURN {
    profile: $profile,
    profile_image: $profile_image
  };
};
