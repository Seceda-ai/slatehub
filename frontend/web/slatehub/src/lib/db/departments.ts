import {
    db,
    getConnectionState,
    connect,
    ConnectionState,
    authState,
} from "$lib/db/surreal";
import type { AuthStateValue, AuthUser } from "$lib/db/profile";

// Department type definitions
export interface Department {
    id: string;
    name: string;
    slug: string;
    description?: string;
    created_at?: string;
    updated_at?: string;
}

export interface PersonDepartment {
    id: string;
    in: string;
    out: string;
    added_at: string;
    priority: number;
    department_details: Department;
}

/**
 * Fetches all departments from the database
 */
export async function getAllDepartments(): Promise<Department[]> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        const result = (await db.query(`
      SELECT
        id,
        name,
        slug,
        description,
        created_at,
        updated_at
      FROM department
      ORDER BY name;
    `)) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        return Array.isArray(result[0])
            ? (result[0] as Department[])
            : ([result[0]] as Department[]);
    } catch (error: any) {
        console.error("Error fetching departments:", error);
        throw new Error(
            `Failed to fetch departments: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Gets departments for a specific role
 * @param roleId The role ID to get departments for
 */
export async function getDepartmentsForRole(
    roleId: string,
): Promise<Department[]> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        const result = (await db.query(
            `
      SELECT
        department.id,
        department.name,
        department.description,
        department.created_at,
        department.updated_at
      FROM belongs_to_department
      WHERE in = $roleId
      FETCH department;
    `,
            { roleId },
        )) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Extract the department data from the result
        const departments = result[0].map((item: any) => item.department);

        return departments;
    } catch (error: any) {
        console.error("Error fetching departments for role:", error);
        throw new Error(
            `Failed to fetch departments for role: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Gets specialized departments for the current user
 */
export async function getUserSpecializedDepartments(): Promise<
    PersonDepartment[]
> {
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
        id,
        in,
        out,
        added_at,
        priority,
        (SELECT
          id,
          name,
          description,
          created_at,
          updated_at
        FROM department WHERE id = $parent.out)[0] as department_details
      FROM person_specializes_in
      WHERE in = $personId
      ORDER BY priority DESC, added_at DESC;
    `,
            { personId: userId },
        )) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        return Array.isArray(result[0])
            ? (result[0] as PersonDepartment[])
            : ([result[0]] as PersonDepartment[]);
    } catch (error: any) {
        console.error("Error fetching user specialized departments:", error);
        throw new Error(
            `Failed to fetch user departments: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Add a specialized department to the current user
 * @param departmentId The ID of the department
 * @param priority Priority level (higher numbers = higher priority)
 */
export async function addUserDepartmentSpecialization(
    departmentId: string,
    priority: number = 0,
): Promise<PersonDepartment> {
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

        // Add the department to the user
        const result = (await db.query(
            `
      LET $personDept = CREATE person_specializes_in CONTENT {
        in: $personId,
        out: $departmentId,
        priority: $priority
      };

      RETURN {
        id: $personDept.id,
        in: $personDept.in,
        out: $personDept.out,
        added_at: $personDept.added_at,
        priority: $personDept.priority,
        department_details: (SELECT
          id,
          name,
          description,
          created_at,
          updated_at
        FROM department WHERE id = $departmentId)[0]
      };
    `,
            {
                personId: userId,
                departmentId,
                priority,
            },
        )) as any[];

        if (!result || !result[0]) {
            throw new Error("Failed to add department specialization");
        }

        return result[0] as PersonDepartment;
    } catch (error: any) {
        console.error("Error adding department specialization:", error);
        throw new Error(
            `Failed to add department: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Updates a user's department specialization priority
 * @param personDeptId The ID of the person_specializes_in relation
 * @param priority The new priority level
 */
export async function updateDepartmentPriority(
    personDeptId: string,
    priority: number,
): Promise<PersonDepartment> {
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

        // Update the priority
        const result = (await db.query(
            `
      LET $updated = UPDATE person_specializes_in:$personDeptId
        SET priority = $priority
        WHERE in = $personId;

      RETURN {
        id: $updated.id,
        in: $updated.in,
        out: $updated.out,
        added_at: $updated.added_at,
        priority: $updated.priority,
        department_details: (SELECT
          id,
          name,
          description,
          created_at,
          updated_at
        FROM department WHERE id = $updated.out)[0]
      };
    `,
            {
                personId: userId,
                personDeptId,
                priority,
            },
        )) as any[];

        if (!result || !result[0]) {
            throw new Error("Failed to update department priority");
        }

        return result[0] as PersonDepartment;
    } catch (error: any) {
        console.error("Error updating department priority:", error);
        throw new Error(
            `Failed to update priority: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Removes a department specialization from the current user
 * @param personDeptId The ID of the person_specializes_in relation to remove
 */
export async function removeDepartmentSpecialization(
    personDeptId: string,
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

        // Delete the specialization relation
        await db.query(
            `
      DELETE person_specializes_in:$personDeptId WHERE in = $personId;
    `,
            {
                personId: userId,
                personDeptId,
            },
        );

        return true;
    } catch (error: any) {
        console.error("Error removing department specialization:", error);
        throw new Error(
            `Failed to remove specialization: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

/**
 * Gets roles for a specific department
 * @param departmentId The department ID
 */
export async function getRolesForDepartment(
    departmentId: string,
): Promise<any[]> {
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
        role.external_references
      FROM belongs_to_department
    WHERE out = $departmentId
    FETCH role;
    `,
            { departmentId },
        )) as any[];

        if (!result || !result[0] || result[0].length === 0) {
            return [];
        }

        // Extract the role data from the result
        const roles = result[0].map((item: any) => item.role);

        return roles;
    } catch (error: any) {
        console.error("Error fetching roles for department:", error);
        throw new Error(
            `Failed to fetch roles: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}
