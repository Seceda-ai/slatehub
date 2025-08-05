# SurrealDB Authentication Architecture

This document explains how SlateHub uses SurrealDB's built-in authentication system instead of custom JWT tokens.

## Architecture Overview

SlateHub leverages SurrealDB's **scope-based authentication** system, which provides:
- Built-in session management
- User-level permissions enforced at the database level
- Secure token generation and validation
- Role-based access control (RBAC)

## Authentication Flow

### 1. User Registration
```surql
-- Scope signup automatically creates user and returns session token
DEFINE SCOPE user
  SIGNUP (
    CREATE person SET
      username = $username,
      email = $email,
      password = crypto::argon2::generate($password),
      name = $name,
      stage_name = $stage_name,
      verification_level = 1,
      created_at = time::now(),
      updated_at = time::now()
  )
```

### 2. User Authentication
```surql
-- Scope signin validates credentials and creates session
SIGNIN (
  SELECT * FROM person
  WHERE username = $username
  AND crypto::argon2::compare(password, $password)
)
```

### 3. API Proxy Pattern
The Rust API acts as a **proxy** to SurrealDB:

```rust
// API receives login request
pub async fn login(payload: LoginRequest) -> Result<AuthResponse> {
    // Proxy to SurrealDB scope authentication
    let auth_result = database.authenticate_user(&payload.username, &payload.password).await?;
    
    // Return SurrealDB token to client
    Ok(Json(AuthResponse {
        token: auth_result.token,
        user: auth_result.user
    }))
}
```

## Permission System

### Database-Level Permissions
All permissions are enforced in SurrealDB, not in the API:

```surql
-- Users can only update their own records
DEFINE TABLE person SCHEMAFULL
  PERMISSIONS
    FOR update WHERE $scope = "user" AND id = $auth.id
    FOR delete WHERE $scope = "user" AND id = $auth.id;

-- Users can only create/manage their own images
DEFINE TABLE image SCHEMAFULL
  PERMISSIONS
    FOR create WHERE $scope = "user" AND person_id = $auth.id
    FOR update WHERE $scope = "user" AND person_id = $auth.id
    FOR delete WHERE $scope = "user" AND person_id = $auth.id;
```

### Automatic User Context
SurrealDB provides `$auth` variable containing current user data:

```surql
-- Update current user's profile
UPDATE $auth SET 
    name = $name,
    stage_name = $stage_name,
    updated_at = time::now();

-- Create image owned by current user
CREATE image SET
    person_id = $auth.id,  -- Automatically set to current user
    filename = $filename,
    content_type = $content_type;
```

## API Implementation

### Middleware
```rust
// Extract and validate SurrealDB token
impl FromRequestParts<AppState> for AuthUser {
    async fn from_request_parts(parts: &mut Parts, state: &AppState) -> Result<Self> {
        let token = extract_bearer_token(parts)?;
        
        // Validate token with SurrealDB and set session context
        let user_data = state.database.validate_token(token).await?;
        
        Ok(AuthUser { user_data })
    }
}
```

### Database Methods
```rust
impl Database {
    // Authenticate user via SurrealDB scope
    pub async fn authenticate_user(&self, username: &str, password: &str) -> Result<Value> {
        self.client.signin(Scope {
            namespace: &self.namespace,
            database: &self.database,
            scope: "user",
            params: json!({
                "username": username,
                "password": password
            }),
        }).await
    }
    
    // Get current user from SurrealDB session
    pub async fn get_current_user(&self) -> Result<Value> {
        self.client.query("SELECT * FROM $auth").await?.take(0)
    }
    
    // Update profile using SurrealDB auth context
    pub async fn update_profile(&self, name: Option<&str>, stage_name: Option<&str>) -> Result<Value> {
        self.client.query(
            "UPDATE $auth SET name = $name, stage_name = $stage_name, updated_at = time::now()"
        )
        .bind(("name", name.unwrap_or("")))
        .bind(("stage_name", stage_name.unwrap_or("")))
        .await?.take(0)
    }
}
```

## Security Benefits

### 1. **Database-Level Security**
- Permissions enforced at the database level, not application level
- No risk of API bypass attacks
- Consistent security across all database operations

### 2. **Built-in Session Management**
- SurrealDB handles token generation, validation, and expiration
- No custom JWT implementation needed
- Session duration configurable per scope

### 3. **Automatic User Context**
- `$auth` variable automatically available in all queries
- No need to manually pass user IDs
- Prevents privilege escalation bugs

### 4. **Role-Based Access Control**
- Multiple scopes can be defined for different user types
- Fine-grained permissions per table/operation
- Easy to add new roles and permissions

## Verification Levels

SlateHub implements a 3-tier verification system:

```surql
DEFINE FIELD verification_level ON TABLE person TYPE number
  DEFAULT 1
  ASSERT $value >= 1 AND $value <= 3;
```

- **Level 1**: Email verified (2 photos, 1 video embed)
- **Level 2**: Phone verified (4 photos, 1 video embed)  
- **Level 3**: ID verified (20 photos, unlimited embeds) - **Monetized**

Permissions can be based on verification level:
```surql
-- Only level 3 users can upload more than 4 images
DEFINE TABLE image SCHEMAFULL
  PERMISSIONS
    FOR create WHERE $scope = "user" 
    AND person_id = $auth.id 
    AND ($auth.verification_level >= 3 OR 
         (SELECT count() FROM image WHERE person_id = $auth.id)[0] < 4);
```

## Future Enhancements

### 1. **Organization Scopes**
```surql
DEFINE SCOPE organization
  SIGNUP (CREATE organization SET ...)
  SIGNIN (SELECT * FROM organization WHERE ...);
```

### 2. **Admin Scope**
```surql
DEFINE SCOPE admin
  SIGNIN (SELECT * FROM admin WHERE username = $username AND ...);
```

### 3. **API Key Authentication**
```surql
DEFINE SCOPE api_key
  SIGNIN (SELECT * FROM api_key WHERE key = $key AND active = true);
```

## Migration from JWT

When SurrealDB is properly integrated:

1. **Remove JWT dependencies**: `jsonwebtoken`, custom token generation
2. **Remove auth middleware**: Replace with SurrealDB token validation
3. **Update database methods**: Use SurrealDB auth context (`$auth`)
4. **Add permission definitions**: Move authorization logic to database
5. **Update API endpoints**: Proxy to SurrealDB instead of custom logic

## Development Status

**Current State**: Mock implementation due to Rust edition2024 compatibility issues
**Next Steps**: 
1. Resolve SurrealDB dependency issues
2. Implement real SurrealDB authentication
3. Add database migration scripts
4. Update permission definitions
5. Test authentication flow end-to-end

This architecture provides a more secure, maintainable, and scalable authentication system by leveraging SurrealDB's built-in capabilities.