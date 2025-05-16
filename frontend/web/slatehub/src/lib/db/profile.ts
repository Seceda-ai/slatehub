import {
  db,
  getConnectionState,
  connect,
  ConnectionState,
  authState,
} from "$lib/db/surreal";
import type { Writable } from "svelte/store";

// Type definition for auth state store value
export interface AuthStateValue {
  isAuthenticated: boolean;
  user: AuthUser | null;
  token: string | null;
}

// Define custom query result type to help with type assertions
type QueryResult<T> = [T] | [T[]] | any[];

// Type definition for user from auth state
export interface AuthUser {
  id: string;
  username?: string;
  email?: string;
  profile_images?: ProfileImage[];
  profile_image_active?: string;
  [key: string]: any;
}

// Types for profile images
export interface ProfileImage {
  id: string;
  data: string; // Base64 encoded image data
  created_at?: string;
}

export interface Profile {
  username: string;
  email: string;
  profile_images: ProfileImage[];
  profile_image_active?: string; // ID of the active profile image
  global_role: string;
  id?: string;
  created_at?: string;
  updated_at?: string;
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

    // Get the current user's ID
    let user: AuthUser | null = null;
    const unsubscribe = authState.subscribe((state: AuthStateValue) => {
      user = state.user as AuthUser;
    });
    unsubscribe();

    if (!user || !user.id) {
      throw new Error("User not authenticated");
    }

    // Fetch the profile data
    const result = await db.query(`
      SELECT 
        id,
        username,
        email,
        global_role,
        created_at,
        updated_at,
        profile_images,
        profile_image_active
      FROM ${user.id};
    `) as any[];

    if (!result || !result[0] || (Array.isArray(result[0]) && result[0].length === 0)) {
      return null;
    }

    return Array.isArray(result[0]) ? result[0][0] as Profile : result[0] as Profile;
  } catch (error: any) {
    console.error("Error fetching profile:", error);
    throw new Error(
      `Failed to fetch profile: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Uploads a profile image for the current user
 * @param imageData Base64 encoded image data
 */
export async function uploadProfileImage(imageData: string): Promise<ProfileImage> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Get the current user's ID
    let user: AuthUser | null = null;
    const unsubscribe = authState.subscribe((state: AuthStateValue) => {
      user = state.user as AuthUser;
    });
    unsubscribe();

    if (!user || !user.id) {
      throw new Error("User not authenticated");
    }

    // Generate a unique ID for the image
    const imageId = crypto.randomUUID();
    
    // Create a new image and add it to the user's profile_images array
    const result = await db.query(`
      BEGIN TRANSACTION;
      
      // Create a new image object
      LET $image = {
        id: $imageId,
        data: $imageData,
        created_at: time::now()
      };
      
      // Update the user's profile_images array
      LET $profile = UPDATE ${user.id} CONTENT {
        profile_images: array::concat(profile_images || [], [$image]),
        profile_image_active: profile_image_active || $imageId
      };
      
      RETURN {
        image: $image,
        profile: $profile
      };
      
      COMMIT TRANSACTION;
    `, { 
      imageId,
      imageData 
    }) as any[];

    if (!result || !result[0] || !result[0].image) {
      throw new Error("Failed to upload profile image");
    }

    // Update auth state with new profile image
    if (user) {
      const currentUser: AuthUser = { ...user };
      authState.update((state: AuthStateValue) => ({
        ...state,
        user: {
          ...currentUser,
          profile_images: [...(currentUser.profile_images || []), result[0].image as ProfileImage],
          profile_image_active: currentUser.profile_image_active || imageId
        } as AuthUser
      }));
    }

    return result[0].image as ProfileImage;
  } catch (error: any) {
    console.error("Error uploading profile image:", error);
    throw new Error(
      `Failed to upload profile image: ${error instanceof Error ? error.message : String(error)}`
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

    // Get the current user's ID
    let user: AuthUser | null = null;
    (authState as Writable<AuthStateValue>).subscribe((state: AuthStateValue) => {
      user = state.user as AuthUser;
    })();

    if (!user || !user.id) {
      throw new Error("User not authenticated");
    }

    // Update the user's profile_images array to remove the image with the given ID
    await db.query(`
      BEGIN TRANSACTION;
      
      // Get the current profile data
      LET $current = (SELECT profile_images, profile_image_active FROM ${user.id})[0];
      
      // Filter out the image to delete
      LET $updatedImages = array::filter($current.profile_images, function($img) {
        return $img.id != $imageId;
      });
      
      // If we're deleting the active image, set the active image to the first available one
      LET $newActiveImage = $current.profile_image_active == $imageId 
        ? (array::len($updatedImages) > 0 ? $updatedImages[0].id : null)
        : $current.profile_image_active;
      
      // Update the user's profile
      UPDATE ${user.id} CONTENT {
        profile_images: $updatedImages,
        profile_image_active: $newActiveImage
      };
      
      COMMIT TRANSACTION;
    `, { imageId });

    // Update auth state with new profile image data
    authState.update((state: AuthStateValue) => {
      if (!state.user) return state;
      
      const currentUser: AuthUser = { ...state.user };
      const isActiveImageDeleted = currentUser.profile_image_active === imageId;
      const updatedImages = (currentUser.profile_images || []).filter((img: ProfileImage) => img.id !== imageId);
      
      return {
        ...state,
        user: {
          ...currentUser,
          profile_images: updatedImages,
          profile_image_active: isActiveImageDeleted && updatedImages.length > 0
            ? updatedImages[0].id
            : (isActiveImageDeleted ? null : currentUser.profile_image_active)
        } as AuthUser
      };
    });

    return true;
  } catch (error: any) {
    console.error("Error deleting profile image:", error);
    throw new Error(
      `Failed to delete profile image: ${error instanceof Error ? error.message : String(error)}`
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

    // Get the current user's ID
    let user: AuthUser | null = null;
    const unsubscribe = authState.subscribe((state: AuthStateValue) => {
      user = state.user as AuthUser;
    });
    unsubscribe();

    if (!user || !user.id) {
      throw new Error("User not authenticated");
    }

    // Make sure the image exists in the user's profile_images array
    const profile = await getProfile();
    if (!profile || !profile.profile_images.some(img => img.id === imageId)) {
      throw new Error("Image not found in user's profile");
    }

    // Update the user's profile_image_active field
    await db.query(`
      UPDATE ${user.id} CONTENT {
        profile_image_active: $imageId
      };
    `, { imageId });

    // Update auth state with new active profile image
    authState.update((state: AuthStateValue) => {
      if (!state.user) return state;
      
      return {
        ...state,
        user: {
          ...state.user,
          profile_image_active: imageId
        } as AuthUser
      };
    });

    return true;
  } catch (error: any) {
    console.error("Error setting active profile image:", error);
    throw new Error(
      `Failed to set active profile image: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Gets the active profile image for the current user
 */
export function getActiveProfileImage(): ProfileImage | null {
  let user: AuthUser | null = null;
  const unsubscribe = authState.subscribe((state: AuthStateValue) => {
    user = state.user as AuthUser;
  });
  unsubscribe();

  if (!user || !user.profile_images || !user.profile_image_active) {
    return null;
  }

  return user.profile_images.find((img: ProfileImage) => img.id === user.profile_image_active) || null;
}