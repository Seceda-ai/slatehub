<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { createProduction, updateProduction, type Production } from '$lib/db/productions';
  
  export let production: Production | null = null;
  export let isSubmitting = false;
  
  // Form data
  let title = production?.title || '';
  
  // Form state
  let formError = '';
  let titleValid = true;
  
  // Event dispatcher for form events
  const dispatch = createEventDispatcher<{
    success: Production;
    error: string;
    cancel: void;
  }>();
  
  // Validate form
  function validateForm() {
    // Reset validation
    titleValid = true;
    formError = '';
    
    // Name validation
    if (!title || title.trim() === '') {
      titleValid = false;
      formError = 'Production title is required';
      return false;
    }
    
    return true;
  }
  
  // Handle form submission
  async function handleSubmit() {
    if (!validateForm()) return;
    
    try {
      isSubmitting = true;
      
      let result: Production;
      
      if (production?.id) {
        // Update existing production
        result = await updateProduction(production.id, { title });
      } else {
        // Create new production
        result = await createProduction(title);
      }
      
      // Success!
      formError = '';
      console.log('Production saved successfully:', result);
      dispatch('success', result);
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to save production';
      formError = errorMessage;
      console.error('Production save error:', err);
      dispatch('error', errorMessage);
    } finally {
      isSubmitting = false;
    }
  }
  
  // Cancel form
  function handleCancel() {
    dispatch('cancel');
  }
</script>

<div class="production-form">
  <h2 class="form-title">
    {production ? 'Edit Production' : 'Create New Production'}
  </h2>
  
  {#if formError}
    <div class="form-message error">
      <p>{formError}</p>
    </div>
  {/if}
  
  <form on:submit|preventDefault={handleSubmit}>
    <div class="form-group">
      <label for="title" class="form-label">Production Title</label>
      <input 
        type="text" 
        id="title" 
        bind:value={title} 
        class="form-input" 
        class:error={!titleValid}
        disabled={isSubmitting}
        placeholder="Enter production title"
        required
      />
      {#if !titleValid}
        <div class="form-error">Please enter a production title</div>
      {/if}
      <small class="form-help">
        This will be used to create a URL-friendly slug for your production
      </small>
    </div>
    
    <div class="form-actions">
      <button 
        type="button" 
        class="btn btn-secondary" 
        on:click={handleCancel}
        disabled={isSubmitting}
      >
        Cancel
      </button>
      
      <button 
        type="submit" 
        class="btn btn-primary" 
        disabled={isSubmitting}
      >
        {isSubmitting ? 
          (production ? 'Saving...' : 'Creating...') : 
          (production ? 'Save Changes' : 'Create Production')
        }
      </button>
    </div>
  </form>
</div>

<style>
  .production-form {
    max-width: 600px;
    margin: 0 auto;
    padding: 1.5rem;
    background-color: white;
    border-radius: var(--border-radius-md);
    box-shadow: var(--shadow-sm);
  }
  
  .form-title {
    margin-bottom: 1.5rem;
    color: var(--text-color);
    font-size: 1.5rem;
  }
  
  .form-message {
    margin-bottom: 1.5rem;
    padding: 1rem;
    border-radius: var(--border-radius-sm);
  }
  
  .form-message.error {
    background-color: rgba(220, 53, 69, 0.1);
    color: var(--danger-color);
    border: 1px solid rgba(220, 53, 69, 0.2);
  }
  
  .form-group {
    margin-bottom: 1.5rem;
  }
  
  .form-label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
  }
  
  .form-input {
    width: 100%;
    padding: 0.75rem;
    font-size: 1rem;
    border: 1px solid var(--border-color);
    border-radius: var(--border-radius-sm);
    transition: border-color 0.2s;
  }
  
  .form-input:focus {
    outline: none;
    border-color: var(--primary-color);
    box-shadow: 0 0 0 2px rgba(0, 102, 204, 0.2);
  }
  
  .form-input.error {
    border-color: var(--danger-color);
  }
  
  .form-error {
    color: var(--danger-color);
    font-size: 0.875rem;
    margin-top: 0.5rem;
  }
  
  .form-help {
    display: block;
    color: #666;
    font-size: 0.875rem;
    margin-top: 0.5rem;
  }
  
  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 1rem;
    margin-top: 2rem;
  }
  
  .btn {
    padding: 0.75rem 1.5rem;
    border-radius: var(--border-radius-sm);
    font-weight: 500;
    cursor: pointer;
    border: none;
    transition: background-color 0.2s;
  }
  
  .btn-primary {
    background-color: var(--primary-color);
    color: white;
  }
  
  .btn-primary:hover:not(:disabled) {
    background-color: var(--primary-hover);
  }
  
  .btn-secondary {
    background-color: #f1f2f3;
    color: var(--text-color);
  }
  
  .btn-secondary:hover:not(:disabled) {
    background-color: #e2e3e5;
  }
  
  .btn:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
  
  @media (max-width: 640px) {
    .form-actions {
      flex-direction: column;
    }
    
    .btn {
      width: 100%;
    }
  }
</style>