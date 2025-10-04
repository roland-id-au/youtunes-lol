# 🔑 API Keys Setup for YouTunes

Your new minimal design is live at: **https://d854ca06.youtunes-lol.pages.dev**

To complete the automated daily music generation, you need to add API keys.

---

## Required API Keys

### 1. **YouTube Data API v3** (FREE)
For discovering trending videos

**Get it:**
1. Go to: https://console.cloud.google.com
2. Create new project (or select existing)
3. **APIs & Services** → **Enable APIs**
4. Search "YouTube Data API v3" → **Enable**
5. **Credentials** → **Create Credentials** → **API Key**
6. Copy the key

**Cost:** FREE (10,000 quota units/day = ~3,000 videos/day)

---

### 2. **Replicate API** ($8-12/month)
For AI music generation

**Get it:**
1. Go to: https://replicate.com
2. Sign up (GitHub login works)
3. **Account** → **API tokens**
4. Copy your API token

**Cost:** ~$0.05 per track × 5 tracks/day = $7.50/month

---

### 3. **OpenAI API** ($3-5/month)
For generating music metadata (title, genre, mood)

**Get it:**
1. Go to: https://platform.openai.com
2. Sign up
3. **Billing** → Add payment method (required)
4. **API keys** → **Create new secret key**
5. Copy key (starts with `sk-`)

**Cost:** GPT-4 usage ~$0.01 per track × 5 tracks/day = $1.50/month

---

### 4. **Supabase** (FREE)
For database

**Set it up:**
1. Go to: https://supabase.com
2. Create new project
3. **SQL Editor** → Run this schema:
   ```sql
   -- Copy contents from supabase-schema.sql
   ```
4. **Settings** → **API**
5. Copy:
   - **Project URL** (e.g., `https://xxx.supabase.co`)
   - **anon/public** key (starts with `eyJ...`)
   - **service_role** key (starts with `eyJ...`)

**Cost:** FREE (500MB database, 2GB bandwidth)

---

## Add Keys to Cloudflare Pages

Once you have all API keys, run these commands:

```bash
cd /Users/blake/Projects/youtunes_lol

# Supabase
echo "YOUR_SUPABASE_URL" | npx wrangler pages secret put SUPABASE_URL --project-name=youtunes-lol
echo "YOUR_SUPABASE_ANON_KEY" | npx wrangler pages secret put SUPABASE_ANON_KEY --project-name=youtunes-lol
echo "YOUR_SUPABASE_SERVICE_KEY" | npx wrangler pages secret put SUPABASE_SERVICE_KEY --project-name=youtunes-lol

# YouTube
echo "YOUR_YOUTUBE_API_KEY" | npx wrangler pages secret put YOUTUBE_API_KEY --project-name=youtunes-lol

# Replicate
echo "YOUR_REPLICATE_API_KEY" | npx wrangler pages secret put REPLICATE_API_KEY --project-name=youtunes-lol

# OpenAI
echo "YOUR_OPENAI_API_KEY" | npx wrangler pages secret put OPENAI_API_KEY --project-name=youtunes-lol

# Discord (already set)
echo "https://discord.com/api/webhooks/1424056962345205840/W_g9dRJL3piScsAULxhrgW-xU9f9MHXDmZ48LDe7CvviFRusjNZo21U-5Zo4i5yq1jUV" | npx wrangler pages secret put DISCORD_WEBHOOK_URL --project-name=youtunes-lol

# Generate CRON_SECRET (save this!)
CRON_SECRET=$(openssl rand -hex 32)
echo "Your CRON_SECRET: $CRON_SECRET"
echo $CRON_SECRET | npx wrangler pages secret put CRON_SECRET --project-name=youtunes-lol
```

---

## Configure R2 Binding (REQUIRED)

The R2 bucket exists but needs to be bound to your Pages project:

1. Go to: https://dash.cloudflare.com
2. **Pages** → **youtunes-lol** → **Settings** → **Functions**
3. Scroll to **R2 bucket bindings**
4. Click **Add binding**
   - Variable name: `MUSIC_BUCKET`
   - R2 bucket: `youtunes-music`
5. Click **Save**

---

## Set Up GitHub Actions (for daily automation)

Add secrets to GitHub for the daily cron job:

```bash
# Re-authenticate with workflow scope
gh auth login --scopes workflow

# Get Cloudflare Account ID
CF_ACCOUNT_ID=$(npx wrangler whoami | grep "Account ID" | awk '{print $3}')

# Create Cloudflare API Token at:
# https://dash.cloudflare.com/profile/api-tokens
# Template: "Edit Cloudflare Workers"
# Then run:

gh secret set CLOUDFLARE_API_TOKEN -b"YOUR_CF_API_TOKEN"
gh secret set CLOUDFLARE_ACCOUNT_ID -b"$CF_ACCOUNT_ID"
gh secret set CRON_SECRET -b"YOUR_CRON_SECRET_FROM_ABOVE"
```

---

## Test Manual Generation

Once all keys are set, test the generation:

```bash
# Trigger manual generation (replace with your CRON_SECRET)
curl -X POST "https://youtunes-lol.pages.dev/api/cron-trigger" \
  -H "Authorization: Bearer YOUR_CRON_SECRET" \
  -H "Content-Type: application/json"
```

Check Discord for live logs!

---

## Automated Schedule

Once GitHub Actions is configured, the system will:

- **Every day at 2 AM UTC:**
  1. Fetch top 5 trending YouTube videos
  2. Generate music metadata with OpenAI
  3. Generate audio with Replicate
  4. Upload to R2
  5. Save to Supabase
  6. Log progress to Discord
  7. Website automatically updates

---

## Monthly Costs

- YouTube API: **$0** (free tier)
- Supabase: **$0** (free tier)
- Cloudflare Pages: **$0** (free tier)
- Cloudflare R2: **$0** (first 10GB free)
- Replicate: **~$8-12** (5 tracks/day)
- OpenAI: **~$3-5** (GPT-4 usage)

**Total: ~$12-18/month**

---

## Verify Everything Works

1. **Check site:** https://youtunes-lol.pages.dev (should show new design)
2. **Add R2 binding** (required for audio to work)
3. **Add all API keys** (see above)
4. **Trigger test generation** (see above)
5. **Watch Discord** for live logs
6. **Check database** in Supabase for new tracks
7. **Verify audio plays** on website

---

## Next Steps

1. ✅ R2 enabled
2. ✅ R2 bucket created
3. ✅ Site deployed with new design
4. ⏳ Configure R2 binding (manual step above)
5. ⏳ Get API keys (links above)
6. ⏳ Add keys to Cloudflare (commands above)
7. ⏳ Set up GitHub Actions (commands above)
8. ⏳ Test first generation
9. ⏳ Add custom domain youtunes.lol

Once complete, your site will automatically generate 5 new tracks every day!
