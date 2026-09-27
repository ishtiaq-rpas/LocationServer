# SOS Location Beacon & GitHub Setup Guide

This guide explains how your single-file web page works and the two approaches you can take to allow remote devices to update [locations.json](file:///d:/BAGROVISION/LocationServer/locations.json).

---

## 1. What was created
- [index.html](file:///d:/BAGROVISION/LocationServer/index.html): Self-contained web page with:
  - Text input for **Name** (optional).
  - Prominent **SOS** button with visual pulse ring and state animations.
  - Automatically generated and persisted **Device ID** stored in `localStorage` so repeat alerts map to the same device.
  - Automatic retrieval of **GPS location** (via `navigator.geolocation` with high accuracy) and **Device Public IP** (via `api.ipify.org`).
  - Logic to format and update `locations.json` keyed by `deviceId`.
- [locations.json](file:///d:/BAGROVISION/LocationServer/locations.json): Initial structured data store:
  ```json
  {
    "devices": {
      "dev-example-uuid": {
        "name": "Alice",
        "deviceIp": "192.0.2.1",
        "gps": {
          "latitude": 23.8103,
          "longitude": 90.4125,
          "accuracyMeters": 15,
          "altitude": null,
          "timestamp": "2026-09-27T12:00:00.000Z"
        },
        "updatedAt": "2026-09-27T12:00:00.000Z"
      }
    }
  }
  ```

---

## 2. The Core Challenge: Editing a file on GitHub from a Browser

GitHub Pages is a **static web host**. Browsers cannot directly edit or save files onto GitHub Pages simply using standard HTTP `PUT`/`POST` requests without an authenticated API or backend.

Below are the **two ways** to enable remote writing:

---

### Method A: Direct GitHub REST API (No backend needed)
The client script in `index.html` already supports updating the repository file directly via the GitHub Contents API (`PUT /repos/{owner}/{repo}/contents/locations.json`).

#### Steps:
1. **Push files to GitHub**:
   - Create a GitHub repo (e.g., `username/LocationServer`).
   - Push `index.html` and `locations.json` to the `main` branch.
   - Go to **Settings > Pages** and enable GitHub Pages on `main` branch.
2. **Generate a GitHub Personal Access Token**:
   - Go to GitHub -> **Settings > Developer Settings > Personal Access Tokens > Fine-grained tokens**.
   - Under Repository Access, select **Only select repositories** -> Pick your `LocationServer` repo.
   - Under **Permissions > Repository permissions**, set **Contents** to **Read and write**.
   - Generate and copy the token.
3. **Using it on your device**:
   - Open your GitHub Pages link on the remote device (e.g. `https://username.github.io/LocationServer/`).
   - Tap **⚙️ GitHub Config**, paste the token once. It will save in that device's `localStorage` and never need to be entered again on that phone/device.
   - Click **SOS**! The device fetches GPS + IP, checks `locations.json`, appends its key, and commits the change to the repo.

> [!CAUTION]
> Anyone with your Personal Access Token can commit to the repository. Only enter this token on your own trusted devices.

---

### Method B: Serverless Relay (Recommended for public / untrusted devices)
If untrusted or arbitrary external users will open the page and you don't want them entering or seeing a GitHub token:

1. Create a free **Cloudflare Worker** or **Vercel Serverless Function**.
2. Store your GitHub token safely inside the Worker environment variable (`GITHUB_PAT`).
3. The Worker exposes an open endpoint `POST /submit-location`.
4. The client's `index.html` simply sends `{ name, deviceId, deviceIp, gps }` to your worker URL.
5. In `index.html`, set `CONFIG.backendWebhookUrl = 'https://your-worker.your-subdomain.workers.dev'`.

---

## 3. Important GPS Note
Browsers only provide high-accuracy GPS coordinates (`navigator.geolocation`) over **secure contexts (HTTPS)**. GitHub Pages automatically enables HTTPS (`https://username.github.io/...`), satisfying this requirement.
