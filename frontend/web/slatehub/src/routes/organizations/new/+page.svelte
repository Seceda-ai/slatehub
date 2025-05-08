<script lang="ts">
  import { goto } from '$app/navigation';
  import AuthGuard from '$lib/components/AuthGuard.svelte';
  import OrganizationForm from '$lib/components/organizations/OrganizationForm.svelte';
  import type { Organization } from '$lib/db/organizations';

  let isSubmitting = false;

  // Handle successful organization creation
  function handleSuccess(event: CustomEvent<Organization>) {
    const organization = event.detail;
    if (organization && organization.id) {
      console.log('Redirecting to organization page:', organization);
      // Use either slug or ID for the route
      const route = organization.slug 
        ? `/organizations/${organization.slug}` 
        : `/organizations/${organization.id}`;
      goto(route);
    } else {
      console.error('Invalid organization data received:', organization);
      goto('/organizations');
    }
  }

  // Handle error in organization creation
  function handleError(event: CustomEvent<string>) {
    console.error('Error creating organization:', event.detail);
    // Show error to user
    const errorMessage = document.getElementById('error-message');
    if (errorMessage) {
      errorMessage.textContent = event.detail;
      errorMessage.style.display = 'block';
    }
  }

  // Handle cancel button click
  function handleCancel() {
    goto('/organizations');
  }
</script>

<svelte:head>
  <title>Create Organization | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
  <div class="new-organization-page">
    <div class="page-header">
      <h1>Create New Organization</h1>
      <p class="page-description">
        Create an organization to collaborate with team members on projects
      </p>
    </div>
    
    <div id="error-message" class="error-message" style="display: none;">
    </div>

    <div class="form-container">
      <OrganizationForm 
        {isSubmitting}
        on:success={handleSuccess}
        on:error={handleError}
        on:cancel={handleCancel}
      />
    </div>
  </div>
</AuthGuard>

<style>
  .new-organization-page {
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