<script lang="ts">
  import { goto } from '$app/navigation';
  import AuthGuard from '$lib/components/AuthGuard.svelte';
  import ProductionForm from '$lib/components/productions/ProductionForm.svelte';
  import type { Production } from '$lib/db/productions';

  let isSubmitting = false;

  // Handle successful production creation
  function handleSuccess(event: CustomEvent<Production>) {
    const production = event.detail;
    if (production && production.id) {
      console.log('Redirecting to production page:', production);
      // Use either slug or ID for the route
      const route = production.slug 
        ? `/productions/${production.slug}` 
        : `/productions/${production.id}`;
      goto(route);
    } else {
      console.error('Invalid production data received:', production);
      goto('/productions');
    }
  }

  // Handle error in production creation
  function handleError(event: CustomEvent<string>) {
    console.error('Error creating production:', event.detail);
    // Show error to user
    const errorMessage = document.getElementById('error-message');
    if (errorMessage) {
      errorMessage.textContent = event.detail;
      errorMessage.style.display = 'block';
    }
  }

  // Handle cancel button click
  function handleCancel() {
    goto('/productions');
  }
</script>

<svelte:head>
  <title>Create Production | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
  <div class="new-production-page">
    <div class="page-header">
      <h1>Create New Production</h1>
      <p class="page-description">
        Create a production to collaborate with team members
      </p>
    </div>
    
    <div id="error-message" class="error-message" style="display: none;">
    </div>

    <div class="form-container">
      <ProductionForm 
        production={null}
        {isSubmitting}
        on:success={handleSuccess}
        on:error={handleError}
        on:cancel={handleCancel}
      />
    </div>
  </div>
</AuthGuard>

<style>
  .new-production-page {
    max-width: 800px;
    margin: 0 auto;
    padding: 1rem;
  }

  .page-header {
    text-align: center;
    margin-bottom: 2rem;
  }

  h1 {
    color: var(--text-color);
    margin-bottom: 0.5rem;
  }

  .page-description {
    color: #666;
    max-width: 600px;
    margin: 0 auto;
  }

  .error-message {
    background-color: rgba(220, 53, 69, 0.1);
    color: var(--danger-color);
    border: 1px solid rgba(220, 53, 69, 0.2);
    padding: 1rem;
    border-radius: var(--border-radius-sm);
    margin-bottom: 1.5rem;
    text-align: center;
  }

  .form-container {
    margin-top: 1.5rem;
  }
</style>