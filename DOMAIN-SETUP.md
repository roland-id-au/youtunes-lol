# Domain Setup Guide - youtunes.lol

## Register Domain

1. **Purchase `youtunes.lol` domain**
   - Recommended registrars: Cloudflare, Namecheap, Porkbun
   - `.lol` TLD is perfect for fun, creative projects
   - Cost: ~$10-15/year

## Cloudflare Pages Custom Domain Setup

### Step 1: Deploy to Cloudflare Pages

```bash
# Login to Cloudflare
wrangler login

# Deploy the project
wrangler pages deploy public --project-name=youtunes-lol
```

### Step 2: Add Custom Domain

1. Go to Cloudflare Dashboard
2. Navigate to **Pages** > **youtunes-lol**
3. Click **Custom domains** tab
4. Click **Set up a custom domain**
5. Enter: `youtunes.lol`
6. Also add: `www.youtunes.lol` (optional but recommended)

### Step 3: Configure DNS

Cloudflare will automatically configure DNS if domain is on Cloudflare. Otherwise:

**If domain is on Cloudflare:**
- DNS records will be added automatically
- CNAME record: `youtunes.lol` → `youtunes-lol.pages.dev`

**If domain is external (Namecheap, etc.):**

Add these records at your registrar:

```
Type: CNAME
Name: @
Value: youtunes-lol.pages.dev
```

```
Type: CNAME
Name: www
Value: youtunes-lol.pages.dev
```

### Step 4: SSL/TLS

- Cloudflare Pages provides free SSL automatically
- Certificate will be provisioned within 24 hours
- No action required

### Step 5: Verify

1. Wait 5-10 minutes for DNS propagation
2. Visit `https://youtunes.lol`
3. Verify SSL certificate is active (padlock icon)

## Domain Best Practices

### Redirects

Set up www → non-www redirect:

1. Pages > Custom domains > www.youtunes.lol
2. Enable "Redirect to canonical domain"

### Email Forwarding

If you want email@youtunes.lol:

1. Use Cloudflare Email Routing (free)
2. Or ImprovMX (free tier available)
3. Forward to your personal email

### DNS Records to Add

**For email forwarding (Cloudflare Email Routing):**
```
MX records automatically configured by Cloudflare
```

**For social verification (optional):**
```
TXT record for domain verification with Twitter, etc.
```

## GitHub Actions Update

After domain is live, update GitHub Actions workflow:

```yaml
# .github/workflows/deploy.yml
# Update the CRON_SECRET URL to use youtunes.lol
- name: Trigger video processing
  run: |
    curl -X POST https://youtunes.lol/api/cron-trigger \
      -H "Authorization: Bearer ${{ secrets.CRON_SECRET }}" \
      -H "Content-Type: application/json"
```

## Environment Variables

No changes needed - all env vars are in Cloudflare Pages settings, domain-agnostic.

## Testing Checklist

After domain setup:

- [ ] https://youtunes.lol loads correctly
- [ ] https://www.youtunes.lol redirects to youtunes.lol
- [ ] SSL certificate is valid (green padlock)
- [ ] All API endpoints work (/api/tracks, /api/cron-trigger)
- [ ] Meta tags show correct domain in social previews
- [ ] Sitemap accessible at /sitemap.xml
- [ ] Robots.txt accessible at /robots.txt
- [ ] Analytics tracking updated with new domain
- [ ] GitHub Actions cron job works with new domain

## SEO Update

After domain is live:

1. **Google Search Console**
   - Add youtunes.lol as new property
   - Submit sitemap: `https://youtunes.lol/sitemap.xml`
   - Set preferred domain (non-www)

2. **Bing Webmaster Tools**
   - Add youtunes.lol
   - Submit sitemap

3. **Update Social Links**
   - ProductHunt (when launching)
   - Twitter profile
   - GitHub repo description

4. **Canonical URLs**
   - Already set to youtunes.lol in meta tags ✓

## Cost Breakdown

- **Domain registration**: $10-15/year
- **Cloudflare Pages**: Free (500 builds/month)
- **SSL Certificate**: Free (Cloudflare)
- **DNS hosting**: Free (Cloudflare)
- **Email forwarding**: Free (Cloudflare Email Routing)

**Total**: ~$10-15/year

## Troubleshooting

### Domain not working after 24 hours

1. Check DNS propagation: https://dnschecker.org
2. Verify CNAME records are correct
3. Check Cloudflare Pages > Custom domains status
4. Clear browser cache

### SSL certificate error

- Wait 24 hours for provisioning
- Ensure domain DNS is pointed correctly
- Check Cloudflare SSL/TLS settings (should be "Full")

### API endpoints returning 404

- Verify `functions/` directory is deployed
- Check Cloudflare Pages build logs
- Ensure environment variables are set

## Alternative: Keep Cloudflare Subdomain

If you don't want to buy a domain yet:

- Site will remain at `youtunes-lol.pages.dev`
- Still works perfectly, just longer URL
- Can add custom domain later without any code changes
- All functionality identical
