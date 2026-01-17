# 🛠️ Repair App — Flutter Frontend

The **Repair App** is a mobile application built with **Flutter** that allows users to report home or office damages and get matched with nearby specialists such as electricians, plumbers, handymen, or contractors.  
It communicates with a **Laravel API backend** for authentication, order management, messaging, and job tracking.

---

## 📌 Features

- **User Authentication** — Sign up, log in, log out (via Laravel Sanctum API).
- **Profile Management** — Update personal details, change password, upload profile picture.
- **Location Autocomplete** — Search and select addresses with coordinates using **OpenStreetMap (Nominatim API)**.
- **Damage Reporting & Status Workflow** — Create repair reports with:
  - Damage description
  - Photo uploads
  - Location on map
  - Reports go through these statuses:
    - `waiting` — Report created, waiting for specialist response.
    - `accepted` — Specialist accepted the job.
    - `rejected` — Specialist declined the job.
    - `escalated` — Sent to another specialist for handling.
    - `inprogress` — Job currently being worked on.
    - `completed` — Job finished by specialist.
  - Users can delete reports if they are in the stage of waiting, rejected or escalated.
- **Feedback System** — Once a report is marked as `completed`, the user can submit feedback about the specialist, so the specialist and other user's can see.
- **Job Tracking** — View progress updates with images and comments from specialists.
- **Messaging System** — Chat with specialists in real-time.
- **Account Management** — Delete account or log out at any time.

---

## 🛠️ Tech Stack

- **Frontend Framework:** Flutter (Dart)
- **Map & Location:** OpenStreetMap + Nominatim API
- **Backend API:** Laravel (via HTTPS requests)
- **Image Handling:** Multipart requests for file uploads

## 📄 Project Report

⬇️ **[Download Project Report (PDF)](https://github.com/hadirida46/repair_app/raw/master/Repair_APP_Report.pdf)**  
> Note: The report will download automatically when clicked.

