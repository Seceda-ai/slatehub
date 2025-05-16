<script lang="ts">
    import AuthGuard from '$lib/components/AuthGuard.svelte';
    import { authState, signout } from '$lib/db/surreal';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { getProfile } from '$lib/db/profile';
    import { 
        getAllRoles, 
        getPersonRoles, 
        addRoleToPerson, 
        removeRoleFromPerson, 
        updatePersonRoleExpertise, 
        getAllDepartments,
        getRolesByDepartment,
        type Role,
        type PersonRole
    } from '$lib/db/roles';

    // Define interfaces for our data types
    interface Profile {
        [key: string]: any;
    }

    // State variables
    let profile: Profile | null = null;
    let isLoading = true;
    let error: string | null = null;
    
    // Roles state
    let userRoles: PersonRole[] = [];
    let allRoles: Role[] = [];
    let departments: string[] = [];
    let selectedDepartment: string = '';
    let departmentRoles: Role[] = [];
    let selectedRoleId: string = '';
    let selectedExpertiseLevel: "beginner" | "intermediate" | "expert" | "professional" = "intermediate";
    let isLoadingRoles = false;
    let rolesError: string | null = null;
    let isAddingRole = false;
    let showRoleSelector = false;

    onMount(async () => {
        await Promise.all([
            loadProfile(),
            loadUserRoles(),
            loadDepartments()
        ]);
    });

    async function loadProfile() {
        try {
            isLoading = true;
            error = null;
            profile = await getProfile();
        } catch (err: unknown) {
            const errorMsg = err instanceof Error ? err.message : 'Failed to load profile';
            error = errorMsg;
            console.error('Error loading profile:', err);
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
            const errorMsg = err instanceof Error ? err.message : 'Failed to load roles';
            rolesError = errorMsg;
            console.error('Error loading roles:', err);
        } finally {
            isLoadingRoles = false;
        }
    }

    async function loadDepartments() {
        try {
            departments = await getAllDepartments();
            if (departments.length > 0) {
                selectedDepartment = departments[0];
                await loadDepartmentRoles(selectedDepartment);
            }
        } catch (err: unknown) {
            const errorMsg = err instanceof Error ? err.message : 'Failed to load departments';
            rolesError = errorMsg;
            console.error('Error loading departments:', err);
        }
    }

    async function loadDepartmentRoles(department: string) {
        try {
            departmentRoles = await getRolesByDepartment(department);
            if (departmentRoles.length > 0) {
                selectedRoleId = departmentRoles[0].id;
            } else {
                selectedRoleId = '';
            }
        } catch (err: unknown) {
            const errorMsg = err instanceof Error ? err.message : 'Failed to load roles';
            rolesError = errorMsg;
            console.error('Error loading roles:', err);
        }
    }

    async function handleDepartmentChange() {
        await loadDepartmentRoles(selectedDepartment);
    }

    async function handleAddRole() {
        if (!selectedRoleId) {
            rolesError = 'Please select a role';
            return;
        }

        try {
            isAddingRole = true;
            rolesError = null;
            await addRoleToPerson(selectedRoleId, selectedExpertiseLevel);
            await loadUserRoles();
            showRoleSelector = false;
        } catch (err: unknown) {
            const errorMsg = err instanceof Error ? err.message : 'Failed to add role';
            rolesError = errorMsg;
            console.error('Error adding role:', err);
        } finally {
            isAddingRole = false;
        }
    }

    async function handleRemoveRole(personRoleId: string) {
        try {
            await removeRoleFromPerson(personRoleId);
            await loadUserRoles();
        } catch (err: unknown) {
            const errorMsg = err instanceof Error ? err.message : 'Failed to remove role';
            rolesError = errorMsg;
            console.error('Error removing role:', err);
        }
    }

    async function handleUpdateExpertise(personRoleId: string, expertiseLevel: "beginner" | "intermediate" | "expert" | "professional") {
        try {
            await updatePersonRoleExpertise(personRoleId, expertiseLevel);
            await loadUserRoles();
        } catch (err: unknown) {
            const errorMsg = err instanceof Error ? err.message : 'Failed to update expertise';
            rolesError = errorMsg;
            console.error('Error updating expertise:', err);
        }
    }

    async function handleSignout() {
        try {
            await signout();
            goto('/login');
        } catch (error) {
            console.error('Error signing out:', error);
        }
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
                                <span class="field-value">{$authState.user?.username || 'Not available'}</span>
                            </div>
                
                            <div class="profile-field">
                                <span class="field-label">Email</span>
                                <span class="field-value">{$authState.user?.email || 'Not available'}</span>
                            </div>
                        
                            <!-- Roles Section -->
                            <div class="profile-field">
                                <div class="field-header">
                                    <span class="field-label">Production Roles</span>
                                    <button class="btn btn-sm btn-primary" on:click={() => showRoleSelector = !showRoleSelector}>
                                        {showRoleSelector ? 'Cancel' : 'Add Role'}
                                    </button>
                                </div>
                            
                                {#if isLoadingRoles}
                                    <p>Loading roles...</p>
                                {:else if rolesError}
                                    <p class="error-message">{rolesError}</p>
                                {:else}
                                    {#if showRoleSelector}
                                        <div class="role-selector">
                                            <div class="form-group">
                                                <label for="department">Department</label>
                                                <select 
                                                    id="department" 
                                                    bind:value={selectedDepartment} 
                                                    on:change={handleDepartmentChange}
                                                    disabled={isAddingRole}
                                                >
                                                    {#each departments as department}
                                                        <option value={department}>{department}</option>
                                                    {/each}
                                                </select>
                                            </div>
                                        
                                            <div class="form-group">
                                                <label for="role">Role</label>
                                                <select 
                                                    id="role" 
                                                    bind:value={selectedRoleId}
                                                    disabled={isAddingRole || departmentRoles.length === 0}
                                                >
                                                    {#each departmentRoles as role}
                                                        <option value={role.id}>{role.standardized_title}</option>
                                                    {/each}
                                                </select>
                                            </div>
                                        
                                            <div class="form-group">
                                                <label for="expertise">Expertise Level</label>
                                                <select 
                                                    id="expertise" 
                                                    bind:value={selectedExpertiseLevel}
                                                    disabled={isAddingRole}
                                                >
                                                    <option value="beginner">Beginner</option>
                                                    <option value="intermediate">Intermediate</option>
                                                    <option value="expert">Expert</option>
                                                    <option value="professional">Professional</option>
                                                </select>
                                            </div>
                                        
                                            <div class="action-buttons">
                                                <button 
                                                    class="btn btn-primary" 
                                                    on:click={handleAddRole}
                                                    disabled={isAddingRole || !selectedRoleId}
                                                >
                                                    {isAddingRole ? 'Adding...' : 'Add Role'}
                                                </button>
                                            </div>
                                        </div>
                                    {/if}
                                
                                    <div class="roles-list">
                                        {#if userRoles.length === 0}
                                            <p class="empty-state">No roles added yet. Add your production roles to showcase your expertise.</p>
                                        {:else}
                                            {#each userRoles as personRole}
                                                <div class="role-card">
                                                    <div class="role-info">
                                                        <h3 class="role-title">{personRole.role_details.standardized_title}</h3>
                                                        <span class="role-department">{personRole.role_details.department}</span>
                                                        <span class="expertise-badge expertise-{personRole.expertise_level}">
                                                            {personRole.expertise_level}
                                                        </span>
                                                    </div>
                                                    <div class="role-actions">
                                                        <select 
                                                            class="expertise-select"
                                                            value={personRole.expertise_level}
                                                            on:change={(e) => handleUpdateExpertise(personRole.id, e.target.value as any)}
                                                        >
                                                            <option value="beginner">Beginner</option>
                                                            <option value="intermediate">Intermediate</option>
                                                            <option value="expert">Expert</option>
                                                            <option value="professional">Professional</option>
                                                        </select>
                                                        <button 
                                                            class="btn btn-sm btn-danger" 
                                                            on:click={() => handleRemoveRole(personRole.id)}
                                                        >
                                                            Remove
                                                        </button>
                                                    </div>
                                                </div>
                                            {/each}
                                        {/if}
                                    </div>
                                {/if}
                            </div>
                
                            <div class="profile-actions">
                                <button class="btn btn-outline">Edit Profile</button>
                                <button class="btn btn-outline danger" on:click={handleSignout}>Sign Out</button>
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
        padding: 1rem;
        border-radius: var(--border-radius-sm);
        margin-bottom: 1.5rem;
    }
    
    .form-group {
        margin-bottom: 1rem;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 0.5rem;
        font-size: 0.9rem;
        color: #495057;
    }
    
    .form-group select {
        width: 100%;
        padding: 0.5rem;
        border: 1px solid #ced4da;
        border-radius: var(--border-radius-sm);
        background-color: white;
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
        padding: 1rem;
        background-color: #f8f9fa;
        border-radius: var(--border-radius-sm);
        border-left: 4px solid var(--primary-color);
    }
    
    .role-info {
        display: flex;
        flex-direction: column;
    }
    
    .role-title {
        font-size: 1rem;
        font-weight: 600;
        margin: 0 0 0.25rem 0;
    }
    
    .role-department {
        font-size: 0.8rem;
        color: #6c757d;
        margin-bottom: 0.25rem;
    }
    
    .role-actions {
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    
    .expertise-select {
        padding: 0.25rem;
        border: 1px solid #ced4da;
        border-radius: var(--border-radius-sm);
        font-size: 0.8rem;
    }
    
    .expertise-badge {
        display: inline-block;
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
        border-radius: var(--border-radius-sm);
    }
    
    .expertise-beginner {
        background-color: #e2e3e5;
        color: #383d41;
    }
    
    .expertise-intermediate {
        background-color: #d1ecf1;
        color: #0c5460;
    }
    
    .expertise-expert {
        background-color: #d4edda;
        color: #155724;
    }
    
    .expertise-professional {
        background-color: #f8d7da;
        color: #721c24;
    }
    
    .empty-state {
        color: #6c757d;
        font-style: italic;
        text-align: center;
        padding: 1rem 0;
    }
    
    .action-buttons {
        margin-top: 1rem;
    }
    
    .btn-sm {
        padding: 0.25rem 0.5rem;
        font-size: 0.875rem;
    }
    
    @media (max-width: 600px) {
        .profile-card {
            text-align: center;
        }
        
        .profile-actions {
            justify-content: center;
        }
        
        .role-card {
            flex-direction: column;
            align-items: flex-start;
        }
        
        .role-actions {
            margin-top: 1rem;
            width: 100%;
            justify-content: space-between;
        }
    }
</style>