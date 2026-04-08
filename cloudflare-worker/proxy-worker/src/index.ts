/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

export default {
	async fetch(request, env, ctx): Promise<Response> {
		const url = new URL(request.url);
		const targetHost = 'https://YOUR-RENDER-APP-URL.onrender.com'; // Replace this!
		const targetUrl = new URL(url.pathname + url.search, targetHost);

		const modifiedRequest = new Request(targetUrl.toString(), {
			method: request.method,
			headers: request.headers,
			body: request.body,
			redirect: 'manual',
		});

		const response = await fetch(modifiedRequest);
		return response;
	},
} satisfies ExportedHandler<Env>;
