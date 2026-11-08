# Bahi on a cloud server (no Unraid)

The same Bahi as on Unraid, running on a small server on the internet. It works with your shop PC switched off, customer links and the Telegram bot work all the time, and every night's backup is also copied to your own Google Drive or OneDrive.

What you need:
- a small Linux server (Ubuntu 22.04 or 24.04): Oracle Cloud's free one (below) or any VPS with 1 GB RAM or more (₹300 to ₹600 a month at most Indian and international hosts);
- 20 minutes.

Bahi on the server holds a copy of your books (the same as on Unraid). It is behind HTTPS and your app password; keep that password strong.

---

## 1. Get a server

### Oracle Cloud "Always Free" (₹0)

Oracle gives every account a small server free for as long as you use it. Signing up needs a debit or credit card for identity (it isn't charged for Always Free things). Oracle's free offer and its terms can change, so read what the sign-up page says.

1. Sign up at **cloud.oracle.com** ("Start for free"). Pick **India South (Hyderabad)** or **India West (Mumbai)** as your home region.
2. In the menu: **Compute → Instances → Create instance**.
   - Name: `bahi`.
   - Image: **Canonical Ubuntu 24.04**.
   - Shape: **Ampere, VM.Standard.A1.Flex**, 1 OCPU and 6 GB memory (well within the free amount).
     If it says **"Out of capacity"** (common in the Indian regions, which have one availability domain), either try again at another time of day, or pick **Specialty and previous generation → VM.Standard.E2.1.Micro** instead: also Always Free and nearly always available. It is small (1 GB memory), but enough for Bahi; the installer adds swap for it.
   - Networking: choose **Create new virtual cloud network** and **Create new public subnet**, then turn on **Automatically assign public IPv4 address**. (That switch is greyed out when a *private* subnet is picked. If you already have a network, make one with internet access first: menu, **Networking → Virtual cloud networks → Start VCN Wizard → Create VCN with Internet Connectivity**, then pick its **public** subnet here.)
   - SSH keys: **Generate a key pair for me**, then **Save private key** (keep this file safe; it's how you log in).
   - **Create**. After a minute it shows the **Public IP address**: note it.
3. Open the web ports: on the instance page click the **Subnet** link, then the **Default Security List**, then **Add Ingress Rules**, and add two rules:
   - Source CIDR `0.0.0.0/0`, IP protocol TCP, destination port `80`
   - Source CIDR `0.0.0.0/0`, IP protocol TCP, destination port `443`

Oracle may stop a free server that sits almost idle for a week; Bahi's syncing usually keeps it busy enough. Upgrading the account to "Pay As You Go" removes that rule and still costs nothing as long as you stay within the free amounts.

### Any other VPS

Any provider works (DigitalOcean, Hetzner, Hostinger, AWS Lightsail ...): create an **Ubuntu** server with 1 GB RAM or more, note its IP address and root (or `ubuntu`) login, and allow ports 80 and 443 if the provider has a firewall.

## 2. Install Bahi (one command)

Log in to the server. On Windows 10/11 open **PowerShell** and type (with your key file and IP):

```
ssh -i C:\path\to\ssh-key.key ubuntu@YOUR-SERVER-IP
```

(type `yes` the first time). Then paste this and press Enter:

```
curl -fsSL https://raw.githubusercontent.com/bdlnaredi/TallyPrimeSync/main/deploy/cloud/install.sh | sudo bash
```

It installs everything and asks two things:
- **Address**: press Enter to use the free one it offers (like `140-238-1-2.sslip.io`), or type your own domain if you have one pointed at the server.
- **Password** for the Bahi app.

At the end it prints Bahi's address (`https://...`) and the **sync token**. Copy both. Bahi now updates itself every night; nothing else to do on the server.

## 3. Point the Tally PC and the phones at it

- **Tally PC**: Bahi Sync → **Settings** → server address `https://your-address`, sync token from step 2 → **Test connection** → **Save**.
- **Phones**: Android app: Settings → **Change server address** → the new `https://` address. Browser or home-screen app: open the new address and add it to the home screen again. Log in with the new password.

## 4. Bring your data over from Unraid (optional)

Without this, the first sync simply copies everything from Tally again. To keep phone entries, follow-up notes, staff logins, customer links and settings too:

1. On the **old** Bahi (Unraid): Settings → Backups → **Back up now** → **Download**.
2. On the **new** Bahi: Settings → Backups → **Restore from a backup file** → pick that file.

The app password becomes the one from the backup (your Unraid password).

## 5. Backups in Google Drive or OneDrive

On the Tally PC: Bahi Sync → **Tools** → **Back up to Google Drive** (or **OneDrive**). Your browser opens; sign in and allow access. From then on, every night's backup is copied to a **Bahi Backups** folder in your Drive (the last 30 are kept). Settings → *Backups in Google Drive or OneDrive* in the app shows the last copy and lets you **Copy now**.

Moving to another server later: install Bahi there, connect the same Google Drive, then **Bring back** the latest backup and **Restore** it.

## Good to know

- Everything lives in `/opt/tallyprimesync` on the server: `data/` (books, backups), `.env` (address, password, sync token).
- Restart: `cd /opt/tallyprimesync && sudo docker compose restart`. Logs: `sudo docker compose logs --tail 100 bahi`.
- Run the install command again any time; it keeps the settings and brings Bahi up to date.
- Your own domain later: point it (an A record) at the server's IP, change `DOMAIN=` in `/opt/tallyprimesync/.env`, then `sudo docker compose up -d`. Update the address in Bahi Sync and the phones.
