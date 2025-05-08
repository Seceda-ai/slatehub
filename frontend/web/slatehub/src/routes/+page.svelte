<script>
    import { authState, connect } from "$lib/db/surreal";
    import { onMount } from "svelte";
    import { goto } from "$app/navigation";

    let welcomeMessage = "AI-Powered Production Management";
    let showDebugInfo = false;

    onMount(async () => {
        // Try to connect to the database on page load
        await connect();

        // Only show debug info in development mode
        showDebugInfo =
            import.meta.env.DEV || import.meta.env.MODE === "development";
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

        {#if !$authState.isAuthenticated}
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
                    <a href="/projects" class="btn btn-primary">My Projects</a>
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
