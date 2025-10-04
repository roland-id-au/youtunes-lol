# 🚀 YouTunes Deployment Guide

Complete step-by-step guide to deploy YouTunes to youtunes.lol with automatic music generation.

## ✅ What's Already Done

- ✅ Code complete and committed to Git
- ✅ Discord webhook integrated and tested
- ✅ Single-page ProductHunt-style design
- ✅ Supabase schema ready
- ✅ GitHub Actions workflow configured
- ✅ SEO optimized for "free music for youtube"

## 📋 Prerequisites

You'll need accounts for:
1. **Cloudflare** (free) - For hosting
2. **Supabase** (free tier) - For database
3. **YouTube Data API** (free) - For trending videos
4. **Replicate** (~$5-10/month) - For AI music generation
5. **OpenAI** (~$5/month) - For music metadata
6. **GitHub** (free) - For automatic deployments

## 🎯 Deployment Steps

### Step 1: Create Supabase Project (5 minutes)

1. Go to https://supabase.com and sign up/login
2. Click "New Project"
   - **Name**: youtunes
   - **Database Password**: (generate secure password - save this!)
   - **Region**: Choose closest to you
   - Click "Create new project"

3. Wait 2-3 minutes for provisioning

4. **Run Database Schema**:
   - Go to SQL Editor (left sidebar)
   - Click "New query"
   - Copy entire contents of `supabase-schema.sql`
   - Paste and click "Run"
   - Should see "Success. No rows returned"

5. **Get API Credentials**:
   - Go to Settings > API
   - Copy these values (you'll need them):
     - **Project URL**: `https://xxx.supabase.co`
     - **anon/public key**: `eyJhbGc...`
     - **service_role key**: `eyJhbGc...` (click "Reveal" first)

### Step 2: Get API Keys (10 minutes)

#### YouTube Data API:
1. Go to https://console.cloud.google.com
2. Create new project or select existing
3. Enable "YouTube Data API v3"
4. Create credentials > API Key
5. Copy API key

#### Replicate API:
1. Go to https://replicate.com
2. Sign up/login
3. Go to account settings
4. Copy API token

#### OpenAI API:
1. Go to https://platform.openai.com
2. Create account / login
3. Add payment method (required)
4. Go to API keys
5. Create new secret key
6. Copy key (starts with sk-)

### Step 3: Deploy to Cloudflare Pages (10 minutes)

#### Option A: Via GitHub (Recommended)

1. **Push to GitHub**:
   ```bash
   cd /Users/blake/Projects/youtunes_lol
   gh repo create youtunes-lol --public --source=. --remote=origin
   git push -u origin main
   ```

2. **Connect to Cloudflare Pages**:
   - Go to https://dash.cloudflare.com
   - Pages > Create a project
   - Connect to Git > Select your GitHub repo
   - **Build settings**:
     - Framework preset: None
     - Build command: (leave empty)
     - Build output directory: `public`
   - Click "Save and Deploy"

3. **Add Environment Variables**:
   - Go to Pages > youtunes-lol > Settings > Environment variables
   - Add ALL of these (Production & Preview):
     ```
     SUPABASE_URL = (from Step 1)
     SUPABASE_ANON_KEY = (from Step 1)
     SUPABASE_SERVICE_KEY = (from Step 1)
     YOUTUBE_API_KEY = (from Step 2)
     REPLICATE_API_KEY = (from Step 2)
     OPENAI_API_KEY = (from Step 2)
     DISCORD_WEBHOOK_URL = https://discord.com/api/webhooks/1424056962345205840/W_g9dRJL3piScsAULxhrgW-xU9f9MHXDmZ48LDe7CvviFRusjNZo21U-5Zo4i5yq1jUV
     CRON_SECRET = (generate random 32-char string)
     ```

   Generate CRON_SECRET:
   ```bash
   openssl rand -hex 32
   ```

#### Option B: Via Wrangler CLI

```bash
# Login to Cloudflare
npx wrangler login

# Deploy
npx wrangler pages deploy public --project-name=youtunes-lol

# Add environment variables (one by one)
npx wrangler pages secret put SUPABASE_URL --project-name=youtunes-lol
npx wrangler pages secret put SUPABASE_ANON_KEY --project-name=youtunes-lol
# ... repeat for all vars above
```

### Step 4: Configure Custom Domain (5 minutes)

1. **Register Domain** (if you haven't):
   - Go to Cloudflare Registrar or Namecheap
   - Search for `youtunes.lol`
   - Purchase (~$10-15/year)

2. **Add to Cloudflare Pages**:
   - Pages > youtunes-lol > Custom domains
   - Click "Set up a custom domain"
   - Enter: `youtunes.lol`
   - Cloudflare will auto-configure DNS
   - Also add `www.youtunes.lol` (optional)

3. **Wait for SSL** (5-10 minutes):
   - SSL certificate will provision automatically
   - Check status in Custom domains tab

### Step 5: Set Up GitHub Actions (5 minutes)

1. **Add GitHub Secrets**:
   - Go to your GitHub repo
   - Settings > Secrets and variables > Actions
   - Add these secrets:
     ```
     CLOUDFLARE_API_TOKEN = (create at Cloudflare dashboard)
     CLOUDFLARE_ACCOUNT_ID = (find in Cloudflare dashboard)
     CRON_SECRET = (same as Step 3)
     ```

2. **Create Cloudflare API Token**:
   - Cloudflare Dashboard > My Profile > API Tokens
   - Create Token > "Edit Cloudflare Workers"
   - Or use custom with:
     - Permissions: Cloudflare Pages - Edit
     - Account Resources: Include - Your Account
   - Copy token

3. **Get Account ID**:
   - Cloudflare Dashboard > Pages
   - Right sidebar shows "Account ID"

4. **Test GitHub Actions**:
   ```bash
   git commit --allow-empty -m "Test deployment"
   git push
   ```
   - Check Actions tab in GitHub
   - Should deploy successfully

### Step 6: Test Everything (10 minutes)

1. **Visit your site**: https://youtunes.lol
   - Should see ProductHunt-style landing page
   - No tracks yet (database is empty)

2. **Test API Endpoint**:
   ```bash
   curl https://youtunes.lol/api/tracks
   ```
   Should return: `{"tracks":[],"stats":{...}}`

3. **Trigger Manual Music Generation**:
   ```bash
   curl -X POST https://youtunes.lol/api/cron-trigger \
     -H "Authorization: Bearer YOUR_CRON_SECRET" \
     -H "Content-Type: application/json"
   ```

4. **Watch Discord**:
   - Check your Discord webhook channel
   - Should see real-time logs:
     - 🚀 Starting generation
     - 📊 Found X videos
     - 🎬 Processing each video
     - 🎵 Generating music
     - ✅ Complete!

5. **Check Database**:
   - Go to Supabase > Table Editor
   - Should see new rows in `videos` and `tracks` tables

6. **Refresh Website**:
   - Visit https://youtunes.lol
   - Should see generated tracks!

### Step 7: Verify Daily Automation (1 minute)

The GitHub Action is set to run daily at 2 AM UTC:

```yaml
schedule:
  - cron: '0 2 * * *'
```

To test it now:
- Go to GitHub > Actions
- Select "Deploy to Cloudflare Pages" workflow
- Click "Run workflow" > "Run workflow"
- Watch the logs

## 🎉 You're Live!

Your site should now be:
- ✅ Live at https://youtunes.lol
- ✅ Generating music daily at 2 AM UTC
- ✅ Logging to Discord
- ✅ Updating automatically via GitHub Actions

## 📊 Monitoring

### Discord Logs
Check your webhook channel for:
- Daily generation summaries
- Real-time progress updates
- Error notifications

### Cloudflare Analytics
- Pages > youtunes-lol > Analytics
- See traffic, requests, bandwidth

### Supabase Dashboard
- Table Editor: View all tracks/videos
- Logs: See database queries
- API: Monitor usage

### GitHub Actions
- Actions tab: See deployment history
- Set up notifications for failures

## 🐛 Troubleshooting

### "Site not loading"
- Check Cloudflare Pages deployment logs
- Verify DNS is pointing correctly (dnschecker.org)
- Wait 5-10 minutes for DNS propagation

### "No tracks appearing"
- Check Supabase has data: Table Editor > tracks
- Run manual cron trigger (Step 6.3)
- Check Discord logs for errors
- Verify all API keys are correct

### "Music generation failing"
- Check Replicate API credits/limits
- Verify OpenAI API key is valid and has credits
- Check Discord logs for specific error

### "CORS errors"
- Check `_headers` file is deployed
- Verify Cloudflare Pages build included `public/` dir

### "GitHub Actions not running"
- Verify all secrets are added
- Check workflow file syntax
- Look at Actions > failed run > logs

## 💰 Cost Breakdown

### Monthly Costs:
- **Domain**: $1/month (paid yearly)
- **Cloudflare Pages**: $0 (free tier)
- **Supabase**: $0 (free tier, 500MB)
- **YouTube API**: $0 (free, 10K quota/day)
- **Replicate**: ~$8-12 (5 tracks/day @ $0.05/track)
- **OpenAI**: ~$3-5 (GPT-4 for metadata)
- **Discord**: $0 (free webhook)

**Total**: ~$12-18/month

### Cost Optimization:
- Use GPT-3.5-turbo instead of GPT-4: saves $3/month
- Process 3 videos/day instead of 5: saves $4/month
- Cache existing tracks: reduce Replicate calls

## 🔧 Optional Enhancements

### 1. Email Notifications
Add to `functions/_worker.js`:
```javascript
// Send email via Resend, SendGrid, etc.
```

### 2. Social Media Auto-Post
Share new tracks to Twitter automatically

### 3. Analytics Integration
Add Google Analytics or Plausible

### 4. Search Functionality
Add genre filtering to track browser

### 5. User Accounts
Let users save favorites (requires auth)

## 📞 Support

If you run into issues:
1. Check Discord logs first
2. Review Cloudflare Pages deployment logs
3. Check Supabase logs
4. Verify all environment variables
5. Test API endpoints manually

## 🎊 Next Steps

1. Submit to ProductHunt
2. Share on social media
3. Add to creator tool directories
4. Set up analytics tracking
5. Monitor costs and optimize
6. Add more features based on usage

---

**Congratulations! YouTunes is now live at https://youtunes.lol 🎉**

Check Discord for daily generation logs and enjoy your free, AI-generated music for YouTube!
