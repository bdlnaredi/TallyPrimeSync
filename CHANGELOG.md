# Changelog

What changed in TallyPrimeSync, newest first. The version is the server version shown in the app under Reports. "Tally PC" is the sync on the PC that runs TallyPrime (Bahi Sync), which updates itself from the server.

## 4.10.0 (17 November 2026)

- **Credit warning:** when you make a sales invoice or order, choosing a customer who is over the credit limit set on their ledger in Tally, or who has bills overdue more than 30 days, shows an orange warning with the oldest bills. It's only a warning: the entry can still be saved. Settings, Credit warning turns it off or changes the days.
- **Due dates:** Dues, *Due dates* shows bills by the day they fall due (bill date plus the credit period in Tally): a strip of the next 14 days with the amount on each, everything due in the next month, and what's already overdue. For both money to receive and money to pay.
- **Reminders:** Dues, *Reminders* lists every customer with overdue bills, newly overdue ones first. *Send reminder* opens WhatsApp with the overdue bills, their customer link and UPI payment, and marks them reminded for 7 days (staff see it too). Home shows "N customers to remind today".
- The Telegram morning summary now says what falls due today and how many customers to remind.
- Bahi now reads the credit limit and credit period on ledgers, and the reorder level and minimum order on stock items, from Tally.

## 4.9.2 (15 November 2026)

- **Bill references shown once.** TallyPrime sends a voucher's ledger lines twice (as *all ledger entries* and *ledger entries*), each with the same bill references, and Bahi kept both. Now it reads them from one list only. The Tally PC sends every voucher again once by itself so the stored copies are corrected (the first sync after updating takes a little longer). Pending bills worked out from vouchers are corrected by the same re-read.

## 4.9.1 (15 November 2026)

- **Customer, item and ledger lists work in the Android app again.**
  - When making an invoice or any other entry, tapping Customer, Item, Charge or Ledger opens a list, and typing narrows it (any part of the name, e.g. "gup" finds Gupta Hardware). Tap a name to choose it.
  - Before, these used the browser's own suggestion list, which often shows nothing inside the Android app.

## 4.9.0 (15 November 2026)

- **Copies of TallyPrime's own backups.**
  - Set TallyPrime 7.0's Schedule Backup to save into a folder (Alt+Y, Backup & Restore, Schedule Backup), and pick the same folder in Bahi Sync, Settings, *Tally backup folder*.
  - Bahi Sync then copies each new backup file (like `TSDBK1800_100000.001`) to the Bahi server, exactly as Tally made it. When Google Drive or OneDrive is connected, it goes there too.
  - Download a file, or all of them as a .zip, from Settings, Backups, *Tally's own backups*, and restore it in Tally with Data, Restore.
  - Bahi Sync only reads that folder: it never writes, renames or deletes anything there, and never touches Tally's company data. A file Tally is still writing waits for the next round.
  - Files go up in 16 MB pieces, so big backups also work through Cloudflare. Files Tally has since removed are kept on the server 30 more days.
- Tally PC 3.20.

## 4.8.0 (15 November 2026)

- **Log out from any screen:** a round button with your initial sits at the top right, next to refresh. It opens a menu with who is logged in (owner or staff), Settings, What's new, light or dark look, and **Log out**.

## 4.7.1 (15 November 2026)

- **Tally PC 3.19:**
  - when the Bahi server doesn't answer (it's restarting after an update, or the network drops for a moment), the sync waits and tries again after 5 and then 19 seconds instead of failing straight away;
  - the log gives the real reason ("couldn't reach the Bahi server: Unable to connect ...", "server says: ...") instead of "Exception calling DownloadString".

## 4.7.0 (15 November 2026)

- **"Data as of" date and time everywhere.**
  - The app shows *Data as of 15 Nov 2026, 12:02 pm* in a box under the company name on every screen, for you and your staff. A second line says whether Tally is connected or a sync is running.
  - When the figures are more than 3 hours old, the box turns orange and says how old they are.
  - Customer links show *Figures as on 15 Nov 2026, 12:02 pm* at the top, so customers know which moment their balance is from.
- The time is when Bahi last checked the company against Tally, not just the last time something changed, so a quiet afternoon with no new entries still shows the current time. Tally PC 3.18 reports this after every sync.

## 4.6.0 (15 November 2026)

- **Settings is a short menu now**, grouped like a phone's settings: *Tally and this phone*, *Customers and money*, *People and security* and *Your data*. Each row shows how it's set (Every 10 min, Off, 3 people, Last backup 6 hr ago) and opens on its own screen, instead of one very long page with everything open.

## 4.5.0 (14 November 2026)

- **The app keeps working when the server is down.** If Unraid is off, the internet at the shop is down, or Cloudflare can't reach the server, the app opens straight away with the copy saved on the phone. An orange line says it's showing the saved copy. Before, it could show Cloudflare's error page or keep loading for minutes.
  - When the server is only slow, the saved copy shows after a few seconds, and fresh figures replace it as soon as the server answers.
  - New entries, PDFs and sharing still need the server.
- **What's new:** Reports, What's new lists the changes in every version, newest first. After an update, Home shows a "Bahi has been updated" card that opens it.

## 4.4.1 (14 November 2026)

- **The Android app keeps itself up to date:**
  - it checks for a new version every time it is opened (at most every 15 minutes), not twice a day;
  - when one is ready, it asks you to update every time you open the app, and an orange **New Bahi app ready** bar with an **Update** button stays at the top until you do;
  - it also checks twice a day in the background and sends a notification ("Update the Bahi app"); tap it to update. Android 13 and later ask once to allow notifications.

## 4.4.0 (14 November 2026)

- **Ledgers open on the month of their last entry** (choose *Month of last entry* again from the period list at any time), so a party you last billed in August opens on August instead of an empty month.
- **Print** on ledgers and vouchers. In the Android app it uses the phone's own printing (any printer the phone knows, or Save as PDF); on a computer the print window opens straight away. The Android app needs updating for this (Reports, Update app).
- The figures you will receive are on a **green** card now (what you owe stays red).
- The period picker has a calendar icon and the word *Showing* in front, so it reads as "Showing: This month".

## 4.3.0 (14 November 2026)

- **A simpler, calmer look:**
  - a soft grey background with white cards, and bold colour only on the figures that matter;
  - Home has one **New entry** button that opens a sheet of entry types, instead of a row of nine buttons;
  - the period is one dropdown (This month, This year ...) instead of six buttons.
- **Ledgers:**
  - a bold balance card says in plain words what the balance means: "You will receive", "You owe", "Advance from them", or "Balance" and "Overdrawn" for banks;
  - **Statement** and **Pending bills** are now separate tabs instead of one long page;
  - Share, WhatsApp and Call stay on the screen; PDF, Excel, customer link and UPI request are under **More**.
- **Bank and cash accounts swap the colours:** money in (Dr) is green and money out or an overdraft (Cr) is red, in the ledger, lists, Home and vouchers. A party's ledger keeps Dr red and Cr green.
- On a phone, menus and sheets rise from the bottom of the screen.

## 4.2.1 (14 November 2026)

- While the Tally PC is syncing, the app says so at the top: **Syncing from Tally now** (with the company, when you have several), with a blinking blue dot and when it started. When the sync finishes, the app shows the new figures by itself.

## 4.2.0 (9 to 12 November 2026)

- **Tally PC 3.17:** companies with many vouchers no longer get stuck on "Tally didn't send its list of vouchers". Tally now has up to 10 minutes to answer (it was 100 seconds). If the whole list still doesn't come, it is asked for one month at a time, and the log gives Tally's real reason.
- Bahi is listed in Unraid's **Community Apps**: search for *bahi* in the Apps tab.
- **New stock items from the app:** Stock, **+ New item**, with name, stock group, unit, HSN, GST rate, alias and barcode. It goes into Tally at the next sync as a new item only; Tally refuses a name it already has, so existing items are never changed. Staff need the new *Add stock items* permission.
- **Barcodes:** scan a barcode to give it to a stock item, then scan items straight into sales, purchases and orders. Each scan beeps, and the scanner waits for **Scan next** or **Done**. An unknown barcode offers *Make a new stock item*.
- Tally PC 3.16: the safety check now allows exactly two kinds of writes into Tally: new vouchers and new stock items.

## 4.1.0 (8 November 2026)

- **Sync to two Bahi servers at once** (Bahi Sync, Settings, *Also sync to*), for example Unraid and a cloud server while you compare them. Phone entries from either one go into Tally only once.
- **Backups in Google Drive or OneDrive** on Unraid too: Bahi Sync, Tools, *Back up to Google Drive* (or OneDrive). Every night's backup is copied there, and the last 30 are kept.
- The cloud installer works on Oracle's small always-free E2.1.Micro server too (it adds swap memory).

## 4.0.0 (1 November 2026)

- **TallyPrimeSync:** Bahi on a cloud server with HTTPS, no Unraid needed (one install command, see docs/CLOUD.md), with every night's backup copied to Google Drive or OneDrive.
- **UPI payment requests:** set your UPI ID in Settings. Ledgers and dues get a *Request payment* button, invoices print a UPI QR code, and customer links show a **Pay with UPI** button.
- **Android app:** update the app from inside the app. Sharing and opening PDFs no longer fails with "java.lang.Throwable".
- **Ledgers and sales follow the period:** this year by month, this quarter by week, this or last month by day.
- **Customer links:** each party gets a private read-only page with their balance, pending bills, statement PDF and every invoice. The link is added whenever you share a ledger or voucher on WhatsApp or Telegram, and you can turn any link off.
- Everything before this is the same as Bahi (github.com/bdlnaredi/bahi) up to its version 3.6.
