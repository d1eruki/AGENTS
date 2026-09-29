---
name: timeweb-deployment
description: Deploy or migrate a website to Timeweb shared hosting, or set up domain mail on Timeweb Mail. Covers GitHub Actions delivery, DNS and mailbox migration, SSL, redirects, and verification. Do not use for Timeweb Cloud or VDS server administration.
---

# Timeweb Deployment

Deploy from GitHub Actions by pushing built artifacts to Timeweb. Keep the client-owned Timeweb account independent from the source repository: the hosting account receives compiled files and a public deployment key, while GitHub stores the private key and performs the build.

Read [references/step-by-step.md](references/step-by-step.md) before configuring a new deployment, moving a production domain, rotating credentials, or removing an old host.

When the domain's mail is being moved to Timeweb, or a site form must send to a Timeweb mailbox, also read [references/mail.md](references/mail.md). Moving website hosting alone does not require moving mail.

## Preserve Access Boundaries

- Create a unique Ed25519 key for each client project. Never reuse one deployment key across customers or hosting accounts.
- Store only the public key in the Timeweb account and only the private key in the relevant GitHub Actions secret.
- Never place a GitHub token, repository deploy key, `.git` directory, source checkout, or the private deployment key on the client server.
- Treat repository write access as deployment access because a writer can change a workflow that consumes repository secrets.
- Verify the SSH host key independently before saving `known_hosts`. Stop on an unexplained fingerprint change.
- Remove superseded public keys from `~/.ssh/authorized_keys`, delete obsolete local key files, and replace the GitHub secret when rotating access.

## Preserve Existing Services

Before changing nameservers, inventory the live zone. Recreate all required website, mail, verification, and security records at Timeweb before the cutover. In particular, preserve MX, SPF, DKIM, DMARC, and provider-verification TXT records when domain mail is in use.

Keep exactly one SPF record for the domain. Merge authorized senders into that record. When the website sends mail through Timeweb while user mail remains at another provider, include both providers according to their current documentation.

Do not assume a green deployment run proves that the public domain, HTTPS, forms, mail, redirects, or error statuses work. Verify each separately after DNS propagation.

## Deploy Conservatively

Build for the production domain root and upload the build output rather than the repository. Start without destructive mirroring flags such as `rsync --delete`. Remove only identified provider placeholder files after confirming the uploaded entry point exists.

Retain the old hosting service until authoritative DNS, common public resolvers, HTTPS, mail, forms, redirects, and required SEO endpoints have been verified on the new host.
