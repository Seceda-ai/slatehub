<script>
  import { authState, signout } from '$lib/db/surreal';
  import { goto } from '$app/navigation';

  async function handleSignout() {
    try {
      await signout();
      goto('/login');
    } catch (error) {
      console.error('Error signing out:', error);
    }
  }
</script>

<nav class="navbar">
  <div class="container navbar-container">
    <div class="navbar-brand">
      <a href="/" class="logo">Slatehub</a>
    </div>
    
    <div class="navbar-menu">
      {#if $authState.isAuthenticated}
        <a href="/projects" class="navbar-item">Projects</a>
        <a href="/organizations" class="navbar-item">Organizations</a>
        <div class="navbar-item dropdown">
          <button class="dropdown-trigger">
            {$authState.user?.username || 'Account'}
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
          </button>
          <div class="dropdown-menu">
            <a href="/profile" class="dropdown-item">Profile</a>
            <a href="/settings" class="dropdown-item">Settings</a>
            <hr class="dropdown-divider" />
            <button on:click={handleSignout} class="dropdown-item">Sign Out</button>
          </div>
        </div>
      {:else}
        <a href="/login" class="navbar-item">Sign In</a>
        <a href="/signup" class="navbar-item-highlight">Sign Up</a>
      {/if}
    </div>
  </div>
</nav>

<style>
  .navbar {
    background-color: white;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    padding: 0.8rem 0;
    position: sticky;
    top: 0;
    z-index: 100;
  }
  
  .navbar-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .navbar-brand {
    font-size: 1.5rem;
    font-weight: bold;
  }
  
  .logo {
    color: var(--primary-color);
    text-decoration: none;
  }
  
  .navbar-menu {
    display: flex;
    align-items: center;
    gap: 1.5rem;
  }
  
  .navbar-item {
    color: var(--text-color);
    text-decoration: none;
    font-weight: 500;
    padding: 0.5rem 0;
    position: relative;
  }
  
  .navbar-item:hover {
    color: var(--primary-color);
    text-decoration: none;
  }
  
  .navbar-item:hover::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    height: 2px;
    background-color: var(--primary-color);
    transform: scaleX(1);
    transition: transform 0.3s ease;
  }
  
  .navbar-item-highlight {
    background-color: var(--primary-color);
    color: white;
    padding: 0.5rem 1rem;
    border-radius: 4px;
    font-weight: 500;
    text-decoration: none;
    transition: background-color 0.2s ease;
  }
  
  .navbar-item-highlight:hover {
    background-color: var(--primary-hover);
    text-decoration: none;
  }
  
  /* Dropdown styling */
  .dropdown {
    position: relative;
  }
  
  .dropdown-trigger {
    background: none;
    border: none;
    cursor: pointer;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 0.3rem;
    color: var(--text-color);
    padding: 0.5rem;
  }
  
  .dropdown-trigger:hover {
    color: var(--primary-color);
  }
  
  .dropdown-menu {
    position: absolute;
    top: 100%;
    right: 0;
    background-color: white;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    border-radius: 4px;
    min-width: 180px;
    padding: 0.5rem 0;
    display: none;
    z-index: 110;
  }
  
  .dropdown:hover .dropdown-menu {
    display: block;
  }
  
  .dropdown-item {
    display: block;
    padding: 0.5rem 1rem;
    text-decoration: none;
    color: var(--text-color);
    background: none;
    border: none;
    text-align: left;
    width: 100%;
    cursor: pointer;
    font-size: 0.95rem;
  }
  
  .dropdown-item:hover {
    background-color: rgba(0, 0, 0, 0.05);
    color: var(--primary-color);
    text-decoration: none;
  }
  
  .dropdown-divider {
    border: none;
    border-top: 1px solid var(--light-gray);
    margin: 0.5rem 0;
  }
  
  @media (max-width: 768px) {
    .navbar-menu {
      gap: 1rem;
    }
  }
</style>