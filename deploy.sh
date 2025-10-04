#!/bin/bash

# YouTunes Deployment Script
# Run this after setting up Supabase and getting all API keys

set -e

echo "🎵 YouTunes Deployment Script"
echo "=============================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) not found${NC}"
    echo "Install it: brew install gh"
    echo "Or deploy manually - see DEPLOY.md"
    exit 1
fi

# Check if wrangler is available
if ! command -v npx &> /dev/null; then
    echo -e "${RED}❌ Node.js/npm not found${NC}"
    echo "Install Node.js first"
    exit 1
fi

echo -e "${BLUE}📋 Pre-deployment Checklist${NC}"
echo ""
echo "Have you completed these steps? (see DEPLOY.md for details)"
echo ""
echo "  ☐ Created Supabase project"
echo "  ☐ Run supabase-schema.sql in SQL Editor"
echo "  ☐ Got YouTube API key"
echo "  ☐ Got Replicate API key"
echo "  ☐ Got OpenAI API key"
echo "  ☐ Generated CRON_SECRET (openssl rand -hex 32)"
echo ""
read -p "Have you completed all steps above? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Please complete setup steps first - see DEPLOY.md${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Starting deployment...${NC}"
echo ""

# Step 1: Create GitHub repo
echo -e "${BLUE}📦 Step 1: Creating GitHub repository${NC}"
echo ""

if gh repo view &> /dev/null; then
    echo "✅ GitHub repo already exists"
else
    echo "Creating GitHub repository..."
    gh repo create youtunes-lol --public --source=. --remote=origin --push
    echo -e "${GREEN}✅ Repository created and pushed${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Step 2: Deploy to Cloudflare Pages${NC}"
echo ""
echo "Choose deployment method:"
echo "  1. GitHub Integration (Recommended)"
echo "  2. Direct Deploy via Wrangler CLI"
echo ""
read -p "Enter choice (1 or 2): " deploy_choice

if [ "$deploy_choice" = "1" ]; then
    echo ""
    echo -e "${BLUE}📋 Manual steps required:${NC}"
    echo ""
    echo "1. Go to: https://dash.cloudflare.com"
    echo "2. Click: Pages > Create a project"
    echo "3. Connect to Git > Select 'youtunes-lol' repo"
    echo "4. Build settings:"
    echo "   - Framework preset: None"
    echo "   - Build command: (leave empty)"
    echo "   - Build output: public"
    echo "5. Click 'Save and Deploy'"
    echo ""
    echo "Then add environment variables (see DEPLOY.md Step 3)"
    echo ""
    echo -e "${GREEN}✅ GitHub repo is ready for Cloudflare connection${NC}"

elif [ "$deploy_choice" = "2" ]; then
    echo ""
    echo "Deploying via Wrangler..."

    # Login to Cloudflare
    npx wrangler login

    # Deploy
    npx wrangler pages deploy public --project-name=youtunes-lol

    echo ""
    echo -e "${GREEN}✅ Site deployed!${NC}"
    echo ""
    echo -e "${BLUE}⚠️  Important: Add environment variables${NC}"
    echo "Run these commands to add secrets:"
    echo ""
    echo "npx wrangler pages secret put SUPABASE_URL --project-name=youtunes-lol"
    echo "npx wrangler pages secret put SUPABASE_ANON_KEY --project-name=youtunes-lol"
    echo "npx wrangler pages secret put SUPABASE_SERVICE_KEY --project-name=youtunes-lol"
    echo "npx wrangler pages secret put YOUTUBE_API_KEY --project-name=youtunes-lol"
    echo "npx wrangler pages secret put REPLICATE_API_KEY --project-name=youtunes-lol"
    echo "npx wrangler pages secret put OPENAI_API_KEY --project-name=youtunes-lol"
    echo "npx wrangler pages secret put DISCORD_WEBHOOK_URL --project-name=youtunes-lol"
    echo "npx wrangler pages secret put CRON_SECRET --project-name=youtunes-lol"
    echo ""
fi

echo ""
echo -e "${BLUE}🔧 Step 3: Configure GitHub Actions${NC}"
echo ""
echo "Add these secrets to your GitHub repo:"
echo "  Settings > Secrets and variables > Actions"
echo ""
echo "Required secrets:"
echo "  - CLOUDFLARE_API_TOKEN"
echo "  - CLOUDFLARE_ACCOUNT_ID"
echo "  - CRON_SECRET"
echo ""
echo "See DEPLOY.md Step 5 for detailed instructions"
echo ""

read -p "Press enter when you've added GitHub secrets..."

echo ""
echo -e "${GREEN}🎉 Deployment setup complete!${NC}"
echo ""
echo -e "${BLUE}📍 Next steps:${NC}"
echo ""
echo "1. Configure custom domain (youtunes.lol)"
echo "   - Cloudflare Pages > Custom domains"
echo ""
echo "2. Test your site:"
echo "   curl https://YOUR-SITE.pages.dev/api/tracks"
echo ""
echo "3. Trigger first music generation:"
echo "   curl -X POST https://YOUR-SITE.pages.dev/api/cron-trigger \\"
echo "     -H \"Authorization: Bearer YOUR_CRON_SECRET\""
echo ""
echo "4. Monitor Discord webhook for logs"
echo ""
echo "5. Visit site and check for tracks!"
echo ""
echo -e "${GREEN}✨ Full guide: DEPLOY.md${NC}"
echo ""
