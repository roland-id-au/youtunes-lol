import { createClient } from '@supabase/supabase-js';

export async function onRequest(context) {
    const { env } = context;

    // Initialize Supabase client
    const supabase = createClient(
        env.SUPABASE_URL,
        env.SUPABASE_ANON_KEY
    );

    try {
        // Fetch tracks from Supabase
        const { data: tracks, error: tracksError } = await supabase
            .from('tracks')
            .select(`
                *,
                videos (
                    video_id,
                    title,
                    thumbnail_url,
                    view_count
                )
            `)
            .order('created_at', { ascending: false })
            .limit(50);

        if (tracksError) throw tracksError;

        // Get stats
        const { count: trackCount } = await supabase
            .from('tracks')
            .select('*', { count: 'exact', head: true });

        const { count: videoCount } = await supabase
            .from('videos')
            .select('*', { count: 'exact', head: true });

        const { data: lastTrack } = await supabase
            .from('tracks')
            .select('created_at')
            .order('created_at', { ascending: false })
            .limit(1)
            .single();

        // Format response
        const formattedTracks = tracks.map(track => ({
            id: track.id,
            title: track.title,
            audio_url: track.audio_url,
            genre: track.genre,
            created_at: track.created_at,
            video_title: track.videos?.title || 'Unknown Video',
            thumbnail_url: track.videos?.thumbnail_url
        }));

        return new Response(JSON.stringify({
            tracks: formattedTracks,
            stats: {
                trackCount: trackCount || 0,
                videoCount: videoCount || 0,
                lastUpdate: lastTrack?.created_at || null
            }
        }), {
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        });
    } catch (error) {
        console.error('Error fetching tracks:', error);
        return new Response(JSON.stringify({
            error: error.message,
            tracks: [],
            stats: { trackCount: 0, videoCount: 0, lastUpdate: null }
        }), {
            status: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        });
    }
}
