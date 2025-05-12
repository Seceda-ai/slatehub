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
export interface Organization {
  id?: string;
  name: string;
  slug: string;
  created_at?: string;
  updated_at?: string;
}

export interface OrganizationMember {
  id?: string;
  in: string; // person id
  out: string; // organization id
  role: "owner" | "admin" | "editor" | "viewer";
  created_at?: string;
  updated_at?: string;
  person?: {
    username: string;
    email: string;
  };
}

// Get all organizations for the current user
export async function getUserOrganizations(): Promise<Organization[]> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Get organizations where the user is a member
    const result = await db.query<[Organization[]]>(`
      SELECT organization.*
      FROM member_of_org
      WHERE in = $auth.id
      FETCH organization.*
    `);

    return result[0] || [];
  } catch (error) {
    console.error("Error fetching user organizations:", error);
    throw new Error(
      `Failed to fetch organizations: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

// Create a new organization and set current user as owner
export async function createOrganization(name: string): Promise<Organization> {
  if (!name || name.trim() === "") {
    throw new Error("Organization name is required");
  }

  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Use a transaction to create both organization and membership
    const result = await db.query<
      [{ organization: Organization; membership: any }]
    >(
      `
      BEGIN TRANSACTION;

      // Create the organization
      LET $org = CREATE organization CONTENT {
        name: $name
      };

      // Create the membership edge with owner role
      LET $membership = CREATE member_of_org CONTENT {
        in: $auth.id,
        out: $org.id,
        role: "${OWNER_ROLE}"
      };

      // Return the organization
      RETURN {
        organization: $org,
        membership: $membership
      };

      COMMIT TRANSACTION;
    `,
      { name },
    );

    // Extract the organization from the result
    if (!result[0]?.organization) {
      throw new Error("Failed to create organization");
    }

    return result[0].organization;
  } catch (error) {
    // Simple error handling
    const message = error instanceof Error ? error.message : String(error);
    throw new Error(`Failed to create organization: ${message}`);
  }
}

// Get organization by slug or ID
export async function getOrganizationBySlug(
  slugOrId: string,
): Promise<Organization | null> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Check if the value looks like an ID (organization:xyz format)
    const isId = slugOrId.includes(":") || slugOrId.includes("/");

    // Construct the appropriate query based on whether we have an ID or slug
    const sql = isId
      ? `SELECT * FROM ${slugOrId}
       WHERE id IN (SELECT out FROM member_of_org WHERE in = $auth.id)`
      : `SELECT * FROM organization
       WHERE slug = $slug
       AND id IN (SELECT out FROM member_of_org WHERE in = $auth.id)`;

    // Execute the query
    const result = await db.query<[Organization[]]>(
      sql,
      isId ? {} : { slug: slugOrId },
    );

    // Return the first organization or null if none found
    if (result[0] && result[0].length > 0) {
      return result[0][0];
    }

    return null;
  } catch (error) {
    console.error(
      `Error fetching organization with slug/id '${slugOrId}':`,
      error,
    );
    throw error;
  }
}

// Update an organization
export async function updateOrganization(
  id: string,
  data: Partial<Organization>,
): Promise<Organization> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // The schema will auto-generate the slug from the updated name
    const result = await db.query<[Organization[]]>(
      `
      UPDATE ${id} CONTENT {
        name: $name,
        updated_at: time::now()
      }
      WHERE id IN (
        SELECT out FROM member_of_org
        WHERE in = $auth.id
        AND role IN ["owner", "admin"]
      )
      RETURN *;
    `,
      { name: data.name },
    );

    // Check if we got a result back
    if (!result[0] || result[0].length === 0) {
      throw new Error("Failed to update organization or you lack permission");
    }

    return result[0][0];
  } catch (error) {
    console.error("Error updating organization:", error);
    throw error;
  }
}

// Delete an organization
export async function deleteOrganization(id: string): Promise<boolean> {
  if (!id) throw new Error("Organization ID is required");

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
        SELECT * FROM member_of_org
        WHERE in = $auth.id
        AND out = $id
        AND role = "${OWNER_ROLE}"
      )[0];

      // Throw error if not owner
      IF $isOwner == NONE THEN
        THROW "Only organization owners can delete organizations";
      END;

      // Delete member relationships
      DELETE member_of_org WHERE out = $id;

      // Delete the organization
      DELETE $id;

      COMMIT TRANSACTION;
    `,
      { id },
    );

    return true;
  } catch (error) {
    console.error("Error deleting organization:", error);
    throw new Error(
      `Failed to delete organization: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

// Get all members of an organization
export async function getOrganizationMembers(
  orgId: string,
): Promise<OrganizationMember[]> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Get all members with person details
    const result = await db.query<[OrganizationMember[]]>(
      `
      SELECT
        id,
        in,
        out,
        role,
        joined_at,
        (SELECT username, email FROM person WHERE id = in) AS person
      FROM member_of_org
      WHERE out = $orgId
    `,
      { orgId },
    );

    return result[0] || [];
  } catch (error) {
    console.error("Error fetching organization members:", error);
    throw new Error(
      `Failed to fetch organization members: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

// Add a member to an organization
export async function addOrganizationMember(
  orgId: string,
  username: string,
  role: "admin" | "editor" | "viewer",
): Promise<OrganizationMember> {
  if (!orgId) throw new Error("Organization ID is required");
  if (!username) throw new Error("Username is required");
  if (!role) throw new Error("Role is required");

  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Do everything in a single transaction
    const result = await db.query<[OrganizationMember[]]>(
      `
      BEGIN TRANSACTION;

      // Check if current user has permission
      LET $hasPermission = (
        SELECT * FROM member_of_org
        WHERE in = $auth.id
        AND out = $orgId
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
        SELECT * FROM member_of_org
        WHERE in = $person.id AND out = $orgId
      )[0];

      IF $existing != NONE THEN
        THROW "User is already a member of this organization";
      END;

      // Add the user as a member
      LET $member = CREATE member_of_org CONTENT {
        in: $person.id,
        out: $orgId,
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
      { orgId, username, role },
    );

    if (!result[0] || result[0].length === 0) {
      throw new Error("Failed to add member");
    }

    return result[0][0];
  } catch (error) {
    console.error("Error adding organization member:", error);
    throw new Error(
      `Failed to add member: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

// Update a member's role
export async function updateMemberRole(
  memberId: string,
  newRole: "owner" | "admin" | "editor" | "viewer",
): Promise<OrganizationMember> {
  if (!memberId) throw new Error("Member ID is required");
  if (!newRole) throw new Error("New role is required");

  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Handle permission checks and update in a single transaction
    const result = await db.query<[OrganizationMember[]]>(
      `
      BEGIN TRANSACTION;

      // Get the membership info
      LET $membership = (SELECT * FROM ${memberId})[0];

      // Error if membership not found
      IF $membership == NONE THEN
        THROW "Membership not found";
      END;

      // Get the organization ID
      LET $orgId = $membership.out;

      // Check if current user has permission
      LET $hasPermission = (
        SELECT * FROM member_of_org
        WHERE in = $auth.id
        AND out = $orgId
        AND role IN ["${OWNER_ROLE}", "${ADMIN_ROLE}"]
      )[0];

      IF $hasPermission == NONE THEN
        THROW "You must be an owner or admin to change member roles";
      END;

      // If changing to owner role, check if current user is owner
      IF $newRole == "${OWNER_ROLE}" THEN
        LET $isOwner = (
          SELECT * FROM member_of_org
          WHERE in = $auth.id
          AND out = $orgId
          AND role = "${OWNER_ROLE}"
        )[0];

        IF $isOwner == NONE THEN
          THROW "Only organization owners can assign owner role";
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

// Remove a member from an organization
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

      LET $orgId = $membership.out;
      LET $personId = $membership.in;
      LET $memberRole = $membership.role;

      // Check if current user has permission
      LET $hasPermission = (
        SELECT * FROM member_of_org
        WHERE in = $auth.id
        AND out = $orgId
        AND role IN ["${OWNER_ROLE}", "${ADMIN_ROLE}"]
      )[0];

      IF $hasPermission == NONE THEN
        THROW "You must be an owner or admin to remove members";
      END;

      // If removing an owner, check if current user is also an owner
      IF $memberRole == "${OWNER_ROLE}" THEN
        LET $isOwner = (
          SELECT * FROM member_of_org
          WHERE in = $auth.id
          AND out = $orgId
          AND role = "${OWNER_ROLE}"
        )[0];

        IF $isOwner == NONE THEN
          THROW "Only organization owners can remove other owners";
        END;
      END;

      // Get current user info
      LET $currentUser = $auth.id;

      // Prevent removing yourself
      IF $personId == $currentUser THEN
        THROW "You cannot remove yourself from an organization";
      END;

      // Delete the membership
      DELETE ${memberId};

      COMMIT TRANSACTION;
    `);

    return true;
  } catch (error) {
    console.error("Error removing organization member:", error);
    throw new Error(
      `Failed to remove member: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}
