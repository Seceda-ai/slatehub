import {
    db,
    getConnectionState,
    connect,
    ConnectionState,
} from "$lib/db/surreal";

// Constants
const OWNER_ROLE = "owner";
const ADMIN_ROLE = "admin";
const EDITOR_ROLE = "editor";
const VIEWER_ROLE = "viewer";

// Interfaces
export interface Production {
    id?: string;
    title: string;
    slug: string;
    created_at?: string;
    updated_at?: string;
}

export interface ProductionMember {
    id?: string;
    in: string; // person id
    out: string; // production id
    role: "owner" | "admin" | "editor" | "viewer";
    created_at?: string;
    updated_at?: string;
    person?: {
        username: string;
        email: string;
    };
}

// Get all productions for the current user
export async function getUserProductions(): Promise<Production[]> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get productions where the user is a member
        const result = await db.query<[Production[]]>(`
       $auth.id->(SELECT * FROM membership ORDER BY out.title)->production.*;
    `);

        console.log("Get Productions: \n", JSON.stringify(result, null, 2));

        // Safely handle the response structure
        if (!result || result.length === 0 || !result[0]) {
            return [];
        }

        // Flatten the array structure if needed
        const productions = Array.isArray(result[0]) ? result[0] : [result[0]];

        // Filter out any null or undefined values
        return productions.filter(
            (p) => p !== null && p !== undefined,
        ) as Production[];
    } catch (error) {
        console.error("Error fetching user productions:", error);
        throw new Error(
            `Failed to fetch productions: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

// Create a new production and set current user as owner
export async function createProduction(title: string): Promise<Production> {
    if (!title || title.trim() === "") {
        throw new Error("Production title is required");
    }

    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Use a transaction to create both production and membership
        const result = await db.query<
            [{ production: Production; membership: any }]
        >(
            `
      BEGIN TRANSACTION;

      // Create the production
      LET $prod = CREATE production CONTENT {
        title: $title
      };

      // Create the membership edge with owner role
      LET $membership = RELATE $auth->membership->$prod SET role = 'owner';

      // Return the production
      RETURN {
        production: $prod,
        membership: $membership
      };

      COMMIT TRANSACTION;
    `,
            { title },
        );

        console.log("Production Create: ", result);
        // Extract the production from the result
        if (!result[0]?.production) {
            throw new Error("Failed to create production");
        }

        return result[0].production;
    } catch (error) {
        // Simple error handling
        const message = error instanceof Error ? error.message : String(error);
        throw new Error(`Failed to create production: ${message}`);
    }
}

// Get production by slug or ID
export async function getProductionBySlug(
    slugOrId: string,
): Promise<Production | null> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Check if the value looks like an ID (production:xyz format)
        const isId = slugOrId.includes(":") || slugOrId.includes("/");

        // Construct the appropriate query based on whether we have an ID or slug
        const sql = `SELECT * FROM production
       WHERE slug = $slug;`;

        // Execute the query
        const result = await db.query<[Production[]]>(sql, { slug: slugOrId });

        // Return the first production or null if none found
        if (result[0] && result[0].length > 0) {
            return result[0][0];
        }

        return null;
    } catch (error) {
        console.error(
            `Error fetching production with slug/id '${slugOrId}':`,
            error,
        );
        throw error;
    }
}

// Update a production
export async function updateProduction(
    id: string,
    data: Partial<Production>,
): Promise<Production> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // The schema will auto-generate the slug from the updated title
        const result = await db.query<[Production[]]>(
            `
      UPDATE ${id} CONTENT {
        title: $title,
        updated_at: time::now()
      }
      WHERE id IN (
        SELECT out FROM membership
        WHERE in = $auth.id
        AND role IN ["owner", "admin"]
      )
      RETURN *;
    `,
            { title: data.title },
        );

        // Check if we got a result back
        if (!result[0] || result[0].length === 0) {
            throw new Error(
                "Failed to update production or you lack permission",
            );
        }

        return result[0][0];
    } catch (error) {
        console.error("Error updating production:", error);
        throw error;
    }
}

// Delete a production
export async function deleteProduction(id: string): Promise<boolean> {
    if (!id) throw new Error("Production ID is required");

    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Check permission and delete in a single transaction
        await db.query(
            `
      BEGIN TRANSACTION;

      // Check if user is owner
      LET $isOwner = (
        SELECT * FROM membership
        WHERE in = $auth.id
        AND out = $id
        AND role = "${OWNER_ROLE}"
      )[0];

      // Throw error if not owner
      IF $isOwner == NONE THEN
        THROW "Only production owners can delete productions";
      END;

      // Delete member relationships
      DELETE membership WHERE out = $id;

      // Delete the production
      DELETE $id;

      COMMIT TRANSACTION;
    `,
            { id },
        );

        return true;
    } catch (error) {
        console.error("Error deleting production:", error);
        throw new Error(
            `Failed to delete production: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

// Get all members of a production
export async function getProductionMembers(
    prodId: string,
): Promise<ProductionMember[]> {
    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Get all members with person details
        const result = await db.query<[ProductionMember[]]>(
            `
      SELECT
        id,
        in,
        out,
        role,
        joined_at,
        (SELECT username, email FROM person WHERE id = in) AS person
      FROM membership
      WHERE out = $prodId
    `,
            { prodId },
        );

        return result[0] || [];
    } catch (error) {
        console.error("Error fetching production members:", error);
        throw new Error(
            `Failed to fetch production members: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

// Add a member to a production
export async function addProductionMember(
    prodId: string,
    username: string,
    role: "admin" | "editor" | "viewer",
): Promise<ProductionMember> {
    if (!prodId) throw new Error("Production ID is required");
    if (!username) throw new Error("Username is required");
    if (!role) throw new Error("Role is required");

    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Do everything in a single transaction
        const result = await db.query<[ProductionMember[]]>(
            `
      BEGIN TRANSACTION;

      // Check if current user has permission
      LET $hasPermission = (
        SELECT * FROM membership
        WHERE in = $auth.id
        AND out = $prodId
        AND role IN ["${OWNER_ROLE}", "${ADMIN_ROLE}"]
      )[0];

      IF $hasPermission == NONE THEN
        THROW "You must be an owner or admin to add members";
      END;

      // Find the person by username
      LET $person = (SELECT id FROM person WHERE username = $username)[0];

      // Check if person exists
      IF $person.id == NONE THEN
        THROW "User not found";
      END;

      // Check if already a member
      LET $existing = (
        SELECT * FROM membership
        WHERE in = $person.id AND out = $prodId
      )[0];

      IF $existing != NONE THEN
        THROW "User is already a member of this production";
      END;

      // Add the user as a member
      LET $member = CREATE membership CONTENT {
        in: $person.id,
        out: $prodId,
        role: $role,
        joined_at: time::now()
      };

      // Return with user details
      RETURN SELECT
        id,
        in,
        out,
        role,
        joined_at,
        (SELECT username, email FROM person WHERE id = in) AS person
      FROM $member.id;

      COMMIT TRANSACTION;
    `,
            { prodId, username, role },
        );

        if (!result[0] || result[0].length === 0) {
            throw new Error("Failed to add member");
        }

        return result[0][0];
    } catch (error) {
        console.error("Error adding production member:", error);
        throw new Error(
            `Failed to add member: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

// Update a member's role
export async function updateMemberRole(
    memberId: string,
    newRole: "owner" | "admin" | "editor" | "viewer",
): Promise<ProductionMember> {
    if (!memberId) throw new Error("Member ID is required");
    if (!newRole) throw new Error("New role is required");

    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Handle permission checks and update in a single transaction
        const result = await db.query<[ProductionMember[]]>(
            `
      BEGIN TRANSACTION;

      // Get the membership info
      LET $membership = (SELECT * FROM ${memberId})[0];

      // Error if membership not found
      IF $membership == NONE THEN
        THROW "Membership not found";
      END;

      // Get the production ID
      LET $prodId = $membership.out;

      // Check if current user has permission
      LET $hasPermission = (
        SELECT * FROM membership
        WHERE in = $auth.id
        AND out = $prodId
        AND role IN ["${OWNER_ROLE}", "${ADMIN_ROLE}"]
      )[0];

      IF $hasPermission == NONE THEN
        THROW "You must be an owner or admin to change member roles";
      END;

      // If changing to owner role, check if current user is owner
      IF $newRole == "${OWNER_ROLE}" THEN
        LET $isOwner = (
          SELECT * FROM membership
          WHERE in = $auth.id
          AND out = $prodId
          AND role = "${OWNER_ROLE}"
        )[0];

        IF $isOwner == NONE THEN
          THROW "Only production owners can assign owner role";
        END;
      END;

      // Update the role and return updated member
      UPDATE ${memberId} CONTENT {
        role: $newRole
      }
      RETURN
        id,
        in,
        out,
        role,
        joined_at,
        (SELECT username, email FROM person WHERE id = in) AS person;

      COMMIT TRANSACTION;
    `,
            { newRole },
        );

        if (!result[0] || result[0].length === 0) {
            throw new Error("Failed to update member role");
        }

        return result[0][0];
    } catch (error) {
        console.error("Error updating member role:", error);
        throw new Error(
            `Failed to update member role: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}

// Remove a member from a production
export async function removeMember(memberId: string): Promise<boolean> {
    if (!memberId) throw new Error("Member ID is required");

    try {
        // Ensure we're connected
        if (getConnectionState() !== ConnectionState.CONNECTED) {
            await connect();
        }

        // Perform permission checks and deletion in a single transaction
        await db.query(`
      BEGIN TRANSACTION;

      // Get membership information
      LET $membership = (SELECT * FROM ${memberId})[0];

      // Error if membership not found
      IF $membership == NONE THEN
        THROW "Membership not found";
      END;

      LET $prodId = $membership.out;
      LET $personId = $membership.in;
      LET $memberRole = $membership.role;

      // Check if current user has permission
      LET $hasPermission = (
        SELECT * FROM membership
        WHERE in = $auth.id
        AND out = $prodId
        AND role IN ["${OWNER_ROLE}", "${ADMIN_ROLE}"]
      )[0];

      IF $hasPermission == NONE THEN
        THROW "You must be an owner or admin to remove members";
      END;

      // If removing an owner, check if current user is also an owner
      IF $memberRole == "${OWNER_ROLE}" THEN
        LET $isOwner = (
          SELECT * FROM membership
          WHERE in = $auth.id
          AND out = $prodId
          AND role = "${OWNER_ROLE}"
        )[0];

        IF $isOwner == NONE THEN
          THROW "Only production owners can remove other owners";
        END;
      END;

      // Get current user info
      LET $currentUser = $auth.id;

      // Prevent removing yourself
      IF $personId == $currentUser THEN
        THROW "You cannot remove yourself from a production";
      END;

      // Delete the membership
      DELETE ${memberId};

      COMMIT TRANSACTION;
    `);

        return true;
    } catch (error) {
        console.error("Error removing production member:", error);
        throw new Error(
            `Failed to remove member: ${error instanceof Error ? error.message : String(error)}`,
        );
    }
}
