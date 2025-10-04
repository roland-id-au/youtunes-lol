import { createClient } from '@supabase/supabase-js';

// Upload audio to Cloudflare R2
async function uploadToR2(bucket, key, audioData, contentType = 'audio/mpeg') {
    if (!bucket) {
        console.error('R2 bucket not available');
        return null;
    }

    try {
        await bucket.put(key, audioData, {
            httpMetadata: {
                contentType: contentType,
            },
        });

        // Return public URL (will be served via custom domain)
        return `https://youtunes.lol/music/${key}`;
    } catch (error) {
        console.error('R2 upload error:', error);
        return null;
    }
}

// Download audio from URL and return as ArrayBuffer
async function downloadAudio(url) {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`Failed to download audio: ${response.statusText}`);
    }
    return await response.arrayBuffer();
}

// Discord webhook logger
async function logToDiscord(webhookUrl, message, color = 0x6366f1) {
    if (!webhookUrl) return;

    try {
        await fetch(webhookUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                embeds: [{
                    title: '🎵 YouTunes Generation Log',
                    description: message,
                    color: color,
                    timestamp: new Date().toISOString(),
                    footer: { text: 'YouTunes AI Music Generator' }
                }]
            })
        });
    } catch (error) {
        console.error('Discord webhook error:', error);
    }
}

// Fetch trending YouTube videos
export async function fetchTrendingVideos(apiKey) {
    const url = `https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&maxResults=20&regionCode=US&key=${apiKey}`;

    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`YouTube API error: ${response.statusText}`);
    }

    const data = await response.json();
    return data.items.map(item => ({
        video_id: item.id,
        title: item.snippet.title,
        description: item.snippet.description,
        thumbnail_url: item.snippet.thumbnails.high.url,
        channel_title: item.snippet.channelTitle,
        view_count: parseInt(item.statistics.viewCount || 0),
        like_count: parseInt(item.statistics.likeCount || 0),
        published_at: item.snippet.publishedAt
    }));
}

// Generate music using AI (using Replicate's MusicGen or similar)
export async function generateMusic(videoData, apiKey) {
    // Using Replicate's MusicGen model as an example
    const prompt = `Create background music inspired by: ${videoData.title}. ${videoData.description.slice(0, 200)}`;

    const response = await fetch('https://api.replicate.com/v1/predictions', {
        method: 'POST',
        headers: {
            'Authorization': `Token ${apiKey}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            version: 'b05b1dff1d8c6dc63d14b0cdb42135378dcb87f6373b0d3d341ede46e59e2b38', // MusicGen model
            input: {
                prompt: prompt,
                model_version: 'stereo-large',
                duration: 30,
                temperature: 1.0,
                top_k: 250,
                top_p: 0.0
            }
        })
    });

    if (!response.ok) {
        throw new Error(`Music generation error: ${response.statusText}`);
    }

    const prediction = await response.json();

    // Poll for completion
    let result = prediction;
    while (result.status !== 'succeeded' && result.status !== 'failed') {
        await new Promise(resolve => setTimeout(resolve, 2000));
        const pollResponse = await fetch(result.urls.get, {
            headers: {
                'Authorization': `Token ${apiKey}`
            }
        });
        result = await pollResponse.json();
    }

    if (result.status === 'failed') {
        throw new Error('Music generation failed');
    }

    return result.output; // URL to generated audio
}

// Alternative: Use OpenAI to generate music metadata/prompt
export async function generateMusicMetadata(videoData, openaiKey) {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${openaiKey}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            model: 'gpt-4',
            messages: [{
                role: 'system',
                content: 'You are a music producer creating background music for videos.'
            }, {
                role: 'user',
                content: `Generate a music description for this video: "${videoData.title}". Return JSON with: title, genre, mood, bpm, description`
            }],
            response_format: { type: 'json_object' }
        })
    });

    const data = await response.json();
    return JSON.parse(data.choices[0].message.content);
}

// Main worker function
export async function processYouTubeVideos(env) {
    const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_KEY);
    const webhookUrl = env.DISCORD_WEBHOOK_URL;
    const r2Bucket = env.MUSIC_BUCKET;

    await logToDiscord(webhookUrl, '🚀 **Starting daily music generation**\nFetching trending YouTube videos...', 0x10b981);

    console.log('Fetching trending videos...');
    const videos = await fetchTrendingVideos(env.YOUTUBE_API_KEY);

    await logToDiscord(webhookUrl, `📊 Found **${videos.length}** trending videos\nProcessing top 5...`, 0x6366f1);

    let processedCount = 0;
    const results = [];

    for (const video of videos.slice(0, 5)) { // Process top 5 to avoid API limits
        try {
            // Check if video already processed
            const { data: existing } = await supabase
                .from('videos')
                .select('id')
                .eq('video_id', video.video_id)
                .single();

            if (existing) {
                console.log(`Video ${video.video_id} already processed, skipping...`);
                await logToDiscord(webhookUrl, `⏭️ Skipping already processed: **${video.title.slice(0, 50)}...**`, 0x94a3b8);
                continue;
            }

            await logToDiscord(webhookUrl, `🎬 Processing: **${video.title.slice(0, 60)}...**\nViews: ${video.view_count.toLocaleString()}`, 0x6366f1);

            // Store video in database
            const { data: savedVideo, error: videoError } = await supabase
                .from('videos')
                .insert(video)
                .select()
                .single();

            if (videoError) throw videoError;

            // Generate music metadata
            await logToDiscord(webhookUrl, `🎼 Generating music metadata with AI...`, 0x8b5cf6);
            const metadata = await generateMusicMetadata(video, env.OPENAI_API_KEY);
            await logToDiscord(webhookUrl, `✅ Created track: **${metadata.title}**\nGenre: ${metadata.genre} | Mood: ${metadata.mood}`, 0x10b981);

            // Generate actual music
            let audioUrl = null;
            try {
                await logToDiscord(webhookUrl, `🎵 Generating AI music (this may take 30-60s)...`, 0xec4899);
                const replicateAudioUrl = await generateMusic(video, env.REPLICATE_API_KEY);
                await logToDiscord(webhookUrl, `✨ Music generated! Uploading to R2...`, 0x10b981);

                // Download and upload to R2
                const audioData = await downloadAudio(replicateAudioUrl);
                const trackKey = `${Date.now()}-${video.video_id}.mp3`;
                audioUrl = await uploadToR2(r2Bucket, trackKey, audioData);

                if (audioUrl) {
                    await logToDiscord(webhookUrl, `☁️ Uploaded to R2 storage!`, 0x10b981);
                } else {
                    // Fallback to Replicate URL if R2 upload fails
                    audioUrl = replicateAudioUrl;
                    await logToDiscord(webhookUrl, `⚠️ R2 upload failed, using direct URL`, 0xfbbf24);
                }
            } catch (error) {
                console.error('Music generation failed:', error);
                await logToDiscord(webhookUrl, `⚠️ Music generation failed: ${error.message}\nWill retry later`, 0xef4444);
                // Continue anyway, will show as "generating" on frontend
            }

            // Store track in database
            const { data: track, error: trackError } = await supabase
                .from('tracks')
                .insert({
                    video_id: savedVideo.id,
                    title: metadata.title,
                    genre: metadata.genre,
                    mood: metadata.mood,
                    bpm: metadata.bpm,
                    description: metadata.description,
                    audio_url: audioUrl
                })
                .select()
                .single();

            if (trackError) throw trackError;

            processedCount++;
            results.push({ video: video.title, track: track.title, success: true });
            await logToDiscord(webhookUrl, `💾 Saved to database: **${track.title}**`, 0x10b981);

        } catch (error) {
            console.error(`Error processing video ${video.video_id}:`, error);
            results.push({ video: video.title, error: error.message, success: false });
            await logToDiscord(webhookUrl, `❌ Error processing video: ${error.message}`, 0xef4444);
        }
    }

    // Final summary
    const summary = `✅ **Generation Complete!**\n\n` +
                   `📊 Processed: ${processedCount}/${videos.length} videos\n` +
                   `🎵 New tracks: ${processedCount}\n` +
                   `⏰ Next run: Tomorrow at 2 AM UTC\n\n` +
                   `Visit https://youtunes.lol to listen! 🎧`;

    await logToDiscord(webhookUrl, summary, processedCount > 0 ? 0x10b981 : 0xfbbf24);

    return {
        processed: processedCount,
        total: videos.length,
        results
    };
}
