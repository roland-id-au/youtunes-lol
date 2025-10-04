#!/bin/bash

# YouTunes Automatic Deployment Setup
# This script sets up everything for automatic daily music generation

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "════════════════════════════════════════════════════════"
echo "  🎵 YouTunes - Automatic Deployment Setup"
echo "════════════════════════════════════════════════════════"
echo -e "${NC}"

# Check required tools
echo -e "${BLUE}📋 Checking requirements...${NC}"
echo ""

MISSING_TOOLS=()

if ! command -v npx &> /dev/null; then
    MISSING_TOOLS+=("npm/npx (Node.js)")
fi

if ! command -v gh &> /dev/null; then
    MISSING_TOOLS+=("gh (GitHub CLI)")
fi

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "${RED}❌ Missing required tools:${NC}"
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
    echo "Install them first:"
    echo "  brew install node gh"
    exit 1
fi

echo -e "${GREEN}✅ All required tools installed${NC}"
echo ""

# Step 1: API Keys Check
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📋 Step 1: API Keys & Credentials${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You'll need these API keys. Get them now:"
echo ""
echo "  1. Supabase:"
echo "     → https://supabase.com"
echo "     → Create project"
echo "     → Run supabase-schema.sql in SQL Editor"
echo "     → Get: URL, anon_key, service_role_key"
echo ""
echo "  2. YouTube Data API:"
echo "     → https://console.cloud.google.com"
echo "     → Enable YouTube Data API v3"
echo "     → Create API Key"
echo ""
echo "  3. Replicate:"
echo "     → https://replicate.com/account"
echo "     → Copy API token"
echo ""
echo "  4. OpenAI:"
echo "     → https://platform.openai.com/api-keys"
echo "     → Create secret key"
echo ""
read -p "Press enter when you have all API keys ready..."

# Collect credentials
echo ""
echo -e "${YELLOW}Enter your credentials:${NC}"
echo ""

read -p "Supabase URL: " SUPABASE_URL
read -p "Supabase Anon Key: " SUPABASE_ANON_KEY
read -sp "Supabase Service Key: " SUPABASE_SERVICE_KEY
echo ""
read -p "YouTube API Key: " YOUTUBE_API_KEY
read -p "Replicate API Key: " REPLICATE_API_KEY
read -sp "OpenAI API Key: " OPENAI_API_KEY
echo ""

# Generate CRON_SECRET
CRON_SECRET=$(openssl rand -hex 32)
echo ""
echo -e "${GREEN}✅ Generated CRON_SECRET: $CRON_SECRET${NC}"
echo ""

# Discord webhook is already set
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1424056962345205840/W_g9dRJL3piScsAULxhrgW-xU9f9MHXDmZ48LDe7CvviFRusjNZo21U-5Zo4i5yq1jUV"

# Save to .env for local testing
cat > .env << EOF
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_SERVICE_KEY=$SUPABASE_SERVICE_KEY
YOUTUBE_API_KEY=$YOUTUBE_API_KEY
REPLICATE_API_KEY=$REPLICATE_API_KEY
OPENAI_API_KEY=$OPENAI_API_KEY
DISCORD_WEBHOOK_URL=$DISCORD_WEBHOOK_URL
CRON_SECRET=$CRON_SECRET
EOF

echo -e "${GREEN}✅ Saved credentials to .env${NC}"
echo ""

# Step 2: Push to GitHub
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📦 Step 2: Push to GitHub${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if gh repo view &> /dev/null; then
    echo "✅ GitHub repo already exists"
    git push
else
    echo "Creating GitHub repository..."
    gh repo create youtunes-lol --public --source=. --remote=origin --push
    echo -e "${GREEN}✅ Pushed to GitHub${NC}"
fi

echo ""

# Step 3: Cloudflare Login & R2
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}☁️  Step 3: Cloudflare Setup${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Logging into Cloudflare..."
npx wrangler login

echo ""
echo "Checking if R2 is enabled..."
if npx wrangler r2 bucket list &> /dev/null; then
    echo -e "${GREEN}✅ R2 is enabled${NC}"
else
    echo -e "${YELLOW}⚠️  R2 not enabled${NC}"
    echo ""
    echo "Enable R2 (it's free):"
    echo "  1. Go to: https://dash.cloudflare.com"
    echo "  2. Click: R2 in left sidebar"
    echo "  3. Click: Purchase R2"
    echo "  4. Accept terms (free up to 10GB)"
    echo ""
    read -p "Press enter after enabling R2..."
fi

echo ""
echo "Creating R2 bucket: youtunes-music..."
if npx wrangler r2 bucket create youtunes-music; then
    echo -e "${GREEN}✅ R2 bucket created${NC}"
else
    echo -e "${YELLOW}⚠️  Bucket might already exist${NC}"
fi

echo ""

# Step 4: Deploy to Cloudflare Pages
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Step 4: Deploy to Cloudflare Pages${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Deploying to Cloudflare Pages..."
npx wrangler pages deploy public --project-name=youtunes-lol

echo ""
echo -e "${GREEN}✅ Deployed to Cloudflare Pages${NC}"
echo ""

# Get the deployment URL
PAGES_URL=$(npx wrangler pages project list | grep youtunes-lol | awk '{print $1}' || echo "youtunes-lol.pages.dev")

echo "Your site is live at: https://${PAGES_URL}"
echo ""

# Step 5: Add Environment Variables
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔧 Step 5: Configure Environment Variables${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Adding environment variables to Cloudflare Pages..."

echo "SUPABASE_URL" | npx wrangler pages secret put SUPABASE_URL --project-name=youtunes-lol <<< "$SUPABASE_URL"
echo "SUPABASE_ANON_KEY" | npx wrangler pages secret put SUPABASE_ANON_KEY --project-name=youtunes-lol <<< "$SUPABASE_ANON_KEY"
echo "SUPABASE_SERVICE_KEY" | npx wrangler pages secret put SUPABASE_SERVICE_KEY --project-name=youtunes-lol <<< "$SUPABASE_SERVICE_KEY"
echo "YOUTUBE_API_KEY" | npx wrangler pages secret put YOUTUBE_API_KEY --project-name=youtunes-lol <<< "$YOUTUBE_API_KEY"
echo "REPLICATE_API_KEY" | npx wrangler pages secret put REPLICATE_API_KEY --project-name=youtunes-lol <<< "$REPLICATE_API_KEY"
echo "OPENAI_API_KEY" | npx wrangler pages secret put OPENAI_API_KEY --project-name=youtunes-lol <<< "$OPENAI_API_KEY"
echo "DISCORD_WEBHOOK_URL" | npx wrangler pages secret put DISCORD_WEBHOOK_URL --project-name=youtunes-lol <<< "$DISCORD_WEBHOOK_URL"
echo "CRON_SECRET" | npx wrangler pages secret put CRON_SECRET --project-name=youtunes-lol <<< "$CRON_SECRET"

echo ""
echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Step 6: Configure R2 Binding
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔗 Step 6: Configure R2 Binding${NC}"
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

# Step 7: GitHub Actions Secrets
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔑 Step 7: GitHub Actions Secrets${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Getting Cloudflare Account ID..."
CF_ACCOUNT_ID=$(npx wrangler whoami | grep "Account ID" | awk '{print $3}' || echo "")

echo ""
echo -e "${YELLOW}⚠️  Manual step required:${NC}"
echo ""
echo "Create Cloudflare API Token:"
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

# Step 8: Custom Domain
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🌐 Step 8: Custom Domain (youtunes.lol)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}⚠️  Manual step required:${NC}"
echo ""
echo "  1. Buy domain youtunes.lol (if not already owned)"
echo "  2. Go to: https://dash.cloudflare.com"
echo "  3. Pages > youtunes-lol > Custom domains"
echo "  4. Click 'Set up a custom domain'"
echo "  5. Enter: youtunes.lol"
echo "  6. Wait 5-10 minutes for SSL"
echo ""
read -p "Press enter after adding domain..."

# Step 9: Test
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧪 Step 9: Test Deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Testing API endpoint..."
sleep 2
curl -s "https://${PAGES_URL}/api/tracks" | head -20

echo ""
echo ""
echo "Triggering first music generation..."
echo "Check your Discord for live logs!"
echo ""

curl -X POST "https://${PAGES_URL}/api/cron-trigger" \
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
echo "  📍 Current URL: https://${PAGES_URL}"
echo "  🔗 Custom domain: youtunes.lol (once configured)"
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
echo "  3. Configure custom domain if not done"
echo "  4. Monitor Discord for daily logs"
echo ""
echo -e "${GREEN}Credentials saved to .env (keep secure!)${NC}"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
