use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
// use uuid::Uuid;
// use validator::Validate;

// Person model
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Person {
    pub id: String,
    pub username: String,
    pub email: String,
    #[serde(skip_serializing)]
    pub password_hash: String,
    pub name: Option<String>,
    pub stage_name: Option<String>,
    pub profile_image_id: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

// Public person model (no sensitive data)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicPerson {
    pub id: String,
    pub username: String,
    pub name: Option<String>,
    pub stage_name: Option<String>,
    pub profile_image_id: Option<String>,
    pub created_at: DateTime<Utc>,
}

impl From<Person> for PublicPerson {
    fn from(person: Person) -> Self {
        PublicPerson {
            id: person.id,
            username: person.username,
            name: person.name,
            stage_name: person.stage_name,
            profile_image_id: person.profile_image_id,
            created_at: person.created_at,
        }
    }
}

// Image model
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Image {
    pub id: String,
    pub person_id: String,
    pub filename: String,
    pub content_type: String,
    pub size: u64,
    pub storage_path: String,
    pub created_at: DateTime<Utc>,
}

// Authentication requests and responses
#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub username: String,
    pub email: String,
    pub password: String,
    pub name: Option<String>,
    pub stage_name: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub token: String,
    pub person: PublicPerson,
}

#[derive(Debug, Serialize)]
pub struct MessageResponse {
    pub message: String,
}

// Profile update request
#[derive(Debug, Deserialize)]
pub struct UpdatePersonProfile {
    pub name: Option<String>,
    pub stage_name: Option<String>,
}

// Internal database models
#[derive(Debug)]
pub struct CreatePersonRequest {
    pub username: String,
    pub email: String,
    pub password_hash: String,
    pub name: Option<String>,
    pub stage_name: Option<String>,
}

#[derive(Debug)]
pub struct CreateImageRequest {
    pub person_id: String,
    pub filename: String,
    pub content_type: String,
    pub size: u64,
    pub storage_path: String,
}

// JWT claims
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // person_id
    pub username: String,
    pub exp: usize,
    pub iat: usize,
}

// Image upload response
#[derive(Debug, Serialize)]
pub struct ImageUploadResponse {
    pub image: Image,
    pub url: String,
}

// Profile response
#[derive(Debug, Serialize)]
pub struct ProfileResponse {
    pub person: PublicPerson,
    pub images: Vec<Image>,
    pub profile_image_url: Option<String>,
}

// Error types
#[derive(Debug, Serialize)]
pub struct ErrorResponse {
    pub error: String,
    pub message: String,
}

// Validation error response
#[derive(Debug, Serialize)]
pub struct ValidationErrorResponse {
    pub error: String,
    pub message: String,
    pub fields: Vec<FieldError>,
}

#[derive(Debug, Serialize)]
pub struct FieldError {
    pub field: String,
    pub message: String,
}
