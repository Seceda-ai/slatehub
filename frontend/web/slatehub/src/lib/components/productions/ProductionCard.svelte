<script lang="ts">
  import { goto } from '$app/navigation';
  import type { Production } from '$lib/db/productions';
  
  export let production: Production;
  
  // Format date for display
  function formatDate(dateString: string | undefined): string {
    if (!dateString) return 'N/A';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  }
  
  // Handle card click to navigate to production detail
  function handleClick() {
    if (production && (production.slug || production.id)) {
      const path = production.slug ? `/productions/${production.slug}` : `/productions/${production.id}`;
      goto(path);
    }
  }
</script>

<div class="production-card" on:click={handleClick} on:keydown={(e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    e.preventDefault();
    handleClick();
  }
}} tabindex="0" role="button">
  <div class="production-info">
    <h3 class="production-name">{production.title}</h3>
    <div class="production-meta">
      <span class="production-date">Created: {formatDate(production.created_at)}</span>
    </div>
  </div>
  <div class="card-action">
    <span class="view-production">View Production</span>
    <span class="arrow">→</span>
  </div>
</div>

<style>
  .production-card {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.25rem;
    background-color: white;
    border-radius: var(--border-radius-md);
    box-shadow: var(--shadow-sm);
    transition: transform 0.2s, box-shadow 0.2s;
    cursor: pointer;
    margin-bottom: 1rem;
  }
  
  .production-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
  }
  
  .production-card:focus {
    outline: 2px solid var(--primary-color);
    outline-offset: 2px;
  }
  
  .production-info {
    flex: 1;
  }
  
  .production-name {
    margin: 0 0 0.5rem 0;
    color: var(--text-color);
    font-size: 1.25rem;
  }
  
  .production-meta {
    color: #666;
    font-size: 0.875rem;
  }
  
  .production-date {
    display: inline-block;
  }
  
  .card-action {
    display: flex;
    align-items: center;
    color: var(--primary-color);
    font-weight: 500;
  }
  
  .view-production {
    margin-right: 0.5rem;
  }
  
  .arrow {
    transition: transform 0.2s;
  }
  
  .production-card:hover .arrow {
    transform: translateX(4px);
  }
  
  @media (max-width: 640px) {
    .production-card {
      flex-direction: column;
      align-items: flex-start;
    }
    
    .card-action {
      margin-top: 1rem;
      align-self: flex-end;
    }
  }
</style>