import { authState } from '$lib/db/surreal';

export const load = async () => {
  let user = null;
  
  // Subscribe to authState to get the current user
  const unsubscribe = authState.subscribe(state => {
    if (state.isAuthenticated) {
      user = state.user;
    }
  });
  
  // Immediately unsubscribe to avoid memory leaks
  unsubscribe();
  
  return {
    user
  };
};