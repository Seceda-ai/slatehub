import { authState } from '$lib/db/surreal';
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = async ({ fetch }) => {
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