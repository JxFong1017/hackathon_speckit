# Quickstart: Transfer talent contracts

Run the demo from `app/` after that directory exists. Sku 16.4 needs Node.js 24.16 or newer.

```bash
cd app
npm install
sku start
```

Open the URL Sku prints. The page starts signed out.

## P1 path

1. Sign in as **North Ferry Co**.
2. Choose **Harbour Lane Pty Ltd**.
3. Use the offer action.
4. Confirm the page shows `Roster cover contract` and `Offered`, and does not show an employer name on the offer.
5. Sign in as **Harbour Lane Pty Ltd** on the same page.
6. Confirm the same label and status `Offered`, still with no employer name on the offer.

## Checks around that path

- Sign out, or reload so the session is signed out. The offer is not shown.
- Sign in as **Brightpath Group** after the offer exists. The offer is not shown.
- As **North Ferry Co**, use the offer action again. The original offer is unchanged, and the page shows that a second offer was not created.
- As **North Ferry Co** before any offer exists, use the offer action with no receiving employer selected. The page shows that it was not offered, and no offer appears.

Fake data only. Do not add real company names, real people, passwords, or tokens.
