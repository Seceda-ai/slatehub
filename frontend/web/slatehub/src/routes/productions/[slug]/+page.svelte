<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import AuthGuard from '$lib/components/AuthGuard.svelte';
  import ProductionForm from '$lib/components/productions/ProductionForm.svelte';
  import ProductionMembers from '$lib/components/productions/ProductionMembers.svelte';
  import { 
      getProductionBySlug, 
      deleteProduction,
      type Production 
    } from '$lib/db/productions';

  // Get the slug from the URL parameter
  $: slug = $page.params.slug;
  
  // State variables
  let production: Production | null = null;
  let isLoading = true;
  let error: string | null = null;
  let showEditForm = false;
  let isDeleting = false;
  let isOwner = false;
  let isAdmin = false;

  // Fetch production data when slug changes
  $: if (slug) {
    loadProduction(slug);
  }

  // Load production data
  async function loadProduction(slugOrId: string) {
    try {
      isLoading = true;
      const data = await getProductionBySlug(slugOrId);
      
      if (!data) {
        error = 'Production not found';
        production = null;
      } else {
        production = data;
        error = null;
        
        // TODO: Get the user's role in this production
        // This would typically come from checking the membership
        isOwner = true; // Temporary: set based on actual role
        isAdmin = true; // Temporary: set based on actual role
      }
    } catch (err: any) {
      error = err.message || 'Failed to load production';
      console.error('Error loading production:', err);
    } finally {
      isLoading = false;
    }
  }

  // Handle deleting the production
  async function handleDelete() {
    if (!production?.id) return;
    
    if (!confirm('Are you sure you want to delete this production? This action cannot be undone.')) {
      return;
    }
    
    try {
      isDeleting = true;
      await deleteProduction(production.id);
      goto('/productions');
    } catch (err: any) {
      error = err.message || 'Failed to delete production';
      console.error('Error deleting production:', err);
    } finally {
      isDeleting = false;
    }
  }

  // Handle successful edit
  function handleEditSuccess(event: CustomEvent<Production>) {
    production = event.detail;
    showEditForm = false;
  }

  // Handle edit error
  function handleEditError(event: CustomEvent<string>) {
    error = event.detail;
  }

  // Toggle edit form
  function toggleEditForm() {
    showEditForm = !showEditForm;
  }

  // Cancel editing
  function handleEditCancel() {
    showEditForm = false;
  }

  // Format date for display
  function formatDate(dateString: string | undefined): string {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }
</script>

<svelte:head>
  <title>{production ? production.title : 'Loading...'} | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
  <div class="production-detail-page">
    {#if error}
      <div class="alert alert-error">
        <p>{error}</p>
      </div>
    {/if}

    {#if isLoading}
      <div class="loading">
        <span class="loading-spinner"></span>
        <span>Loading production...</span>
      </div>
    {:else if !production}
      <div class="not-found">
        <h2>Production Not Found</h2>
        <p>The production you're looking for doesn't exist or you don't have access to it.</p>
        <a href="/productions" class="btn btn-primary">Back to Productions</a>
      </div>
    {:else}
      {#if !showEditForm}
        <div class="production-header">
          <div class="title-area">
            <h1>{production.title}</h1>
            <div class="meta">
              <span class="created-date">Created: {formatDate(production.created_at)}</span>
              {#if production.updated_at && production.updated_at !== production.created_at}
                <span class="updated-date">Updated: {formatDate(production.updated_at)}</span>
              {/if}
            </div>
          </div>
          
          {#if isOwner || isAdmin}
            <div class="actions">
              <button class="btn btn-secondary" on:click={toggleEditForm}>
                Edit
              </button>
              {#if isOwner}
                <button 
                  class="btn btn-danger" 
                  on:click={handleDelete}
                  disabled={isDeleting}
                >
                  {isDeleting ? 'Deleting...' : 'Delete'}
                </button>
              {/if}
            </div>
          {/if}
        </div>
        
        <!-- Production members section -->
        <ProductionMembers 
          productionId={production.id || ''} 
          {isOwner}
          {isAdmin}
        />
        
        <!-- Additional production details would go here -->
        <!-- For example, tasks, timeline, documents, etc. -->
        
      {:else}
        <!-- Edit form -->
        <div class="edit-form-container">
          <h2>Edit Production</h2>
          <ProductionForm 
            production={production} 
            on:success={handleEditSuccess}
            on:error={handleEditError}
            on:cancel={handleEditCancel}
          />
        </div>
      {/if}
    {/if}
  </div>
</AuthGuard>

<style>
  .production-detail-page {
    max-width: 900px;
    margin: 0 auto;
    padding: 1rem;
  }

  .alert {
    padding: 1rem;
    border-radius: var(--border-radius-sm);
    margin-bottom: 1.5rem;
  }

  .alert-error {
    background-color: rgba(220, 53, 69, 0.1);
    color: var(--danger-color);
    border: 1px solid rgba(220, 53, 69, 0.2);
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

  .not-found {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    text-align: center;
  }

  .production-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--border-color);
  }

  h1 {
    margin: 0 0 0.5rem 0;
    color: var(--text-color);
  }

  h2 {
    margin-top: 0;
    color: var(--text-color);
  }

  .meta {
    display: flex;
    gap: 1rem;
    color: #666;
    font-size: 0.875rem;
  }

  .actions {
    display: flex;
    gap: 0.5rem;
  }

  .btn {
    display: inline-block;
    padding: 0.5rem 1rem;
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
    text-decoration: none;
  }

  .btn-primary {
    background-color: var(--primary-color);
    color: white;
  }

  .btn-primary:hover:not(:disabled) {
    background-color: var(--primary-hover);
  }

  .btn-secondary {
    background-color: #e9ecef;
    color: #495057;
  }

  .btn-secondary:hover:not(:disabled) {
    background-color: #dce0e5;
  }

  .btn-danger {
    background-color: var(--danger-color);
    color: white;
  }

  .btn-danger:hover:not(:disabled) {
    background-color: #c82333;
  }

  .btn:disabled {
    opacity: 0.65;
    cursor: not-allowed;
  }

  .edit-form-container {
    background-color: white;
    border-radius: var(--border-radius-md);
    padding: 1.5rem;
    box-shadow: var(--shadow-sm);
  }

  @media (max-width: 640px) {
    .production-header {
      flex-direction: column;
    }
    
    .actions {
      margin-top: 1rem;
    }
  }
</style>