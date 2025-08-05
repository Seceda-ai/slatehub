use axum::{
    extract::Path,
    http::{header, HeaderValue, Method},
    routing::{get, post, put},
    Json, Router,
};
use serde_json::{json, Value};
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

/// A minimal, mock version of the SlateHub API.
///
/// This implementation provides a stable, working foundation by mocking the
/// authentication and database layers. It allows frontend development to proceed
/// while the complexities of the SurrealDB v2.x API are resolved separately.
#[tokio::main]
async fn main() {
    // Initialize tracing for structured, context-aware logging.
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "slatehub_api=debug,tower_http=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Configure Cross-Origin Resource Sharing (CORS) to allow requests
    // from the SvelteKit frontend development server.
    let cors = CorsLayer::new()
        .allow_origin("http://localhost:5173".parse::<HeaderValue>().unwrap())
        .allow_methods([Method::GET, Method::POST, Method::PUT, Method::DELETE])
        .allow_headers([header::AUTHORIZATION, header::CONTENT_TYPE])
        .allow_credentials(true);

    // Create the application router and apply the CORS middleware.
    let app = create_router().layer(cors);

    // Define the server's listening address.
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    tracing::info!("Starting mock API server on {}", addr);

    // Start the Axum server.
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

/// Creates the Axum router with all the mock API endpoints.
fn create_router() -> Router {
    Router::new()
        .route("/health", get(health_check))
        .route("/api/auth/register", post(mock_register))
        .route("/api/auth/login", post(mock_login))
        .route("/api/auth/me", get(mock_me))
        .route("/api/auth/check-username", post(mock_check_username))
        .route("/api/auth/logout", post(mock_logout))
        .route("/api/profile", put(mock_update_profile))
        .route("/api/users/:username", get(mock_get_public_profile))
}

// --- Mock Handlers ---

/// A simple health check endpoint to confirm the server is running.
async fn health_check() -> Json<Value> {
    Json(json!({
        "status": "healthy",
        "service": "slatehub-api (mock)",
        "timestamp": chrono::Utc::now()
    }))
}

/// Mock registration endpoint.
///
/// Simulates creating a new user and returns a mock token and user object.
async fn mock_register(Json(payload): Json<Value>) -> Json<Value> {
    tracing::info!("Mock register called with payload: {:?}", payload);
    let username = payload
        .get("username")
        .and_then(|v| v.as_str())
        .unwrap_or("new_user");

    Json(json!({
        "token": format!("mock_token_for_{}", username),
        "user": {
            "id": format!("person:{}", username),
            "username": username,
            "email": payload.get("email"),
            "name": payload.get("name"),
            "stage_name": payload.get("stage_name"),
            "verification_level": 1
        }
    }))
}

/// Mock login endpoint.
///
/// Simulates authenticating a user and returns a mock token and user object.
async fn mock_login(Json(payload): Json<Value>) -> Json<Value> {
    tracing::info!("Mock login called with payload: {:?}", payload);
    let username = payload
        .get("username")
        .and_then(|v| v.as_str())
        .unwrap_or("test_user");

    Json(json!({
        "token": format!("mock_token_for_{}", username),
        "user": {
            "id": format!("person:{}", username),
            "username": username,
            "email": format!("{}@example.com", username),
            "name": "Test User",
            "stage_name": "The Tester",
            "verification_level": 1
        }
    }))
}

/// Mock endpoint to get the current authenticated user.
///
/// Simulates fetching the user profile based on a token.
async fn mock_me() -> Json<Value> {
    tracing::info!("Mock '/api/auth/me' endpoint called");
    Json(json!({
        "id": "person:current_user_id",
        "username": "current_user",
        "email": "current@example.com",
        "name": "Current User",
        "stage_name": "The Current One",
        "verification_level": 2
    }))
}

/// Mock endpoint for checking username availability.
async fn mock_check_username(Json(payload): Json<Value>) -> Json<Value> {
    tracing::info!("Mock check-username called with payload: {:?}", payload);
    let username = payload
        .get("username")
        .and_then(|v| v.as_str())
        .unwrap_or("");

    // Simulate some taken usernames
    let is_taken = matches!(username.to_lowercase().as_str(), "admin" | "test" | "root");

    Json(json!({
        "available": !is_taken
    }))
}

/// Mock logout endpoint.
///
/// Simulates invalidating a user's session.
async fn mock_logout() -> Json<Value> {
    tracing::info!("Mock '/api/auth/logout' endpoint called");
    Json(json!({
        "message": "Logged out successfully"
    }))
}

/// Mock endpoint for updating a user profile.
async fn mock_update_profile(Json(payload): Json<Value>) -> Json<Value> {
    tracing::info!("Mock update_profile called with payload: {:?}", payload);
    // In a real app, you'd update the user and return the updated data.
    // Here we just merge the payload with some default data.
    Json(json!({
        "id": "person:current_user_id",
        "username": "current_user",
        "email": "current@example.com",
        "name": payload.get("name"),
        "stage_name": payload.get("stage_name"),
        "verification_level": 2
    }))
}

/// Mock endpoint for fetching a public user profile.
async fn mock_get_public_profile(Path(username): Path<String>) -> Json<Value> {
    tracing::info!("Mock get_public_profile called for username: {}", username);
    // Simulate a not found case
    if username.to_lowercase() == "notfound" {
        // This is a simplified error response. A real API would return a 404 status.
        return Json(json!({
            "error": "User not found",
            "message": "A user with that username does not exist."
        }));
    }

    Json(json!({
        "id": format!("person:{}", username),
        "username": username,
        // Public profiles should not expose emails in a real application.
        // This is included for testing purposes.
        "email": format!("{}@example.com", username),
        "name": format!("{}", username.to_uppercase()),
        "stage_name": format!("The Great {}", username),
        "verification_level": 1
    }))
}
