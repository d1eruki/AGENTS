# Timeweb shared-hosting deployment workflow

Use this workflow for static sites and frontend builds deployed to ordinary Timeweb virtual hosting. Adapt commands, build output, routes, mail providers, and DNS values to the current project. Never copy credentials, host keys, DNS values, or paths from another customer.

## 1. Inspect the project and the live service

Before changing code or external configuration, establish:

- the production branch, package manager, build command, runtime version, and build directory;
- whether the application is static, an SPA, or includes server-side files such as PHP handlers;
- whether the build expects a subpath or the domain root `/`;
- the complete set of public routes, legacy URLs, forms, APIs, uploads, and writable server data;
- the current registrar, authoritative nameservers, A/AAAA, CNAME, MX, TXT, SPF, DKIM, DMARC, SRV, CAA, and relevant subdomain records;
- whether addresses at the domain are displayed on the site, receive form submissions, or send mail;
- the current HTTP redirects, canonical host, TLS coverage, `robots.txt`, `sitemap.xml`, canonical URLs, metadata, and 404 behavior.

Query several record types explicitly. A typical read-only inventory is:

```sh
dig +short NS example.com
dig +short A example.com
dig +short AAAA example.com
dig +short A www.example.com
dig +short CNAME www.example.com
dig +short MX example.com
dig +short TXT example.com
dig +short TXT selector._domainkey.example.com
dig +short TXT _dmarc.example.com
```

Search the repository for domain mail and delivery integrations:

```sh
rg -n -i '@example\.com|mailto:|smtp|mail\(|nodemailer|sendgrid|mailgun|postmark|resend|formspree|web3forms' . \
  --glob '!node_modules/**' --glob '!dist/**' --glob '!.git/**'
```

Record the results before editing DNS. Public DNS is the recovery source when the previous hosting panel is unavailable, but it may not expose inactive or unqueried records. Ask the owner about business mail and special subdomains when evidence is incomplete.

## 2. Prepare the production build

Make the production base path configurable when the same repository also deploys under a GitHub Pages subpath. For Vite, a common pattern is:

```js
export default defineConfig({
  base: process.env.SITE_BASE || '/repository-name/',
})
```

Build the Timeweb version with the domain root:

```sh
SITE_BASE=/ npm run build
```

For an SPA on Apache, ship a `.htaccess` in the public assets so it enters the build output. Serve real files and directories directly. Rewrite only known application routes to `index.html`; return a real 404 for unknown URLs. Add explicit 301 redirects for legacy URLs and choose one canonical host.

A route-aware structure is:

```apache
RewriteEngine On

RewriteCond %{HTTP_HOST} ^www\.example\.com$ [NC]
RewriteRule ^ https://example.com%{REQUEST_URI} [R=301,L,NE]

# Add explicit legacy 301 redirects here.

RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

RewriteRule ^$ index.html [L]
RewriteRule ^(?:known-route|another-route)/?$ index.html [L]
RewriteRule ^ - [R=404,L]
```

Avoid a catch-all rewrite that returns `index.html` with status 200 for arbitrary missing URLs. Verify that API and PHP files bypass the SPA rewrite.

Run the repository's relevant nonvisual checks and a production build before configuring deployment.

## 3. Prepare the Timeweb account

In the client-owned Timeweb account:

1. Enable SSH on the dashboard.
2. Open the Timeweb web SSH console and confirm the prompt contains the intended account login.
3. Determine the document root rather than guessing it:

   ```sh
   find ~ -maxdepth 3 -type d -name public_html -print
   ```

4. Confirm the temporary Timeweb domain is bound to that site directory.

The account belongs to the client. The deployment design does not grant the client access to GitHub; it grants GitHub Actions write access to the published directory.

## 4. Create one deployment key

Use an English, lowercase, project-specific filename, for example:

```sh
ssh-keygen -t ed25519 \
  -f ~/.ssh/timeweb-example-client-deploy \
  -N '' \
  -C github-actions-timeweb-example-client
chmod 600 ~/.ssh/timeweb-example-client-deploy
chmod 644 ~/.ssh/timeweb-example-client-deploy.pub
```

In the client's Timeweb web SSH console, append the public key and set strict permissions:

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
printf '%s\n' 'PUBLIC_KEY_LINE' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Confirm the expected comment appears without printing unrelated authorized keys:

```sh
grep -n 'github-actions-timeweb-example-client$' ~/.ssh/authorized_keys
```

Do not paste the private key into chat, issue text, logs, documentation, or the server. Transfer it directly to the GitHub secret input, for example through a local clipboard command:

```sh
pbcopy < ~/.ssh/timeweb-example-client-deploy
```

## 5. Verify the SSH host key

Collect the Ed25519 host key from a trusted route and inspect its fingerprint:

```sh
ssh-keyscan -T 5 -t ed25519 HOSTNAME 2>/dev/null | ssh-keygen -lf -
```

Timeweb's web SSH console and a public GitHub runner can resolve the same hostname through different network paths. If a strict-checking failure shows a different fingerprint:

1. Do not disable `StrictHostKeyChecking` and do not blindly replace the key.
2. In the Timeweb web console, inspect the address resolved for the hosting server.
3. Scan that server endpoint, calculate its fingerprint, and compare it with the fingerprint reported by the GitHub runner.
4. Only after the fingerprints match, store a `known_hosts` line whose first field is the public hostname used by the workflow.

Keep spaces as ordinary ASCII spaces. Do not copy HTML entities such as `&nbsp;`. Validate the final line locally:

```sh
printf '%s\n' 'HOSTNAME ssh-ed25519 PUBLIC_HOST_KEY' | ssh-keygen -lf -
```

## 6. Configure GitHub Actions

Create repository secrets:

- `TIMEWEB_SSH_KEY`: the complete private deployment key;
- `TIMEWEB_KNOWN_HOSTS`: the verified `known_hosts` line.

Create repository variables:

- `TIMEWEB_HOST`: Timeweb SSH hostname;
- `TIMEWEB_USER`: client hosting login;
- `TIMEWEB_PATH`: verified site document root, ending in `/public_html`;
- `TIMEWEB_ENABLED`: `true` only when automated deployment should run.

A conservative Node/Vite workflow is:

```yaml
name: Deploy to Timeweb

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: timeweb
  cancel-in-progress: false

jobs:
  deploy:
    if: ${{ vars.TIMEWEB_ENABLED == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository
        uses: actions/checkout@PINNED_COMMIT

      - name: Set up Node.js
        uses: actions/setup-node@PINNED_COMMIT
        with:
          node-version: '24'
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Build for domain root
        run: npm run build
        env:
          SITE_BASE: /

      - name: Configure SSH
        env:
          TIMEWEB_SSH_KEY: ${{ secrets.TIMEWEB_SSH_KEY }}
          TIMEWEB_KNOWN_HOSTS: ${{ secrets.TIMEWEB_KNOWN_HOSTS }}
        run: |
          test -n "$TIMEWEB_SSH_KEY" || { echo 'Missing TIMEWEB_SSH_KEY secret'; exit 1; }
          test -n "$TIMEWEB_KNOWN_HOSTS" || { echo 'Missing TIMEWEB_KNOWN_HOSTS secret'; exit 1; }
          mkdir -p ~/.ssh
          chmod 700 ~/.ssh
          printf '%s\n' "$TIMEWEB_SSH_KEY" > ~/.ssh/id_ed25519
          printf '%s\n' "$TIMEWEB_KNOWN_HOSTS" > ~/.ssh/known_hosts
          chmod 600 ~/.ssh/id_ed25519 ~/.ssh/known_hosts

      - name: Upload site
        env:
          TIMEWEB_HOST: ${{ vars.TIMEWEB_HOST }}
          TIMEWEB_USER: ${{ vars.TIMEWEB_USER }}
          TIMEWEB_PATH: ${{ vars.TIMEWEB_PATH }}
        run: |
          test -n "$TIMEWEB_HOST" || { echo 'Missing TIMEWEB_HOST variable'; exit 1; }
          test -n "$TIMEWEB_USER" || { echo 'Missing TIMEWEB_USER variable'; exit 1; }
          case "$TIMEWEB_PATH" in
            */public_html) ;;
            *) echo 'TIMEWEB_PATH must point to public_html'; exit 1 ;;
          esac
          rsync -az --delay-updates \
            -e "ssh -i $HOME/.ssh/id_ed25519 -o StrictHostKeyChecking=yes" \
            dist/ "$TIMEWEB_USER@$TIMEWEB_HOST:$TIMEWEB_PATH/"
```

Replace action placeholders with current commit SHAs from official action repositories. Match the Node version, package manager, build command, and output directory to the project. Do not add `--delete` until remote-only content and writable data are understood and a rollback exists.

Run the workflow manually first. Inspect the failing step rather than repeatedly changing secrets without evidence.

## 7. Activate the uploaded site safely

A fresh Timeweb account may serve its placeholder `index.htm` before the uploaded `index.html`. Remove it only after confirming the real entry point exists:

```sh
cd /verified/path/public_html
if [ -f index.html ]; then
  rm -f index.htm
  echo 'Placeholder removed'
else
  echo 'index.html is missing; inspect the deployment run'
  exit 1
fi
```

Verify the temporary Timeweb domain before moving production DNS. Check direct assets, known SPA routes, API handlers, forms, and a missing route.

## 8. Prepare DNS at Timeweb

Add the production domain to the intended Timeweb site before changing nameservers. In Timeweb's DNS editor:

1. Keep or create the website A and, when supported by the hosting account, AAAA records generated for the site.
2. Add `www` as a CNAME to the apex or configure the chosen canonical alternative.
3. Replace default Timeweb MX records when mail is hosted elsewhere.
4. Recreate the current external mail provider's MX, DKIM selector, DMARC, verification TXT, and useful mail CNAME records.
5. Remove records that point only to the former hosting provider and are no longer required.
6. Merge SPF senders into one TXT record. When domain mail remains at an external provider and a PHP form sends through Timeweb, a typical structure is:

   ```text
   v=spf1 include:_spf.external-provider.example include:_spf.timeweb.ru ~all
   ```

   Use the actual providers' current documented include mechanisms.

For PHP `mail()`, review the envelope sender as well as the visible `From` header. Timeweb documents the fifth `mail()` argument for setting the envelope sender. Test real delivery rather than inferring it from a successful PHP return value.

## 9. Cut over nameservers

At the registrar, replace the former provider's nameservers with the current Timeweb nameservers displayed by Timeweb. At the time this guide was written, Timeweb documented:

```text
ns1.timeweb.ru
ns2.timeweb.ru
ns3.timeweb.org
ns4.timeweb.org
```

Verify these values against current Timeweb documentation before mutation. Do not enter glue IPs unless the registrar specifically requires them for in-domain nameservers.

DNS propagation is not instantaneous. Different providers can temporarily return the old host and the new Timeweb host. Check authoritative nameservers and several public recursive resolvers separately. Do not describe the migration as complete while some required resolvers or record types still point to the former provider.

## 10. Issue TLS certificates

After the domain resolves to Timeweb and is bound to the correct site:

1. Order a free Let's Encrypt certificate in `Domains and SSL`.
2. Leave optional paid configuration services disabled unless the user explicitly wants them.
3. If Timeweb treats the apex and `www` as separate names, order and wait for both certificates separately.
4. Do not order a Timeweb certificate for a mail CNAME that terminates at the external mail provider.
5. Wait until the certificate status is installed or active before enabling a forced HTTPS redirect.
6. Enable HTTPS redirect in the site settings and verify both canonical and alternate hosts.

A browser reaching the new Timeweb host before its certificate is installed can show `ERR_CERT_COMMON_NAME_INVALID`. Do not bypass the warning; finish certificate installation.

## 11. Complete SEO and URL migration

For a public site, treat these as deployment completion work rather than optional polish:

- Add or update `sitemap.xml` with only canonical production URLs and correct protocol/host.
- Add or update `robots.txt`; include the absolute sitemap URL and preserve intentional crawl restrictions.
- Give each indexable page an appropriate title, description, canonical URL, and relevant social metadata. Canonicals must use the final HTTPS canonical host.
- Add explicit permanent redirects from known legacy URLs to their closest replacement. Preserve query strings when required.
- Return an actual HTTP 404 status for unknown URLs. A branded not-found view with status 200 is not a correct replacement.
- Ensure `www` and non-`www`, HTTP and HTTPS, and trailing-slash variants resolve to one canonical URL without redirect loops.

Do not invent redirects for unknown legacy URLs. Derive them from the old sitemap, analytics, search-console data, public indexes, access logs, or an approved mapping.

## 12. Verify the completed migration

Verify with DNS and HTTP tools in addition to browser checks:

```sh
dig +short NS example.com
dig +short A example.com
dig +short AAAA example.com
dig +short MX example.com
dig +short TXT example.com
curl -I http://example.com/
curl -I https://example.com/
curl -I https://www.example.com/
curl -I https://example.com/known-route/
curl -I https://example.com/legacy-url
curl -I https://example.com/definitely-missing-url
curl -I https://example.com/robots.txt
curl -I https://example.com/sitemap.xml
```

Confirm:

- authoritative NS are Timeweb and common resolvers no longer return the former hosting IP;
- apex and `www` reach the intended site and converge on the canonical HTTPS URL;
- the certificate covers every public hostname and renews automatically;
- old URLs return the intended 301 destination;
- missing URLs return 404;
- `robots.txt`, `sitemap.xml`, canonical tags, and metadata use the production domain;
- contact forms deliver, replies go to the submitted address when intended, and messages pass expected SPF/DKIM/DMARC checks;
- domain mail can both send and receive;
- a new commit to the production branch completes the automatic deployment.

Only after these checks pass should the old hosting service be cancelled.

## 13. Rotate or remove deployment access

For a new client account or project, generate a new key rather than moving the old private key. Update `TIMEWEB_USER`, `TIMEWEB_PATH`, and `TIMEWEB_SSH_KEY`, then run a manual deployment.

Remove the obsolete public key by its exact unique comment:

```sh
sed -i '/github-actions-timeweb-old-project$/d' ~/.ssh/authorized_keys
```

Verify it is absent, then delete the corresponding local private/public key files. Do not delete keys with broad patterns that could match another project. Keep `TIMEWEB_HOST` and `TIMEWEB_KNOWN_HOSTS` only when the verified server host key is genuinely unchanged.
