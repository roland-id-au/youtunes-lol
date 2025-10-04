// Frontend JavaScript for YouTunes

const API_BASE = '/api';

async function fetchTracks() {
    try {
        const response = await fetch(`${API_BASE}/tracks`);
        if (!response.ok) throw new Error('Failed to fetch tracks');

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching tracks:', error);
        return { tracks: [], stats: {} };
    }
}

function formatDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));

    if (diffHours < 1) return 'Just now';
    if (diffHours < 24) return `${diffHours}h ago`;
    const diffDays = Math.floor(diffHours / 24);
    if (diffDays === 1) return 'Yesterday';
    if (diffDays < 7) return `${diffDays} days ago`;
    return date.toLocaleDateString();
}

function renderTrack(track) {
    return `
        <div class="track-card">
            <img
                src="${track.thumbnail_url || 'https://via.placeholder.com/640x360?text=No+Thumbnail'}"
                alt="${track.video_title}"
                class="track-thumbnail"
            />
            <div class="track-info">
                <h3 class="track-title">${track.title || 'Untitled Track'}</h3>
                <p class="track-video">From: ${track.video_title}</p>
                <div class="track-meta">
                    <span>🎵 ${track.genre || 'Unknown'}</span>
                    <span>${formatDate(track.created_at)}</span>
                </div>
                ${track.audio_url ? `
                    <audio controls class="audio-player">
                        <source src="${track.audio_url}" type="audio/mpeg">
                        Your browser does not support audio playback.
                    </audio>
                ` : '<p style="color: var(--text-muted); font-size: 0.9rem;">🎼 Generating...</p>'}
            </div>
        </div>
    `;
}

function renderTracks(tracks) {
    const container = document.getElementById('tracks-container');

    if (!tracks || tracks.length === 0) {
        container.innerHTML = '<div class="loading">No tracks yet. Check back soon!</div>';
        return;
    }

    container.innerHTML = tracks.map(renderTrack).join('');
}

function updateStats(stats) {
    // Update hero stats
    const trackCountHero = document.getElementById('track-count-hero');
    const videoCountHero = document.getElementById('video-count-hero');

    if (trackCountHero) trackCountHero.textContent = stats.trackCount || 0;
    if (videoCountHero) videoCountHero.textContent = stats.videoCount || 0;
}

async function init() {
    const data = await fetchTracks();
    renderTracks(data.tracks);
    updateStats(data.stats);

    // Refresh data every 5 minutes
    setInterval(async () => {
        const newData = await fetchTracks();
        renderTracks(newData.tracks);
        updateStats(newData.stats);
    }, 5 * 60 * 1000);
}

// Initialize app
init();
