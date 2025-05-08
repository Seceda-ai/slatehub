import {
  query,
  getConnectionState,
  connect,
  ConnectionState,
} from "$lib/db/surreal";

// Interfaces
export interface Organization {
  id?: string;
  name: string;
  slug: string;
  created_at?: string;
}

export interface OrganizationMember {
  id?: string;
  in: string; // person id
  out: string; // organization id
  role: "owner" | "admin" | "editor" | "viewer";
  joined_at?: string;
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
    const result = await query<[Organization[]]>(`
          SELECT organization.*
          FROM member_of_org
          WHERE in = $auth.id
          FETCH organization.*
        `);

    return result[0] || [];
  } catch (error) {
    console.error("Error fetching user organizations:", error);
    throw error;
  }
}

// Create a new organization
export async function createOrganization(name: string): Promise<Organization> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // First create the organization
    try {
      // Log the current user for debugging
      console.log("Current auth user:", await query("SELECT * FROM $auth"));

      // Create organization with a more basic query
      const createResult = await query(`CREATE organization SET name = $name`, {
        name,
      });

      console.log(
        "Organization creation raw result:",
        JSON.stringify(createResult),
      );

      // Extract the organization ID from the result, handling different response formats
      let orgId = "";

      // Dump the structure for debugging
      console.log("Create result type:", typeof createResult);
      console.log(
        "Create result structure:",
        JSON.stringify(createResult, null, 2),
      );

      try {
        // Most common format: [{ result: [{ id: "organization:xyz" }] }]
        if (Array.isArray(createResult) && createResult.length > 0) {
          if (
            createResult[0]?.result &&
            Array.isArray(createResult[0].result)
          ) {
            orgId = createResult[0].result[0]?.id;
          }
          // Format: [{ id: "organization:xyz" }]
          else if (createResult[0]?.id) {
            orgId = createResult[0].id;
          }
          // Format: [[{ id: "organization:xyz" }]]
          else if (
            Array.isArray(createResult[0]) &&
            createResult[0].length > 0 &&
            createResult[0][0]?.id
          ) {
            orgId = createResult[0][0].id;
          }
        }
      } catch (e) {
        console.error("Error parsing organization ID:", e);
      }

      console.log("Extracted organization ID:", orgId);

      if (!orgId) {
        // As a fallback, query for the recently created organization
        console.log(
          "ID extraction failed, trying to find the org by name/slug",
        );
        const findResult = await query(
          `
        SELECT id FROM organization
        WHERE name = $name AND slug = $slug
        ORDER BY created_at DESC
        LIMIT 1
      `,
          { name, slug },
        );

        console.log("Find result:", JSON.stringify(findResult));

        // Try to extract ID from the find result
        if (
          Array.isArray(findResult) &&
          findResult.length > 0 &&
          Array.isArray(findResult[0]) &&
          findResult[0].length > 0
        ) {
          orgId = findResult[0][0].id;
          console.log("Found organization ID through query:", orgId);
        }

        if (!orgId) {
          throw new Error("Could not extract or find organization ID");
        }
      }

      // Add current user as owner
      const memberResult = await query(
        `
      CREATE member_of_org CONTENT {
        in: $auth.id,
        out: $orgId,
        role: "owner",
        joined_at: time::now()
      }
    `,
        { orgId },
      );

      console.log("Membership creation result:", JSON.stringify(memberResult));

      // Return the organization object directly
      return {
        id: orgId,
        name: name,
        slug: slug,
        created_at: new Date().toISOString(),
      };
    } catch (err) {
      console.error("Error in organization creation process:", err);
      throw new Error(`Organization creation failed: ${err.message}`);
    }
  } catch (error) {
    console.error("Error creating organization:", error);
    throw error;
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

    console.log(`Looking up organization with slug/id: ${slugOrId}`);

    // Check if the value looks like an ID (organization:xyz format)
    const isId = slugOrId.includes(":") || slugOrId.includes("/");

    let result;
    if (isId) {
      // If it's an ID, use direct lookup
      result = await query<[Organization[]]>(`
        SELECT *
        FROM ${slugOrId}
        WHERE id IN (
          SELECT out FROM member_of_org
          WHERE in = $auth.id
        )
      `);
    } else {
      // Otherwise treat as slug
      result = await query<[Organization[]]>(
        `
        SELECT *
        FROM organization
        WHERE slug = $slug
        AND id IN (
          SELECT out FROM member_of_org
          WHERE in = $auth.id
        )
      `,
        { slug: slugOrId },
      );
    }

    console.log("Organization lookup result:", JSON.stringify(result));

    // Extract the organization from the result
    let org = null;
    if (Array.isArray(result) && result.length > 0) {
      if (Array.isArray(result[0]) && result[0].length > 0) {
        org = result[0][0];
      } else if (typeof result[0] === "object") {
        org = result[0];
      }
    }

    // Log and validate what we found
    console.log("Organization found:", org);

    return org;
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

    // Generate a slug if the name was updated
    const slug = data.name
      ? data.name
          .toLowerCase()
          .replace(/[^\w-]+/g, "-")
          .replace(/^-+|-+$/g, "")
      : undefined;

    const result = await query<[Organization[]]>(
      `
        UPDATE ${id} CONTENT {
          name: $name,
          slug: $slug
        }
        WHERE id IN (
          SELECT out FROM member_of_org
          WHERE in = $auth.id
          AND role IN ["owner", "admin"]
        );
      `,
      { name: data.name, slug },
    );

    // Fetch the updated organization
    const orgResult = await query<[Organization[]]>(`
        SELECT * FROM ${id}
        WHERE id IN (
          SELECT out FROM member_of_org
          WHERE in = $auth.id
        )
      `);

    console.log("Organization update result:", JSON.stringify(orgResult));

    // Extract the organization from the result
    let org = null;
    if (Array.isArray(orgResult) && orgResult.length > 0) {
      if (Array.isArray(orgResult[0]) && orgResult[0].length > 0) {
        org = orgResult[0][0];
      } else if (typeof orgResult[0] === "object") {
        org = orgResult[0];
      }
    }

    if (!org) {
      throw new Error("Failed to update organization or you lack permission");
    }

    return org;
  } catch (error) {
    console.error("Error updating organization:", error);
    throw error;
  }
}

// Delete an organization
export async function deleteOrganization(id: string): Promise<boolean> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // First check if user is owner
    const checkResult = await query<[OrganizationMember[]]>(
      `
      SELECT * FROM member_of_org
      WHERE in = $auth.id
      AND out = $id
      AND role = "owner";
    `,
      { id },
    );

    if (!checkResult[0] || checkResult[0].length === 0) {
      throw new Error("Only organization owners can delete organizations");
    }

    // Delete org and all relationships in transaction
    await query(
      `
      BEGIN TRANSACTION;

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
    throw error;
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

    const result = await query<[OrganizationMember[]]>(
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
    throw error;
  }
}

// Add a member to an organization
export async function addOrganizationMember(
  orgId: string,
  username: string,
  role: "admin" | "editor" | "viewer",
): Promise<OrganizationMember> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // First check if current user has permission (must be owner or admin)
    const checkResult = await query<[OrganizationMember[]]>(
      `
      SELECT * FROM member_of_org
      WHERE in = $auth.id
      AND out = $orgId
      AND role IN ["owner", "admin"];
    `,
      { orgId },
    );

    if (!checkResult[0] || checkResult[0].length === 0) {
      throw new Error("You must be an owner or admin to add members");
    }

    // Now add the user
    const result = await query<[OrganizationMember[]]>(
      `
      BEGIN TRANSACTION;

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
          FROM $member.id

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
    throw error;
  }
}

// Update a member's role
export async function updateMemberRole(
  memberId: string,
  newRole: "owner" | "admin" | "editor" | "viewer",
): Promise<OrganizationMember> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // First get the organization ID from the membership
    const membershipResult = await query<[OrganizationMember[]]>(`
      SELECT * FROM ${memberId};
    `);

    if (!membershipResult[0] || membershipResult[0].length === 0) {
      throw new Error("Membership not found");
    }

    const orgId = membershipResult[0][0].out;

    // Check if current user has permission (must be owner or admin)
    const checkResult = await query<[OrganizationMember[]]>(
      `
      SELECT * FROM member_of_org
      WHERE in = $auth.id
      AND out = $orgId
      AND role IN ["owner", "admin"];
    `,
      { orgId },
    );

    if (!checkResult[0] || checkResult[0].length === 0) {
      throw new Error("You must be an owner or admin to change member roles");
    }

    // If changing to owner role, make sure current user is owner
    if (newRole === "owner") {
      const ownerCheckResult = await query<[OrganizationMember[]]>(
        `
        SELECT * FROM member_of_org
        WHERE in = $auth.id
        AND out = $orgId
        AND role = "owner";
      `,
        { orgId },
      );

      if (!ownerCheckResult[0] || ownerCheckResult[0].length === 0) {
        throw new Error("Only organization owners can assign owner role");
      }
    }

    // Update the role
    const result = await query<[OrganizationMember[]]>(
      `
      UPDATE ${memberId} CONTENT {
        role: $newRole
      }
      RETURN
        id,
        in,
        out,
        role,
        joined_at,
        (SELECT username, email FROM person WHERE id = in) AS person
    `,
      { newRole },
    );

    if (!result[0] || result[0].length === 0) {
      throw new Error("Failed to update member role");
    }

    return result[0][0];
  } catch (error) {
    console.error("Error updating member role:", error);
    throw error;
  }
}

// Remove a member from an organization
export async function removeMember(memberId: string): Promise<boolean> {
  try {
    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // First get the organization ID from the membership
    const membershipResult = await query<[OrganizationMember[]]>(`
      SELECT * FROM ${memberId};
    `);

    if (!membershipResult[0] || membershipResult[0].length === 0) {
      throw new Error("Membership not found");
    }

    const orgId = membershipResult[0][0].out;
    const personId = membershipResult[0][0].in;

    // Check if current user has permission (must be owner or admin)
    const checkResult = await query<[OrganizationMember[]]>(
      `
      SELECT * FROM member_of_org
      WHERE in = $auth.id
      AND out = $orgId
      AND role IN ["owner", "admin"];
    `,
      { orgId },
    );

    if (!checkResult[0] || checkResult[0].length === 0) {
      throw new Error("You must be an owner or admin to remove members");
    }

    // If removing an owner, make sure current user is also an owner
    if (membershipResult[0][0].role === "owner") {
      const ownerCheckResult = await query<[OrganizationMember[]]>(
        `
        SELECT * FROM member_of_org
        WHERE in = $auth.id
        AND out = $orgId
        AND role = "owner";
      `,
        { orgId },
      );

      if (!ownerCheckResult[0] || ownerCheckResult[0].length === 0) {
        throw new Error("Only organization owners can remove other owners");
      }
    }

    // Prevent removing yourself
    if (personId === "$auth.id") {
      throw new Error("You cannot remove yourself from an organization");
    }

    // Delete the membership
    await query(`
      DELETE ${memberId};
    `);

    return true;
  } catch (error) {
    console.error("Error removing organization member:", error);
    throw error;
  }
}
