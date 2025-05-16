import {
  db,
  getConnectionState,
  connect,
  ConnectionState,
  authState,
} from "$lib/db/surreal";
import type { AuthStateValue, AuthUser } from "$lib/db/profile";

// Role type definitions
export interface Role {
  id: string;
  role_id: string;
  standardized_title: string;
  aliases: string[];
  department: string;
  description: string;
  reports_to?: string;
  localizations: {
    en: string;
    en_uk: string;
    de: string;
    fr: string;
    it: string;
    es: string;
    pt: string;
    nl: string;
  };
  external_references: {
    imdb?: string;
    tmdb?: string;
  };
}

export interface PersonRole {
  id: string;
  in: string;
  out: string;
  added_at: string;
  expertise_level: "beginner" | "intermediate" | "expert" | "professional";
  role_details: Role;
}

/**
 * Fetches all production roles from the database
 */
export async function getAllRoles(): Promise<Role[]> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    const result = await db.query(`
      SELECT 
        id,
        role_id,
        standardized_title,
        aliases,
        department,
        description,
        reports_to,
        localizations,
        external_references
      FROM role
      ORDER BY department, standardized_title;
    `) as any[];

    if (!result || !result[0] || result[0].length === 0) {
      return [];
    }

    return Array.isArray(result[0]) ? result[0] as Role[] : [result[0]] as Role[];
  } catch (error: any) {
    console.error("Error fetching roles:", error);
    throw new Error(
      `Failed to fetch roles: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Gets roles by department
 * @param department The department to filter by
 */
export async function getRolesByDepartment(department: string): Promise<Role[]> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    const result = await db.query(`
      SELECT 
        id,
        role_id,
        standardized_title,
        aliases,
        department,
        description,
        reports_to,
        localizations,
        external_references
      FROM role
      WHERE department = $department
      ORDER BY standardized_title;
    `, { department }) as any[];

    if (!result || !result[0] || result[0].length === 0) {
      return [];
    }

    return Array.isArray(result[0]) ? result[0] as Role[] : [result[0]] as Role[];
  } catch (error: any) {
    console.error(`Error fetching roles for department ${department}:`, error);
    throw new Error(
      `Failed to fetch roles: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Gets all departments
 */
export async function getAllDepartments(): Promise<string[]> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    const result = await db.query(`
      SELECT DISTINCT department FROM role ORDER BY department;
    `) as any[];

    if (!result || !result[0] || result[0].length === 0) {
      return [];
    }

    const departments = Array.isArray(result[0]) 
      ? result[0].map((item: any) => item.department) 
      : [result[0].department];
      
    return departments;
  } catch (error: any) {
    console.error("Error fetching departments:", error);
    throw new Error(
      `Failed to fetch departments: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Gets roles assigned to the current user
 */
export async function getPersonRoles(): Promise<PersonRole[]> {
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

    const result = await db.query(`
      SELECT 
        id,
        in,
        out,
        added_at,
        expertise_level,
        (SELECT 
          id,
          role_id,
          standardized_title,
          aliases,
          department,
          description,
          reports_to,
          localizations,
          external_references
        FROM role WHERE id = $parent.out)[0] as role_details
      FROM person_has_role
      WHERE in = $personId
      ORDER BY added_at DESC;
    `, { personId: user.id }) as any[];

    if (!result || !result[0] || result[0].length === 0) {
      return [];
    }

    return Array.isArray(result[0]) ? result[0] as PersonRole[] : [result[0]] as PersonRole[];
  } catch (error: any) {
    console.error("Error fetching person roles:", error);
    throw new Error(
      `Failed to fetch person roles: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Adds a role to the current user
 * @param roleId The ID of the role to add
 * @param expertiseLevel The user's expertise level with this role
 */
export async function addRoleToPerson(
  roleId: string, 
  expertiseLevel: "beginner" | "intermediate" | "expert" | "professional" = "intermediate"
): Promise<PersonRole> {
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

    // Add the role to the user
    const result = await db.query(`
      LET $personRole = CREATE person_has_role SET
        in = $personId,
        out = $roleId,
        expertise_level = $expertiseLevel;
      
      RETURN {
        id: $personRole.id,
        in: $personRole.in,
        out: $personRole.out,
        added_at: $personRole.added_at,
        expertise_level: $personRole.expertise_level,
        role_details: (SELECT 
          id,
          role_id,
          standardized_title,
          aliases,
          department,
          description,
          reports_to,
          localizations,
          external_references
        FROM role WHERE id = $roleId)[0]
      };
    `, { 
      personId: user.id,
      roleId,
      expertiseLevel 
    }) as any[];

    if (!result || !result[0]) {
      throw new Error("Failed to add role to person");
    }

    return result[0] as PersonRole;
  } catch (error: any) {
    console.error("Error adding role to person:", error);
    throw new Error(
      `Failed to add role: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Updates a person's expertise level for a role
 * @param personRoleId The ID of the person_has_role relation
 * @param expertiseLevel The new expertise level
 */
export async function updatePersonRoleExpertise(
  personRoleId: string, 
  expertiseLevel: "beginner" | "intermediate" | "expert" | "professional"
): Promise<PersonRole> {
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

    // Update the expertise level
    const result = await db.query(`
      LET $updated = UPDATE person_has_role:$personRoleId 
        SET expertise_level = $expertiseLevel
        WHERE in = $personId;
      
      RETURN {
        id: $updated.id,
        in: $updated.in,
        out: $updated.out,
        added_at: $updated.added_at,
        expertise_level: $updated.expertise_level,
        role_details: (SELECT 
          id,
          role_id,
          standardized_title,
          aliases,
          department,
          description,
          reports_to,
          localizations,
          external_references
        FROM role WHERE id = $updated.out)[0]
      };
    `, { 
      personId: user.id,
      personRoleId,
      expertiseLevel 
    }) as any[];

    if (!result || !result[0]) {
      throw new Error("Failed to update role expertise");
    }

    return result[0] as PersonRole;
  } catch (error: any) {
    console.error("Error updating role expertise:", error);
    throw new Error(
      `Failed to update role expertise: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}

/**
 * Removes a role from the current user
 * @param personRoleId The ID of the person_has_role relation to remove
 */
export async function removeRoleFromPerson(personRoleId: string): Promise<boolean> {
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

    // Delete the role relation
    await db.query(`
      DELETE person_has_role:$personRoleId WHERE in = $personId;
    `, { 
      personId: user.id,
      personRoleId
    });

    return true;
  } catch (error: any) {
    console.error("Error removing role from person:", error);
    throw new Error(
      `Failed to remove role: ${error instanceof Error ? error.message : String(error)}`
    );
  }
}