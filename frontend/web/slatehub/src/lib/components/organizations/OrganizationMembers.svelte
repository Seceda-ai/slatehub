<script lang="ts">
  import { onMount } from 'svelte';
  import { getOrganizationMembers, addOrganizationMember, updateMemberRole, removeMember, type OrganizationMember } from '$lib/db/organizations';
  
  export let organizationId: string;
  
  // State variables
  let members: OrganizationMember[] = [];
  let isLoading = true;
  let error: string | null = null;
  
  // Form state for adding new members
  let newMemberUsername = '';
  let newMemberRole: "admin" | "editor" | "viewer" = "editor";
  let isSubmitting = false;
  let showAddMemberForm = false;
  let addMemberError: string | null = null;
  
  // Editing state
  let editingMemberId: string | null = null;
  let editingRole: "owner" | "admin" | "editor" | "viewer" = "editor";
  
  // Helper functions to safely extract person data
  function getPersonUsername(member: OrganizationMember | null | undefined): string {
    if (!member) return 'Unknown';
    
    const person = member.person;
    if (!person) return 'Unknown';
    
    // Handle array format
    if (Array.isArray(person)) {
      return person[0]?.username || 'Unknown';
    }
    
    // Handle object format
    if (typeof person === 'object') {
      return person.username || 'Unknown';
    }
    
    return 'Unknown';
  }
  
  function getPersonEmail(member: OrganizationMember | null | undefined): string {
    if (!member) return '';
    
    const person = member.person;
    if (!person) return '';
    
    // Handle array format
    if (Array.isArray(person)) {
      return person[0]?.email || '';
    }
    
    // Handle object format
    if (typeof person === 'object') {
      return person.email || '';
    }
    
    return '';
  }
  
  function getPersonInitial(member: OrganizationMember | null | undefined): string {
    const username = getPersonUsername(member);
    return username !== 'Unknown' ? username.substring(0, 1).toUpperCase() : '?';
  }
  
  // Load members on mount
  onMount(async () => {
    await loadMembers();
  });
  
  // Load members
  async function loadMembers() {
    try {
      isLoading = true;
      error = null;
      members = await getOrganizationMembers(organizationId);
      console.log('Loaded members:', members);
      
      // Filter out any invalid members and normalize the data structure
      members = (members || []).filter(m => m && typeof m === 'object')
        .map(member => {
          // Ensure we have consistent person data structure
          if (member.person) {
            // If it's not an array or object, set it to undefined
            if (typeof member.person !== 'object') {
              member.person = undefined;
            }
          }
          return member;
        });
    } catch (err: any) {
      error = err.message || 'Failed to load organization members';
      console.error('Error loading members:', err);
      members = [];
    } finally {
      isLoading = false;
    }
  }
  
  // Add new member
  async function handleAddMember() {
    if (!newMemberUsername) {
      addMemberError = 'Please enter a username';
      return;
    }
    
    try {
      isSubmitting = true;
      addMemberError = null;
      
      await addOrganizationMember(organizationId, newMemberUsername, newMemberRole);
      
      // Clear form and refresh members
      newMemberUsername = '';
      showAddMemberForm = false;
      await loadMembers();
    } catch (err: any) {
      addMemberError = err.message || 'Failed to add member';
      console.error('Error adding member:', err);
    } finally {
      isSubmitting = false;
    }
  }
  
  // Update member role
  async function handleUpdateRole(memberId: string) {
    if (!memberId) {
      error = 'Invalid member ID';
      return;
    }
    
    try {
      isSubmitting = true;
      await updateMemberRole(memberId, editingRole);
      
      // Reset editing state and refresh members
      editingMemberId = null;
      await loadMembers();
    } catch (err: any) {
      error = err.message || 'Failed to update member role';
      console.error('Error updating role:', err);
    } finally {
      isSubmitting = false;
    }
  }
  
  // Remove member
  async function handleRemoveMember(memberId: string) {
    if (!memberId) {
      error = 'Invalid member ID';
      return;
    }
    
    if (!confirm('Are you sure you want to remove this member from the organization?')) {
      return;
    }
    
    try {
      isSubmitting = true;
      await removeMember(memberId);
      
      // Refresh members
      await loadMembers();
    } catch (err: any) {
      error = err.message || 'Failed to remove member';
      console.error('Error removing member:', err);
    } finally {
      isSubmitting = false;
    }
  }
  
  // Start editing a member's role
  function startEditingRole(member: OrganizationMember) {
    editingMemberId = member.id || null;
    editingRole = member.role || 'viewer';
  }
  
  // Cancel editing
  function cancelEditing() {
    editingMemberId = null;
  }
</script>

<div class="organization-members">
  <div class="members-header">
    <h2>Organization Members</h2>
    
    {#if !showAddMemberForm}
      <button 
        class="btn btn-primary btn-sm" 
        on:click={() => showAddMemberForm = true}
        disabled={isSubmitting}
      >
        Add Member
      </button>
    {/if}
  </div>
  
  {#if error}
    <div class="alert alert-error">
      {error}
    </div>
  {/if}
  
  {#if showAddMemberForm}
    <div class="add-member-form">
      <h3>Add New Member</h3>
      
      {#if addMemberError}
        <div class="alert alert-error">
          {addMemberError}
        </div>
      {/if}
      
      <div class="form-group">
        <label for="username">Username</label>
        <input 
          type="text" 
          id="username" 
          bind:value={newMemberUsername} 
          placeholder="Enter username" 
          disabled={isSubmitting}
        />
      </div>
      
      <div class="form-group">
        <label for="role">Role</label>
        <select id="role" bind:value={newMemberRole} disabled={isSubmitting}>
          <option value="admin">Admin</option>
          <option value="editor">Editor</option>
          <option value="viewer">Viewer</option>
        </select>
      </div>
      
      <div class="form-actions">
        <button 
          type="button" 
          class="btn btn-secondary btn-sm" 
          on:click={() => {
            showAddMemberForm = false;
            addMemberError = null;
            newMemberUsername = '';
          }}
          disabled={isSubmitting}
        >
          Cancel
        </button>
        
        <button 
          type="button" 
          class="btn btn-primary btn-sm" 
          on:click={handleAddMember}
          disabled={isSubmitting}
        >
          {isSubmitting ? 'Adding...' : 'Add Member'}
        </button>
      </div>
    </div>
  {/if}
  
  {#if isLoading}
    <div class="loading">Loading members...</div>
  {:else if members.length === 0}
    <div class="empty-state">
      <p>No members found in this organization.</p>
    </div>
  {:else}
    <div class="members-list">
      <table>
        <thead>
          <tr>
            <th>User</th>
            <th>Role</th>
            <th>Joined</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {#each members.filter(m => m !== null && m !== undefined) as member (member?.id || `member-${Math.random()}`)}
                    <tr>
                      <td class="member-info">
                        <span class="member-avatar">
                          {getPersonInitial(member)}
                        </span>
                        <div>
                          <div class="member-name">{getPersonUsername(member)}</div>
                          <div class="member-email">{getPersonEmail(member)}</div>
                        </div>
                      </td>
              <td>
                {#if editingMemberId === member.id}
                  <select bind:value={editingRole} disabled={isSubmitting}>
                    <option value="owner">Owner</option>
                    <option value="admin">Admin</option>
                    <option value="editor">Editor</option>
                    <option value="viewer">Viewer</option>
                  </select>
                {:else}
                  <span class="role-badge role-{member.role || 'viewer'}">
                    {member.role || 'viewer'}
                  </span>
                {/if}
              </td>
              <td>
                {#if member.joined_at}
                  <span class="joined-date">
                    {new Date(member.joined_at).toLocaleDateString()}
                  </span>
                {/if}
              </td>
              <td>
                {#if editingMemberId === member.id}
                  <div class="action-buttons">
                    <button 
                      class="btn btn-sm btn-secondary" 
                      on:click={cancelEditing}
                      disabled={isSubmitting}
                    >
                      Cancel
                    </button>
                    <button 
                      class="btn btn-sm btn-primary" 
                      on:click={() => handleUpdateRole(member.id || '')}
                      disabled={isSubmitting}
                    >
                      Save
                    </button>
                  </div>
                {:else}
                  <div class="action-buttons">
                    <button 
                      class="btn btn-sm btn-secondary" 
                      on:click={() => startEditingRole(member)}
                      disabled={isSubmitting}
                    >
                      Edit
                    </button>
                    <button 
                      class="btn btn-sm btn-danger" 
                      on:click={() => handleRemoveMember(member.id || '')}
                      disabled={isSubmitting}
                    >
                      Remove
                    </button>
                  </div>
                {/if}
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<style>
  .organization-members {
    background-color: white;
    border-radius: var(--border-radius-md);
    padding: 1.5rem;
    box-shadow: var(--shadow-sm);
    margin-bottom: 2rem;
  }
  
  .members-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }
  
  .members-header h2 {
    margin: 0;
    font-size: 1.25rem;
  }
  
  .add-member-form {
    background-color: #f9f9f9;
    border-radius: var(--border-radius-sm);
    padding: 1.25rem;
    margin-bottom: 1.5rem;
  }
  
  .add-member-form h3 {
    margin-top: 0;
    margin-bottom: 1rem;
    font-size: 1.1rem;
  }
  
  .form-group {
    margin-bottom: 1rem;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
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
    gap: 0.75rem;
    margin-top: 1.25rem;
  }
  
  .alert {
    padding: 0.75rem 1rem;
    border-radius: var(--border-radius-sm);
    margin-bottom: 1rem;
  }
  
  .alert-error {
    background-color: rgba(220, 53, 69, 0.1);
    color: var(--danger-color);
    border: 1px solid rgba(220, 53, 69, 0.2);
  }
  
  .loading {
    text-align: center;
    padding: 2rem 0;
    color: #666;
  }
  
  .empty-state {
    text-align: center;
    padding: 2rem 0;
    color: #666;
  }
  
  .members-list {
    overflow-x: auto;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th {
    text-align: left;
    padding: 0.75rem;
    background-color: #f5f5f5;
    border-bottom: 1px solid #eee;
    font-weight: 500;
    color: #555;
  }
  
  td {
    padding: 0.75rem;
    border-bottom: 1px solid #eee;
    vertical-align: middle;
  }
  
  .member-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }
  
  .member-avatar {
    width: 32px;
    height: 32px;
    background-color: var(--primary-color);
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
    font-size: 0.875rem;
  }
  
  .member-name {
    font-weight: 500;
  }
  
  .member-email {
    font-size: 0.75rem;
    color: #666;
  }
  
  .role-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 1rem;
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: capitalize;
  }
  
  .role-owner {
    background-color: #fce3d6;
    color: #d35400;
  }
  
  .role-admin {
    background-color: #d4edda;
    color: #28a745;
  }
  
  .role-editor {
    background-color: #d1ecf1;
    color: #17a2b8;
  }
  
  .role-viewer {
    background-color: #e2e3e5;
    color: #6c757d;
  }
  
  .joined-date {
    font-size: 0.875rem;
    color: #666;
  }
  
  .action-buttons {
    display: flex;
    gap: 0.5rem;
  }
  
  .btn {
    border: none;
    border-radius: var(--border-radius-sm);
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.875rem;
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
  
  /* Responsive adjustments */
  @media (max-width: 768px) {
    .members-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 1rem;
    }
    
    .action-buttons {
      flex-direction: column;
      gap: 0.5rem;
    }
    
    th:nth-child(3),
    td:nth-child(3) {
      display: none;
    }
  }
</style>