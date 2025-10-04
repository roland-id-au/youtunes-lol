# YouTunes 🎵

**Free Royalty-Free Music for YouTube Creators**

100% free, copyright-free background music for YouTube videos, generated daily using AI. No attribution required, no copyright claims, perfect for content creators.

> **Design Inspired by Top ProductHunt Launches** - Modern single-page design with gradients, glassmorphism, social proof, and conversion-focused layout.

## Features

- ✅ **100% Free** - No subscriptions, no credits, no payment required
- ✅ **Royalty-Free** - Use in monetized YouTube videos, commercial projects, anywhere
- ✅ **No Copyright Claims** - Won't trigger YouTube Content ID
- ✅ **No Attribution** - Credit not required (but appreciated!)
- ✅ **Daily Updates** - Fresh music generated every day based on trending content
- ✅ **Multiple Genres** - Lo-fi, electronic, ambient, cinematic, and more
- ✅ **SEO Optimized** - Ranks for "free music for youtube" and related searches
- ✅ **ProductHunt-Ready** - Modern design with social proof, testimonials, and clear CTAs

## Architecture

- **Frontend**: Modern single-page design with ProductHunt-style aesthetics
  - Purple/indigo gradient color scheme
  - Glassmorphism effects and smooth animations
  - Fully responsive and mobile-optimized
  - Hosted on Cloudflare Pages (static HTML/CSS/JS)
- **Backend**: Cloudflare Pages Functions (serverless)
- **Database**: Supabase (PostgreSQL)
- **APIs**:
  - YouTube Data API v3 (trending videos)
  - Replicate API (MusicGen for AI music generation)
  - OpenAI API (music metadata generation)
- **Automation**: GitHub Actions (daily cron jobs)
- **SEO**: Structured data (Schema.org), sitemap, robots.txt, optimized meta tags
- **Design**: Inspired by successful ProductHunt launches in the music/creator tools category

## Setup

### 1. Supabase Setup

1. Create a new Supabase project at https://supabase.com
2. Go to SQL Editor and run the schema from `supabase-schema.sql`
3. Get your project URL and keys from Settings > API

### 2. API Keys

Get the following API keys:
- **YouTube API**: https://console.cloud.google.com/apis/credentials
- **Replicate API**: https://replicate.com/account/api-tokens
- **OpenAI API**: https://platform.openai.com/api-keys

### 3. Cloudflare Setup

1. Create a Cloudflare account at https://cloudflare.com
2. Install Wrangler: `npm install -g wrangler`
3. Login: `wrangler login`
4. Create a new Pages project: `wrangler pages project create youtunes-lol`

### 4. Environment Variables

#### For local development:
Create `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
# Edit .env with your actual keys
```

#### For Cloudflare Pages:
Add secrets via Wrangler or Dashboard:

```bash
# Via Wrangler
wrangler pages secret put SUPABASE_URL
wrangler pages secret put SUPABASE_ANON_KEY
wrangler pages secret put SUPABASE_SERVICE_KEY
wrangler pages secret put YOUTUBE_API_KEY
wrangler pages secret put REPLICATE_API_KEY
wrangler pages secret put OPENAI_API_KEY
wrangler pages secret put CRON_SECRET
```

Or via Cloudflare Dashboard:
1. Go to Pages > youtunes-lol > Settings > Environment variables
2. Add all the above variables

### 5. GitHub Secrets

For GitHub Actions automation, add these secrets to your repository:

1. Go to Settings > Secrets and variables > Actions
2. Add:
   - `CLOUDFLARE_API_TOKEN`
   - `CLOUDFLARE_ACCOUNT_ID`
   - `CRON_SECRET` (generate a random string)

### 6. Deploy

```bash
# Install dependencies
npm install

# Deploy to Cloudflare Pages
npm run deploy

# Or let GitHub Actions deploy automatically on push to main
git push origin main
```

## Development

```bash
# Install dependencies
npm install

# Run local dev server
npm run dev

# Visit http://localhost:8788
```

## How It Works

1. **Daily Cron Job** (2 AM UTC via GitHub Actions):
   - Fetches top 20 trending YouTube videos
   - Analyzes video titles and descriptions
   - Generates music metadata using OpenAI
   - Creates AI music using Replicate's MusicGen
   - Stores everything in Supabase

2. **Frontend**:
   - SEO-optimized landing page targeting "free music for youtube"
   - Comprehensive FAQ section with structured data
   - Genre browsing page
   - License information page
   - Audio player for each track
   - Auto-refreshes every 5 minutes
   - Fully responsive design

3. **API**:
   - `/api/tracks` - Get all tracks and stats
   - `/api/cron-trigger` - Trigger manual update (authenticated)

## SEO Strategy

The site is optimized to rank for these keywords:
- **Primary**: "free music for youtube", "royalty free music", "copyright free music"
- **Secondary**: "youtube background music", "no copyright music", "free youtube music"
- **Long-tail**: "free music for youtube videos no copyright", "royalty free music for youtube creators"

### SEO Features Implemented:
- ✅ Optimized title tags and meta descriptions
- ✅ Schema.org structured data (WebSite, MusicGroup, FAQPage)
- ✅ Open Graph and Twitter Card meta tags
- ✅ Semantic HTML with proper heading hierarchy
- ✅ Internal linking structure
- ✅ XML sitemap
- ✅ Robots.txt
- ✅ FAQ section answering common queries
- ✅ Content-rich pages (License, Genres)
- ✅ Fast loading (static site on Cloudflare CDN)
- ✅ Mobile responsive
- ✅ Security headers

## Customization

- **Music Generation**: Edit `functions/_worker.js` to use different AI models
- **Video Selection**: Modify `fetchTrendingVideos()` to change region, count, etc.
- **Frontend Design**: Customize `public/styles.css`
- **Update Frequency**: Change cron schedule in `.github/workflows/deploy.yml`

## Cost Estimates

- **Cloudflare Pages**: Free tier (up to 500 builds/month)
- **Supabase**: Free tier (500MB database)
- **YouTube API**: Free (10,000 quota units/day)
- **Replicate**: ~$0.05 per track (30s audio)
- **OpenAI**: ~$0.01 per track (GPT-4)

**Daily cost**: ~$0.30 for 5 tracks/day = ~$9/month

## License

MIT
