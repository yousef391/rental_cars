# Website Deployment Guide

This guide will help you deploy the CarRental Pro website to various hosting platforms.

## 🚀 Quick Deployment Options

### 1. GitHub Pages (Free)

**Step 1: Create GitHub Repository**
```bash
# Create a new repository on GitHub
# Name it: carrental-pro-website
```

**Step 2: Upload Files**
```bash
# Clone the repository
git clone https://github.com/yourusername/carrental-pro-website.git
cd carrental-pro-website

# Copy website files
cp -r website/* .

# Add and commit files
git add .
git commit -m "Initial website upload"
git push origin main
```

**Step 3: Enable GitHub Pages**
1. Go to repository Settings
2. Scroll to "Pages" section
3. Select "Deploy from a branch"
4. Choose "main" branch
5. Save

**Step 4: Access Your Site**
- URL: `https://yourusername.github.io/carrental-pro-website`
- Takes 5-10 minutes to deploy

### 2. Netlify (Free Tier)

**Step 1: Connect GitHub**
1. Go to [netlify.com](https://netlify.com)
2. Click "New site from Git"
3. Connect your GitHub account
4. Select your repository

**Step 2: Configure Build Settings**
- Build command: (leave empty)
- Publish directory: `website` (or root if files are in root)
- Click "Deploy site"

**Step 3: Custom Domain (Optional)**
1. Go to Site settings > Domain management
2. Add custom domain
3. Configure DNS settings

### 3. Vercel (Free Tier)

**Step 1: Import Project**
1. Go to [vercel.com](https://vercel.com)
2. Click "New Project"
3. Import your GitHub repository

**Step 2: Configure Settings**
- Framework Preset: Other
- Root Directory: `website`
- Build Command: (leave empty)
- Output Directory: (leave empty)

**Step 3: Deploy**
- Click "Deploy"
- Access via provided URL

### 4. Traditional Web Hosting

**Step 1: Prepare Files**
```bash
# Create a zip file of the website
zip -r carrental-pro-website.zip website/
```

**Step 2: Upload to Hosting**
1. Login to your web hosting control panel
2. Go to File Manager
3. Upload and extract the zip file
4. Move files to public_html folder

**Step 3: Configure Domain**
1. Point your domain to hosting provider
2. Update DNS settings
3. Wait for propagation (24-48 hours)

## 🔧 Advanced Configuration

### Custom Domain Setup

**For GitHub Pages:**
1. Add custom domain in repository settings
2. Create CNAME file in repository root:
   ```
   yourdomain.com
   ```
3. Update DNS settings with your domain provider:
   ```
   Type: CNAME
   Name: @
   Value: yourusername.github.io
   ```

**For Netlify/Vercel:**
1. Add custom domain in platform settings
2. Update DNS settings:
   ```
   Type: CNAME
   Name: @
   Value: your-site.netlify.app (or vercel.app)
   ```

### SSL Certificate
- **GitHub Pages**: Automatic SSL
- **Netlify**: Automatic SSL
- **Vercel**: Automatic SSL
- **Traditional Hosting**: Enable SSL in hosting control panel

### Performance Optimization

**Enable Compression:**
```apache
# .htaccess file
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>
```

**Browser Caching:**
```apache
# .htaccess file
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
</IfModule>
```

## 📊 Analytics Setup

### Google Analytics 4

**Step 1: Create GA4 Property**
1. Go to [analytics.google.com](https://analytics.google.com)
2. Create new property
3. Get Measurement ID (G-XXXXXXXXXX)

**Step 2: Add to Website**
Add this code to `<head>` section in `index.html`:

```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

### Facebook Pixel

**Step 1: Create Pixel**
1. Go to [business.facebook.com](https://business.facebook.com)
2. Create new pixel
3. Get Pixel ID

**Step 2: Add to Website**
Add this code to `<head>` section:

```html
<!-- Facebook Pixel Code -->
<script>
!function(f,b,e,v,n,t,s)
{if(f.fbq)return;n=f.fbq=function(){n.callMethod?
n.callMethod.apply(n,arguments):n.queue.push(arguments)};
if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
n.queue=[];t=b.createElement(e);t.async=!0;
t.src=v;s=b.getElementsByTagName(e)[0];
s.parentNode.insertBefore(t,s)}(window, document,'script',
'https://connect.facebook.net/en_US/fbevents.js');
fbq('init', 'YOUR_PIXEL_ID');
fbq('track', 'PageView');
</script>
<noscript><img height="1" width="1" style="display:none"
src="https://www.facebook.com/tr?id=YOUR_PIXEL_ID&ev=PageView&noscript=1"
/></noscript>
<!-- End Facebook Pixel Code -->
```

## 🔒 Security Considerations

### Content Security Policy
Add this meta tag to `<head>`:

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com https://connect.facebook.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://www.google-analytics.com;">
```

### HTTPS Redirect
For traditional hosting, add to `.htaccess`:

```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

## 📱 Mobile Optimization

### Viewport Meta Tag
Ensure this is in your `<head>`:

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### App Icons
Add these to `<head>`:

```html
<link rel="icon" type="image/x-icon" href="/favicon.ico">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
```

## 🔄 Continuous Deployment

### GitHub Actions (Optional)
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Netlify
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Deploy to Netlify
      uses: nwtgck/actions-netlify@v1.2
      with:
        publish-dir: './website'
        production-branch: main
        github-token: ${{ secrets.GITHUB_TOKEN }}
        deploy-message: "Deploy from GitHub Actions"
      env:
        NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
        NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

## 📞 Support

If you encounter issues during deployment:

1. **Check file paths**: Ensure all files are in correct locations
2. **Verify permissions**: Files should be readable by web server
3. **Check console errors**: Use browser developer tools
4. **Test locally**: Use local server before deploying

For additional help:
- **Email**: support@carrentalpro.com
- **Documentation**: Check the main README.md file
- **Issues**: Create GitHub issue in repository

---

**Happy Deploying! 🚀** 