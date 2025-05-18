<script lang="ts">
    import AuthGuard from "$lib/components/AuthGuard.svelte";
    import { authState, signout } from "$lib/db/surreal";
    import { goto } from "$app/navigation";
    import { onMount } from "svelte";
    import { getProfile, updateProfile, updateCredentials, type ProfileUpdateData, type CredentialsUpdateData } from "$lib/db/profile";
    import {
        getAllRoles,
        getPersonRoles,
        addRoleToPerson,
        removeRoleFromPerson,
        type Role,
        type PersonRole
    } from '$lib/db/roles';

    // Active tab for profile sections
    type TabType = 'account' | 'personal' | 'social' | 'roles';
    let activeTab: TabType = 'account';
    
    // View mode or edit mode
    let isEditMode = false;

    // State variables
    let profile: any = null;
    let isLoading = true;
    let error: string | null = null;
    let isSavingProfile = false;
    let profileUpdateError: string | null = null;

    // Account details form fields
    let username = '';
    let currentPassword = '';
    let newPassword = '';
    let confirmPassword = '';
    let accountError: string | null = null;
    let isUpdatingCredentials = false;

    // Personal info form fields
    let fullName = '';
    let location = '';
    let countryCode = '';
    let phoneNumber = '';
    
    // Social media form fields
    let discordHandle = '';
    let instagramHandle = '';

    // Country codes data for dropdown
    const countryCodes = [
        { code: "+1", country: "United States/Canada" },
        { code: "+44", country: "United Kingdom" },
        { code: "+49", country: "Germany" },
        { code: "+33", country: "France" },
        { code: "+61", country: "Australia" },
        { code: "+81", country: "Japan" },
        { code: "+86", country: "China" },
        { code: "+91", country: "India" },
        { code: "+52", country: "Mexico" },
        { code: "+55", country: "Brazil" },
        { code: "+34", country: "Spain" },
        { code: "+39", country: "Italy" },
        { code: "+7", country: "Russia" },
        { code: "+82", country: "South Korea" },
        { code: "+27", country: "South Africa" },
        { code: "+41", country: "Switzerland" },
        { code: "+31", country: "Netherlands" },
        { code: "+46", country: "Sweden" },
        { code: "+47", country: "Norway" },
        { code: "+45", country: "Denmark" },
        { code: "+358", country: "Finland" },
        { code: "+48", country: "Poland" },
        { code: "+420", country: "Czech Republic" },
        { code: "+36", country: "Hungary" },
        { code: "+43", country: "Austria" }
    ];

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
        await Promise.all([
            loadProfile(),
            loadUserRoles(),
            loadAllRoles()
        ]);
    });
    
    // Change active tab
    function setActiveTab(tab: TabType) {
        activeTab = tab;
    }
    
    // Toggle between view mode and edit mode
    function toggleEditMode() {
        isEditMode = !isEditMode;
        if (!isEditMode) {
            // Reset form values when exiting edit mode
            resetFormValues();
        }
    }
    
    // Reset form values to match profile data
    function resetFormValues() {
        if (profile) {
            // Account fields
            username = profile.username || '';
            currentPassword = '';
            newPassword = '';
            confirmPassword = '';
            
            // Personal info fields
            fullName = profile.full_name || '';
            location = profile.location || '';
            countryCode = profile.phone?.country_code || '';
            phoneNumber = profile.phone?.number || '';
            
            // Social fields
            discordHandle = profile.social?.discord || '';
            instagramHandle = profile.social?.instagram || '';
        }
    }

    async function loadProfile() {
        try {
            isLoading = true;
            error = null;
            profile = await getProfile();
            
            // Initialize form fields with profile data
            if (profile) {
                // Set account fields
                username = profile.username || '';
                
                // Set personal info fields
                fullName = profile.full_name || '';
                location = profile.location || '';
                countryCode = profile.phone?.country_code || '';
                phoneNumber = profile.phone?.number || '';
                
                // Set social fields
                discordHandle = profile.social?.discord || '';
                instagramHandle = profile.social?.instagram || '';
            }
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
        return roles.map(role => role.role.name).join(", ");
    }

    // Save personal info
    async function savePersonalInfo() {
        try {
            profileUpdateError = null;
            isSavingProfile = true;

            const profileData: ProfileUpdateData = {
                full_name: fullName,
                location: location,
                phone: {
                    country_code: countryCode,
                    number: phoneNumber
                }
            };

            profile = await updateProfile(profileData);
        } catch (err: unknown) {
            profileUpdateError = err instanceof Error 
                ? err.message 
                : "Failed to update personal information";
            console.error("Error updating profile:", err);
        } finally {
            isSavingProfile = false;
        }
    }
    
    // Save social media info
    async function saveSocialInfo() {
        try {
            profileUpdateError = null;
            isSavingProfile = true;

            const profileData: ProfileUpdateData = {
                social: {
                    discord: discordHandle,
                    instagram: instagramHandle
                }
            };

            profile = await updateProfile(profileData);
        } catch (err: unknown) {
            profileUpdateError = err instanceof Error 
                ? err.message 
                : "Failed to update social media information";
            console.error("Error updating social info:", err);
        } finally {
            isSavingProfile = false;
        }
    }
    
    // Update account credentials
    async function updateAccountCredentials() {
        try {
            accountError = null;
            isUpdatingCredentials = true;
            
            // Validate passwords match if changing password
            if (newPassword && newPassword !== confirmPassword) {
                accountError = "New passwords do not match";
                return;
            }
            
            // Validate current password is provided
            if (!currentPassword) {
                accountError = "Current password is required";
                return;
            }
            
            const credentialsData: CredentialsUpdateData = {
                currentPassword
            };
            
            // Only include username/password if they're being changed
            if (username !== profile.username) {
                credentialsData.username = username;
            }
            
            if (newPassword) {
                credentialsData.newPassword = newPassword;
            }
            
            // If nothing is being changed, show message
            if (!credentialsData.username && !credentialsData.newPassword) {
                accountError = "No changes to save";
                return;
            }
            
            profile = await updateCredentials(credentialsData);
            
            // Clear form fields after successful update
            currentPassword = '';
            newPassword = '';
            confirmPassword = '';
            
            // Show success message
            accountError = "✓ Account updated successfully";
            
        } catch (err: unknown) {
            accountError = err instanceof Error 
                ? err.message 
                : "Failed to update credentials";
            console.error("Error updating credentials:", err);
        } finally {
            isUpdatingCredentials = false;
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
            {#if isEditMode}
                <!-- Tab navigation for edit mode -->
                <div class="profile-tabs">
                    <button 
                        class="tab-button {activeTab === 'account' ? 'active' : ''}" 
                        on:click={() => setActiveTab('account')}
                    >
                        Account
                    </button>
                    <button 
                        class="tab-button {activeTab === 'personal' ? 'active' : ''}"
                        on:click={() => setActiveTab('personal')}
                    >
                        Personal Info
                    </button>
                    <button 
                        class="tab-button {activeTab === 'social' ? 'active' : ''}"
                        on:click={() => setActiveTab('social')}
                    >
                        Social Media
                    </button>
                    <button 
                        class="tab-button {activeTab === 'roles' ? 'active' : ''}"
                        on:click={() => setActiveTab('roles')}
                    >
                        Production Roles
                    </button>
                </div>
            {/if}

            <div class="profile-details">
                {#if !isEditMode}
                    <!-- View mode: show all profile information -->
                    <div class="profile-overview">
                        <div class="section">
                            <h3 class="section-title">Account Information</h3>
                            <div class="profile-field">
                                <span class="field-label">Username</span>
                                <span class="field-value">{profile?.username || "Not available"}</span>
                            </div>
                            <div class="profile-field">
                                <span class="field-label">Email</span>
                                <span class="field-value">{profile?.email || "Not available"}</span>
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3 class="section-title">Personal Information</h3>
                            <div class="profile-field">
                                <span class="field-label">Full Name</span>
                                <span class="field-value">{profile?.full_name || "Not set"}</span>
                            </div>
                            <div class="profile-field">
                                <span class="field-label">Location</span>
                                <span class="field-value">{profile?.location || "Not set"}</span>
                            </div>
                            <div class="profile-field">
                                <span class="field-label">Phone Number</span>
                                <span class="field-value">
                                    {#if profile?.phone?.country_code && profile?.phone?.number}
                                        {profile.phone.country_code} {profile.phone.number}
                                    {:else}
                                        Not set
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3 class="section-title">Social Media</h3>
                            <div class="profile-field">
                                <span class="field-label">Discord</span>
                                <span class="field-value">
                                    {#if profile?.social?.discord}
                                        @{profile.social.discord}
                                    {:else}
                                        Not set
                                    {/if}
                                </span>
                            </div>
                            <div class="profile-field">
                                <span class="field-label">Instagram</span>
                                <span class="field-value">
                                    {#if profile?.social?.instagram}
                                        @{profile.social.instagram}
                                    {:else}
                                        Not set
                                    {/if}
                                </span>
                            </div>
                        </div>
                        
                        <div class="section">
                            <h3 class="section-title">Production Roles</h3>
                            <div class="roles-summary" class:empty={userRoles.length === 0}>
                                {getRolesList(userRoles)}
                            </div>
                        </div>
                        
                        <div class="profile-actions">
                            <button class="btn btn-primary" on:click={toggleEditMode}>
                                Edit Profile
                            </button>
                            <button class="btn btn-outline danger" on:click={handleSignout}>
                                Sign Out
                            </button>
                        </div>
                    </div>
                {:else if activeTab === 'account'}
                    <div class="tab-content">
                        <h3 class="section-title">Account Credentials</h3>
                        
                        {#if accountError}
                            <div class="alert {accountError.includes('✓') ? 'alert-success' : 'alert-error'}">
                                {accountError}
                            </div>
                        {/if}
                        
                        <div class="form-section">
                            <div class="profile-field">
                                <label for="username" class="field-label">Username</label>
                                <input 
                                    type="text" 
                                    id="username" 
                                    class="form-input" 
                                    bind:value={username} 
                                    placeholder="Enter username"
                                />
                                <span class="field-hint">Username must be at least 3 characters and contain only letters, numbers, hyphens and underscores</span>
                            </div>
                            
                            <div class="profile-field">
                                <label for="current-password" class="field-label">Current Password <span class="required">*</span></label>
                                <input 
                                    type="password" 
                                    id="current-password" 
                                    class="form-input" 
                                    bind:value={currentPassword} 
                                    placeholder="Enter current password"
                                />
                                <span class="field-hint">Required to make any changes</span>
                            </div>
                            
                            <div class="profile-field">
                                <label for="new-password" class="field-label">New Password</label>
                                <input 
                                    type="password" 
                                    id="new-password" 
                                    class="form-input" 
                                    bind:value={newPassword} 
                                    placeholder="Enter new password"
                                />
                                <span class="field-hint">Leave blank to keep current password</span>
                            </div>
                            
                            <div class="profile-field">
                                <label for="confirm-password" class="field-label">Confirm New Password</label>
                                <input 
                                    type="password" 
                                    id="confirm-password" 
                                    class="form-input" 
                                    bind:value={confirmPassword} 
                                    placeholder="Confirm new password"
                                />
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button 
                                class="btn btn-primary" 
                                on:click={updateAccountCredentials}
                                disabled={isUpdatingCredentials}
                            >
                                {isUpdatingCredentials ? 'Updating...' : 'Update Account'}
                            </button>
                        </div>
                    </div>
                {:else if activeTab === 'personal'}
                        <div class="tab-content">
                            {#if profileUpdateError}
                                <div class="alert alert-error">
                                    {profileUpdateError}
                                </div>
                            {/if}

                            <div class="form-section">
                                <h3 class="section-title">Personal Information</h3>
                            
                                <div class="profile-field">
                                    <span class="field-label">Email</span>
                                    <span class="field-value">{$authState.user?.email || "Not available"}</span>
                                    <span class="field-hint">(Cannot be changed)</span>
                                </div>

                                <div class="profile-field">
                                    <label for="fullName" class="field-label">Full Name</label>
                                    <input 
                                        type="text" 
                                        id="fullName" 
                                        class="form-input" 
                                        bind:value={fullName} 
                                        placeholder="Enter your full name"
                                    />
                                </div>

                                <div class="profile-field">
                                    <label for="location" class="field-label">Location</label>
                                    <input 
                                        type="text" 
                                        id="location" 
                                        class="form-input" 
                                        bind:value={location} 
                                        placeholder="City, Country"
                                    />
                                </div>
                            
                                <div class="profile-field phone-field">
                                    <label for="phone" class="field-label">Phone Number</label>
                                    <div class="phone-input-group">
                                        <select 
                                            id="countryCode" 
                                            class="country-code-select" 
                                            bind:value={countryCode}
                                        >
                                            <option value="">Select Code</option>
                                            {#each countryCodes as country}
                                                <option value={country.code}>{country.code} ({country.country})</option>
                                            {/each}
                                        </select>
                                        <input 
                                            type="tel" 
                                            id="phone" 
                                            class="phone-input" 
                                            bind:value={phoneNumber} 
                                            placeholder="Phone number"
                                        />
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button 
                                    class="btn btn-primary" 
                                    on:click={savePersonalInfo}
                                    disabled={isSavingProfile}
                                >
                                    {isSavingProfile ? 'Saving...' : 'Save Personal Info'}
                                </button>
                            </div>
                        </div>
                    {:else if activeTab === 'social'}
                        <div class="tab-content">
                            {#if profileUpdateError}
                                <div class="alert alert-error">
                                    {profileUpdateError}
                                </div>
                            {/if}

                            <div class="form-section">
                                <h3 class="section-title">Social Media</h3>
                            
                                <div class="profile-field">
                                    <label for="discord" class="field-label">Discord</label>
                                    <div class="social-input-group">
                                        <span class="social-prefix">@</span>
                                        <input 
                                            type="text" 
                                            id="discord" 
                                            class="social-input" 
                                            bind:value={discordHandle} 
                                            placeholder="Discord username"
                                        />
                                    </div>
                                </div>

                                <div class="profile-field">
                                    <label for="instagram" class="field-label">Instagram</label>
                                    <div class="social-input-group">
                                        <span class="social-prefix">@</span>
                                        <input 
                                            type="text" 
                                            id="instagram" 
                                            class="social-input" 
                                            bind:value={instagramHandle} 
                                            placeholder="Instagram handle"
                                        />
                                    </div>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button 
                                    class="btn btn-primary" 
                                    on:click={saveSocialInfo}
                                    disabled={isSavingProfile}
                                >
                                    {isSavingProfile ? 'Saving...' : 'Save Social Info'}
                                </button>
                            </div>
                        </div>
                    {:else if activeTab === 'roles'}
                        <div class="tab-content">
                            <div class="roles-header">
                                <button
                                    class="btn btn-sm btn-primary"
                                    on:click={() => (showRoleSelector = !showRoleSelector)}
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
                                <div class="roles-summary" class:empty={userRoles.length === 0}>
                                    {getRolesList(userRoles)}
                                </div>

                                {#if showRoleSelector}
                                    <div class="role-selector">
                                        <div class="form-group">
                                            <label for="role-search">Search Available Roles</label>
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
                                                <p class="no-roles-found">No roles found. Try another search term.</p>
                                            {/if}
                                        </div>

                                        <div class="role-details">
                                            {#if selectedRoleId}
                                                {#each filteredRoles.filter((r) => r.id === selectedRoleId) as selectedRole}
                                                    <div class="selected-role-info">
                                                        <h4>{selectedRole.name}</h4>
                                                        {#if selectedRole.description}
                                                            <p>{selectedRole.description}</p>
                                                        {/if}
                                                    </div>
                                                {/each}
                                            {/if}
                                        </div>

                                        <div class="action-buttons">
                                            <button
                                                class="btn btn-secondary"
                                                on:click={() => showRoleSelector = false}
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
                                                    on:click={() => handleRemoveRole(personRole.person_has_role_id)}
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
                    {/if}

                    <div class="profile-actions">
                        <button
                            class="btn btn-secondary"
                            on:click={toggleEditMode}>
                            Cancel
                        </button>
                        <button
                            class="btn btn-outline danger"
                            on:click={handleSignout}>
                            Sign Out
                        </button>
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
    
    .profile-tabs {
        display: flex;
        border-bottom: 1px solid var(--border-color);
        margin-bottom: 2rem;
        overflow-x: auto;
        scrollbar-width: none; /* Hide scrollbar for Firefox */
    }
    
    .profile-tabs::-webkit-scrollbar {
        display: none; /* Hide scrollbar for Chrome/Safari */
    }
    
    .tab-button {
        padding: 0.75rem 1.25rem;
        background: none;
        border: none;
        font-size: 1rem;
        font-weight: 500;
        color: #666;
        cursor: pointer;
        border-bottom: 3px solid transparent;
        transition: all 0.2s ease;
        white-space: nowrap;
    }
    
    .tab-button:hover {
        color: var(--primary-color);
    }
    
    .tab-button.active {
        color: var(--primary-color);
        border-bottom-color: var(--primary-color);
    }
    
    .tab-content {
        padding: 1rem 0;
    }
    
    .roles-header {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 1rem;
    }
    
    .alert-success {
        background-color: rgba(40, 167, 69, 0.1);
        color: #28a745;
        border: 1px solid rgba(40, 167, 69, 0.2);
    }
    
    .required {
        color: #dc3545;
        margin-left: 0.25rem;
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
        margin-bottom: 0.5rem;
        font-weight: 500;
    }

    .field-value {
        display: block;
        font-size: 1.1rem;
        font-weight: 500;
    }

    .field-hint {
        display: block;
        font-size: 0.8rem;
        color: #999;
        margin-top: 0.25rem;
        font-style: italic;
    }



    .form-section {
        margin-bottom: 2rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid var(--light-gray);
    }

    .form-input {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: var(--border-radius-sm);
        font-size: 1rem;
    }

    .form-input:focus {
        border-color: var(--primary-color);
        outline: none;
        box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.1);
    }

    .phone-field {
        margin-bottom: 2rem;
    }

    .phone-input-group {
        display: flex;
        gap: 0.5rem;
    }

    .country-code-select {
        width: 180px;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: var(--border-radius-sm);
    }

    .phone-input {
        flex: 1;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: var(--border-radius-sm);
    }

    .social-input-group {
        display: flex;
        align-items: center;
    }

    .social-prefix {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0 0.75rem;
        background-color: #f8f9fa;
        border: 1px solid var(--border-color);
        border-right: none;
        border-radius: var(--border-radius-sm) 0 0 var(--border-radius-sm);
        height: 46px;
    }

    .social-input {
        flex: 1;
        padding: 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: 0 var(--border-radius-sm) var(--border-radius-sm) 0;
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 1rem;
        margin-top: 2rem;
    }
    
    .profile-overview {
        padding: 1rem 0;
    }
    
    .section {
        margin-bottom: 2rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid var(--light-gray);
    }
    
    .section:last-child {
        border-bottom: none;
    }

    .alert {
        padding: 0.75rem 1rem;
        border-radius: var(--border-radius-sm);
        margin-bottom: 1.5rem;
    }

    .alert-error {
        background-color: rgba(220, 53, 69, 0.1);
        color: var(--danger-color);
        border: 1px solid rgba(220, 53, 69, 0.2);
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

        .phone-input-group {
            flex-direction: column;
        }

        .country-code-select,
        .phone-input {
            width: 100%;
        }

        .social-input-group {
            flex-direction: row;
        }

        .form-actions {
            flex-direction: column;
        }
    
        .btn {
            width: 100%;
        }
    }
    </style>
