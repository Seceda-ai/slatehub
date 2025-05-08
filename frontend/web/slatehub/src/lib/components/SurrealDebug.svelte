<script>
  import { onMount } from 'svelte';
  import { errorDetails, errorMessage, connectionState, ConnectionState, authState } from '$lib/db/surreal';

  export let expanded = false;
  
  let showDebug = false;
  
  // Toggle expanded state
  function toggleExpanded() {
    expanded = !expanded;
  }
  
  // Format JSON for display
  function formatJson(obj) {
    try {
      return JSON.stringify(obj, null, 2);
    } catch (error) {
      return `Error formatting JSON: ${error.message}`;
    }
  }
  
  // Only show in development
  onMount(() => {
    showDebug = import.meta.env.DEV || import.meta.env.MODE === 'development';
  });
</script>

{#if showDebug}
  <div class="surreal-debug {expanded ? 'expanded' : 'collapsed'}">
    <div class="debug-header" on:click={toggleExpanded}>
      <span class="debug-title">SurrealDB Debug</span>
      <span class="connection-status" class:connected={$connectionState === ConnectionState.CONNECTED} 
        class:error={$connectionState === ConnectionState.ERROR}
        class:connecting={$connectionState === ConnectionState.CONNECTING}
        class:disconnected={$connectionState === ConnectionState.DISCONNECTED}>
        {ConnectionState[$connectionState]}
      </span>
      <span class="toggle-icon">{expanded ? '▼' : '►'}</span>
    </div>
    
    {#if expanded}
      <div class="debug-content">
        <div class="debug-section">
          <h3>Auth State</h3>
          <div class="debug-value">
            <pre>{formatJson($authState)}</pre>
          </div>
        </div>
        
        {#if $errorMessage}
          <div class="debug-section error">
            <h3>Error Message</h3>
            <div class="debug-value">
              <pre>{$errorMessage}</pre>
            </div>
          </div>
        {/if}
        
        {#if $errorDetails.message}
          <div class="debug-section error">
            <h3>Error Details</h3>
            <div class="debug-value">
              <table>
                <tbody>
                  <tr>
                    <th>Message:</th>
                    <td>{$errorDetails.message}</td>
                  </tr>
                  {#if $errorDetails.code}
                    <tr>
                      <th>Code:</th>
                      <td>{$errorDetails.code}</td>
                    </tr>
                  {/if}
                  {#if $errorDetails.details}
                    <tr>
                      <th>Details:</th>
                      <td>{$errorDetails.details}</td>
                    </tr>
                  {/if}
                </tbody>
              </table>
              
              {#if $errorDetails.raw}
                <div class="raw-error">
                  <h4>Raw Error Data</h4>
                  <pre>{formatJson($errorDetails.raw)}</pre>
                </div>
              {/if}
            </div>
          </div>
        {/if}
        
        <div class="debug-actions">
          <button on:click={() => console.log('Auth State:', $authState)}>
            Log Auth State
          </button>
          <button on:click={() => console.log('Error Details:', $errorDetails)}>
            Log Error Details
          </button>
        </div>
      </div>
    {/if}
  </div>
{/if}

<style>
  .surreal-debug {
    position: fixed;
    bottom: 0;
    right: 0;
    background-color: #2d2d2d;
    color: #e0e0e0;
    font-family: monospace;
    z-index: 9999;
    border-top-left-radius: 4px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
    transition: all 0.3s ease;
    width: 500px;
    max-width: 100vw;
  }
  
  .debug-header {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    cursor: pointer;
    background-color: #1c1c1c;
    border-top-left-radius: 4px;
  }
  
  .debug-title {
    flex-grow: 1;
    font-weight: bold;
  }
  
  .connection-status {
    margin: 0 10px;
    padding: 2px 6px;
    border-radius: 3px;
    font-size: 12px;
  }
  
  .connected {
    background-color: #2e7d32;
  }
  
  .disconnected {
    background-color: #616161;
  }
  
  .connecting {
    background-color: #f57c00;
  }
  
  .error {
    background-color: #c62828;
  }
  
  .toggle-icon {
    margin-left: 5px;
  }
  
  .debug-content {
    padding: 10px;
    overflow: auto;
    max-height: 60vh;
  }
  
  .debug-section {
    margin-bottom: 15px;
    border: 1px solid #444;
    border-radius: 4px;
    overflow: hidden;
  }
  
  .debug-section h3 {
    margin: 0;
    padding: 8px 10px;
    background-color: #3c3c3c;
    font-size: 14px;
  }
  
  .debug-section.error h3 {
    background-color: #7f1d1d;
  }
  
  .debug-value {
    padding: 10px;
    overflow: auto;
    background-color: #252525;
  }
  
  pre {
    margin: 0;
    white-space: pre-wrap;
    word-break: break-word;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th {
    text-align: left;
    padding: 4px;
    vertical-align: top;
    width: 80px;
    color: #bbb;
  }
  
  td {
    padding: 4px;
    word-break: break-word;
  }
  
  .raw-error {
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px dashed #444;
  }
  
  .raw-error h4 {
    margin: 0 0 5px 0;
    font-size: 13px;
    color: #bbb;
  }
  
  .debug-actions {
    display: flex;
    gap: 8px;
    margin-top: 10px;
  }
  
  button {
    background-color: #3c3c3c;
    border: none;
    color: #e0e0e0;
    padding: 6px 10px;
    border-radius: 3px;
    cursor: pointer;
    font-family: monospace;
    font-size: 12px;
  }
  
  button:hover {
    background-color: #4c4c4c;
  }
  
  .collapsed {
    width: 200px;
  }
  
  @media (max-width: 600px) {
    .surreal-debug {
      width: 100%;
      right: 0;
    }
    
    .collapsed {
      width: 150px;
    }
  }
</style>