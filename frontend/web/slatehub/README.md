# Slatehub Frontend

This is the Svelte-based frontend for Slatehub, an open-source production management tool for film, TV, commercial, and social video projects.

## Features

- **Authentication System**: Sign up, sign in, and sign out functionality
- **SurrealDB Integration**: Direct connection to SurrealDB backend
- **Profile Management**: User profile information display
- **Responsive Design**: Works on desktop and mobile devices
- **Role-Based Access Control**: Different views and permissions for different user roles
- **Debugging Tools**: Comprehensive error handling and debugging utilities

## Prerequisites

- Node.js (v18+)
- npm or pnpm
- Running SurrealDB instance (see main project README)

## Installation

1. Navigate to the frontend directory:

```bash
cd slatehub/frontend/web/slatehub
```

2. Install dependencies:

```bash
npm install
# or
pnpm install
```

3. Create a `.env` file in this directory with the following content:

```
VITE_SURREAL_URL=http://localhost:8000
VITE_SURREAL_NS=seceda
VITE_SURREAL_DB=core
```

Adjust these values if your SurrealDB is running on a different URL or with different namespace/database names.

## Development

To start the development server:

```bash
npm run dev
# or
pnpm dev
```

This will start the development server at [http://localhost:5173](http://localhost:5173).

## Building for Production

To create a production build:

```bash
npm run build
# or
pnpm build
```

To preview the production build:

```bash
npm run preview
# or
pnpm preview
```

## Project Structure

- `src/lib/db`: SurrealDB connection and auth management
- `src/lib/components`: Reusable UI components
- `src/lib/styles`: Global and component-specific styles
- `src/routes`: Page components for each route

## Authentication Flow

1. User signs up through `/signup` page
2. Authentication token is stored in localStorage
3. Protected routes check auth status before rendering
4. AuthGuard component handles redirects for unauthenticated users

## Customization

### Styling

Global CSS variables are defined in `src/app.css`. You can modify these to change the overall look and feel of the application.

### Adding New Pages

1. Create a new folder in `src/routes/`
2. Add a `+page.svelte` file in the folder
3. Wrap your page content with the AuthGuard component if authentication is required:

```svelte
<script>
  import AuthGuard from '$lib/components/AuthGuard.svelte';
  // other imports
</script>

<AuthGuard requireAuth={true}>
  <!-- Your page content here -->
</AuthGuard>
```

## Debugging

Slatehub includes comprehensive debugging tools to help you troubleshoot SurrealDB authentication and query issues:

### 1. Enhanced Error Display

The login and signup forms now display detailed error information, including:
- Error message
- Error code
- Detailed description of the problem
- Raw error data when available

### 2. SurrealDebug Component

In development mode, a floating debug panel is available at the bottom right of the screen:
- Shows current connection status
- Displays authentication state
- Provides detailed error information
- Can be expanded/collapsed as needed

### 3. Debug Console

A dedicated debug route at `/debug` provides a comprehensive testing interface:
- Test database connections
- Try authentication operations (signup, signin, signout)
- Execute custom SurrealQL queries
- View detailed error information
- Monitor operation timing

### 4. Console Logging

Enhanced error logging in the browser console provides additional context for troubleshooting:
- Connection errors
- Authentication errors
- Query errors
- Raw error data for detailed inspection

## Contributing

Please follow these guidelines when contributing to the project:

1. Use descriptive commit messages
2. Maintain the existing code style
3. Add comments for complex logic
4. Create components for reusable UI elements

## License

This project is open-source under the MIT License.