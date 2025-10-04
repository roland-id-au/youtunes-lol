#!/bin/bash

# YouTunes - Complete Setup Helper
# Run this after enabling R2 in Cloudflare Dashboard

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "════════════════════════════════════════════════════════"
echo "  🎵 YouTunes - Complete Setup"
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""

# Step 1: Check R2
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 1: Enable R2${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Have you enabled R2 in Cloudflare Dashboard?"
echo "  → https://dash.cloudflare.com/c6e610a42f1f261bb8e487c8ff6036e4/r2"
echo ""
read -p "Press enter after enabling R2..."
echo ""

# Step 2: Create R2 bucket
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 2: Create R2 Bucket${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if npx wrangler r2 bucket create youtunes-music; then
    echo -e "${GREEN}✅ R2 bucket created${NC}"
else
    echo -e "${YELLOW}⚠️  Bucket might already exist${NC}"
fi
echo ""

# Step 3: Collect API Keys
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 3: API Keys${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Get your API keys ready:"
echo ""
echo "  1. Supabase: https://supabase.com"
echo "  2. YouTube: https://console.cloud.google.com"
echo "  3. Replicate: https://replicate.com/account"
echo "  4. OpenAI: https://platform.openai.com/api-keys"
echo ""
read -p "Press enter when ready..."
echo ""

# Collect credentials
echo -e "${YELLOW}Enter your API keys:${NC}"
echo ""

read -p "Supabase URL: " SUPABASE_URL
read -p "Supabase Anon Key: " SUPABASE_ANON_KEY
read -sp "Supabase Service Key: " SUPABASE_SERVICE_KEY
echo ""
read -p "YouTube API Key: " YOUTUBE_API_KEY
read -p "Replicate API Key: " REPLICATE_API_KEY
read -sp "OpenAI API Key: " OPENAI_API_KEY
echo ""
echo ""

# Generate CRON_SECRET
CRON_SECRET=$(openssl rand -hex 32)
echo -e "${GREEN}Generated CRON_SECRET: $CRON_SECRET${NC}"
echo ""

# Discord webhook
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1424056962345205840/W_g9dRJL3piScsAULxhrgW-xU9f9MHXDmZ48LDe7CvviFRusjNZo21U-5Zo4i5yq1jUV"

# Step 4: Add to Cloudflare
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 4: Configure Cloudflare Environment Variables${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Adding environment variables to Cloudflare Pages..."
echo ""

echo "$SUPABASE_URL" | npx wrangler pages secret put SUPABASE_URL --project-name=youtunes-lol
echo "$SUPABASE_ANON_KEY" | npx wrangler pages secret put SUPABASE_ANON_KEY --project-name=youtunes-lol
echo "$SUPABASE_SERVICE_KEY" | npx wrangler pages secret put SUPABASE_SERVICE_KEY --project-name=youtunes-lol
echo "$YOUTUBE_API_KEY" | npx wrangler pages secret put YOUTUBE_API_KEY --project-name=youtunes-lol
echo "$REPLICATE_API_KEY" | npx wrangler pages secret put REPLICATE_API_KEY --project-name=youtunes-lol
echo "$OPENAI_API_KEY" | npx wrangler pages secret put OPENAI_API_KEY --project-name=youtunes-lol
echo "$DISCORD_WEBHOOK_URL" | npx wrangler pages secret put DISCORD_WEBHOOK_URL --project-name=youtunes-lol
echo "$CRON_SECRET" | npx wrangler pages secret put CRON_SECRET --project-name=youtunes-lol

echo ""
echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Step 5: R2 Binding
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 5: Configure R2 Binding${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}⚠️  Manual step required:${NC}"
echo ""
echo "  1. Go to: https://dash.cloudflare.com"
echo "  2. Pages > youtunes-lol > Settings > Functions"
echo "  3. Scroll to 'R2 bucket bindings'"
echo "  4. Click 'Add binding'"
echo "     - Variable name: MUSIC_BUCKET"
echo "     - R2 bucket: youtunes-music"
echo "  5. Click 'Save'"
echo ""
read -p "Press enter after adding R2 binding..."

# Step 6: GitHub Secrets
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 6: GitHub Actions${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Re-authenticating GitHub with workflow scope..."
gh auth login --scopes workflow

echo ""
echo "Getting Cloudflare Account ID..."
CF_ACCOUNT_ID=$(npx wrangler whoami | grep "Account ID" | awk '{print $3}' || echo "")

echo ""
echo -e "${YELLOW}Create Cloudflare API Token:${NC}"
echo "  1. Go to: https://dash.cloudflare.com/profile/api-tokens"
echo "  2. Create Token > Edit Cloudflare Workers"
echo "  3. Copy the token"
echo ""
read -sp "Paste Cloudflare API Token: " CF_API_TOKEN
echo ""
echo ""

echo "Adding GitHub secrets..."
gh secret set CLOUDFLARE_API_TOKEN -b"$CF_API_TOKEN"
gh secret set CLOUDFLARE_ACCOUNT_ID -b"$CF_ACCOUNT_ID"
gh secret set CRON_SECRET -b"$CRON_SECRET"

echo ""
echo -e "${GREEN}✅ GitHub secrets configured${NC}"
echo ""

# Step 7: Uncomment R2 bindings
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 7: Enable R2 in wrangler.toml${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Updating wrangler.toml to enable R2 bindings..."

# Uncomment R2 bindings
sed -i '' 's/# \(\[\[r2_buckets\]\]\)/\1/g' wrangler.toml
sed -i '' 's/# \(binding = "MUSIC_BUCKET"\)/\1/g' wrangler.toml
sed -i '' 's/# \(bucket_name = "youtunes-music\)/\1/g' wrangler.toml
sed -i '' 's/# \(\[\[env\.production\.r2_buckets\]\]\)/\1/g' wrangler.toml
sed -i '' 's/# \(\[\[env\.preview\.r2_buckets\]\]\)/\1/g' wrangler.toml

echo -e "${GREEN}✅ R2 bindings enabled${NC}"
echo ""

# Step 8: Redeploy
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 8: Redeploy with R2${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Committing changes and pushing to GitHub..."
git add wrangler.toml
git commit -m "Enable R2 bindings"
git push origin main

echo ""
echo "Redeploying to Cloudflare Pages with R2 enabled..."
npx wrangler pages deploy public --project-name=youtunes-lol --commit-dirty=true

echo ""
echo -e "${GREEN}✅ Redeployed with R2 support${NC}"
echo ""

# Step 9: Test
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Step 9: Test & Trigger First Generation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Testing API endpoint..."
sleep 2
curl -s "https://youtunes-lol.pages.dev/api/tracks" | head -20

echo ""
echo ""
echo "Triggering first music generation..."
echo "Check your Discord for live logs!"
echo ""

curl -X POST "https://youtunes-lol.pages.dev/api/cron-trigger" \
  -H "Authorization: Bearer $CRON_SECRET" \
  -H "Content-Type: application/json"

echo ""
echo ""

# Summary
echo -e "${GREEN}"
echo "════════════════════════════════════════════════════════"
echo "  ✅ YouTunes Setup Complete!"
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo -e "${GREEN}🎉 Your site is live!${NC}"
echo ""
echo "  📍 URL: https://youtunes-lol.pages.dev"
echo "  🔗 Custom domain: youtunes.lol (configure manually)"
echo "  📊 GitHub: https://github.com/roland-id-au/youtunes-lol"
echo ""
echo -e "${BLUE}What happens next:${NC}"
echo ""
echo "  ✨ Music generation running now (check Discord!)"
echo "  ✨ Site updates automatically daily at 2 AM UTC"
echo "  ✨ GitHub Actions deploys on every push"
echo "  ✨ Discord logs all activity"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "  1. Wait for first generation to complete (~5-10 min)"
echo "  2. Visit your site and test audio playback"
echo "  3. Configure custom domain: youtunes.lol"
echo "  4. Monitor Discord for daily logs"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
