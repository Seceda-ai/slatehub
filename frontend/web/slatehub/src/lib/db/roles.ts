import {
    db,
    getConnectionState,
    connect,
    ConnectionState,
    authState,
} from "$lib/db/surreal";
import type { AuthStateValue, AuthUser } from "$lib/db/profile";
import type { Department } from "$lib/db/departments";

// Role type definitions
export interface Role {
    id: string;
    role_id: string;
    standardized_title: string;
    aliases: string[];
    description: string;
    reports_to?: string;
    departments?: Department[];
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

// Interface for department relationship
export interface RoleDepartment {
    id: string;
    in: string; // role id
    out: string; // department id
    created_at: string;
    department_details: Department;
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

        const result = (await db.query(`
      LET $roles = SELECT
        id,
        role_id,
        standardized_title,
        aliases,
        description,
        reports_to,
        localizations,
        external_references
      FROM role
      ORDER BY standardized_title;
      
      // For each role, fetch its departments
      FOREACH $role IN $roles {
        LET $role.departments = (
          SELECT 
            department.id,
            department.name,
            department.description
          FROM role_belongs_to_department
          WHERE in = $role.id
          FETCH department
        );
      };
      
      RETURN $roles;
    `)) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Process the roles to extract department data
        const roles = Array.isArray(result[0]) ? result[0] : [result[0]];
        
        // Convert department results to flat department objects
        return roles.map(role => {
            if (role.departments && Array.isArray(role.departments)) {
                role.departments = role.departments.map((dept: any) => dept.department);
            }
            return role;
        }) as Role[];
    } catch (error: any) {
        console.error("Error fetching roles:", error);
        throw new Error(
            `Failed to fetch roles: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Gets roles by department
 * @param departmentId The department ID to filter by
 */
export async function getRolesByDepartment(
    departmentId: string,
): Promise<Role[]> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        const result = (await db.query(
            `
      SELECT
        role.id,
        role.role_id,
        role.standardized_title,
        role.aliases,
        role.description,
        role.reports_to,
        role.localizations,
        role.external_references,
        (SELECT 
          department.id,
          department.name,
          department.description
        FROM department 
        WHERE id = $departmentId
        ) AS departments
      FROM role_belongs_to_department
      WHERE out = $departmentId
      FETCH role
      ORDER BY role.standardized_title;
    `,
            { departmentId },
        )) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Extract roles from the result and ensure departments are properly formatted
        const roles = Array.isArray(result[0]) ? result[0] : [result[0]];
        
        return roles.map(item => {
            const role = item.role;
            // Add departments to the role
            role.departments = item.departments;
            return role;
        }) as Role[];
    } catch (error: any) {
        console.error(
            `Error fetching roles for department ${departmentId}:`,
            error,
        );
        throw new Error(
            `Failed to fetch roles: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * This function is deprecated. Use getAllDepartments from departments.ts instead.
 * @deprecated
 */
export async function getAllDepartments(): Promise<string[]> {
    console.warn("getAllDepartments() in roles.ts is deprecated. Use the function from departments.ts instead.");
    
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        const result = (await db.query(`
      SELECT name FROM department ORDER BY name;
    `)) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        const departments = Array.isArray(result[0])
            ? result[0].map((item: any) => item.name)
            : [result[0].name];
            
        return departments;
    } catch (error: any) {
        console.error("Error fetching departments:", error);
        throw new Error(
            `Failed to fetch departments: ${error instanceof Error ? error.message : String(error)}`,
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

        const result = (await db.query(
            `
      LET $personRoles = SELECT
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
          description,
          reports_to,
          localizations,
          external_references
        FROM role WHERE id = $parent.out)[0] as role_details
      FROM person_has_role
      WHERE in = $personId
      ORDER BY added_at DESC;
      
      // For each person role, fetch departments for the role
      FOREACH $personRole IN $personRoles {
        LET $personRole.role_details.departments = (
          SELECT
            department.id,
            department.name,
            department.description
          FROM role_belongs_to_department
          WHERE in = $personRole.role_details.id
          FETCH department
        );
      };
      
      RETURN $personRoles;
    `,
            { personId: user.id },
        )) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Process the results to format departments correctly
        const personRoles = Array.isArray(result[0]) ? result[0] : [result[0]];
        
        return personRoles.map(personRole => {
            if (personRole.role_details && personRole.role_details.departments) {
                // Convert department results to flat department objects
                personRole.role_details.departments = personRole.role_details.departments.map(
                    (dept: any) => dept.department
                );
            }
            return personRole;
        }) as PersonRole[];
    } catch (error: any) {
        console.error("Error fetching person roles:", error);
        throw new Error(
            `Failed to fetch person roles: ${error instanceof Error ? error.message : String(error)}`,
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
    expertiseLevel:
        | "beginner"
        | "intermediate"
        | "expert"
        | "professional" = "intermediate",
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
        const result = (await db.query(
            `
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
    `,
            {
                personId: user.id,
                roleId,
                expertiseLevel,
            },
        )) as any[];

        if (!result || !result[0]) {
            throw new Error("Failed to add role to person");
        }

        return result[0] as PersonRole;
    } catch (error: any) {
        console.error("Error adding role to person:", error);
        throw new Error(
            `Failed to add role: ${error instanceof Error ? error.message : String(error)}`,
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
    expertiseLevel: "beginner" | "intermediate" | "expert" | "professional",
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
        const result = (await db.query(
            `
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
    `,
            {
                personId: user.id,
                personRoleId,
                expertiseLevel,
            },
        )) as any[];

        if (!result || !result[0]) {
            throw new Error("Failed to update role expertise");
        }

        return result[0] as PersonRole;
    } catch (error: any) {
        console.error("Error updating role expertise:", error);
        throw new Error(
            `Failed to update role expertise: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Removes a role from the current user
 * @param personRoleId The ID of the person_has_role relation to remove
 */
export async function removeRoleFromPerson(
    personRoleId: string,
): Promise<boolean> {
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
        await db.query(
            `
      DELETE person_has_role:$personRoleId WHERE in = $personId;
    `,
            {
                personId: user.id,
                personRoleId,
            },
        );

        return true;
    } catch (error: any) {
        console.error("Error removing role from person:", error);
        throw new Error(
            `Failed to remove role: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}
