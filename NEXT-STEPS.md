# 🚀 YouTunes - Next Steps to Complete Deployment

Your site is live at: **https://3176a1d8.youtunes-lol.pages.dev**

GitHub repo: **https://github.com/roland-id-au/youtunes-lol**

---

## ✅ What's Done

- ✅ Code pushed to GitHub
- ✅ Deployed to Cloudflare Pages
- ✅ Site is live (frontend only)
- ✅ Project structure ready

---

## 🔧 Required Steps to Complete

### 1. Enable Cloudflare R2 (2 minutes)

R2 must be enabled before music storage will work:

1. Go to: https://dash.cloudflare.com/c6e610a42f1f261bb8e487c8ff6036e4/r2
2. Click **"Purchase R2"**
3. Accept terms (it's **FREE** up to 10GB)
4. Click **"Enable R2"**

### 2. Create R2 Bucket (1 minute)

Once R2 is enabled, run:

```bash
cd /Users/blake/Projects/youtunes_lol
npx wrangler r2 bucket create youtunes-music
```

### 3. Uncomment R2 Bindings in wrangler.toml

Edit `wrangler.toml` and uncomment the R2 sections (lines 6-8, 16-18, 23-25):

```toml
# Change this:
# [[r2_buckets]]
# binding = "MUSIC_BUCKET"
# bucket_name = "youtunes-music"

# To this:
[[r2_buckets]]
binding = "MUSIC_BUCKET"
bucket_name = "youtunes-music"
```

### 4. Configure R2 Binding in Cloudflare Dashboard (2 minutes)

1. Go to: https://dash.cloudflare.com → **Pages** → **youtunes-lol** → **Settings** → **Functions**
2. Scroll to **"R2 bucket bindings"**
3. Click **"Add binding"**
4. Set:
   - Variable name: `MUSIC_BUCKET`
   - R2 bucket: `youtunes-music`
5. Click **"Save"**

### 5. Set Up Supabase (5 minutes)

1. Go to: https://supabase.com
2. Create new project
3. Go to **SQL Editor**
4. Copy contents of `supabase-schema.sql`
5. Paste and run
6. Go to **Settings** → **API**
7. Copy:
   - Project URL
   - `anon` public key
   - `service_role` key

### 6. Get API Keys (10 minutes)

#### YouTube Data API
1. Go to: https://console.cloud.google.com
2. Create/select project
3. Enable **"YouTube Data API v3"**
4. **Credentials** → **Create Credentials** → **API Key**
5. Copy key

#### Replicate
1. Go to: https://replicate.com
2. Sign up/login
3. **Account settings** → **API tokens**
4. Copy token

#### OpenAI
1. Go to: https://platform.openai.com
2. Add payment method (required)
3. **API keys** → **Create new secret key**
4. Copy key (starts with `sk-`)

### 7. Add Environment Variables to Cloudflare (3 minutes)

Run these commands with your API keys:

```bash
cd /Users/blake/Projects/youtunes_lol

# Supabase
echo "YOUR_SUPABASE_URL" | npx wrangler pages secret put SUPABASE_URL --project-name=youtunes-lol
echo "YOUR_SUPABASE_ANON_KEY" | npx wrangler pages secret put SUPABASE_ANON_KEY --project-name=youtunes-lol
echo "YOUR_SUPABASE_SERVICE_KEY" | npx wrangler pages secret put SUPABASE_SERVICE_KEY --project-name=youtunes-lol

# API Keys
echo "YOUR_YOUTUBE_API_KEY" | npx wrangler pages secret put YOUTUBE_API_KEY --project-name=youtunes-lol
echo "YOUR_REPLICATE_API_KEY" | npx wrangler pages secret put REPLICATE_API_KEY --project-name=youtunes-lol
echo "YOUR_OPENAI_API_KEY" | npx wrangler pages secret put OPENAI_API_KEY --project-name=youtunes-lol

# Discord (already set)
echo "https://discord.com/api/webhooks/1424056962345205840/W_g9dRJL3piScsAULxhrgW-xU9f9MHXDmZ48LDe7CvviFRusjNZo21U-5Zo4i5yq1jUV" | npx wrangler pages secret put DISCORD_WEBHOOK_URL --project-name=youtunes-lol

# Generate and set CRON_SECRET
CRON_SECRET=$(openssl rand -hex 32)
echo $CRON_SECRET | npx wrangler pages secret put CRON_SECRET --project-name=youtunes-lol
echo "Save this CRON_SECRET for GitHub: $CRON_SECRET"
```

### 8. Set Up GitHub Actions (5 minutes)

Add secrets to GitHub:

```bash
# Re-authenticate with workflow scope
gh auth login --scopes workflow

# Get Cloudflare Account ID
CF_ACCOUNT_ID=$(npx wrangler whoami | grep "Account ID" | awk '{print $3}')

# Create Cloudflare API Token
# Go to: https://dash.cloudflare.com/profile/api-tokens
# Create Token → Edit Cloudflare Workers
# Copy the token, then run:

gh secret set CLOUDFLARE_API_TOKEN -b"YOUR_CF_API_TOKEN"
gh secret set CLOUDFLARE_ACCOUNT_ID -b"$CF_ACCOUNT_ID"
gh secret set CRON_SECRET -b"YOUR_CRON_SECRET_FROM_STEP_7"
```

Then push the workflow:

```bash
git push origin main
```

### 9. Add Custom Domain (5 minutes)

1. Go to: https://dash.cloudflare.com → **Pages** → **youtunes-lol** → **Custom domains**
2. Click **"Set up a custom domain"**
3. Enter: `youtunes.lol`
4. Follow DNS instructions
5. Wait 5-10 minutes for SSL

### 10. Test & Trigger First Generation

Once all environment variables are set:

```bash
# Test API endpoint
curl https://youtunes-lol.pages.dev/api/tracks

# Manually trigger first generation
# (Replace with your CRON_SECRET from step 7)
curl -X POST "https://youtunes-lol.pages.dev/api/cron-trigger" \
  -H "Authorization: Bearer YOUR_CRON_SECRET" \
  -H "Content-Type: application/json"
```

Check Discord for live logs!

---

## 🎯 After Completion

Your site will automatically:

- **Daily at 2 AM UTC**: Generate 5 new music tracks from trending YouTube videos
- **Log to Discord**: Real-time updates on generation progress
- **Update website**: New tracks appear automatically
- **Store in R2**: Music files served from Cloudflare CDN

---

## 📊 What You'll See in Discord

```
🚀 Starting daily music generation
📊 Found 20 trending videos
Processing top 5...

🎬 Processing: "Video Title"
🎼 Generating music metadata with AI...
✅ Created track: "Chill Vibes"
🎵 Generating AI music...
✨ Music generated! Uploading to R2...
☁️ Uploaded to R2 storage!
💾 Saved to database

[... repeats for each video ...]

✅ Generation Complete!
📊 Processed: 5/20 videos
🎵 New tracks: 5
⏰ Next run: Tomorrow at 2 AM UTC
```

---

## 🆘 Troubleshooting

**"R2 not enabled"**
→ Complete Step 1 above

**"Bucket not found"**
→ Complete Steps 2-4 above

**"Music generation failed"**
→ Check all environment variables are set (Step 7)

**"Audio not playing"**
→ Verify R2 binding is configured (Step 4)

---

## 📚 Documentation

- **DEPLOY-LIVE.md** - Full deployment guide
- **AUTO-SETUP.md** - Automated setup (requires API keys)
- **README.md** - Project overview

---

**Total Time to Complete: ~30 minutes**

**Monthly Cost: $12-18** (Replicate + OpenAI only)
