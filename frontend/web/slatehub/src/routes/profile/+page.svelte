<script>
    import AuthGuard from '$lib/components/AuthGuard.svelte';
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

<svelte:head>
    <title>My Profile | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={true}>
    <div class="profile-page">
        <div class="profile-header">
            <h1>My Profile</h1>
            <p class="subtitle">Manage your account information</p>
        </div>
        
        <div class="profile-card">
            <div class="avatar-section">
                <div class="avatar">
                    {#if $authState.user?.username}
                        <span class="initials">{$authState.user.username.charAt(0).toUpperCase()}</span>
                    {:else}
                        <span class="initials">U</span>
                    {/if}
                </div>
            </div>
            
            <div class="profile-details">
                <div class="profile-field">
                    <span class="field-label">Username</span>
                    <span class="field-value">{$authState.user?.username || 'Not available'}</span>
                </div>
                
                <div class="profile-field">
                    <span class="field-label">Email</span>
                    <span class="field-value">{$authState.user?.email || 'Not available'}</span>
                </div>
                
                <div class="profile-actions">
                    <button class="btn btn-outline">Edit Profile</button>
                    <button class="btn btn-outline danger" on:click={handleSignout}>Sign Out</button>
                </div>
            </div>
        </div>
    </div>
</AuthGuard>

<style>
    .profile-page {
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem 1rem;
    }
    
    .profile-header {
        text-align: center;
        margin-bottom: 2rem;
    }
    
    .profile-header h1 {
        color: var(--primary-color);
        margin-bottom: 0.5rem;
    }
    
    .subtitle {
        color: #666;
    }
    
    .profile-card {
        background-color: white;
        border-radius: var(--border-radius-md);
        padding: 2rem;
        box-shadow: var(--shadow-sm);
        display: flex;
        align-items: flex-start;
        gap: 2rem;
    }
    
    .avatar-section {
        flex-shrink: 0;
    }
    
    .avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background-color: var(--primary-color);
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 2.5rem;
        font-weight: bold;
    }
    
    .profile-details {
        flex-grow: 1;
    }
    
    .profile-field {
        margin-bottom: 1.5rem;
    }
    
    .field-label {
        display: block;
        font-size: 0.9rem;
        color: #666;
        margin-bottom: 0.25rem;
    }
    
    .field-value {
        display: block;
        font-size: 1.1rem;
        font-weight: 500;
    }
    
    .profile-actions {
        display: flex;
        gap: 1rem;
        margin-top: 2rem;
    }
    
    .danger {
        color: var(--danger-color);
        border-color: var(--danger-color);
    }
    
    .danger:hover {
        background-color: var(--danger-color);
        color: white;
    }
    
    @media (max-width: 600px) {
        .profile-card {
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        .profile-actions {
            justify-content: center;
        }
    }
</style>