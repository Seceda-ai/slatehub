<script>
    import { authState, connect, getConnectionState, ConnectionState } from "$lib/db/surreal";
    import { onMount, onDestroy } from "svelte";
    import { goto } from "$app/navigation";

    let welcomeMessage = "AI-Powered Production Management";
    let showDebugInfo = false;
    let connectionError = false;
    let isLoading = true;

    // Create auth state subscription
    const unsubscribe = authState.subscribe(state => {
        // Auth state changes will trigger reactivity
    });

    onMount(async () => {
        try {
            // Try to connect to the database on page load
            const connected = await connect();
            connectionError = !connected;
            
            if (!connected) {
                console.error("Failed to connect to SurrealDB");
            }
        } catch (error) {
            console.error("Connection error:", error);
            connectionError = true;
        } finally {
            isLoading = false;
        }

        // Only show debug info in development mode
        showDebugInfo =
            import.meta.env.DEV || import.meta.env.MODE === "development";
    });
    
    onDestroy(() => {
        // Clean up subscription
        unsubscribe();
    });
</script>

<div class="home">
    {#if showDebugInfo}
        <div class="debug-notice">
            <p>
                <strong>Developer Mode:</strong> Having authentication issues?
                Visit the
                <a href="/debug">Debug Console</a> to troubleshoot SurrealDB connections.
            </p>
        </div>
    {/if}
    <div class="hero">
        <h1>{welcomeMessage}</h1>
        <p class="subtitle">
            Free, open-source production management for film, TV, documentary,
            commercial, and social video creators
        </p>
        <div class="ai-badge">
            <span class="ai-icon">🤖</span> AI-Enhanced Workflow
        </div>

        {#if isLoading}
            <div class="loading-state">
                <div class="loading-spinner"></div>
                <p>Connecting to services...</p>
            </div>
        {:else if connectionError}
            <div class="connection-error">
                <p>Unable to connect to the SurrealDB server. Please check your server configuration and ensure SurrealDB is running.</p>
                <p class="connection-help">If you're developing locally, make sure SurrealDB is running on {import.meta.env.VITE_SURREAL_URL || "http://localhost:8000"}</p>
                <div class="connection-actions">
                    <button class="btn btn-primary" on:click={() => window.location.reload()}>Retry</button>
                    <a href="/debug" class="btn btn-outline">Debug Connection</a>
                </div>
            </div>
        {:else if !$authState.isAuthenticated}
            <div class="value-prop">
                <p>
                    Streamline your entire production process with intelligent
                    planning, team collaboration, and resource management
                    &mdash; all completely <strong>free</strong>.
                </p>
            </div>
            <div class="cta-buttons">
                <a href="/signup" class="btn btn-primary">Get Started Free</a>
                <a href="/login" class="btn btn-outline">Sign In</a>
                <a
                    href="https://github.com/seceda/slatehub"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="btn btn-outline secondary">View on GitHub</a
                >
            </div>
        {:else}
            <div class="welcome-back">
                <h2>Welcome back, {$authState.user?.username || "User"}!</h2>
                <div class="cta-buttons">
                    <a href="/productions" class="btn btn-primary">My Productions</a>
                    <a href="/organizations" class="btn btn-outline"
                        >My Organizations</a
                    >
                    <a href="/profile" class="btn btn-outline">My Profile</a>
                </div>
            </div>
        {/if}
    </div>

    <div class="features">
        <div class="feature-card">
            <div class="feature-icon">🤖</div>
            <h3>AI Project Planning</h3>
            <p>
                Intelligent scheduling, budgeting, and resource allocation
                powered by AI
            </p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">👥</div>
            <h3>Team Collaboration</h3>
            <p>Invite team members, assign roles, and collaborate seamlessly</p>
        </div>
        <div class="feature-card">
            <div class="feature-icon">🎬</div>
            <h3>Production Workflow</h3>
            <p>
                Manage your entire project from development through
                post-production
            </p>
        </div>
    </div>

    <div class="about-section">
        <h2>Built by Filmmakers, Enhanced by AI</h2>
        <p>
            Slatehub combines industry expertise with cutting-edge AI to solve
            real-world production challenges. From script breakdown to final
            delivery, our platform helps you stay organized, on budget, and on
            schedule.
        </p>
        <div class="cta-secondary">
            <a href="/signup" class="btn btn-primary">Start Your Free Project</a
            >
        </div>
        <p class="small-text">
            Visit <a
                href="https://secedastudios.com"
                target="_blank"
                rel="noopener noreferrer">Seceda Studios</a
            >
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
        margin-bottom: 1rem;
    }

    .ai-badge {
        display: inline-block;
        background-color: rgba(0, 102, 204, 0.1);
        color: var(--primary-color);
        padding: 0.5rem 1rem;
        border-radius: 20px;
        font-weight: 600;
        margin-bottom: 1.5rem;
    }

    .ai-icon {
        margin-right: 0.5rem;
    }

    .value-prop {
        max-width: 600px;
        margin: 0 auto 1rem;
        font-size: 1.1rem;
        line-height: 1.6;
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

    .cta-secondary {
        margin: 1.5rem 0;
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
        transition:
            transform 0.3s ease,
            box-shadow 0.3s ease;
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

    .small-text {
        font-size: 0.9rem;
        color: #666;
        margin-top: 2rem;
    }
    
    .loading-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        margin: 2rem 0;
    }
    
    .loading-spinner {
        display: inline-block;
        width: 3rem;
        height: 3rem;
        border: 0.25rem solid rgba(0, 102, 204, 0.1);
        border-radius: 50%;
        border-top-color: var(--primary-color);
        animation: spin 1s ease-in-out infinite;
        margin-bottom: 1rem;
    }
    
    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
    
    .connection-error {
        background-color: #f8d7da;
        color: #721c24;
        padding: 1.5rem;
        text-align: center;
        border-radius: var(--border-radius-md);
        margin: 1rem 0;
        border: 1px solid rgba(220, 53, 69, 0.3);
    }
    
    .connection-help {
        font-size: 0.9rem;
        margin: 0.75rem 0;
        color: #666;
    }
    
    .connection-actions {
        display: flex;
        gap: 1rem;
        justify-content: center;
        margin-top: 1rem;
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
