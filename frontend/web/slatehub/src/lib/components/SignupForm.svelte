<script lang="ts">
  import { onMount } from 'svelte';
  import { connect, signup, errorMessage, connectionState, ConnectionState } from '$lib/db/surreal';
  import '$lib/styles/forms.css';
  
  // Form data
  let username = '';
  let email = '';
  let password = '';
  let confirmPassword = '';
  
  // Form state
  let isSubmitting = false;
  let success = false;
  let formError = '';
  
  // Validation
  let usernameValid = true;
  let emailValid = true;
  let passwordValid = true;
  let passwordsMatch = true;
  
  // Connect to SurrealDB when component mounts
  onMount(async () => {
    const dbUrl = import.meta.env.VITE_SURREAL_URL || 'http://localhost:8000';
    await connect(dbUrl);
  });
  
  // Validate form
  function validateForm() {
    // Reset validation
    usernameValid = true;
    emailValid = true;
    passwordValid = true;
    passwordsMatch = true;
    formError = '';
    
    // Username validation (3+ chars, alphanumeric with - and _)
    if (!username || username.length < 3 || !/^[a-z0-9_-]+$/.test(username)) {
      usernameValid = false;
      formError = 'Username must be at least 3 characters and contain only letters, numbers, hyphens, and underscores';
      return false;
    }
    
    // Email validation
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      emailValid = false;
      formError = 'Please enter a valid email address';
      return false;
    }
    
    // Password validation (8+ chars)
    if (!password || password.length < 8) {
      passwordValid = false;
      formError = 'Password must be at least 8 characters';
      return false;
    }
    
    // Confirm password validation
    if (password !== confirmPassword) {
      passwordsMatch = false;
      formError = 'Passwords do not match';
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
      if ($connectionState !== ConnectionState.CONNECTED) {
        const dbUrl = import.meta.env.VITE_SURREAL_URL || 'http://localhost:8000';
        await connect(dbUrl);
      }
      
      // Attempt signup
      await signup(username, email, password);
      
      // Success! Clear form
      success = true;
      username = '';
      email = '';
      password = '';
      confirmPassword = '';
      formError = '';
    } catch (err) {
      // Use error from store if available, otherwise use error message
      formError = $errorMessage || 'Failed to sign up. Please try again.';
      success = false;
    } finally {
      isSubmitting = false;
    }
  }
</script>

<div class="form-container">
  <h2 class="form-title">Create an Account</h2>
  
  {#if success}
    <div class="form-message success">
      Account created successfully! You are now signed in.
    </div>
  {/if}
  
  {#if formError}
    <div class="form-message error">
      {formError}
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
        <div class="form-error">Username must be at least 3 characters (letters, numbers, -, _)</div>
      {/if}
    </div>
    
    <div class="form-group">
      <label for="email" class="form-label">Email</label>
      <input 
        type="email" 
        id="email" 
        bind:value={email} 
        class="form-input" 
        class:error={!emailValid}
        disabled={isSubmitting}
        autocomplete="email"
        required
      />
      {#if !emailValid}
        <div class="form-error">Please enter a valid email address</div>
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
        autocomplete="new-password"
        required
      />
      {#if !passwordValid}
        <div class="form-error">Password must be at least 8 characters</div>
      {/if}
    </div>
    
    <div class="form-group">
      <label for="confirmPassword" class="form-label">Confirm Password</label>
      <input 
        type="password" 
        id="confirmPassword" 
        bind:value={confirmPassword} 
        class="form-input" 
        class:error={!passwordsMatch}
        disabled={isSubmitting}
        autocomplete="new-password"
        required
      />
      {#if !passwordsMatch}
        <div class="form-error">Passwords do not match</div>
      {/if}
    </div>
    
    <button 
      type="submit" 
      class="form-button" 
      disabled={isSubmitting}
    >
      {isSubmitting ? 'Creating Account...' : 'Sign Up'}
    </button>
  </form>
  
  <a href="/login" class="form-link">Already have an account? Sign in</a>
</div>