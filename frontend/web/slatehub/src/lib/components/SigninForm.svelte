<script lang="ts">
  import { onMount } from 'svelte';
  import { connect, signin, errorMessage, errorDetails, connectionState, ConnectionState, getConnectionState } from '$lib/db/surreal';
  import '$lib/styles/forms.css';
  
  // Form data
  let username = '';
  let password = '';
  
  // Form state
  let isSubmitting = false;
  let success = false;
  let formError = '';
  
  // Validation
  let usernameValid = true;
  let passwordValid = true;
  
  // Connect to SurrealDB when component mounts
  onMount(async () => {
    await connect();
  });
  
  // Validate form
  function validateForm() {
    // Reset validation
    usernameValid = true;
    passwordValid = true;
    formError = '';
    
    // Username validation
    if (!username || username.trim() === '') {
      usernameValid = false;
      formError = 'Please enter your username';
      return false;
    }
    
    // Password validation
    if (!password) {
      passwordValid = false;
      formError = 'Please enter your password';
      return false;
    }
    
    return true;
  }
  
  // Handle form submission
  async function handleSubmit() {
    if (!validateForm()) return;
    
    try {
      isSubmitting = true;
      
      // Check if connected
      if (getConnectionState() !== ConnectionState.CONNECTED) {
        await connect();
      }
      
      // Attempt signin
      await signin(username, password);
      
      // Success!
      success = true;
      formError = '';
    } catch (err) {
      // Use error from store if available, otherwise use error message
      formError = $errorMessage || 'Invalid username or password';
      success = false;
    } finally {
      isSubmitting = false;
    }
  }
</script>

<div class="form-container">
  <h2 class="form-title">Sign In</h2>
  
  {#if success}
    <div class="form-message success">
      You are now signed in!
    </div>
  {/if}
  
  {#if formError}
    <div class="form-message error">
      <p class="error-title">{formError}</p>
      {#if $errorDetails.details}
        <div class="error-details">
          <p>{$errorDetails.details}</p>
          {#if $errorDetails.code}
            <p class="error-code">Error code: {$errorDetails.code}</p>
          {/if}
        </div>
      {/if}
    </div>
  {/if}
  
  <form on:submit|preventDefault={handleSubmit}>
    <div class="form-group">
      <label for="username" class="form-label">Username</label>
      <input 
        type="text" 
        id="username" 
        bind:value={username} 
        class="form-input" 
        class:error={!usernameValid}
        disabled={isSubmitting}
        autocomplete="username"
        required
      />
      {#if !usernameValid}
        <div class="form-error">Please enter your username</div>
      {/if}
    </div>
    
    <div class="form-group">
      <label for="password" class="form-label">Password</label>
      <input 
        type="password" 
        id="password" 
        bind:value={password} 
        class="form-input" 
        class:error={!passwordValid}
        disabled={isSubmitting}
        autocomplete="current-password"
        required
      />
      {#if !passwordValid}
        <div class="form-error">Please enter your password</div>
      {/if}
    </div>
    
    <button 
      type="submit" 
      class="form-button" 
      disabled={isSubmitting}
    >
      {isSubmitting ? 'Signing in...' : 'Sign In'}
    </button>
  </form>
  
  <a href="/signup" class="form-link">Don't have an account? Sign up</a>
</div>