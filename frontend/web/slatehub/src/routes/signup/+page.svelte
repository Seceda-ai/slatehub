<script>
    import SignupForm from '$lib/components/SignupForm.svelte';
    import AuthGuard from '$lib/components/AuthGuard.svelte';
</script>

<svelte:head>
    <title>Sign Up | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={false} redirectTo="/">
    <div class="signup-page">
        <div class="container">
            <div class="header">
                <h1>Welcome to Slatehub</h1>
                <p>Create your account to get started</p>
            </div>
            <SignupForm />
        </div>
    </div>
</AuthGuard>

<style>
    .signup-page {
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        background-color: #f5f5f5;
        padding: 2rem 1rem;
    }
    
    .container {
        width: 100%;
        max-width: 600px;
    }
    
    .header {
        text-align: center;
        margin-bottom: 2rem;
    }
    
    h1 {
        font-size: 2rem;
        color: #333;
        margin-bottom: 0.5rem;
    }
    
    p {
        color: #666;
    }
</style>