import { Surreal } from 'surrealdb.js';
import { writable, type Writable } from 'svelte/store';

// Connection states
export enum ConnectionState {
  DISCONNECTED,
  CONNECTING,
  CONNECTED,
  ERROR
}

// Auth state
export interface AuthState {
  isAuthenticated: boolean;
  user: any | null;
  token: string | null;
}

// Create stores
export const connectionState: Writable<ConnectionState> = writable(ConnectionState.DISCONNECTED);
export const authState: Writable<AuthState> = writable({
  isAuthenticated: false,
  user: null,
  token: null
});
export const errorMessage: Writable<string | null> = writable(null);

// Create a single instance of SurrealDB
const db = new Surreal();

// Initialize connection
export async function connect(url: string = 'http://localhost:8000') {
  try {
    connectionState.set(ConnectionState.CONNECTING);
    errorMessage.set(null);
    
    await db.connect(url);
    connectionState.set(ConnectionState.CONNECTED);
    
    // Try to restore session from localStorage if it exists
    const storedToken = localStorage.getItem('surrealToken');
    if (storedToken) {
      try {
        await db.authenticate(storedToken);
        const result = await db.info();
        authState.set({
          isAuthenticated: true,
          user: result,
          token: storedToken
        });
      } catch (e) {
        // Invalid token, clear it
        localStorage.removeItem('surrealToken');
      }
    }
    
    return true;
  } catch (e) {
    connectionState.set(ConnectionState.ERROR);
    errorMessage.set(e instanceof Error ? e.message : 'Failed to connect to database');
    return false;
  }
}

// Direct API signup request
export async function signup(username: string, email: string, password: string) {
  try {
    errorMessage.set(null);
    
    const dbUrl = import.meta.env.VITE_SURREAL_URL || 'http://localhost:8000';
    const ns = import.meta.env.VITE_SURREAL_NS || 'seceda';
    const dbName = import.meta.env.VITE_SURREAL_DB || 'core';
    
    // Use direct API call for signup
    const response = await fetch(`${dbUrl}/signup`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        ns: ns,
        db: dbName,
        ac: 'user_access',
        username,
        password,
        email
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.description || 'Signup failed');
    }
    
    // If signup was successful, sign in to get a token
    return await signin(username, password);
  } catch (e) {
    errorMessage.set(e instanceof Error ? e.message : 'Failed to sign up');
    throw e;
  }
}

// Sign in
export async function signin(username: string, password: string) {
  try {
    errorMessage.set(null);
    
    const dbUrl = import.meta.env.VITE_SURREAL_URL || 'http://localhost:8000';
    const ns = import.meta.env.VITE_SURREAL_NS || 'seceda';
    const dbName = import.meta.env.VITE_SURREAL_DB || 'core';
    
    // Use direct API call for signin
    const response = await fetch(`${dbUrl}/signin`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        ns: ns,
        db: dbName,
        ac: 'user_access',
        username,
        password
      })
    });
    
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.description || 'Signin failed');
    }
    
    const result = await response.json();
    
    // Store the token
    if (result && result.token) {
      localStorage.setItem('surrealToken', result.token);
      
      // Set the user in the store
      authState.set({
        isAuthenticated: true,
        user: { username, ...result }, // Include username and any other data
        token: result.token
      });
      
      // Authenticate the DB connection with the token
      await db.authenticate(result.token);
    }
    
    return result;
  } catch (e) {
    errorMessage.set(e instanceof Error ? e.message : 'Failed to sign in');
    throw e;
  }
}

// Sign out
export async function signout() {
  try {
    await db.invalidate();
    localStorage.removeItem('surrealToken');
    
    authState.set({
      isAuthenticated: false,
      user: null,
      token: null
    });
    
    return true;
  } catch (e) {
    errorMessage.set(e instanceof Error ? e.message : 'Failed to sign out');
    throw e;
  }
}

// Query wrapper
export async function query(sql: string, vars: Record<string, any> = {}) {
  try {
    errorMessage.set(null);
    return await db.query(sql, vars);
  } catch (e) {
    errorMessage.set(e instanceof Error ? e.message : 'Query failed');
    throw e;
  }
}

// Export the db instance for direct access if needed
export { db };