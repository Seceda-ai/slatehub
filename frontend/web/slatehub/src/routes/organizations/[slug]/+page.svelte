<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import AuthGuard from '$lib/components/AuthGuard.svelte';
  import OrganizationForm from '$lib/components/organizations/OrganizationForm.svelte';
  import OrganizationMembers from '$lib/components/organizations/OrganizationMembers.svelte';
  import { authState } from '$lib/db/surreal';
  import { getOrganizationBySlug, deleteOrganization, type Organization, getOrganizationMembers, type OrganizationMember } from '$lib/db/organizations';

  // Get organization slug from the route params
  const slug = $page.params.slug;

  // State variables
  let organization: Organization | null = null;
  let isLoading = true;
  let error: string | null = null;
  let isEditing = false;
  let isSubmitting = false;
  let currentUserRole: string | null = null;

  // Fetch organization data on mount
  onMount(async () => {
    await loadOrganization();
  });

  // Load organization data
  async function loadOrganization() {
    try {
      isLoading = true;
      error = null;
      
      // Get organization by slug
          console.log(`Fetching organization with slug: ${slug}`);
          organization = await getOrganizationBySlug(slug);
          console.log('Organization data received:', organization);
      
          if (!organization || !organization.id) {
            error = "Organization not found or you don't have permission to view it";
            return;
          }
      
      // Get current user's role in this organization
      console.log(`Fetching members for organization ID: ${organization.id}`);
      const members = await getOrganizationMembers(organization.id);
      console.log('Organization members:', members);
      
      // Get current user from authState
      let currentUsername = '';
      const unsubscribe = authState.subscribe(state => {
        currentUsername = state.user?.username || '';
      });
      unsubscribe();
      console.log('Current username:', currentUsername);
      
      // Helper function to extract username from member
      function getMemberUsername(member: any): string {
        if (!member || !member.person) return '';
        
        if (Array.isArray(member.person)) {
          return member.person[0]?.username || '';
        }
        
        if (typeof member.person === 'object') {
          return member.person.username || '';
        }
        
        return '';
      }
      
      const currentUserMember = members.find(m => 
        getMemberUsername(m) === currentUsername
      );
      console.log('Current user member data:', currentUserMember);
      
      if (currentUserMember) {
        currentUserRole = currentUserMember.role;
      }
    } catch (err: any) {
      error = err.message || 'Failed to load organization';
      console.error('Error loading organization:', err);
    } finally {
      isLoading = false;
    }
  }

  // Handle successful organization update
  function handleUpdateSuccess(event: CustomEvent<Organization>) {
    console.log('Organization updated successfully:', event.detail);
    organization = event.detail;
    isEditing = false;
  }

  // Handle organization deletion
  async function handleDelete() {
    if (!organization?.id) return;
    
    if (!confirm('Are you sure you want to delete this organization? This action cannot be undone.')) {
      return;
    }
    
    try {
      isSubmitting = true;
      await deleteOrganization(organization.id);
      goto('/organizations');
    } catch (err: any) {
      error = err.message || 'Failed to delete organization';
      console.error('Error deleting organization:', err);
    } finally {
      isSubmitting = false;
    }
  }

  // Check if user is owner or admin
  function canManageOrg(): boolean {
    return currentUserRole === 'owner' || currentUserRole === 'admin';
  }
  
  // Check if user is owner
  function isOwner(): boolean {
    return currentUserRole === 'owner';
  }
  
  // For debugging
  console.log('Current user role:', currentUserRole);
</script>

<svelte:head>
  <title>{organization?.name || 'Organization'} | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
  <div class="organization-page">
    {#if isLoading}
      <div class="loading">
        <span class="loading-spinner"></span>
        <span>Loading organization...</span>
      </div>
    {:else if error || !organization || !organization.id || !organization.slug}
      <div class="error-container">
        <h2>Error</h2>
        <p>{error || "Organization not found or you don't have access to it"}</p>
        <a href="/organizations" class="btn btn-primary">Back to Organizations</a>
      </div>
    {:else if organization}
      <div class="organization-header">
        <div class="header-content">
          <div class="avatar">
            <span>{organization.name.substring(0, 2).toUpperCase()}</span>
          </div>
          <div class="info">
            {#if isEditing}
              <OrganizationForm 
                {organization}
                {isSubmitting}
                on:success={handleUpdateSuccess}
                on:error={(e) => error = e.detail}
                on:cancel={() => isEditing = false}
              />
            {:else}
              <h1>{organization.name}</h1>
              <p class="subtitle">/{organization.slug}</p>
              
              {#if organization.created_at}
                <p class="date">
                  Created on {new Date(organization.created_at).toLocaleDateString()}
                </p>
              {/if}
              
              {#if canManageOrg()}
                <div class="actions">
                  <button class="btn btn-secondary" on:click={() => isEditing = true}>
                    Edit Organization
                  </button>
                  
                  {#if isOwner()}
                    <button class="btn btn-danger" on:click={handleDelete} disabled={isSubmitting}>
                      {isSubmitting ? 'Deleting...' : 'Delete Organization'}
                    </button>
                  {/if}
                </div>
              {/if}
            {/if}
          </div>
        </div>
      </div>

      <!-- Organization projects will go here in the future -->
      
      <!-- Organization members management -->
      <div class="organization-members-section">
        {#if organization.id}
          <OrganizationMembers organizationId={organization.id} />
        {:else}
          <div class="error-message">Unable to load members: missing organization ID</div>
        {/if}
      </div>
    {/if}
  </div>
</AuthGuard>

<style>
  .organization-page {
    max-width: 1000px;
    margin: 0 auto;
    padding: 1rem;
  }
  
  .loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 3rem 0;
  }
  
  .loading-spinner {
    display: inline-block;
    width: 2rem;
    height: 2rem;
    border: 0.25rem solid rgba(0, 0, 0, 0.1);
    border-radius: 50%;
    border-top-color: var(--primary-color);
    animation: spin 1s ease-in-out infinite;
    margin-bottom: 0.75rem;
  }
  
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
  
  .error-container {
    text-align: center;
    background-color: white;
    border-radius: var(--border-radius-md);
    padding: 2rem;
    box-shadow: var(--shadow-sm);
  }
  
  .error-container h2 {
    color: var(--danger-color);
    margin-top: 0;
  }
  
  .organization-header {
    background-color: white;
    border-radius: var(--border-radius-md);
    padding: 2rem;
    box-shadow: var(--shadow-sm);
    margin-bottom: 2rem;
  }
  
  .header-content {
    display: flex;
    gap: 2rem;
  }
  
  .avatar {
    width: 80px;
    height: 80px;
    background-color: var(--primary-color);
    border-radius: 16px;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    font-weight: bold;
    flex-shrink: 0;
  }
  
  .info {
    flex-grow: 1;
  }
  
  h1 {
    margin: 0 0 0.5rem 0;
    color: var(--text-color);
  }
  
  .subtitle {
    color: #666;
    margin: 0 0 0.5rem 0;
    font-size: 1.1rem;
  }
  
  .date {
    color: #888;
    font-size: 0.9rem;
    margin-bottom: 1.5rem;
  }
  
  .actions {
    display: flex;
    gap: 1rem;
  }
  
  .btn {
    padding: 0.6rem 1.2rem;
    border-radius: var(--border-radius-sm);
    font-weight: 500;
    cursor: pointer;
    border: none;
    transition: all 0.2s;
  }
  
  .btn-primary {
    background-color: var(--primary-color);
    color: white;
    text-decoration: none;
  }
  
  .btn-primary:hover {
    background-color: var(--primary-hover);
    text-decoration: none;
  }
  
  .btn-secondary {
    background-color: #f1f2f3;
    color: var(--text-color);
  }
  
  .btn-secondary:hover {
    background-color: #e2e3e5;
  }
  
  .btn-danger {
    background-color: #f8d7da;
    color: var(--danger-color);
  }
  
  .btn-danger:hover:not(:disabled) {
    background-color: #f5c2c7;
  }
  
  .btn:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
  
  .organization-members-section {
    margin-top: 2rem;
  }
  
  @media (max-width: 768px) {
    .header-content {
      flex-direction: column;
      align-items: center;
      text-align: center;
    }
    
    .actions {
      justify-content: center;
      flex-wrap: wrap;
    }
  }
</style>