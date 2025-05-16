<script lang="ts">
  // Define props
  export let user: {
    username?: string;
    email?: string;
    profileImages?: any[];
    activeImageId?: string;
    [key: string]: any;
  } = {};
  export let size: 'xs' | 'sm' | 'md' | 'lg' = 'md';
  export let customClass: string = '';

  // Get active image if available
  $: activeImage = user.profileImages?.find(
    (img) => img?.id === user.activeImageId
  );
  
  // Get user initials for fallback
  $: initials = getUserInitials(user.username || '');
  
  // Helper function to get user's initials
  function getUserInitials(username: string): string {
    if (!username) return '?';
    
    // For usernames like "john_doe" or "john.doe", split and get initials
    const parts = username.split(/[_.-]/);
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    
    // For simple usernames, use the first two characters or just first if too short
    return username.length > 1 
      ? username.substring(0, 2).toUpperCase() 
      : (username[0]?.toUpperCase() || '?');
  }
  
  // Determine CSS classes based on size
  $: sizeClass = {
    'xs': 'avatar-xs',
    'sm': 'avatar-sm',
    'md': 'avatar-md',
    'lg': 'avatar-lg'
  }[size] || 'avatar-md';
</script>

<div class="avatar {sizeClass} {customClass}">
  {#if activeImage && activeImage.data}
    <img src={activeImage.data} alt="{user.username || 'User'}'s avatar" />
  {:else}
    <div class="avatar-initials">
      {initials}
    </div>
  {/if}
</div>

<style>
  .avatar {
    border-radius: 50%;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--primary-color);
    color: white;
  }
  
  .avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  
  .avatar-initials {
    font-weight: 600;
    letter-spacing: 0.05em;
    text-transform: uppercase;
  }
  
  .avatar-xs {
    width: 24px;
    height: 24px;
    font-size: 0.7rem;
  }
  
  .avatar-sm {
    width: 32px;
    height: 32px;
    font-size: 0.85rem;
  }
  
  .avatar-md {
    width: 48px;
    height: 48px;
    font-size: 1.1rem;
  }
  
  .avatar-lg {
    width: 64px;
    height: 64px;
    font-size: 1.5rem;
  }
</style>