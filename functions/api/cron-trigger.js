// This endpoint will be called by a scheduled cron job (GitHub Actions or Cloudflare Cron)

export async function onRequest(context) {
    const { env, request } = context;

    // Simple auth check - only allow requests with the correct secret
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || authHeader !== `Bearer ${env.CRON_SECRET}`) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }

    try {
        // Import and run the worker logic
        const { processYouTubeVideos } = await import('../_worker.js');
        const result = await processYouTubeVideos(env);

        return new Response(JSON.stringify({
            success: true,
            message: 'Cron job completed',
            result
        }), {
            headers: { 'Content-Type': 'application/json' }
        });
    } catch (error) {
        console.error('Cron job error:', error);
        return new Response(JSON.stringify({
            success: false,
            error: error.message
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' }
        });
    }
}
