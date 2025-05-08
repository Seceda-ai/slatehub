<script>
    import { onMount } from 'svelte';
    import { connect, authState } from '$lib/db/surreal';
    import Navbar from '$lib/components/Navbar.svelte';
    import '../app.css';
    
    // Connect to SurrealDB when layout mounts
    onMount(async () => {
        const dbUrl = import.meta.env.VITE_SURREAL_URL || 'http://localhost:8000';
        await connect(dbUrl);
    });
</script>

<svelte:head>
    <title>Slatehub - Film & TV Production Management</title>
</svelte:head>

<div class="app">
    <Navbar />
    
    <main class="main-content">
        <div class="container">
            <slot />
        </div>
    </main>
    
    <footer class="footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-copyright">
                    &copy; {new Date().getFullYear()} Seceda Studios. All rights reserved.
                </div>
                <div class="footer-links">
                    <a href="/about">About</a>
                    <a href="/privacy">Privacy</a>
                    <a href="/terms">Terms</a>
                </div>
            </div>
        </div>
    </footer>
</div>

<style>
    .app {
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }
    
    .main-content {
        flex: 1;
    }
    
    .footer {
        background-color: #f1f1f1;
        padding: 1.5rem 0;
        margin-top: 3rem;
    }
    
    .footer-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .footer-copyright {
        color: #666;
        font-size: 0.9rem;
    }
    
    .footer-links {
        display: flex;
        gap: 1.5rem;
    }
    
    .footer-links a {
        color: #666;
        font-size: 0.9rem;
    }
    
    @media (max-width: 768px) {
        .footer-content {
            flex-direction: column;
            gap: 1rem;
            text-align: center;
        }
    }
</style>