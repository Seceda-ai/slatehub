<script>
    import { authState, connect } from '$lib/db/surreal';
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';

    let welcomeMessage = "Welcome to Slatehub";
    let showDebugInfo = false;
    
    onMount(async () => {
        // Try to connect to the database on page load
        const dbUrl = import.meta.env.VITE_SURREAL_URL || 'http://localhost:8000';
        await connect(dbUrl);
        
        // Only show debug info in development mode
        showDebugInfo = import.meta.env.DEV || import.meta.env.MODE === 'development';
    });
</script>

<div class="home">
    {#if showDebugInfo}
        <div class="debug-notice">
            <p>
                <strong>Developer Mode:</strong> Having authentication issues? Visit the 
                <a href="/debug">Debug Console</a> to troubleshoot SurrealDB connections.
            </p>
        </div>
    {/if}
    <div class="hero">
        <h1>{welcomeMessage}</h1>
        <p class="subtitle">
            An open-source film, TV, commercial, and social video production management tool
        </p>

        {#if !$authState.isAuthenticated}
            <div class="cta-buttons">
                <a href="/signup" class="btn btn-primary">Get Started</a>
                <a href="/login" class="btn btn-outline">Sign In</a>
                <a href="https://github.com/seceda/slatehub" target="_blank" rel="noopener noreferrer" class="btn btn-outline secondary">View on GitHub</a>
            </div>
        {:else}
            <div class="welcome-back">
                <h2>Welcome back, {$authState.user?.username || 'User'}!</h2>
                <div class="cta-buttons">
                    <a href="/projects" class="btn btn-primary">My Projects</a>
                    <a href="/organizations" class="btn btn-outline">My Organizations</a>
                    <a href="/profile" class="btn btn-outline">My Profile</a>
                </div>
            </div>
        {/if}
    </div>

    <div class="features">
        <div class="feature-card">
            <div class="feature-icon">📋</div>
            <h3>Project Management</h3>
            <p>Organize your productions with powerful, flexible project management tools</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">👥</div>
            <h3>Team Collaboration</h3>
            <p>Invite team members, assign roles, and collaborate seamlessly</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">🔒</div>
            <h3>Role-Based Access</h3>
            <p>Control who can view, edit, or manage your production data</p>
        </div>
    </div>

    <div class="about-section">
        <h2>Built by Filmmakers for Filmmakers</h2>
        <p>
            Slatehub is developed by active filmmakers using it every day to solve real-world production challenges.
            From pre-production planning to post-production management, Slatehub helps you stay organized 
            and on schedule.
        </p>
        <p>
            Visit <a href="https://secedastudios.com" target="_blank" rel="noopener noreferrer">Seceda Studios</a> 
            to learn more about our production company.
        </p>
    </div>
</div>

<style>
    .debug-notice {
        background-color: #f8f9fa;
        border: 1px solid #e9ecef;
        border-left: 4px solid #0066cc;
        border-radius: 4px;
        padding: 1rem;
        margin: 1rem 2rem;
        text-align: center;
    }
    
    .debug-notice a {
        font-weight: bold;
    }
    
    .home {
        padding: 2rem 0;
    }

    .hero {
        text-align: center;
        padding: 4rem 1rem;
        max-width: 800px;
        margin: 0 auto;
    }

    h1 {
        font-size: 3rem;
        margin-bottom: 1rem;
        color: var(--primary-color);
    }

    .subtitle {
        font-size: 1.25rem;
        color: #666;
        margin-bottom: 2rem;
    }

    .welcome-back {
        margin: 2rem 0;
    }

    .welcome-back h2 {
        margin-bottom: 1.5rem;
        color: var(--text-color);
    }

    .cta-buttons {
        display: flex;
        gap: 1rem;
        justify-content: center;
        margin: 2rem 0;
    }

    .features {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 2rem;
        margin: 4rem 0;
    }

    .feature-card {
        background-color: white;
        padding: 2rem;
        border-radius: var(--border-radius-md);
        box-shadow: var(--shadow-sm);
        text-align: center;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .feature-card:hover {
        transform: translateY(-5px);
        box-shadow: var(--shadow-md);
    }

    .feature-icon {
        font-size: 2.5rem;
        margin-bottom: 1rem;
    }

    .feature-card h3 {
        margin-bottom: 0.75rem;
        color: var(--primary-color);
    }

    .feature-card p {
        color: #666;
    }
    
    .secondary {
        color: #666;
        border-color: #666;
    }
    
    .secondary:hover {
        background-color: #666;
        color: white;
    }

    .about-section {
        background-color: white;
        padding: 3rem 2rem;
        border-radius: var(--border-radius-md);
        box-shadow: var(--shadow-sm);
        margin: 3rem 0;
        text-align: center;
        max-width: 900px;
        margin-left: auto;
        margin-right: auto;
    }

    .about-section h2 {
        color: var(--primary-color);
        margin-bottom: 1.5rem;
    }

    .about-section p {
        margin-bottom: 1rem;
        line-height: 1.7;
    }

    @media (max-width: 768px) {
        h1 {
            font-size: 2.25rem;
        }

        .features {
            grid-template-columns: 1fr;
        }

        .cta-buttons {
            flex-direction: column;
        }
    }
</style>