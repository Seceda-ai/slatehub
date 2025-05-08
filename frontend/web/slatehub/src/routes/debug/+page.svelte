<script>
    import { onMount } from 'svelte';
    import { connect, signin, signup, signout, query, errorDetails, errorMessage, connectionState, ConnectionState, authState, db, getConnectionState } from '$lib/db/surreal';
    import SurrealDebug from '$lib/components/SurrealDebug.svelte';

    let username = '';
    let password = '';
    let email = '';
    let queryText = 'SELECT * FROM person LIMIT 5';
    let queryVars = '{}';
    let queryResult = '';
    let operationStatus = '';
    let operationTime = 0;

    // Connection management
    async function handleConnect() {
        startOperation('Connecting to database...');
        try {
            await connect();
            completeOperation('Successfully connected to database');
        } catch (error) {
            failOperation(`Connection failed: ${error.message}`);
        }
    }

    // Auth operations
    async function handleSignin() {
        if (!username || !password) {
            setStatus('Please enter username and password');
            return;
        }

        startOperation('Signing in...');
        try {
            // Sign in with the correct parameters
            const result = await signin(username, password);
            completeOperation('Sign in successful', result);
        } catch (error) {
            failOperation(`Sign in failed: ${error.message}`);
        }
    }

    async function handleSignup() {
        if (!username || !password || !email) {
            setStatus('Please enter username, password and email');
            return;
        }

        startOperation('Signing up...');
        try {
            // Sign up with the correct parameters
            const result = await signup(username, email, password);
            completeOperation('Sign up successful', result);
        } catch (error) {
            failOperation(`Sign up failed: ${error.message}`);
        }
    }

    async function handleSignout() {
        startOperation('Signing out...');
        try {
            await signout();
            completeOperation('Sign out successful');
        } catch (error) {
            failOperation(`Sign out failed: ${error.message}`);
        }
    }

    // Query execution
    async function executeQuery() {
        startOperation('Executing query...');
        try {
            const vars = JSON.parse(queryVars);
            const result = await query(queryText, vars);
            completeOperation('Query executed successfully', result);
            queryResult = JSON.stringify(result, null, 2);
        } catch (error) {
            failOperation(`Query failed: ${error.message}`);
            queryResult = error.message;
        }
    }

    // Helper functions
    function startOperation(message) {
        operationStatus = message;
        operationTime = Date.now();
    }

    function completeOperation(message, data = null) {
        const elapsed = Date.now() - operationTime;
        operationStatus = `${message} (${elapsed}ms)`;
        if (data) {
            console.log('Operation result:', data);
        }
    }

    function failOperation(message) {
        const elapsed = Date.now() - operationTime;
        operationStatus = `${message} (${elapsed}ms)`;
    }

    function setStatus(message) {
        operationStatus = message;
    }

    // Connect on mount
    onMount(() => {
        handleConnect();
    });
</script>

<svelte:head>
    <title>SurrealDB Debug | Slatehub</title>
</svelte:head>

<div class="debug-page">
    <h1>SurrealDB Debug Console</h1>
    <p class="status-message" class:error={operationStatus.includes('failed')}>
        Status: {operationStatus || 'Ready'}
    </p>

    <div class="debug-sections">
        <div class="debug-section">
            <h2>Connection State</h2>
            <div class="status-display">
                <div class="status-indicator" class:connected={$connectionState === ConnectionState.CONNECTED} 
                    class:error={$connectionState === ConnectionState.ERROR}
                    class:connecting={$connectionState === ConnectionState.CONNECTING}
                    class:disconnected={$connectionState === ConnectionState.DISCONNECTED}>
                </div>
                <span>{ConnectionState[$connectionState]}</span>
            </div>
            <button on:click={handleConnect}>Reconnect</button>
        </div>

        <div class="debug-section">
            <h2>Authentication</h2>
            <div class="auth-status">
                {#if $authState.isAuthenticated}
                    <div class="status-display">
                        <div class="status-indicator connected"></div>
                        <span>Authenticated as {$authState.user?.username}</span>
                    </div>
                    <button on:click={handleSignout}>Sign Out</button>
                {:else}
                    <div class="status-display">
                        <div class="status-indicator disconnected"></div>
                        <span>Not authenticated</span>
                    </div>
                    <div class="auth-form">
                        <div class="form-row">
                            <label for="username">Username:</label>
                            <input type="text" id="username" bind:value={username} />
                        </div>
                        <div class="form-row">
                            <label for="password">Password:</label>
                            <input type="password" id="password" bind:value={password} />
                        </div>
                        <div class="form-row">
                            <label for="email">Email (for signup):</label>
                            <input type="email" id="email" bind:value={email} />
                        </div>
                        <div class="button-row">
                            <button on:click={handleSignin}>Sign In</button>
                            <button on:click={handleSignup}>Sign Up</button>
                        </div>
                    </div>
                {/if}
            </div>
        </div>

        <div class="debug-section">
            <h2>Execute Query</h2>
            <div class="query-form">
                <div class="form-row">
                    <label for="query">Query:</label>
                    <textarea id="query" bind:value={queryText} rows="3"></textarea>
                </div>
                <div class="form-row">
                    <label for="vars">Variables (JSON):</label>
                    <textarea id="vars" bind:value={queryVars} rows="2"></textarea>
                </div>
                <button on:click={executeQuery}>Execute</button>
            </div>
            <div class="query-result">
                <h3>Result</h3>
                <pre>{queryResult}</pre>
            </div>
        </div>

        <div class="debug-section">
            <h2>Error Information</h2>
            {#if $errorMessage}
                <div class="error-display">
                    <h3>Error Message</h3>
                    <pre>{$errorMessage}</pre>
                    
                    {#if $errorDetails.details}
                        <h3>Details</h3>
                        <pre>{$errorDetails.details}</pre>
                    {/if}
                    
                    {#if $errorDetails.code}
                        <h3>Code</h3>
                        <pre>{$errorDetails.code}</pre>
                    {/if}
                    
                    {#if $errorDetails.raw}
                        <h3>Raw Error Data</h3>
                        <pre>{JSON.stringify($errorDetails.raw, null, 2)}</pre>
                    {/if}
                </div>
            {:else}
                <p>No errors to display</p>
            {/if}
        </div>
    </div>

    <SurrealDebug expanded={true} />
</div>

<style>
    .debug-page {
        max-width: 1200px;
        margin: 0 auto;
        padding: 2rem 1rem;
    }

    h1 {
        color: #333;
        margin-bottom: 1rem;
        text-align: center;
    }

    h2 {
        font-size: 1.2rem;
        margin: 0 0 1rem 0;
        border-bottom: 1px solid #eee;
        padding-bottom: 0.5rem;
    }
    
    h3 {
        font-size: 1rem;
        margin: 1rem 0 0.5rem 0;
    }

    .status-message {
        text-align: center;
        padding: 0.5rem;
        background-color: #f0f0f0;
        border-radius: 4px;
        margin-bottom: 2rem;
        font-weight: 500;
    }

    .status-message.error {
        background-color: rgba(220, 53, 69, 0.1);
        color: #dc3545;
    }

    .debug-sections {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
        gap: 2rem;
    }

    .debug-section {
        background-color: white;
        border-radius: 8px;
        padding: 1.5rem;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .status-display {
        display: flex;
        align-items: center;
        margin-bottom: 1rem;
    }

    .status-indicator {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-right: 8px;
    }

    .connected {
        background-color: #28a745;
    }

    .disconnected {
        background-color: #6c757d;
    }

    .connecting {
        background-color: #ffc107;
    }

    .error {
        background-color: #dc3545;
    }

    button {
        background-color: #0066cc;
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 0.9rem;
    }

    button:hover {
        background-color: #0055aa;
    }

    .form-row {
        margin-bottom: 1rem;
    }

    label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
    }

    input, textarea {
        width: 100%;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-family: inherit;
        font-size: 0.9rem;
    }

    textarea {
        font-family: monospace;
        resize: vertical;
    }

    .button-row {
        display: flex;
        gap: 1rem;
        margin-top: 1rem;
    }

    pre {
        background-color: #f8f9fa;
        padding: 1rem;
        border-radius: 4px;
        overflow: auto;
        font-size: 0.9rem;
        margin: 0;
    }

    .query-result {
        margin-top: 1.5rem;
    }

    .error-display {
        margin-top: 1rem;
    }

    @media (max-width: 768px) {
        .debug-sections {
            grid-template-columns: 1fr;
        }
    }
</style>