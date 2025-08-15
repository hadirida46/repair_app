# 🛠️ Repair App — Flutter Frontend

The **Repair App** is a mobile application built with **Flutter** that allows users to report home or office damages and get matched with nearby specialists such as electricians, plumbers, handymen, or contractors.  
It communicates with a **Laravel API backend** for authentication, order management, messaging, and job tracking.

---

## 📌 Features

- **User Authentication** — Sign up, log in, log out (via Laravel Sanctum API).
- **Profile Management** — Update personal details, change password, upload profile picture.
- **Location Autocomplete** — Search and select addresses with coordinates using **OpenStreetMap (Nominatim API)**.
- **Damage Reporting** — Create reports with:
  - Damage description
  - Photo uploads
  - Location on map
- **Job Tracking** — View progress updates with images and comments from specialists.
- **Messaging System** — Chat with specialists in real-time.
- **Account Management** — Delete account or log out at any time.

---

## 🛠️ Tech Stack

- **Frontend Framework:** Flutter (Dart)
- **State Management:** setState / FutureBuilder (or your choice if using Provider, Riverpod, etc.)
- **Map & Location:** OpenStreetMap + Nominatim API
- **Backend API:** Laravel (via HTTPS requests)
- **Image Handling:** Multipart requests for file uploads
