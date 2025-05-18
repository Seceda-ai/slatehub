<script lang="ts">
    import AuthGuard from "$lib/components/AuthGuard.svelte";
    import { authState, signout } from "$lib/db/surreal";
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import { getProfile } from "$lib/db/profile";
    import {
        getAllRoles,
        getPersonRoles,
        addRoleToPerson,
        removeRoleFromPerson,
        type Role,
        type PersonRole,
    } from "$lib/db/roles";

    // State variables
    let profile: any = null;
    let isLoading = true;
    let error: string | null = null;

    // Roles state
    let userRoles: PersonRole[] = [];
    let allRoles: Role[] = [];
    let selectedRoleId: string = "";
    let isLoadingRoles = false;
    let rolesError: string | null = null;
    let isAddingRole = false;
    let showRoleSelector = false;
    let roleSearchTerm: string = "";
    let filteredRoles: Role[] = [];

    onMount(async () => {
        await Promise.all([loadProfile(), loadUserRoles(), loadAllRoles()]);
    });

    async function loadProfile() {
        try {
            isLoading = true;
            error = null;
            profile = await getProfile();
        } catch (err: unknown) {
            const errorMsg =
                err instanceof Error ? err.message : "Failed to load profile";
            error = errorMsg;
            console.error("Error loading profile:", err);
        } finally {
            isLoading = false;
        }
    }

    async function loadUserRoles() {
        try {
            isLoadingRoles = true;
            rolesError = null;
            userRoles = await getPersonRoles();
        } catch (err: unknown) {
            const errorMsg =
                err instanceof Error ? err.message : "Failed to load roles";
            rolesError = errorMsg;
            console.error("Error loading roles:", err);
        } finally {
            isLoadingRoles = false;
        }
    }

    async function loadAllRoles() {
        try {
            allRoles = await getAllRoles();
            filteredRoles = [...allRoles];
            if (allRoles.length > 0) {
                selectedRoleId = allRoles[0].id;
            }
        } catch (err: unknown) {
            const errorMsg =
                err instanceof Error ? err.message : "Failed to load roles";
            rolesError = errorMsg;
            console.error("Error loading roles:", err);
        }
    }

    function filterRoles() {
        if (!roleSearchTerm || roleSearchTerm.trim() === "") {
            filteredRoles = [...allRoles];
            return;
        }

        const searchTermLower = roleSearchTerm.toLowerCase();
        filteredRoles = allRoles.filter(
            (role) =>
                role.name.toLowerCase().includes(searchTermLower) ||
                (role.description &&
                    role.description.toLowerCase().includes(searchTermLower)) ||
                (role.slug &&
                    role.slug.toLowerCase().includes(searchTermLower)),
        );
    }

    async function handleAddRole() {
        if (!selectedRoleId) {
            rolesError = "Please select a role";
            return;
        }

        try {
            isAddingRole = true;
            rolesError = null;
            // Add the role with default expertise level
            await addRoleToPerson(selectedRoleId);
            await loadUserRoles();
            showRoleSelector = false;
        } catch (err: unknown) {
            const errorMsg =
                err instanceof Error ? err.message : "Failed to add role";
            rolesError = errorMsg;
            console.error("Error adding role:", err);
        } finally {
            isAddingRole = false;
        }
    }

    async function handleRemoveRole(personRoleId: string) {
        try {
            await removeRoleFromPerson(personRoleId);
            await loadUserRoles();
        } catch (err: unknown) {
            const errorMsg =
                err instanceof Error ? err.message : "Failed to remove role";
            rolesError = errorMsg;
            console.error("Error removing role:", err);
        }
    }

    async function handleSignout() {
        try {
            await signout();
            goto("/login");
        } catch (error) {
            console.error("Error signing out:", error);
        }
    }

    // Format roles as a comma-separated list
    function getRolesList(roles: PersonRole[]): string {
        if (!roles || roles.length === 0) return "No roles added yet";
        return roles.map((role) => role.role.name).join(", ");
    }
</script>

<svelte:head>
    <title>My Profile | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
    <div class="profile-page">
        <div class="profile-header">
            <h1>My Profile</h1>
            <p class="subtitle">Manage your account information</p>
        </div>

        <div class="profile-card">
            <div class="profile-details">
                <div class="profile-field">
                    <span class="field-label">Username</span>
                    <span class="field-value"
                        >{$authState.user?.username || "Not available"}</span
                    >
                </div>

                <div class="profile-field">
                    <span class="field-label">Email</span>
                    <span class="field-value"
                        >{$authState.user?.email || "Not available"}</span
                    >
                </div>

                <!-- Roles Section -->
                <div class="profile-field">
                    <div class="field-header">
                        <span class="field-label">Production Roles</span>
                        <button
                            class="btn btn-sm btn-primary"
                            on:click={() =>
                                (showRoleSelector = !showRoleSelector)}
                        >
                            {showRoleSelector ? "Cancel" : "Add Role"}
                        </button>
                    </div>

                    {#if isLoadingRoles}
                        <p>Loading roles...</p>
                    {:else if rolesError}
                        <p class="error-message">{rolesError}</p>
                    {:else}
                        <!-- Show roles as comma-separated list -->
                        <div
                            class="roles-summary"
                            class:empty={userRoles.length === 0}
                        >
                            {getRolesList(userRoles)}
                        </div>

                        {#if showRoleSelector}
                            <div class="role-selector">
                                <div class="form-group">
                                    <label for="role-search"
                                        >Search Available Roles</label
                                    >
                                    <input
                                        type="text"
                                        id="role-search"
                                        placeholder="Type to search roles..."
                                        bind:value={roleSearchTerm}
                                        on:input={filterRoles}
                                        disabled={isAddingRole}
                                    />
                                </div>

                                <div class="form-group">
                                    <label for="role">Select a Role</label>
                                    <select
                                        id="role"
                                        bind:value={selectedRoleId}
                                        disabled={isAddingRole ||
                                            filteredRoles.length === 0}
                                        size="5"
                                        class="role-select"
                                    >
                                        {#each filteredRoles as role}
                                            <option value={role.id}
                                                >{role.name}</option
                                            >
                                        {/each}
                                    </select>
                                    {#if filteredRoles.length === 0}
                                        <p class="no-roles-found">
                                            No roles found. Try another search
                                            term.
                                        </p>
                                    {/if}
                                </div>

                                <div class="role-details">
                                    {#if selectedRoleId}
                                        {#each filteredRoles.filter((r) => r.id === selectedRoleId) as selectedRole}
                                            <div class="selected-role-info">
                                                <h4>{selectedRole.name}</h4>
                                                {#if selectedRole.description}
                                                    <p>
                                                        {selectedRole.description}
                                                    </p>
                                                {/if}
                                            </div>
                                        {/each}
                                    {/if}
                                </div>

                                <div class="action-buttons">
                                    <button
                                        class="btn btn-secondary"
                                        on:click={() =>
                                            (showRoleSelector = false)}
                                        disabled={isAddingRole}
                                    >
                                        Cancel
                                    </button>
                                    <button
                                        class="btn btn-primary"
                                        on:click={handleAddRole}
                                        disabled={isAddingRole ||
                                            !selectedRoleId}
                                    >
                                        {isAddingRole
                                            ? "Adding..."
                                            : "Add Role"}
                                    </button>
                                </div>
                            </div>
                        {/if}

                        <!-- Role management list -->
                        {#if userRoles.length > 0}
                            <h3 class="section-title">Manage Your Roles</h3>
                            <div class="roles-list">
                                {#each userRoles as personRole}
                                    <div class="role-card">
                                        <div class="role-info">
                                            <span class="role-title">
                                                {personRole.role.name}
                                            </span>
                                        </div>
                                        <button
                                            class="btn btn-sm btn-danger"
                                            on:click={() =>
                                                handleRemoveRole(
                                                    personRole.person_has_role_id,
                                                )}
                                            title="Remove this role"
                                        >
                                            ✕
                                        </button>
                                    </div>
                                {/each}
                            </div>
                        {/if}
                    {/if}
                </div>

                <div class="profile-actions">
                    <button class="btn btn-outline">Edit Profile</button>
                    <button
                        class="btn btn-outline danger"
                        on:click={handleSignout}>Sign Out</button
                    >
                </div>
            </div>
        </div>
    </div>
</AuthGuard>

<style>
    .profile-page {
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem 1rem;
    }

    .profile-header {
        text-align: center;
        margin-bottom: 2rem;
    }

    .profile-header h1 {
        color: var(--primary-color);
        margin-bottom: 0.5rem;
    }

    .subtitle {
        color: #666;
    }

    .profile-card {
        background-color: white;
        border-radius: var(--border-radius-md);
        padding: 2rem;
        box-shadow: var(--shadow-sm);
    }

    .profile-details {
        width: 100%;
    }

    .profile-field {
        margin-bottom: 1.5rem;
    }

    .field-label {
        display: block;
        font-size: 0.9rem;
        color: #666;
        margin-bottom: 0.25rem;
    }

    .field-value {
        display: block;
        font-size: 1.1rem;
        font-weight: 500;
    }

    .field-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 1rem;
    }

    .section-title {
        font-size: 1.1rem;
        color: var(--text-color);
        margin: 1.5rem 0 1rem 0;
        padding-bottom: 0.5rem;
        border-bottom: 1px solid var(--light-gray);
    }

    .roles-summary {
        font-size: 1.1rem;
        padding: 0.75rem;
        background-color: #f8f9fa;
        border-radius: var(--border-radius-sm);
        margin-bottom: 1rem;
        border-left: 3px solid var(--primary-color);
    }

    .roles-summary.empty {
        color: #6c757d;
        font-style: italic;
    }

    .profile-actions {
        display: flex;
        gap: 1rem;
        margin-top: 2rem;
    }

    .danger {
        color: var(--danger-color);
        border-color: var(--danger-color);
    }

    .danger:hover {
        background-color: var(--danger-color);
        color: white;
    }

    .error-message {
        color: var(--danger-color);
        font-size: 0.875rem;
        margin-top: 0.5rem;
    }

    .role-selector {
        background: #f8f9fa;
        padding: 1.5rem;
        border-radius: var(--border-radius-sm);
        margin-bottom: 1.5rem;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    }

    .form-group {
        margin-bottom: 1.5rem;
    }

    .form-group label {
        display: block;
        margin-bottom: 0.5rem;
        font-size: 0.9rem;
        font-weight: 500;
        color: #495057;
    }

    .form-group select,
    .form-group input {
        width: 100%;
        padding: 0.5rem;
        border: 1px solid #ced4da;
        border-radius: var(--border-radius-sm);
        background-color: white;
        font-size: 0.95rem;
    }

    .form-group input:focus,
    .form-group select:focus {
        border-color: var(--primary-color);
        outline: none;
        box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.25);
    }

    .role-select {
        height: auto;
        min-height: 150px;
    }

    .no-roles-found {
        color: #6c757d;
        font-style: italic;
        margin-top: 0.5rem;
        font-size: 0.9rem;
    }

    .role-details {
        background-color: white;
        border: 1px solid #e9ecef;
        border-radius: var(--border-radius-sm);
        padding: 1rem;
        margin-bottom: 1.5rem;
        min-height: 100px;
    }

    .selected-role-info h4 {
        margin: 0 0 0.75rem 0;
        color: var(--primary-color);
        font-size: 1.1rem;
    }

    .selected-role-info p {
        margin: 0 0 0.75rem 0;
        color: #495057;
        font-size: 0.95rem;
    }

    .roles-list {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
    }

    .role-card {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0.5rem 0.75rem;
        background-color: #f8f9fa;
        border-radius: 20px;
        margin-bottom: 0.5rem;
        border: 1px solid #e9ecef;
    }

    .role-title {
        font-size: 0.95rem;
        font-weight: 500;
        margin: 0;
    }

    .btn-danger {
        border: none;
        background: none;
        color: #dc3545;
        font-size: 14px;
        font-weight: bold;
        cursor: pointer;
        padding: 0.2rem 0.5rem;
        border-radius: 50%;
    }

    .btn-danger:hover {
        background-color: rgba(220, 53, 69, 0.1);
    }

    .action-buttons {
        margin-top: 1.5rem;
        display: flex;
        justify-content: flex-end;
        gap: 1rem;
    }

    .btn-sm {
        padding: 0.25rem 0.5rem;
        font-size: 0.875rem;
    }

    @media (max-width: 600px) {
        .profile-card {
            text-align: center;
            padding: 1.5rem 1rem;
        }

        .profile-actions {
            justify-content: center;
        }

        .action-buttons {
            flex-direction: column;
        }

        .role-selector {
            padding: 1rem;
        }
    }
</style>
