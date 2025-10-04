# 🚀 Automatic Setup for youtunes.lol

**One script to set up everything for automatic daily music generation**

## Quick Start

```bash
cd /Users/blake/Projects/youtunes_lol
./setup-auto-deploy.sh
```

The script will:

1. ✅ Check requirements (Node.js, GitHub CLI)
2. ✅ Collect all API keys
3. ✅ Push code to GitHub
4. ✅ Create Cloudflare R2 bucket
5. ✅ Deploy to Cloudflare Pages
6. ✅ Configure all environment variables
7. ✅ Set up GitHub Actions secrets
8. ✅ Guide domain configuration
9. ✅ Trigger first music generation

**Total time: ~15-20 minutes**

---

## Before You Run

### 1. Get API Keys (10 minutes)

Have these ready before running the script:

#### Supabase
1. Go to https://supabase.com
2. Create new project
3. Go to SQL Editor
4. Copy contents of `supabase-schema.sql`
5. Paste and run
6. Go to Settings > API
7. Copy:
   - Project URL
   - anon/public key
   - service_role key

#### YouTube Data API
1. Go to https://console.cloud.google.com
2. Create/select project
3. Enable "YouTube Data API v3"
4. Credentials > Create Credentials > API Key
5. Copy key

#### Replicate
1. Go to https://replicate.com
2. Sign up/login
3. Account settings > API tokens
4. Copy token

#### OpenAI
1. Go to https://platform.openai.com
2. Add payment method (required)
3. API keys > Create new secret key
4. Copy key (starts with `sk-`)

### 2. Install Requirements

```bash
# Install Node.js (if not installed)
brew install node

# Install GitHub CLI (if not installed)
brew install gh

# Login to GitHub
gh auth login
```

---

## Running the Setup

```bash
cd /Users/blake/Projects/youtunes_lol
./setup-auto-deploy.sh
```

Follow the prompts. The script will:

### Automated Steps

✅ **GitHub**
- Create repository
- Push code
- Set up Actions secrets

✅ **Cloudflare**
- Login via wrangler
- Create R2 bucket
- Deploy to Pages
- Add environment variables

✅ **Testing**
- Test API endpoint
- Trigger first generation
- Verify Discord logging

### Manual Steps (Script Guides You)

⚠️ **R2 Binding**
- Cloudflare Dashboard > Pages > Functions
- Add binding: MUSIC_BUCKET = youtunes-music

⚠️ **Domain**
- Buy youtunes.lol (if needed)
- Pages > Custom domains
- Add youtunes.lol

---

## What You'll See

### During Setup

```
════════════════════════════════════════════════════════
  🎵 YouTunes - Automatic Deployment Setup
════════════════════════════════════════════════════════

📋 Checking requirements...
✅ All required tools installed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Step 1: API Keys & Credentials
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Enter your API keys...]

✅ Saved credentials to .env

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Step 2: Push to GitHub
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Pushed to GitHub

[... continues through all steps ...]

════════════════════════════════════════════════════════
  ✅ YouTunes Setup Complete!
════════════════════════════════════════════════════════

🎉 Your site is live!
  📍 Current URL: https://youtunes-lol.pages.dev
  🔗 Custom domain: youtunes.lol (once configured)
```

### In Discord

You'll see:

```
🚀 Starting daily music generation
Fetching trending YouTube videos...

📊 Found 20 trending videos
Processing top 5...

🎬 Processing: "Amazing Video Title..."
Views: 1,234,567

🎼 Generating music metadata with AI...
✅ Created track: "Chill Summer Vibes"
Genre: Lo-fi | Mood: Relaxed

🎵 Generating AI music (this may take 30-60s)...
✨ Music generated! Uploading to R2...
☁️ Uploaded to R2 storage!
💾 Saved to database: "Chill Summer Vibes"

[... repeats for each video ...]

✅ Generation Complete!
📊 Processed: 5/20 videos
🎵 New tracks: 5
⏰ Next run: Tomorrow at 2 AM UTC

Visit https://youtunes.lol to listen! 🎧
```

---

## After Setup

### Automatic Daily Updates

Your site will automatically:

1. **2 AM UTC Every Day**:
   - GitHub Action triggers
   - Fetches trending YouTube videos
   - Generates 5 new music tracks
   - Uploads to R2 storage
   - Updates database
   - Logs to Discord

2. **On Every Git Push**:
   - GitHub Action deploys
   - Updates Cloudflare Pages
   - Site goes live in ~30 seconds

### Monitoring

**Discord**: Real-time logs
- Generation progress
- Success/errors
- Daily summaries

**Cloudflare**: Analytics
- Traffic stats
- Bandwidth usage
- Function logs

**Supabase**: Database
- Track count
- Video metadata
- Usage stats

---

## Troubleshooting

### "R2 not enabled"

```bash
# Go to Cloudflare Dashboard
# R2 > Purchase R2 (it's free)
# Run script again
```

### "Wrangler not logged in"

```bash
npx wrangler logout
npx wrangler login
# Run script again
```

### "GitHub CLI not authenticated"

```bash
gh auth login
# Follow prompts
# Run script again
```

### "Music generation failed"

Check:
- OpenAI API key valid and has credits
- Replicate API key valid
- Supabase database schema created
- All environment variables set

### "Audio not playing"

Check:
- R2 binding configured (MUSIC_BUCKET)
- Files uploaded to R2: `npx wrangler r2 object list --bucket=youtunes-music`
- Browser console for errors

---

## Manual Alternative

If script doesn't work, follow these guides:

1. **DEPLOY-LIVE.md** - Complete manual guide
2. **QUICKSTART.md** - Quick reference
3. **README.md** - Project overview

---

## Verify Everything Works

### 1. Check Site

```bash
# Visit your site
open https://youtunes-lol.pages.dev
# or
open https://youtunes.lol
```

Should see:
- ProductHunt-style landing page
- Generated tracks (after first run)
- Working audio player

### 2. Check API

```bash
curl https://youtunes-lol.pages.dev/api/tracks
# Should return JSON with tracks
```

### 3. Check R2

```bash
npx wrangler r2 object list --bucket=youtunes-music
# Should list uploaded MP3 files
```

### 4. Check Database

Go to Supabase:
- Table Editor > tracks
- Should see generated tracks

### 5. Check Automation

GitHub > Actions:
- Should see scheduled workflow
- Next run: 2 AM UTC

---

## What's Automated

✅ **Daily Music Generation** (2 AM UTC)
- Fetch trending videos
- Generate music with AI
- Upload to R2
- Update database
- Log to Discord

✅ **Deployments**
- Every git push
- Automatic via GitHub Actions
- Live in ~30 seconds

✅ **Monitoring**
- Discord notifications
- Cloudflare analytics
- Supabase logs

✅ **Storage**
- R2 for music files
- CDN delivery
- Automatic caching

---

## Cost

After setup, costs are:

- **Free**: Cloudflare Pages, R2 (10GB), Supabase (500MB), GitHub
- **Paid**: Replicate (~$8-12/mo), OpenAI (~$3-5/mo)
- **Domain**: $10-15/year (one-time)

**Total: ~$12-18/month**

---

## Support

If you need help:

1. Check Discord logs first
2. Review Cloudflare deployment logs
3. Check Supabase logs
4. Verify all environment variables
5. Re-run setup script

---

## Success!

Once setup completes, your site will:

🎵 **Generate unique music daily**
☁️ **Store in Cloudflare R2**
🌐 **Serve globally via CDN**
📢 **Log everything to Discord**
🚀 **Update automatically**
🔍 **Rank for "free music for youtube"**

**Your AI music platform is live and fully automated!** 🎉

Check Discord for the first generation logs!
