# 🚀 YouTunes Quick Start

**Get your AI music site live in 30 minutes!**

## 📍 Current Status

✅ **Code Complete** - All 22 files ready
✅ **Discord Connected** - Webhook tested and working
✅ **Git Initialized** - Ready to push
✅ **Design Complete** - ProductHunt-style single page

## ⚡ 30-Minute Deploy

### 1. Supabase Setup (5 min)
```bash
# Visit: https://supabase.com
# Create project > Run supabase-schema.sql in SQL Editor
# Copy: URL, anon_key, service_role_key
```

### 2. Get API Keys (5 min)
- **YouTube**: https://console.cloud.google.com → Enable YouTube Data API v3
- **Replicate**: https://replicate.com/account → Copy token
- **OpenAI**: https://platform.openai.com/api-keys → Create key

### 3. Deploy (10 min)
```bash
# Option A: Automated
./deploy.sh

# Option B: Manual
gh repo create youtunes-lol --public --source=. --push
# Then connect at: https://dash.cloudflare.com > Pages
```

### 4. Configure (5 min)
Add these environment variables in Cloudflare Pages settings:
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_KEY=...
YOUTUBE_API_KEY=...
REPLICATE_API_KEY=...
OPENAI_API_KEY=...
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/1424056962345205840/...
CRON_SECRET=$(openssl rand -hex 32)
```

### 5. Test (5 min)
```bash
# Visit your site
open https://YOUR-SITE.pages.dev

# Trigger music generation
curl -X POST https://YOUR-SITE.pages.dev/api/cron-trigger \
  -H "Authorization: Bearer YOUR_CRON_SECRET"

# Watch Discord for live logs! 🎉
```

## 📚 Detailed Guide

See **DEPLOY.md** for complete step-by-step instructions.

## 🆘 Need Help?

1. Check **DEPLOY.md** troubleshooting section
2. Review Discord webhook logs
3. Check Cloudflare Pages deployment logs
4. Verify all environment variables are set

## 💰 Costs

- Domain: $10-15/year
- Hosting: Free (Cloudflare Pages)
- Database: Free (Supabase 500MB)
- APIs: ~$12-18/month (5 tracks/day)

## 🎯 What You Get

- ✨ Beautiful single-page site at youtunes.lol
- 🤖 AI-generated music from trending YouTube videos
- 📊 Automatic daily updates at 2 AM UTC
- 📢 Discord notifications for all activity
- 🔍 SEO optimized for "free music for youtube"
- 📱 Fully responsive mobile design
- 🚀 ProductHunt-ready design

**Ready to launch?** Run `./deploy.sh` or follow **DEPLOY.md**!
