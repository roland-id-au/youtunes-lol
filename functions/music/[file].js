// Serve music files from Cloudflare R2
export async function onRequest(context) {
    const { env, params } = context;
    const fileName = params.file;

    if (!fileName) {
        return new Response('File not found', { status: 404 });
    }

    try {
        const object = await env.MUSIC_BUCKET.get(fileName);

        if (!object) {
            return new Response('Music file not found', { status: 404 });
        }

        const headers = new Headers();
        object.writeHttpMetadata(headers);
        headers.set('etag', object.httpEtag);
        headers.set('Cache-Control', 'public, max-age=31536000, immutable');
        headers.set('Access-Control-Allow-Origin', '*');

        return new Response(object.body, { headers });
    } catch (error) {
        console.error('Error serving music file:', error);
        return new Response('Error loading music file', { status: 500 });
    }
}
