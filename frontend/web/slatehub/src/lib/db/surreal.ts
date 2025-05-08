import { Surreal } from "surrealdb";
import { writable, type Writable } from "svelte/store";

// Connection states
export enum ConnectionState {
  DISCONNECTED,
  CONNECTING,
  CONNECTED,
  ERROR,
}

// Auth state
export interface AuthState {
  isAuthenticated: boolean;
  user: any | null;
  token: string | null;
}

// Error details
export interface ErrorDetails {
  message: string | null;
  code?: number;
  details?: string;
  raw?: any;
}

// Database configuration interface
interface DbConfig {
  url: string;
  namespace: string;
  database: string;
}

// Default database configuration
const DEFAULT_CONFIG: DbConfig = {
  url: import.meta.env.VITE_SURREAL_URL || "http://127.0.0.1:8000/rpc",
  namespace: import.meta.env.VITE_SURREAL_NS || "seceda",
  database: import.meta.env.VITE_SURREAL_DB || "core",
};

// Create stores
export const connectionState: Writable<ConnectionState> = writable(
  ConnectionState.DISCONNECTED,
);
export const authState: Writable<AuthState> = writable({
  isAuthenticated: false,
  user: null,
  token: null,
});
export const errorMessage: Writable<string | null> = writable(null);
export const errorDetails: Writable<ErrorDetails> = writable({ message: null });

// Create a single instance of SurrealDB
export const db = new Surreal();

// Initialize connection
export async function connect(
  config: DbConfig = DEFAULT_CONFIG,
): Promise<boolean> {
  try {
    connectionState.set(ConnectionState.CONNECTING);
    errorMessage.set(null);

    console.log("Connecting to SurrealDB at:", config.url);

    // Connect to the database
    await db.connect(config.url);

    // Use namespace and database
    await db.use({
      namespace: config.namespace,
      database: config.database,
    });

    console.log(
      `Connected to SurrealDB (NS: ${config.namespace}, DB: ${config.database})`,
    );
    connectionState.set(ConnectionState.CONNECTED);

    // Try to restore session from localStorage if it exists
    const storedToken = localStorage.getItem("surrealToken");
    if (storedToken) {
      try {
        await db.authenticate(storedToken);
        const info = await db.info();

        authState.set({
          isAuthenticated: true,
          user: info,
          token: storedToken,
        });

        console.log("Successfully restored previous session");
      } catch (e) {
        console.warn("Invalid stored token, removing it:", e);
        localStorage.removeItem("surrealToken");
      }
    }

    return true;
  } catch (e) {
    connectionState.set(ConnectionState.ERROR);
    const message =
      e instanceof Error ? e.message : "Failed to connect to database";
    errorMessage.set(message);
    console.error("Connection error:", e);

    errorDetails.set({
      message,
      raw: e,
      details:
        "Check that SurrealDB is running and accessible at the configured URL",
    });

    return false;
  }
}

// Sign up
export async function signup(
  username: string,
  email: string,
  password: string,
) {
  try {
    errorMessage.set(null);

    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    console.log("Attempting signup for user:", username);

    // Use the latest authentication format
    const result = await db.signup({
      namespace: DEFAULT_CONFIG.namespace,
      database: DEFAULT_CONFIG.database,
      access: "user_access",
      variables: {
        username,
        email,
        password,
      },
    });

    console.log("Signup successful");

    // If signup was successful, sign in to get a token
    return await signin(username, password);
  } catch (e) {
    console.error("Signup error:", e);

    // Extract error information
    let message = "Failed to sign up";
    let details = "Unknown error during signup";
    let code = 400;

    if (e instanceof Error) {
      message = e.message;
    }

    if (e && typeof e === "object") {
      if ("code" in e) code = e.code;
      if ("description" in e) details = e.description;
      if ("information" in e) details = `${details}: ${e.information}`;
    }

    errorMessage.set(message);
    errorDetails.set({
      message,
      code,
      details,
      raw: e,
    });

    throw e;
  }
}

// Sign in
export async function signin(username: string, password: string) {
  try {
    errorMessage.set(null);

    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    console.log("Attempting signin for user:", username);

    // Use the latest authentication format
    const token = await db.signin({
      namespace: DEFAULT_CONFIG.namespace,
      database: DEFAULT_CONFIG.database,
      access: "user_access",
      variables: {
        username,
        password,
      },
    });

    console.log("Signin successful: " + token);

    // Store token and update auth state
    if (token) {
      localStorage.setItem("surrealToken", token);

      // Get user info
      const info = await db.info();

      authState.set({
        isAuthenticated: true,
        user: { username, ...info },
        token,
      });

      return { user: { username, ...info }, token };
    } else {
      throw new Error("No authentication token returned");
    }
  } catch (e) {
    console.error("Signin error:", e);

    // Extract error information
    let message = "Failed to sign in";
    let details = "Unknown error during signin";
    let code = 400;

    if (e instanceof Error) {
      message = e.message;
    }

    if (e && typeof e === "object") {
      if ("code" in e) code = e.code;
      if ("description" in e) details = e.description;
      if ("information" in e) details = `${details}: ${e.information}`;
    }

    errorMessage.set(message);
    errorDetails.set({
      message,
      code,
      details,
      raw: e,
    });

    throw e;
  }
}

// Sign out
export async function signout() {
  try {
    // Invalidate the token on the server
    await db.invalidate();

    // Remove from local storage
    localStorage.removeItem("surrealToken");

    // Reset auth state
    authState.set({
      isAuthenticated: false,
      user: null,
      token: null,
    });

    return true;
  } catch (e) {
    console.error("Signout error:", e);

    const message = e instanceof Error ? e.message : "Failed to sign out";
    errorMessage.set(message);
    errorDetails.set({
      message,
      raw: e,
      details: "Error occurred while signing out",
    });

    throw e;
  }
}

// Close database connection
export async function closeConnection() {
  try {
    await db.close();
    connectionState.set(ConnectionState.DISCONNECTED);
    return true;
  } catch (e) {
    console.error("Error closing connection:", e);
    return false;
  }
}

// Helper for running queries
export async function query<T = any>(
  sql: string,
  vars: Record<string, any> = {},
) {
  try {
    errorMessage.set(null);

    // Ensure we're connected
    if (getConnectionState() !== ConnectionState.CONNECTED) {
      await connect();
    }

    // Run the query with variables
    return await db.query<T>(sql, vars);
  } catch (e) {
    console.error("Query error:", e);

    const message = e instanceof Error ? e.message : "Query failed";
    errorMessage.set(message);

    let details = "Unknown error during database query";
    let code = 0;

    if (e && typeof e === "object") {
      if ("code" in e) code = e.code;
      if ("description" in e) details = e.description;
      if ("information" in e) details = `${details}: ${e.information}`;
    }

    errorDetails.set({
      message,
      code,
      details,
      raw: e,
    });

    throw e;
  }
}

// Helper for checking connection state
export function getConnectionState(): ConnectionState {
  let state: ConnectionState = ConnectionState.DISCONNECTED;
  connectionState.subscribe((value) => {
    state = value;
  })();
  return state;
}

// Helper for checking auth state
export function isAuthenticated(): boolean {
  let authenticated = false;
  authState.subscribe((state) => {
    authenticated = state.isAuthenticated;
  })();
  return authenticated;
}

// Helper for getting the current user
export function getCurrentUser(): any | null {
  let user = null;
  authState.subscribe((state) => {
    user = state.user;
  })();
  return user;
}
