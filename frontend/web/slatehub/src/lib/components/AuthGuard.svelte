<script lang="ts">
  import { onMount } from 'svelte';
  import { authState } from '$lib/db/surreal';
  import { goto } from '$app/navigation';

  export let requireAuth: boolean = true;
  export let redirectTo: string = '/login';

  let isLoading = true;

  onMount(() => {
    // Check authentication status
    isLoading = false;
    if (requireAuth && !$authState.isAuthenticated) {
      goto(redirectTo);
    } else if (!requireAuth && $authState.isAuthenticated) {
      goto('/'); // Redirect to home if already authenticated
    }
  });
</script>

{#if isLoading}
  <div class="loading">
    <span class="loading-spinner"></span>
    <span class="loading-text">Loading...</span>
  </div>
{:else if (requireAuth && $authState.isAuthenticated) || (!requireAuth && !$authState.isAuthenticated)}
  <slot />
{/if}

<style>
  .loading {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 2rem;
    color: var(--text-color);
  }

  .loading-spinner {
    display: inline-block;
    width: 2rem;
    height: 2rem;
    border: 0.25rem solid rgba(0, 0, 0, 0.1);
    border-radius: 50%;
    border-top-color: var(--primary-color);
    animation: spin 1s ease-in-out infinite;
    margin-bottom: 1rem;
  }

  .loading-text {
    font-size: 1rem;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>