import {
    db,
    getConnectionState,
    connect,
    ConnectionState,
    authState,
} from "$lib/db/surreal";
import { get } from "svelte/store";
import type { Writable } from "svelte/store";

// Type for SurrealDB auth state store
export interface AuthState {
    isAuthenticated: boolean;
    user: Record<string, any> | null;
    token: string | null;
}

// We'll use this for strong typing in our functions
export interface AuthUser {
    id: string;
    username?: string;
    email?: string;
    profile_images?: ProfileImage[];
    profile_image_active?: string;
    [key: string]: any;
}

// Define custom query result type to help with type assertions
type QueryResult<T> = [T] | [T[]] | any[];

// Types for profile images

// Types for profile images
export interface ProfileImage {
    id: string;
    data: string; // Base64 encoded image data
    created_at?: string;
}

export interface Email {
    address: string;
    is_primary: boolean;
}

export interface Profile {
    username: string;
    emails: Email[];
    full_name?: string;
    location?: string;
    phone?: {
        country_code?: string;
        number?: string;
    };
    social?: {
        discord?: string;
        instagram?: string;
    };
    profile_images: ProfileImage[];
    profile_image_active?: string; // ID of the active profile image
    global_role: string;
    id?: string;
    created_at?: string;
    updated_at?: string;
}

export interface ProfileUpdateData {
    full_name?: string;
    location?: string;
    phone?: {
        country_code?: string;
        number?: string;
    };
    social?: {
        discord?: string;
        instagram?: string;
    };
}

export interface CredentialsUpdateData {
    username?: string;
    currentPassword: string;
    newPassword?: string;
}

/**
 * Fetches the current user's profile
 */
export async function getProfile(): Promise<Profile | null> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Fetch the profile data
        const result = (await db.query(`
      SELECT
        id,
        username,
        emails,
        full_name,
        location,
        phone,
        social,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active
      FROM ${userId};
    `)) as any[];

        if (
            !result ||
            !result[0] ||
            (Array.isArray(result[0]) && result[0].length === 0)
        ) {
            return null;
        }

        return Array.isArray(result[0])
            ? (result[0][0] as Profile)
            : (result[0] as Profile);
    } catch (error: any) {
        console.error("Error fetching profile:", error);
        throw new Error(
            `Failed to fetch profile: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Uploads a profile image for the current user
 * @param imageData Base64 encoded image data
 */
export async function uploadProfileImage(
    imageData: string,
): Promise<ProfileImage> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Generate a unique ID for the image
        const imageId = crypto.randomUUID();

        // Create a new image and add it to the user's profile_images array
        const result = (await db.query(
            `
      BEGIN TRANSACTION;

      // Create a new image object
      LET $image = {
        id: $imageId,
        data: $imageData,
        created_at: time::now()
      };

      // Update the user's profile_images array
      LET $profile = UPDATE ${userId} CONTENT {
        profile_images: array::concat(profile_images || [], [$image]),
        profile_image_active: profile_image_active || $imageId
      };

      RETURN {
        image: $image,
        profile: $profile
      };

      COMMIT TRANSACTION;
    `,
            {
                imageId,
                imageData,
            },
        )) as any[];

        if (!result || !result[0] || !result[0].image) {
            throw new Error("Failed to upload profile image");
        }

        // Update auth state with new profile image
        authState.update((state) => {
            if (!state.user) return state;

            // Get current profile images or empty array
            const currentImages = state.user.profile_images || [];

            return {
                ...state,
                user: {
                    ...state.user,
                    profile_images: [...currentImages, result[0].image],
                    profile_image_active:
                        state.user.profile_image_active || imageId,
                },
            };
        });

        return result[0].image as ProfileImage;
    } catch (error: any) {
        console.error("Error uploading profile image:", error);
        throw new Error(
            `Failed to upload profile image: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Deletes a profile image
 * @param imageId ID of the image to delete
 */
export async function deleteProfileImage(imageId: string): Promise<boolean> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Update the user's profile_images array to remove the image with the given ID
        await db.query(
            `
      BEGIN TRANSACTION;

      // Get the current profile data
      LET $current = (SELECT profile_images, profile_image_active FROM ${userId})[0];

      // Filter out the image to delete
      LET $updatedImages = array::filter($current.profile_images, function($img) {
        return $img.id != $imageId;
      });

      // If we're deleting the active image, set the active image to the first available one
      LET $newActiveImage = $current.profile_image_active == $imageId
        ? (array::len($updatedImages) > 0 ? $updatedImages[0].id : null)
        : $current.profile_image_active;

      // Update the user's profile
      UPDATE ${userId} CONTENT {
        profile_images: $updatedImages,
        profile_image_active: $newActiveImage
      };

      COMMIT TRANSACTION;
    `,
            { imageId },
        );

        // Update auth state with new profile image data
        authState.update((state) => {
            if (!state.user) return state;

            const isActiveImageDeleted =
                state.user.profile_image_active === imageId;
            const currentImages = state.user.profile_images || [];
            const updatedImages = currentImages.filter(
                (img: ProfileImage) => img.id !== imageId,
            );

            return {
                ...state,
                user: {
                    ...state.user,
                    profile_images: updatedImages,
                    profile_image_active:
                        isActiveImageDeleted && updatedImages.length > 0
                            ? updatedImages[0].id
                            : isActiveImageDeleted
                              ? null
                              : state.user.profile_image_active,
                },
            };
        });

        return true;
    } catch (error: any) {
        console.error("Error deleting profile image:", error);
        throw new Error(
            `Failed to delete profile image: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Sets the active profile image
 * @param imageId ID of the image to set as active
 */
export async function setActiveProfileImage(imageId: string): Promise<boolean> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Make sure the image exists in the user's profile_images array
        const profile = await getProfile();
        if (
            !profile ||
            !profile.profile_images.some((img) => img.id === imageId)
        ) {
            throw new Error("Image not found in user's profile");
        }

        // Update the user's profile_image_active field
        await db.query(
            `
      UPDATE ${userId} CONTENT {
        profile_image_active: $imageId
      };
    `,
            { imageId },
        );

        // Update auth state with new active profile image
        authState.update((state) => {
            if (!state.user) return state;

            return {
                ...state,
                user: {
                    ...state.user,
                    profile_image_active: imageId,
                },
            };
        });

        return true;
    } catch (error: any) {
        console.error("Error setting active profile image:", error);
        throw new Error(
            `Failed to set active profile image: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Gets the active profile image for the current user
 */
export function getActiveProfileImage(): ProfileImage | null {
    const state = get(authState);
    if (!state.user) {
        return null;
    }

    const activeId = state.user.profile_image_active;
    const images = (state.user.profile_images as ProfileImage[]) || [];

    if (!activeId || images.length === 0) {
        return null;
    }

    return images.find((img) => img.id === activeId) || null;
}

/**
 * Updates the current user's profile information
 * @param data The profile data to update
 */
export async function updateProfile(data: ProfileUpdateData): Promise<Profile> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Update the profile data
        const result = (await db.query(
            `
      UPDATE ${userId} CONTENT {
        full_name: $full_name,
        location: $location,
        phone: $phone,
        social: $social,
        updated_at: time::now()
      }
      RETURN
        id,
        username,
        emails,
        full_name,
        location,
        phone,
        social,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active;
    `,
            {
                full_name: data.full_name,
                location: data.location,
                phone: data.phone,
                social: data.social,
            },
        )) as any[];

        if (
            !result ||
            !result[0] ||
            (Array.isArray(result[0]) && result[0].length === 0)
        ) {
            throw new Error("Failed to update profile");
        }

        const updatedProfile = Array.isArray(result[0])
            ? (result[0][0] as Profile)
            : (result[0] as Profile);

        // Update auth state with new profile data
        authState.update((state) => {
            if (!state.user) return state;

            return {
                ...state,
                user: {
                    ...state.user,
                    ...data,
                },
            };
        });

        return updatedProfile;
    } catch (error: any) {
        console.error("Error updating profile:", error);
        throw new Error(
            `Failed to update profile: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Updates the user's credentials (username and/or password)
 * @param data The credentials data to update
 */
export async function updateCredentials(
    data: CredentialsUpdateData,
): Promise<Profile> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Verify the current password first
        const verifyResult = (await db.query(
            `
      SELECT * FROM ${userId}
      WHERE crypto::argon2::compare(password, $currentPassword);
    `,
            {
                currentPassword: data.currentPassword,
            },
        )) as any[];

        // Check if the password verification failed
        if (!verifyResult[0] || verifyResult[0].length === 0) {
            throw new Error("Current password is incorrect");
        }

        // Build the update content based on what's being changed
        let updateContent = {};
        let params: any = {};

        if (data.username) {
            // Check if username already exists
            const usernameCheck = (await db.query(
                `
        SELECT * FROM person
        WHERE username = $username
        AND id != $userId;
      `,
                {
                    username: data.username.toLowerCase(),
                    userId,
                },
            )) as any[];

            if (usernameCheck[0] && usernameCheck[0].length > 0) {
                throw new Error("Username already exists");
            }

            updateContent = {
                ...updateContent,
                username: data.username.toLowerCase(),
            };
            params.username = data.username.toLowerCase();
        }

        if (data.newPassword) {
            // Generate hash for new password
            const hashedPassword = (await db.query(
                `
        RETURN crypto::argon2::generate($password);
      `,
                {
                    password: data.newPassword,
                },
            )) as any[];

            if (!hashedPassword[0]) {
                throw new Error("Failed to hash new password");
            }

            updateContent = { ...updateContent, password: hashedPassword[0] };
            params.password = hashedPassword[0];
        }

        // If no changes requested, return current profile
        if (Object.keys(updateContent).length === 0) {
            return getProfile() as Promise<Profile>;
        }

        // Update the credentials
        params.userId = userId;

        // Create dynamic query based on what's being updated
        let updateFields = "";
        if (params.username) updateFields += "username: $username,\n";
        if (params.password) updateFields += "password: $password,\n";
        updateFields += "updated_at: time::now()";

        const result = (await db.query(
            `
      UPDATE $userId CONTENT {
        ${updateFields}
      }
      RETURN
        id,
        username,
        emails,
        full_name,
        location,
        phone,
        social,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active;
    `,
            params,
        )) as any[];

        if (
            !result ||
            !result[0] ||
            (Array.isArray(result[0]) && result[0].length === 0)
        ) {
            throw new Error("Failed to update credentials");
        }

        const updatedProfile = Array.isArray(result[0])
            ? (result[0][0] as Profile)
            : (result[0] as Profile);

        // Update auth state with new username if it was changed
        if (data.username) {
            authState.update((state) => {
                if (!state.user) return state;

                return {
                    ...state,
                    user: {
                        ...state.user,
                        username: data.username?.toLowerCase(),
                    },
                };
            });
        }

        return updatedProfile;
    } catch (error: any) {
        console.error("Error updating credentials:", error);
        throw new Error(
            `Failed to update credentials: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Validates an email address format
 * @param email The email address to validate
 */
export function validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Adds an email address to the user's profile
 * @param email The email address to add
 * @param isPrimary Whether this should be the primary email
 */
export async function addEmail(
    email: string,
    isPrimary: boolean = false,
): Promise<Profile> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Validate email format
        if (!validateEmail(email)) {
            throw new Error("Invalid email format");
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Normalize email to lowercase
        const normalizedEmail = email.toLowerCase();

        // Check if email already exists
        const checkResult = (await db.query(
            `
      SELECT * FROM person
      WHERE $email IN emails[*].address;
    `,
            { email: normalizedEmail },
        )) as any[];

        if (checkResult[0] && checkResult[0].length > 0) {
            throw new Error("This email address is already in use");
        }

        // Get current emails and update primary flags if needed
        const currentProfile = await getProfile();
        if (!currentProfile) {
            throw new Error("Failed to get current profile");
        }

        let updatedEmails = [...currentProfile.emails];

        // If setting as primary, unset all other primary flags
        if (isPrimary) {
            updatedEmails = updatedEmails.map((e) => ({
                ...e,
                is_primary: false,
            }));
        }

        // Add the new email
        updatedEmails.push({
            address: normalizedEmail,
            is_primary: isPrimary,
        });

        // Update the user's emails
        const result = (await db.query(
            `
      UPDATE ${userId} SET
        emails = $emails,
        updated_at = time::now()
      RETURN
        id,
        username,
        emails,
        full_name,
        location,
        phone,
        social,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active;
    `,
            { emails: updatedEmails },
        )) as any[];

        if (
            !result ||
            !result[0] ||
            (Array.isArray(result[0]) && result[0].length === 0)
        ) {
            throw new Error("Failed to add email address");
        }

        const updatedProfile = Array.isArray(result[0])
            ? (result[0][0] as Profile)
            : (result[0] as Profile);

        // Update auth state with new email data
        authState.update((state) => {
            if (!state.user) return state;

            return {
                ...state,
                user: {
                    ...state.user,
                    emails: updatedProfile.emails,
                },
            };
        });

        return updatedProfile;
    } catch (error: any) {
        console.error("Error adding email:", error);
        throw new Error(
            `Failed to add email: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Removes an email address from the user's profile
 * @param email The email address to remove
 */
export async function removeEmail(email: string): Promise<Profile> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Normalize email to lowercase
        const normalizedEmail = email.toLowerCase();

        // Get current profile
        const currentProfile = await getProfile();
        if (!currentProfile) {
            throw new Error("Failed to get current profile");
        }

        // Check if trying to remove the primary email when it's the only one
        const emailToRemove = currentProfile.emails.find(
            (e) => e.address === normalizedEmail,
        );
        if (!emailToRemove) {
            throw new Error("Email not found");
        }

        if (emailToRemove.is_primary && currentProfile.emails.length === 1) {
            throw new Error("Cannot remove the only email address");
        }

        // Filter out the email
        let updatedEmails = currentProfile.emails.filter(
            (e) => e.address !== normalizedEmail,
        );

        // If we removed the primary email, make the first remaining email primary
        if (emailToRemove.is_primary && updatedEmails.length > 0) {
            updatedEmails[0].is_primary = true;
        }

        // Update the user's emails
        const result = (await db.query(
            `
      UPDATE ${userId} SET
        emails = $emails,
        updated_at = time::now()
      RETURN
        id,
        username,
        emails,
        full_name,
        location,
        phone,
        social,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active;
    `,
            { emails: updatedEmails },
        )) as any[];

        if (
            !result ||
            !result[0] ||
            (Array.isArray(result[0]) && result[0].length === 0)
        ) {
            throw new Error("Failed to remove email address");
        }

        const updatedProfile = Array.isArray(result[0])
            ? (result[0][0] as Profile)
            : (result[0] as Profile);

        // Update auth state with new email data
        authState.update((state) => {
            if (!state.user) return state;

            return {
                ...state,
                user: {
                    ...state.user,
                    emails: updatedProfile.emails,
                },
            };
        });

        return updatedProfile;
    } catch (error: any) {
        console.error("Error removing email:", error);
        throw new Error(
            `Failed to remove email: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Sets an email as the primary email address
 * @param email The email address to set as primary
 */
export async function setPrimaryEmail(email: string): Promise<Profile> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID from auth state
        const state = get(authState);
        if (!state.user || !state.isAuthenticated) {
            throw new Error("User not authenticated");
        }

        const userId = state.user.id as string;
        if (!userId) {
            throw new Error("User ID not found");
        }

        // Normalize email to lowercase
        const normalizedEmail = email.toLowerCase();

        // Get current profile
        const currentProfile = await getProfile();
        if (!currentProfile) {
            throw new Error("Failed to get current profile");
        }

        // Check if email exists
        const emailExists = currentProfile.emails.some(
            (e) => e.address === normalizedEmail,
        );
        if (!emailExists) {
            throw new Error("Email not found in your profile");
        }

        // Update primary flags
        const updatedEmails = currentProfile.emails.map((e) => ({
            ...e,
            is_primary: e.address === normalizedEmail,
        }));

        // Update the user's emails
        const result = (await db.query(
            `
      UPDATE ${userId} SET
        emails = $emails,
        updated_at = time::now()
      RETURN
        id,
        username,
        emails,
        full_name,
        location,
        phone,
        social,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active;
    `,
            { emails: updatedEmails },
        )) as any[];

        if (
            !result ||
            !result[0] ||
            (Array.isArray(result[0]) && result[0].length === 0)
        ) {
            throw new Error("Failed to update primary email");
        }

        const updatedProfile = Array.isArray(result[0])
            ? (result[0][0] as Profile)
            : (result[0] as Profile);

        // Update auth state with new email data
        authState.update((state) => {
            if (!state.user) return state;

            return {
                ...state,
                user: {
                    ...state.user,
                    emails: updatedProfile.emails,
                },
            };
        });

        return updatedProfile;
    } catch (error: any) {
        console.error("Error setting primary email:", error);
        throw new Error(
            `Failed to set primary email: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Gets the primary email address for a profile
 * @param profile The profile to get the primary email from
 */
export function getPrimaryEmail(profile: Profile | null): string | null {
    if (!profile || !profile.emails || profile.emails.length === 0) {
        return null;
    }

    const primaryEmail = profile.emails.find((e) => e.is_primary);
    return primaryEmail ? primaryEmail.address : profile.emails[0].address;
}
