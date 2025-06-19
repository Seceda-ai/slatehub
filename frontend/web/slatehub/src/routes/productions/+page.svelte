<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import AuthGuard from '$lib/components/AuthGuard.svelte';
  import ProductionCard from '$lib/components/productions/ProductionCard.svelte';
  import { getUserProductions, type Production } from '$lib/db/productions';
  import { connect, getConnectionState, ConnectionState } from '$lib/db/surreal';

  // State variables
  let productions: Production[] = [];
  let isLoading = true;
  let error: string | null = null;

  // Fetch productions on mount
  onMount(async () => {
    try {
      isLoading = true;
      // Make sure we're connected to SurrealDB
      if (getConnectionState() !== ConnectionState.CONNECTED) {
        await connect();
      }
      productions = await getUserProductions();
    } catch (err: any) {
      error = err.message || 'Failed to load productions';
      console.error('Error loading productions:', err);
    } finally {
      isLoading = false;
    }
  });
</script>

<svelte:head>
  <title>My Productions | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
  <div class="productions-page">
    <div class="page-header">
      <h1>My Productions</h1>
      <button class="btn btn-primary" on:click={() => goto('/productions/new')}>
        Create Production
      </button>
    </div>

    {#if error}
      <div class="alert alert-error">
        <p>{error}</p>
        {#if error.includes('connect') || error.includes('network') || error.includes('SurrealDB')}
          <p class="error-help">
            Make sure your SurrealDB server is running and accessible.
            <a href="/debug" class="debug-link">Go to Debug Console</a>
          </p>
        {/if}
      </div>
    {/if}

    {#if isLoading}
      <div class="loading">
        <span class="loading-spinner"></span>
        <span>Loading productions...</span>
      </div>
    {:else if productions.length === 0}
      <div class="empty-state">
        <h2>No Productions Yet</h2>
        <p>Create your first production to start collaborating with your team.</p>
        <button class="btn btn-primary" on:click={() => goto('/productions/new')}>
          Create Production
        </button>
      </div>
    {:else}
      <div class="productions-list">
        {#each productions as production (production.id)}
          <ProductionCard production={production} />
        {/each}
      </div>
    {/if}
  </div>
</AuthGuard>

<style>
  .productions-page {
    max-width: 900px;
    margin: 0 auto;
    padding: 1rem;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
  }

  h1 {
    margin: 0;
    color: var(--text-color);
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
  
  .error-help {
    font-size: 0.875rem;
    margin-top: 0.5rem;
    padding-top: 0.5rem;
    border-top: 1px solid rgba(220, 53, 69, 0.2);
  }
  
  .debug-link {
    display: inline-block;
    margin-top: 0.5rem;
    color: var(--primary-color);
    font-weight: 500;
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

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    text-align: center;
    background-color: white;
    border-radius: var(--border-radius-md);
    box-shadow: var(--shadow-sm);
  }

  .empty-state h2 {
    margin-top: 0;
    margin-bottom: 0.5rem;
    color: var(--text-color);
  }

  .empty-state p {
    color: #666;
    margin-bottom: 1.5rem;
  }

  .btn {
    display: inline-block;
    padding: 0.6rem 1.2rem;
    background-color: var(--primary-color);
    color: white;
    border: none;
    border-radius: var(--border-radius-sm);
    font-weight: 500;
    cursor: pointer;
    text-decoration: none;
    transition: background-color 0.2s ease;
  }

  .btn:hover {
    background-color: var(--primary-hover);
    text-decoration: none;
  }

  .productions-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  @media (max-width: 640px) {
    .page-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 1rem;
    }
  }
</style>