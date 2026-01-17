# Ziggers - Gig Economy Platform

Ziggers is a full-stack mobile application connecting Gig Workers with Employers. It features real-time gig tracking, wallet management, and a robust notification system.

## 🚀 Tech Stack

### Frontend (Mobile App)
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: http
- **UI Libraries**: Google Fonts, Lucide Icons

### Backend (API)
- **Framework**: Spring Boot (Java 21)
- **Database**: PostgreSQL (Supabase)
- **ORM**: Spring Data JPA (Hibernate)
- **Build Tool**: Maven

## ✨ Key Features

### 1. Gig Worker Flow
- **Role Selection**: Users can sign up as Workers.
- **KYC**: Basic identity verification (mocked for dev).
- **Gig Discovery**: Location-based feed of available gigs.
- **Applications**: One-tap apply with duplicate check prevention.
- **Notifications**: "You're Hired!" alerts via in-app notification center.
- **Live Tracking**: Real-time status updates during active gigs.

### 2. Employer Flow
- **Gig Posting**: Create gigs with location, pay, and requirements.
- **Applicant Management**: View applicants, review pitches, and hire workers.
- **Gig Management**: Track assigned, in-progress, and completed gigs.
- **Wallet**: Fund gigs and pay workers securely (Escrow model).

### 3. Notifications System
- **Backend Trigger**: Notifications created automatically when a worker is hired.
- **Frontend UI**: Dedicated Notification Screen accessible from Home.

## 🛠️ Setup Instructions

### Backend
1. Navigate to `backend/` directory.
2. Update `application.properties` with your Supabase credentials.
3. Run the application:
   ```bash
   ./mvnw spring-boot:run
   ```
   *Server runs on port 8080.*

### Frontend
1. Navigate to root directory.
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## 📚 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login/signup |
| POST | `/api/gigs` | Create a new gig |
| GET | `/api/gigs/feed` | Get nearby gigs |
| POST | `/api/gigs/{id}/apply` | Apply for a gig |
| POST | `/api/gigs/{id}/assign/{workerId}` | Hire a worker |
| GET | `/api/notifications` | Get user notifications |

## 📝 Recent Updates
- **Fixed Duplicate Applications**: Added database constraints and UI checks.
- **Notifications**: Implemented end-to-end notification system for "Hired" events.
- **Hire Action**: Fixed database constraint issue preventing hiring.
- **UI/UX**: Improved employer dashboard and success feedbacks.
