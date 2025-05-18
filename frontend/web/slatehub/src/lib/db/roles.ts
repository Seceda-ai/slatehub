import {
    db,
    getConnectionState,
    connect,
    ConnectionState,
    authState,
} from "$lib/db/surreal";
import type { AuthState, AuthUser } from "$lib/db/profile";
import type { Department } from "$lib/db/departments";

// Role type definitions
export interface Role {
    id: string;
    name: string;
    slug?: string;
    description?: string;
    created_at?: string;
    updated_at?: string;
    // Add departments as a runtime property that's not in the schema
    departments?: Department[];
}

export interface PersonRole {
    person_has_role_id: string;
    role: {
        id: string;
        name: string;
        slug?: string;
        description?: string;
        created_at?: string;
    };
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
            SELECT
                *,
                (->belongs_to_department->department) AS department
            FROM
                role
            ORDER BY
                department.name ASC,
                name ASC;
    `)) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Process the roles to extract department data
        const roles = Array.isArray(result[0]) ? result[0] : [result[0]];

        // Convert department results to flat department objects
        return roles.map((role) => {
            if (role.departments && Array.isArray(role.departments)) {
                role.departments = role.departments.map(
                    (dept: any) => dept.department,
                );
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
            SELECT *
            FROM $departmentId<-belongs_to_department<-role
            ORDER BY name;
    `,
            { departmentId },
        )) as any[];

        console.log("Roles by Dept Result:", result);

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Extract roles from the result and ensure departments are properly formatted
        const roles = Array.isArray(result[0]) ? result[0] : [result[0]];

        return roles.map((item) => {
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
 * Gets roles assigned to the current user
 */
export async function getPersonRoles(): Promise<PersonRole[]> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID
        let userId: string | null = null;
        const unsubscribe = authState.subscribe((state) => {
            userId = state.user?.id || null;
        });
        unsubscribe();

        if (!userId) {
            throw new Error("User not authenticated");
        }

        const result = (await db.query(
            `
            SELECT
              id AS person_has_role_id,
              out.* AS role
            FROM person_has_role
            WHERE in = $personId
            FETCH out
    `,
            { personId: userId },
        )) as any[];
        console.log("GetPersonRoles: ", result);

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Process the results to format departments correctly
        const personRoles = Array.isArray(result[0]) ? result[0] : [result[0]];
        return personRoles;
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
 */
export async function addRoleToPerson(roleId: string): Promise<PersonRole> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get the current user's ID
        let userId: string | null = null;
        const unsubscribe = authState.subscribe((state) => {
            userId = state.user?.id || null;
        });
        unsubscribe();

        if (!userId) {
            throw new Error("User not authenticated");
        }

        // Add the role to the user
        const result = (await db.query(
            `
            RELATE $personId->person_has_role->$roleId;
    `,
            {
                personId: userId,
                roleId,
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
        let userId: string | null = null;
        const unsubscribe = authState.subscribe((state) => {
            userId = state.user?.id || null;
        });
        unsubscribe();

        if (!userId) {
            throw new Error("User not authenticated");
        }

        console.log("Deleting Role: ", personRoleId);

        // Delete the role relation
        await db.query(
            `
      DELETE $personRoleId;
    `,
            {
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
