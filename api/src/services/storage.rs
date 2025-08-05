use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use uuid::Uuid;

use crate::config::Config;
use crate::error::{AppError, Result};

#[derive(Clone)]
pub struct StorageService {
    storage_path: PathBuf,
}

impl StorageService {
    pub async fn new(config: &Config) -> Result<Self> {
        // Use local filesystem storage for now
        let storage_path = PathBuf::from("./uploads");

        // Create storage directory if it doesn't exist
        if !storage_path.exists() {
            fs::create_dir_all(&storage_path).map_err(|e| {
                AppError::storage(format!("Failed to create storage directory: {}", e))
            })?;
        }

        let service = StorageService { storage_path };

        tracing::info!("Storage service initialized with local filesystem");
        Ok(service)
    }

    pub async fn upload_image(
        &self,
        data: Vec<u8>,
        content_type: &str,
        filename: &str,
    ) -> Result<String> {
        // Generate unique storage path
        let file_id = Uuid::new_v4();
        let extension = self.get_file_extension(content_type);
        let storage_filename = format!("{}{}", file_id, extension);
        let storage_path = self.storage_path.join(&storage_filename);

        // Validate and process image (basic validation for now)
        self.validate_image(&data, content_type)?;

        // Write file to disk
        let mut file = fs::File::create(&storage_path)
            .map_err(|e| AppError::storage(format!("Failed to create file: {}", e)))?;

        file.write_all(&data)
            .map_err(|e| AppError::storage(format!("Failed to write file: {}", e)))?;

        tracing::info!("Uploaded image to {}", storage_filename);
        Ok(storage_filename)
    }

    pub async fn get_image(&self, storage_filename: &str) -> Result<(Vec<u8>, String)> {
        let storage_path = self.storage_path.join(storage_filename);

        if !storage_path.exists() {
            return Err(AppError::not_found("Image not found"));
        }

        let data = fs::read(&storage_path)
            .map_err(|e| AppError::storage(format!("Failed to read image: {}", e)))?;

        // Determine content type from extension
        let content_type = self.get_content_type_from_filename(storage_filename);

        Ok((data, content_type))
    }

    pub async fn delete_image(&self, storage_filename: &str) -> Result<()> {
        let storage_path = self.storage_path.join(storage_filename);

        if storage_path.exists() {
            fs::remove_file(&storage_path)
                .map_err(|e| AppError::storage(format!("Failed to delete image: {}", e)))?;

            tracing::info!("Deleted image from {}", storage_filename);
        }

        Ok(())
    }

    pub fn get_image_url(&self, storage_filename: &str) -> String {
        // Return API endpoint for serving the image
        format!("/api/images/{}", storage_filename)
    }

    fn validate_image(&self, data: &[u8], content_type: &str) -> Result<()> {
        // Basic validation
        if data.is_empty() {
            return Err(AppError::bad_request("Empty image data"));
        }

        // Check file size (max 10MB)
        if data.len() > 10 * 1024 * 1024 {
            return Err(AppError::bad_request("Image too large (max 10MB)"));
        }

        // Validate content type
        match content_type {
            "image/jpeg" | "image/jpg" | "image/png" | "image/webp" => Ok(()),
            _ => Err(AppError::bad_request(
                "Unsupported image format. Supported formats: JPEG, PNG, WebP",
            )),
        }
    }

    fn get_file_extension(&self, content_type: &str) -> &'static str {
        match content_type {
            "image/jpeg" | "image/jpg" => ".jpg",
            "image/png" => ".png",
            "image/webp" => ".webp",
            _ => ".bin",
        }
    }

    fn get_content_type_from_filename(&self, filename: &str) -> String {
        let path = Path::new(filename);
        match path.extension().and_then(|ext| ext.to_str()) {
            Some("jpg") | Some("jpeg") => "image/jpeg".to_string(),
            Some("png") => "image/png".to_string(),
            Some("webp") => "image/webp".to_string(),
            _ => "application/octet-stream".to_string(),
        }
    }

    pub async fn health_check(&self) -> Result<bool> {
        // Check if storage directory is accessible
        Ok(self.storage_path.exists() && self.storage_path.is_dir())
    }
}
