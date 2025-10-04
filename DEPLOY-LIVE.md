# 🚀 Live Deployment to youtunes.lol

**Complete deployment to Cloudflare Pages + Vercel with R2 storage**

## Status

✅ Code complete with R2 integration
✅ Discord webhook tested
✅ Multi-platform deployment ready (Cloudflare + Vercel)
✅ Live audio player configured
✅ Domain ready: youtunes.lol

## Quick Deploy (Choose One Platform)

### Option A: Cloudflare Pages (Recommended)

**Why:** Free R2 storage, edge CDN, integrated functions

```bash
# 1. Enable R2 in Cloudflare Dashboard
# Visit: https://dash.cloudflare.com > R2
# Click "Purchase" (it's free up to 10GB)

# 2. Create R2 bucket
npx wrangler login
npx wrangler r2 bucket create youtunes-music

# 3. Create Supabase project and get keys
# Visit: https://supabase.com
# Run: supabase-schema.sql

# 4. Deploy to Cloudflare Pages
npx wrangler pages deploy public --project-name=youtunes-lol

# 5. Configure R2 binding
# Cloudflare Dashboard > Pages > youtunes-lol > Settings > Functions
# Add R2 bucket binding: MUSIC_BUCKET = youtunes-music

# 6. Add environment variables (see below)

# 7. Configure domain
# Pages > youtunes-lol > Custom domains > Add youtunes.lol
```

### Option B: Vercel (Static Frontend Only)

**Why:** Fast deployment, good for testing

```bash
# 1. Install Vercel CLI
npm i -g vercel

# 2. Deploy
vercel --prod

# 3. Configure domain
# Vercel Dashboard > Settings > Domains > Add youtunes.lol

# Note: Vercel proxies API calls to Cloudflare (see vercel.json)
```

## Detailed Steps - Cloudflare (Primary Deployment)

### Step 1: Enable R2 Storage (1 minute)

1. Go to https://dash.cloudflare.com
2. Click **R2** in left sidebar
3. Click **Purchase R2**
4. Accept terms (it's free!)
5. R2 is now enabled ✅

### Step 2: Create R2 Bucket (2 minutes)

```bash
# Login to Cloudflare
npx wrangler login

# Create production bucket
npx wrangler r2 bucket create youtunes-music

# Create preview bucket (optional)
npx wrangler r2 bucket create youtunes-music-preview

# Verify
npx wrangler r2 bucket list
```

### Step 3: Set Up Supabase (5 minutes)

1. Go to https://supabase.com and create project
2. Copy project details:
   - **URL**: `https://xxx.supabase.co`
   - **anon key**: `eyJhbGc...`
   - **service_role key**: `eyJhbGc...`
3. Go to SQL Editor
4. Copy contents of `supabase-schema.sql`
5. Paste and run
6. Verify tables created: `videos` and `tracks`

### Step 4: Get API Keys (10 minutes)

#### YouTube Data API
```bash
# 1. Visit: https://console.cloud.google.com
# 2. Create/select project
# 3. Enable "YouTube Data API v3"
# 4. Credentials > Create Credentials > API Key
# 5. Copy key
```

#### Replicate
```bash
# 1. Visit: https://replicate.com
# 2. Sign up / login
# 3. Go to account settings
# 4. Copy API token
```

#### OpenAI
```bash
# 1. Visit: https://platform.openai.com
# 2. Add payment method (required)
# 3. API keys > Create new secret key
# 4. Copy key (starts with sk-)
```

### Step 5: Deploy to Cloudflare Pages (5 minutes)

#### Via GitHub (Recommended)

```bash
# Push to GitHub
gh repo create youtunes-lol --public --source=. --push

# Or if repo exists
git push

# Then connect in Cloudflare Dashboard:
# 1. Pages > Create a project
# 2. Connect to Git > Select youtunes-lol
# 3. Framework: None
# 4. Build command: (leave empty)
# 5. Build output: public
# 6. Save and Deploy
```

#### Via Wrangler CLI

```bash
npx wrangler pages deploy public --project-name=youtunes-lol
```

### Step 6: Configure R2 Binding (2 minutes)

**Important:** R2 binding must be configured for music storage to work!

1. Go to Cloudflare Dashboard
2. Pages > **youtunes-lol** > Settings > **Functions**
3. Scroll to **R2 bucket bindings**
4. Click **Add binding**:
   - Variable name: `MUSIC_BUCKET`
   - R2 bucket: `youtunes-music`
5. Click **Save**

### Step 7: Add Environment Variables (3 minutes)

Pages > youtunes-lol > Settings > Environment variables

Add these for **Production** AND **Preview**:

```
SUPABASE_URL = https://xxx.supabase.co
SUPABASE_ANON_KEY = eyJhbGc...
SUPABASE_SERVICE_KEY = eyJhbGc...
YOUTUBE_API_KEY = AIza...
REPLICATE_API_KEY = r8_...
OPENAI_API_KEY = sk-...
DISCORD_WEBHOOK_URL = https://discord.com/api/webhooks/1424056962345205840/W_g9dRJL3piScsAULxhrgW-xU9f9MHXDmZ48LDe7CvviFRusjNZo21U-5Zo4i5yq1jUV
CRON_SECRET = [generate with: openssl rand -hex 32]
```

### Step 8: Configure Custom Domain (5 minutes)

1. **Buy Domain** (if needed):
   - Go to Cloudflare Registrar or Namecheap
   - Search: `youtunes.lol`
   - Purchase (~$10-15/year)

2. **Add to Cloudflare Pages**:
   - Pages > youtunes-lol > Custom domains
   - Click "Set up a custom domain"
   - Enter: `youtunes.lol`
   - Cloudflare auto-configures DNS ✅

3. **Wait for SSL** (5-10 minutes):
   - SSL certificate provisions automatically
   - Check status: Pages > Custom domains

4. **Verify**:
   ```bash
   curl https://youtunes.lol
   # Should return HTML
   ```

### Step 9: Test Everything (10 minutes)

#### Test 1: API Endpoint
```bash
curl https://youtunes.lol/api/tracks
# Should return: {"tracks":[],"stats":{...}}
```

#### Test 2: Trigger Music Generation
```bash
curl -X POST https://youtunes.lol/api/cron-trigger \
  -H "Authorization: Bearer YOUR_CRON_SECRET" \
  -H "Content-Type: application/json"
```

#### Test 3: Check Discord Logs
- Watch your Discord channel
- Should see:
  - 🚀 Starting generation
  - 📊 Found X videos
  - 🎬 Processing videos
  - 🎵 Generating music
  - ☁️ Uploaded to R2
  - ✅ Complete!

#### Test 4: Verify R2 Storage
```bash
# List files in R2 bucket
npx wrangler r2 object list --bucket=youtunes-music

# Should see: 1234567890-videoId.mp3
```

#### Test 5: Play Music on Website
1. Visit https://youtunes.lol
2. Scroll to "Browse Free Royalty-Free Music"
3. Should see generated tracks
4. Click play on audio player ▶️
5. Music should play from R2! 🎵

### Step 10: Configure GitHub Actions (5 minutes)

For automatic daily deployments:

1. Add GitHub secrets:
   - Settings > Secrets and variables > Actions
   - Add:
     ```
     CLOUDFLARE_API_TOKEN = [create at Cloudflare dashboard]
     CLOUDFLARE_ACCOUNT_ID = [find in dashboard]
     CRON_SECRET = [same as above]
     ```

2. Test workflow:
   ```bash
   git commit --allow-empty -m "Test deployment"
   git push
   ```

3. Check: GitHub > Actions tab

## Alternative: Deploy to Vercel (Static Only)

**Note:** Vercel hosts the frontend, but API calls proxy to Cloudflare.

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod

# Add domain
# Vercel Dashboard > Settings > Domains > Add youtunes.lol
```

**Pros:**
- Super fast deployment
- Great CDN
- Easy rollbacks

**Cons:**
- No serverless functions (uses Cloudflare)
- No R2 access (uses Cloudflare)
- Essentially just a frontend mirror

## Troubleshooting

### "R2 bucket not found"
```bash
# Verify bucket exists
npx wrangler r2 bucket list

# Verify binding in Cloudflare Pages > Functions > R2 bindings
```

### "Music not playing"
```bash
# Check R2 has files
npx wrangler r2 object list --bucket=youtunes-music

# Check browser console for errors
# Verify audio URL points to youtunes.lol/music/...
```

### "API returning 404"
```bash
# Verify functions deployed
# Check Cloudflare Pages > Deployments > View details

# Verify environment variables set
# Check Pages > Settings > Environment variables
```

### "No new music generated"
```bash
# Check GitHub Actions logs
# Verify CRON_SECRET is correct
# Check Discord webhook for errors
```

## Post-Deployment Checklist

- [ ] Site loads at https://youtunes.lol ✅
- [ ] SSL certificate active (green padlock) ✅
- [ ] API endpoint works (/api/tracks) ✅
- [ ] Can trigger music generation ✅
- [ ] Discord logs working ✅
- [ ] R2 bucket receiving files ✅
- [ ] Audio player works on site ✅
- [ ] GitHub Actions deploying ✅
- [ ] Domain configured ✅
- [ ] All environment variables set ✅

## Next Steps

1. **Monitor First Generation**:
   - Watch Discord for logs
   - Should complete in 5-10 minutes
   - Check R2 for uploaded files

2. **Verify Website**:
   - Visit youtunes.lol
   - See new tracks
   - Test audio playback

3. **Set Up Monitoring**:
   - Cloudflare Analytics
   - Supabase logs
   - Discord notifications

4. **Launch**:
   - Submit to ProductHunt
   - Share on social media
   - Monitor costs

## Cost Summary

### Monthly:
- Cloudflare Pages: $0 (free)
- Cloudflare R2: $0 (10GB free, ~$0.015/GB after)
- Supabase: $0 (500MB free)
- YouTube API: $0 (free quota)
- Replicate: ~$8-12 (5 tracks/day @ ~$0.05/track)
- OpenAI: ~$3-5 (GPT-4 for metadata)
- **Total: ~$12-18/month**

### Annual:
- Domain (youtunes.lol): ~$10-15/year

---

## 🎉 You're Live!

Once deployed, your site will:
- ✅ Generate 5 new tracks daily at 2 AM UTC
- ✅ Store music in Cloudflare R2
- ✅ Log everything to Discord
- ✅ Update website automatically
- ✅ Serve music via CDN at youtunes.lol

**Congratulations! Your AI music generation platform is live! 🚀**

Check Discord for your first generation logs!
