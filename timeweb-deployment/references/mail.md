# Domain mail on Timeweb shared hosting

Use this procedure when the owner chooses Timeweb Mail for a domain, including when access to a former mail provider is unavailable. Check current Timeweb documentation and the live DNS zone before entering provider-specific values.

## Establish control and create mailboxes

- Confirm that the owner controls the domain's authoritative DNS and the intended Timeweb account. A mailbox name such as `info@example.com` can be recreated on Timeweb even if a former provider used the same address. This creates a new mailbox; it does not recover messages stored at the former provider.
- In Timeweb, select the correct domain in **Почта** and use **Добавить ящик** for each required address. Store new passwords in the owner's password manager. Do not put passwords in source code, GitHub secrets meant for deployment, screenshots, or chat.
- Decide which address receives each type of site request before changing forms. The visible address, form recipient, and `Reply-To` behavior are separate settings.

## Switch DNS for the chosen mail provider

1. Find the authoritative DNS editor. Editing a zone that is not authoritative will not change public delivery.
2. Inventory the existing MX, SPF, DKIM, DMARC, verification TXT, and mail CNAME records. Keep website A/AAAA and `www` records out of this mail change.
3. If mail is moving fully to Timeweb, replace the former provider's MX records with Timeweb's current MX pair. At the time of this guide, Timeweb documents `mx1.timeweb.ru` (priority 10) and `mx2.timeweb.ru` (priority 20). Use MX records from one mail provider only.
4. Keep one SPF TXT record for the domain. Authorize every service that still sends mail as the domain, including the website if applicable; remove an old provider's SPF include only after confirming it no longer sends. Use Timeweb's current published SPF mechanism, not a value copied from another domain.
5. Check the Timeweb DKIM record after creating a mailbox and sending the first message; Timeweb may create it automatically. Preserve a former provider's DKIM selector only while that provider still sends legitimate mail. Keep or configure DMARC deliberately. Remove obsolete verification TXT and mail CNAME records only after identifying their purpose.
6. Query public DNS after the change. Cached records can continue sending some messages to the old provider until their TTL expires.

Timeweb's [DNS record guide](https://timeweb.com/ru/docs/domeny/resursnye-zapisi-domena-dns-zapisi/nastrojka-dns-zapisej/) lists its current mail records and automatic DKIM/DMARC behavior. Its [mailbox guide](https://timeweb.com/ru/docs/pochta/osnovnye-voprosy-po-rabote-s-pochtoj/sozdanie-i-nastrojka-pochtovogo-yashchika/) shows the current panel flow.

## Read and verify mail

- Open [Timeweb Mail](https://mail.timeweb.com/) and sign in with the full mailbox address and its new password. A desktop or mobile mail client is optional; use Timeweb's current IMAP/SMTP settings if one is needed.
- Send a message from an unrelated external mailbox to every new address. Check that it arrives in the intended Timeweb inbox.
- Reply from Timeweb to that external mailbox and check delivery and sender authentication. Test both directions; creating a mailbox and changing MX alone do not prove that sending works.
- If a website form sends to the new address, submit it through the public site with distinctive test data and confirm the exact fields in the received message. A successful HTTP response or PHP `mail()` return value alone does not prove delivery. Inspect the browser request path and response when the form reports failure; a stale frontend endpoint can fail while direct PHP tests pass.
- Verify all site forms separately when they use different recipients or handlers. Clean up only identified test messages after the checks.

If a former provider or administrator still controls an old mailbox, switching authoritative MX stops new mail from being routed there after DNS caches expire. It does not revoke that person's access to old stored messages or to any other credentials they still hold. Rotate those credentials through their respective owners and providers.
