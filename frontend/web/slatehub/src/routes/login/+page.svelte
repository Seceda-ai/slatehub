<script>
    import SigninForm from '$lib/components/SigninForm.svelte';
    import AuthGuard from '$lib/components/AuthGuard.svelte';
</script>

<svelte:head>
    <title>Sign In | Slatehub</title>
</svelte:head>

<AuthGuard requireAuth={false} redirectTo="/">
    <div class="signin-page">
        <div class="container">
            <div class="header">
                <h1>Welcome Back</h1>
                <p>Sign in to your Slatehub account</p>
            </div>
            <SigninForm />
        </div>
    </div>
</AuthGuard>

<style>
    .signin-page {
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