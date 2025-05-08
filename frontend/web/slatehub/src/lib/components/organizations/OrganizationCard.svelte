<script lang="ts">
  import { goto } from '$app/navigation';
  import type { Organization } from '$lib/db/organizations';
  
  export let organization: Organization;
  
  // Handles the click on the card
  function viewOrganization() {
    goto(`/organizations/${organization.slug}`);
  }
</script>

<div class="organization-card" 
  on:click={viewOrganization} 
  on:keydown={(e) => e.key === 'Enter' && viewOrganization()} 
  tabindex="0" 
  role="button"
  aria-label={`View organization ${organization.name}`}>
  <div class="card-content">
    <div class="organization-avatar">
      <span class="avatar-letters">{organization.name.substring(0, 2).toUpperCase()}</span>
    </div>
    
    <div class="organization-info">
      <h3 class="organization-name">{organization.name}</h3>
      <p class="organization-slug">/{organization.slug}</p>
      {#if organization.created_at}
        <p class="organization-created">
          Created {new Date(organization.created_at).toLocaleDateString(undefined, {month: 'short', day: 'numeric', year: 'numeric'})}
        </p>
      {/if}
    </div>
  </div>
  
  <div class="card-action">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <polyline points="9 18 15 12 9 6"></polyline>
    </svg>
  </div>
</div>

<style>
  .organization-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: white;
    border-radius: var(--border-radius-md);
    padding: 1.25rem;
    box-shadow: var(--shadow-sm);
    transition: all 0.2s ease;
    cursor: pointer;
    margin-bottom: 1rem;
  }
  
  .organization-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
  }
  
  .organization-card:focus {
    outline: 2px solid var(--primary-color);
    outline-offset: 2px;
  }
  
  .card-content {
    display: flex;
    align-items: center;
    gap: 1rem;
  }
  
  .organization-avatar {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    background-color: var(--primary-color);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: bold;
    flex-shrink: 0;
  }
  
  .avatar-letters {
    font-size: 1.25rem;
  }
  
  .organization-info {
    display: flex;
    flex-direction: column;
  }
  
  .organization-name {
    font-size: 1.1rem;
    margin: 0 0 0.25rem 0;
    color: var(--text-color);
  }
  
  .organization-slug {
    font-size: 0.875rem;
    color: #666;
    margin: 0 0 0.25rem 0;
  }
  
  .organization-created {
    font-size: 0.75rem;
    color: #888;
    margin: 0;
  }
  
  .card-action {
    color: #aaa;
    transition: color 0.2s ease;
  }
  
  .organization-card:hover .card-action {
    color: var(--primary-color);
  }
  
  @media (max-width: 640px) {
    .organization-card {
      padding: 1rem;
    }
    
    .organization-avatar {
      width: 40px;
      height: 40px;
    }
    
    .avatar-letters {
      font-size: 1rem;
    }
    
    .organization-name {
      font-size: 1rem;
    }
  }
</style>