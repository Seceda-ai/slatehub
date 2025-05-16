// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		interface PageData {
			user?: {
				username: string;
				email?: string;
				id?: string;
				profileImages?: Array<{
					id: string;
					data: string;
					created_at?: string;
				}>;
				activeImageId?: string;
				[key: string]: any;
			} | null;
		}
		// interface PageState {}
		// interface Platform {}
	}
}

export {};
