// Frontend JavaScript for YouTunes - Minimal Professional Design

const API_BASE = '/api';
let allTracks = [];
let currentTrack = null;
const audioElement = document.getElementById('audioElement');

// Fetch all tracks
async function fetchTracks() {
    try {
        const response = await fetch(`${API_BASE}/tracks`);
        if (!response.ok) throw new Error('Failed to fetch tracks');
        const data = await response.json();
        return data.tracks || [];
    } catch (error) {
        console.error('Error fetching tracks:', error);
        return [];
    }
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffDays === 0) return 'Today';
    if (diffDays === 1) return 'Yesterday';
    if (diffDays < 7) return `${diffDays} days ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
}

// Render track card (for latest tracks grid)
function renderTrackCard(track) {
    const channelName = track.channel_name || 'Unknown Channel';
    const videoTitle = track.video_title || 'Unknown Video';
    const genre = track.genre || 'Uncategorized';
    const mood = track.mood || 'Neutral';

    return `
        <div class="track-card" data-track-id="${track.id}">
            <div class="track-card-header">
                <div class="track-title">${track.title || 'Untitled Track'}</div>
                <div class="track-source">From: ${channelName}</div>
                <div class="track-tags">
                    <span class="tag genre">${genre}</span>
                    <span class="tag mood">${mood}</span>
                    <span class="tag channel">${channelName}</span>
                </div>
            </div>
            <div class="track-actions">
                <button class="btn btn-primary" onclick="playTrack('${track.id}')">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
                        <path d="M4 2v12l10-6z"/>
                    </svg>
                    Play
                </button>
                <button class="btn btn-secondary" onclick="downloadTrack('${track.audio_url}', '${track.title}')">
                    <svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 10v2.67A1.33 1.33 0 0112.67 14H3.33A1.33 1.33 0 012 12.67V10M4.67 6.67L8 10l3.33-3.33M8 10V2"/>
                    </svg>
                    Download
                </button>
            </div>
        </div>
    `;
}

// Render track item (for archive list)
function renderTrackItem(track) {
    const channelName = track.channel_name || 'Unknown Channel';
    const genre = track.genre || 'Uncategorized';
    const mood = track.mood || 'Neutral';
    const date = formatDate(track.created_at);

    return `
        <div class="track-item" data-track-id="${track.id}">
            <div class="track-item-main">
                <div class="track-item-title">${track.title || 'Untitled Track'}</div>
                <div class="track-item-meta">
                    <span>${genre}</span>
                    <span>•</span>
                    <span>${mood}</span>
                    <span>•</span>
                    <span>${channelName}</span>
                    <span>•</span>
                    <span>${date}</span>
                </div>
            </div>
            <div class="track-item-actions">
                <button class="icon-btn" onclick="playTrack('${track.id}')" title="Play">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                        <path d="M5 3v14l12-7z"/>
                    </svg>
                </button>
                <button class="icon-btn" onclick="downloadTrack('${track.audio_url}', '${track.title}')" title="Download">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 12v3.33A1.67 1.67 0 0115.33 17H4.67A1.67 1.67 0 013 15.33V12M5.67 8.33L10 12.5l4.33-4.17M10 12.5V2.5"/>
                    </svg>
                </button>
            </div>
        </div>
    `;
}

// Render tracks
function renderTracks(tracks) {
    // Latest tracks (first 6)
    const latestTracksContainer = document.getElementById('latestTracks');
    const latestTracks = tracks.slice(0, 6);

    if (latestTracks.length === 0) {
        latestTracksContainer.innerHTML = '<div class="empty-state"><h3>No tracks yet</h3><p>Check back soon for new music!</p></div>';
    } else {
        latestTracksContainer.innerHTML = latestTracks.map(renderTrackCard).join('');
    }

    // Archive tracks (rest)
    const archiveTracksContainer = document.getElementById('archiveTracks');
    const archiveTracks = tracks.slice(6);

    if (archiveTracks.length === 0) {
        archiveTracksContainer.innerHTML = '<div class="empty-state"><h3>No archived tracks</h3><p>More tracks will appear here as we generate them.</p></div>';
    } else {
        archiveTracksContainer.innerHTML = archiveTracks.map(renderTrackItem).join('');
    }
}

// Search tracks
function searchTracks(query) {
    const lowerQuery = query.toLowerCase();
    const filtered = allTracks.filter(track => {
        return (
            (track.title && track.title.toLowerCase().includes(lowerQuery)) ||
            (track.genre && track.genre.toLowerCase().includes(lowerQuery)) ||
            (track.mood && track.mood.toLowerCase().includes(lowerQuery)) ||
            (track.channel_name && track.channel_name.toLowerCase().includes(lowerQuery)) ||
            (track.video_title && track.video_title.toLowerCase().includes(lowerQuery))
        );
    });

    renderTracks(filtered);
}

// Play track
function playTrack(trackId) {
    const track = allTracks.find(t => t.id === trackId);
    if (!track || !track.audio_url) return;

    currentTrack = track;
    audioElement.src = track.audio_url;
    audioElement.play();

    // Show player
    document.getElementById('player').classList.remove('hidden');

    // Update player info
    document.getElementById('playerTitle').textContent = track.title || 'Untitled Track';
    document.getElementById('playerMeta').textContent = `${track.genre || 'Unknown'} • ${track.mood || 'Unknown'}`;

    // Update play/pause icon
    document.getElementById('playIcon').style.display = 'none';
    document.getElementById('pauseIcon').style.display = 'block';
}

// Download track
function downloadTrack(url, title) {
    const a = document.createElement('a');
    a.href = url;
    a.download = `${title || 'track'}.mp3`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

// Player controls
function setupPlayer() {
    const playPauseBtn = document.getElementById('playPauseBtn');
    const downloadBtn = document.getElementById('downloadBtn');
    const closePlayerBtn = document.getElementById('closePlayerBtn');
    const playIcon = document.getElementById('playIcon');
    const pauseIcon = document.getElementById('pauseIcon');
    const progressFill = document.getElementById('progressFill');
    const currentTimeEl = document.getElementById('currentTime');
    const durationEl = document.getElementById('duration');

    // Play/Pause
    playPauseBtn.addEventListener('click', () => {
        if (audioElement.paused) {
            audioElement.play();
            playIcon.style.display = 'none';
            pauseIcon.style.display = 'block';
        } else {
            audioElement.pause();
            playIcon.style.display = 'block';
            pauseIcon.style.display = 'none';
        }
    });

    // Download
    downloadBtn.addEventListener('click', () => {
        if (currentTrack) {
            downloadTrack(currentTrack.audio_url, currentTrack.title);
        }
    });

    // Close player
    closePlayerBtn.addEventListener('click', () => {
        audioElement.pause();
        document.getElementById('player').classList.add('hidden');
        playIcon.style.display = 'block';
        pauseIcon.style.display = 'none';
    });

    // Update progress
    audioElement.addEventListener('timeupdate', () => {
        const progress = (audioElement.currentTime / audioElement.duration) * 100;
        progressFill.style.width = `${progress}%`;
        currentTimeEl.textContent = formatTime(audioElement.currentTime);
    });

    // Update duration
    audioElement.addEventListener('loadedmetadata', () => {
        durationEl.textContent = formatTime(audioElement.duration);
    });

    // Seek
    document.querySelector('.progress-bar').addEventListener('click', (e) => {
        const rect = e.currentTarget.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const percentage = x / rect.width;
        audioElement.currentTime = percentage * audioElement.duration;
    });
}

// Format time (seconds to mm:ss)
function formatTime(seconds) {
    if (isNaN(seconds)) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
}

// Search functionality
function setupSearch() {
    const searchInput = document.getElementById('searchInput');
    const searchBtn = document.getElementById('searchBtn');

    searchBtn.addEventListener('click', () => {
        const query = searchInput.value.trim();
        if (query) {
            searchTracks(query);
        } else {
            renderTracks(allTracks);
        }
    });

    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            const query = searchInput.value.trim();
            if (query) {
                searchTracks(query);
            } else {
                renderTracks(allTracks);
            }
        }
    });

    // Real-time search
    searchInput.addEventListener('input', () => {
        const query = searchInput.value.trim();
        if (query.length > 2) {
            searchTracks(query);
        } else if (query.length === 0) {
            renderTracks(allTracks);
        }
    });
}

// Initialize app
async function init() {
    allTracks = await fetchTracks();
    renderTracks(allTracks);
    setupPlayer();
    setupSearch();

    // Refresh every 5 minutes
    setInterval(async () => {
        allTracks = await fetchTracks();
        renderTracks(allTracks);
    }, 5 * 60 * 1000);
}

// Start
init();
