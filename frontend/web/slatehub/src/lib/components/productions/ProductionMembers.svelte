<script lang="ts">
  import { onMount } from 'svelte';
  import { 
    getProductionMembers, 
    addProductionMember, 
    updateMemberRole, 
    removeMember, 
    type ProductionMember 
  } from '$lib/db/productions';

  // Props
  export let productionId: string;
  export let isOwner = false;
  export let isAdmin = false;

  // Computed
  $: canManageMembers = isOwner || isAdmin;

  // State
  let members: ProductionMember[] = [];
  let isLoading = true;
  let error: string | null = null;
  let showAddForm = false;
  let newUsername = '';
  let newRole: 'admin' | 'editor' | 'viewer' = 'viewer';
  let isSubmitting = false;
  let editMemberId: string | null = null;
  let editRole: 'owner' | 'admin' | 'editor' | 'viewer' = 'viewer';

  // Load members on mount
  onMount(async () => {
    await loadMembers();
  });

  // Load or reload members
  async function loadMembers() {
    try {
      isLoading = true;
      if (!productionId) {
        error = 'Missing production ID';
        members = [];
        return;
      }
      members = await getProductionMembers(productionId);
      error = null;
    } catch (err: any) {
      error = err.message || 'Failed to load members';
      console.error('Error loading members:', err);
      members = [];
    } finally {
      isLoading = false;
    }
  }

  // Add a new member
  // Handler functions
  async function handleAddMember() {
    if (!productionId) {
      error = 'Production ID is missing';
      return;
    }
    
    if (!newUsername || !newRole) {
      error = 'Username and role are required';
      return;
    }

    try {
      isSubmitting = true;
      await addProductionMember(productionId, newUsername, newRole);
      
      // Reset form and reload members
      newUsername = '';
      newRole = 'viewer';
      showAddForm = false;
      await loadMembers();
      error = null;
    } catch (err: any) {
      error = err.message || 'Failed to add member';
      console.error('Error adding member:', err);
    } finally {
      isSubmitting = false;
    }
  }

  // Update member role
  async function handleUpdateRole(memberId: string) {
    if (!memberId) {
      error = 'Member ID is missing';
      return;
    }
    
    if (!editRole) {
      error = 'Role is required';
      return;
    }

    try {
      isSubmitting = true;
      await updateMemberRole(memberId, editRole);
      
      // Reset and reload
      editMemberId = null;
      await loadMembers();
      error = null;
    } catch (err: any) {
      error = err.message || 'Failed to update role';
      console.error('Error updating role:', err);
    } finally {
      isSubmitting = false;
    }
  }

  // Remove a member
  async function handleRemoveMember(memberId: string) {
    if (!memberId) {
      error = 'Member ID is missing';
      return;
    }
    
    if (!confirm('Are you sure you want to remove this member?')) {
      return;
    }

    try {
      isSubmitting = true;
      await removeMember(memberId);
      await loadMembers();
      error = null;
    } catch (err: any) {
      error = err.message || 'Failed to remove member';
      console.error('Error removing member:', err);
    } finally {
      isSubmitting = false;
    }
  }

  // Start editing a member's role
  function startEdit(member: ProductionMember) {
    editMemberId = member.id || null;
    editRole = member.role || 'viewer';
  }

  // Cancel editing
  function cancelEdit() {
    editMemberId = null;
  }

  // Format role for display
  function formatRole(role: string | undefined): string {
    if (!role) return 'Viewer';
    return role.charAt(0).toUpperCase() + role.slice(1);
  }
</script>

<div class="production-members">
  <div class="section-header">
    <h3>Production Members</h3>
    
    {#if canManageMembers && !showAddForm}
      <button class="btn btn-sm btn-outline" on:click={() => showAddForm = true}>
        Add Member
      </button>
    {/if}
  </div>

  {#if error}
    <div class="alert alert-error">
      <p>{error}</p>
    </div>
  {/if}

  {#if showAddForm}
    <div class="add-member-form">
      <h4>Add New Member</h4>
      <div class="form-row">
        <div class="form-group">
          <label for="username">Username</label>
          <input 
            type="text" 
            id="username" 
            bind:value={newUsername} 
            placeholder="Enter username"
            disabled={isSubmitting}
          />
        </div>
        
        <div class="form-group">
          <label for="role">Role</label>
          <select id="role" bind:value={newRole} disabled={isSubmitting}>
            {#if isOwner}
              <option value="admin">Admin</option>
            {/if}
            <option value="editor">Editor</option>
            <option value="viewer">Viewer</option>
          </select>
        </div>
      </div>
      
      <div class="form-actions">
        <button 
          type="button" 
          class="btn btn-sm btn-secondary"
          on:click={() => showAddForm = false}
          disabled={isSubmitting}
        >
          Cancel
        </button>
        <button 
          type="button" 
          class="btn btn-sm btn-primary"
          on:click={handleAddMember}
          disabled={isSubmitting}
        >
          {isSubmitting ? 'Adding...' : 'Add Member'}
        </button>
      </div>
    </div>
  {/if}

  {#if isLoading}
    <div class="loading">
      <span>Loading members...</span>
    </div>
  {:else if members.length === 0}
    <div class="empty-state">
      <p>This production doesn't have any members yet.</p>
    </div>
  {:else}
    <div class="members-list">
      {#each members.filter(m => m !== null && m !== undefined) as member (member.id || `member-${Math.random()}`)}
        <div class="member-item">
          <div class="member-info">
            <div class="member-username">{member.person?.username || 'Unknown'}</div>
            <div class="member-email">{member.person?.email || 'No email'}</div>
          </div>
          
          <div class="member-role">
            {#if editMemberId === member.id}
              <div class="role-edit">
                <select bind:value={editRole} disabled={isSubmitting}>
                  {#if isOwner}
                    <option value="owner">Owner</option>
                    <option value="admin">Admin</option>
                  {/if}
                  <option value="editor">Editor</option>
                  <option value="viewer">Viewer</option>
                </select>
                
                <div class="role-edit-actions">
                  <button 
                    class="btn btn-xs btn-primary"
                    on:click={() => handleUpdateRole(member.id || '')}
                    disabled={isSubmitting}
                  >
                    Save
                  </button>
                  <button 
                    class="btn btn-xs btn-secondary"
                    on:click={cancelEdit}
                    disabled={isSubmitting}
                  >
                    Cancel
                  </button>
                </div>
              </div>
            {:else}
              <span class="role-badge" class:role-owner={member.role === 'owner'}>
                {formatRole(member.role)}
              </span>
              
              {#if canManageMembers}
                <div class="member-actions">
                  <button 
                    class="btn btn-xs btn-icon"
                    on:click={() => startEdit(member)}
                    title="Edit role"
                  >
                    ✏️
                  </button>
                  
                  {#if !(member.role === 'owner' && !isOwner) && member.id}
                    <button 
                      class="btn btn-xs btn-icon btn-danger"
                      on:click={() => handleRemoveMember(member.id || '')}
                      title="Remove member"
                    >
                      🗑️
                    </button>
                  {/if}
                </div>
              {/if}
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .production-members {
    margin-top: 2rem;
  }
  
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }
  
  h3 {
    margin: 0;
    color: var(--text-color);
  }
  
  h4 {
    margin-top: 0;
    margin-bottom: 1rem;
    color: var(--text-color);
  }
  
  .alert {
    padding: 1rem;
    border-radius: var(--border-radius-sm);
    margin-bottom: 1rem;
  }
  
  .alert-error {
    background-color: rgba(220, 53, 69, 0.1);
    color: var(--danger-color);
    border: 1px solid rgba(220, 53, 69, 0.2);
  }
  
  .add-member-form {
    margin-bottom: 1.5rem;
    padding: 1rem;
    background-color: #f8f9fa;
    border-radius: var(--border-radius-sm);
  }
  
  .form-row {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
  }
  
  .form-group {
    flex: 1;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    font-size: 0.875rem;
  }
  
  .form-group input,
  .form-group select {
    width: 100%;
    padding: 0.5rem;
    border: 1px solid var(--border-color);
    border-radius: var(--border-radius-sm);
  }
  
  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 0.5rem;
  }
  
  .loading {
    text-align: center;
    padding: 1rem;
    color: #666;
  }
  
  .empty-state {
    text-align: center;
    padding: 1rem;
    color: #666;
    background-color: #f8f9fa;
    border-radius: var(--border-radius-sm);
  }
  
  .members-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .member-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem;
    background-color: white;
    border-radius: var(--border-radius-sm);
    border: 1px solid var(--border-color);
  }
  
  .member-info {
    flex: 1;
  }
  
  .member-username {
    font-weight: 500;
    color: var(--text-color);
  }
  
  .member-email {
    font-size: 0.875rem;
    color: #666;
  }
  
  .member-role {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }
  
  .role-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
    font-weight: 500;
    background-color: #e9ecef;
    color: #495057;
    border-radius: 1rem;
  }
  
  .role-owner {
    background-color: rgba(0, 123, 255, 0.2);
    color: #0056b3;
  }
  
  .role-edit {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .role-edit-actions {
    display: flex;
    gap: 0.25rem;
  }
  
  .member-actions {
    display: flex;
    gap: 0.25rem;
    opacity: 0;
    transition: opacity 0.2s;
  }
  
  .member-item:hover .member-actions {
    opacity: 1;
  }
  
  .btn {
    display: inline-block;
    padding: 0.375rem 0.75rem;
    font-size: 0.875rem;
    font-weight: 500;
    line-height: 1.5;
    text-align: center;
    white-space: nowrap;
    vertical-align: middle;
    cursor: pointer;
    border: 1px solid transparent;
    border-radius: var(--border-radius-sm);
    transition: color 0.15s, background-color 0.15s, border-color 0.15s;
  }
  
  .btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
  }
  
  .btn-xs {
    padding: 0.125rem 0.25rem;
    font-size: 0.75rem;
  }
  
  .btn-primary {
    background-color: var(--primary-color);
    color: white;
  }
  
  .btn-primary:hover:not(:disabled) {
    background-color: var(--primary-hover);
  }
  
  .btn-secondary {
    background-color: #f1f2f3;
    color: var(--text-color);
  }
  
  .btn-secondary:hover:not(:disabled) {
    background-color: #e2e3e5;
  }
  
  .btn-outline {
    background-color: transparent;
    border: 1px solid var(--primary-color);
    color: var(--primary-color);
  }
  
  .btn-outline:hover {
    background-color: var(--primary-color);
    color: white;
  }
  
  .btn-icon {
    padding: 0.125rem 0.25rem;
    background: transparent;
    border: none;
  }
  
  .btn-danger {
    color: var(--danger-color);
  }
  
  .btn-danger:hover {
    background-color: rgba(220, 53, 69, 0.1);
  }
  
  .btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
  }
  
  @media (max-width: 640px) {
    .form-row {
      flex-direction: column;
    }
    
    .member-item {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .member-role {
      margin-top: 0.5rem;
      width: 100%;
      justify-content: space-between;
    }
    
    .member-actions {
      opacity: 1;
    }
  }
</style>