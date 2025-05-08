# Slatehub Authentication Documentation

This document explains how the authentication system in Slatehub works and how to integrate it into your components.

## Table of Contents

- [Overview](#overview)
- [Authentication Flow](#authentication-flow)
- [Integration](#integration)
- [Auth State](#auth-state)
- [Connection State](#connection-state)
- [Error Handling](#error-handling)
- [Database Queries in Authenticated Context](#database-queries-in-authenticated-context)
- [Custom Auth Headers for Fetch](#custom-auth-headers-for-fetch)
- [Debugging Tools](#debugging-tools)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## Overview

Slatehub uses SurrealDB for authentication, which provides user signup, signin, and token management. The system is built to be:

- **Client-side only**: No server-side rendering required
- **Token-based**: JWT tokens stored in localStorage
- **Reactive**: Uses Svelte stores to propagate auth state changes
- **Persistent**: Login sessions are maintained between page refreshes

## Authentication Flow

1. User signs up or signs in
2. Authentication token is obtained from SurrealDB
3. Token is stored in localStorage
4. Auth state is updated in Svelte store
5. Protected routes check auth state before rendering

## Integration

### Auth Library

The core authentication functionality is in `$lib/db/surreal.ts`, which exports:

- **Functions**: `connect()`, `signup()`, `signin()`, `signout()`, `query()`
- **Stores**: `authState`, `connectionState`, `errorMessage`
- **Types**: `ConnectionState`, `AuthState`

### Basic Usage

```svelte
<script>
  import { authState, signin, signout } from '$lib/db/surreal';
  
  // Check if user is logged in
  const isLoggedIn = $authState.isAuthenticated;
  
  // Get current user info
  const user = $authState.user;
  
  // Login function
  async function handleLogin(username, password) {
    try {
      await signin(username, password);
      // Redirect or show success message
    } catch (error) {
      // Show error message
    }
  }
  
  // Logout function
  async function handleLogout() {
    await signout();
    // Redirect to login page
  }
</script>
```

### Protecting Routes

Use the `AuthGuard` component to protect routes:

```svelte
<script>
  import AuthGuard from '$lib/components/AuthGuard.svelte';
</script>

<AuthGuard requireAuth={true} redirectTo="/login">
  <!-- Protected page content -->
</AuthGuard>
```

For public-only pages (like login/signup that should redirect if already logged in):

```svelte
<AuthGuard requireAuth={false} redirectTo="/">
  <!-- Public page content -->
</AuthGuard>
```

## Auth State

The `authState` store contains:

```typescript
{
  isAuthenticated: boolean;
  user: any | null;
  token: string | null;
}
```

You can subscribe to this store in any component to reactively respond to auth state changes.

## Connection State

The `connectionState` store contains the current SurrealDB connection state:

```typescript
enum ConnectionState {
  DISCONNECTED,
  CONNECTING,
  CONNECTED,
  ERROR
}
```

## Error Handling

The authentication system provides two stores for error handling:

1. The `errorMessage` store contains the most recent error message from an auth operation:

```svelte
<script>
  import { errorMessage } from '$lib/db/surreal';
</script>

{#if $errorMessage}
  <div class="error-message">
    {$errorMessage}
  </div>
{/if}
```

2. The `errorDetails` store contains more comprehensive error information:

```svelte
<script>
  import { errorDetails } from '$lib/db/surreal';
</script>

{#if $errorDetails.message}
  <div class="error-message">
    <p>{$errorDetails.message}</p>
    {#if $errorDetails.details}
      <p class="details">{$errorDetails.details}</p>
    {/if}
    {#if $errorDetails.code}
      <p class="code">Error code: {$errorDetails.code}</p>
    {/if}
  </div>
{/if}
```

## Database Queries in Authenticated Context

Once authenticated, you can use the `query` function to run SurrealQL queries:

```javascript
import { query } from '$lib/db/surreal';

async function loadUserData() {
  try {
    const result = await query('SELECT * FROM person WHERE id = $id', { id: 'person:123' });
    return result[0].result;
  } catch (error) {
    console.error('Failed to load user data:', error);
  }
}
```

## Custom Auth Headers for Fetch

If you need to make HTTP requests with the auth token:

```javascript
import { authState } from '$lib/db/surreal';

async function fetchProtectedResource() {
  const response = await fetch('/api/resource', {
    headers: {
      'Authorization': `Bearer ${$authState.token}`
    }
  });
  return await response.json();
}
```

## Security Considerations

- Tokens are stored in localStorage, which means they are vulnerable to XSS attacks
- Always validate user input on both client and server
- Use HTTPS in production to prevent token interception
- Consider adding token expiration and refresh mechanism for better security

## Debugging Tools

Slatehub includes several tools to help debug authentication and database issues:

### SurrealDebug Component

The `SurrealDebug` component provides a floating debug panel in development mode:

```svelte
<script>
  import SurrealDebug from '$lib/components/SurrealDebug.svelte';
</script>

<!-- Add this to your layout or page -->
<SurrealDebug expanded={false} />
```

This component:
- Shows connection status 
- Displays current auth state
- Shows detailed error information
- Provides console logging shortcuts
- Only displays in development mode

### Debug Console

A dedicated debug page at `/debug` provides a testing interface for:
- Connection management
- Authentication operations
- Custom query execution
- Detailed error display

To use the debug console, navigate to `/debug` in your application.

### Enhanced Error Logging

All authentication and database operations include enhanced error logging:

```javascript
try {
  await signin(username, password);
} catch (error) {
  // Error will be:
  // 1. Logged to console with full details
  // 2. Stored in errorMessage store
  // 3. Detailed information stored in errorDetails store
}
```

## Troubleshooting

1. **Auth state not persisting**: Check that localStorage is available and working
2. **Connection errors**: Verify SurrealDB is running and accessible at the specified URL
3. **Authentication failures**: Check credentials and database access permissions
4. **CORS issues**: Ensure SurrealDB is configured to allow requests from your frontend
5. **Detailed error investigation**: Use the `/debug` page to view complete error information
6. **Database query issues**: Check permission rules in your SurrealDB schema