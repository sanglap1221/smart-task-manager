# Smart Task Manager

Live API: https://smart-task-manager-my9r.onrender.com

## Project Overview

- A lightweight task management system with an auto-classifier that suggests category and priority from task title/description.
- Built to showcase a full-stack workflow: Node.js + Supabase/PostgreSQL backend and a Flutter (Material 3) mobile app.
- Why: demonstrate clean API design, simple NLP-style classification, state management (Provider), pagination/filters, and production deployment to Render.

## Tech Stack

- Backend: Node.js, Express, Zod (validation), Supabase JS SDK
- Database: Supabase (PostgreSQL)
- Mobile App: Flutter, Provider (state), Dio (HTTP), Material 3 UI
- Tests: Jest (backend classification unit tests)
- Hosting: Render (backend)

## Architecture

- High level:
  - Flutter app calls REST endpoints under `/api` on the deployed backend.
  - Backend classifies tasks, validates payloads, and persists to Supabase (PostgreSQL).
  - Task status transitions are recorded in `task_history` for traceability.
- Key decisions:
  - Express + Zod for fast, type-safe request validation without overengineering.
  - Supabase for managed Postgres + JS client, easing local dev/testing and production hosting.
  - Provider for lean, explicit state flows on a single-screen Flutter dashboard.
  - Clear separation: routes → controller → services → db client.

Repository layout:

- Backend API: backend/
- Flutter app: flutter_app/

## Database Schema (Supabase)

Tables used by the API:

1. tasks

```
id                uuid primary key default gen_random_uuid(),
title             text not null,
description       text not null,
assigned_to       text null,
due_date          timestamptz null,
category          text not null,                 -- e.g. general | scheduling | finance | technical | safety
priority          text not null,                 -- low | medium | high
extracted_entities jsonb not null default '{}',  -- { people:[], locations:[], dates:[] }
suggested_actions jsonb not null default '[]',   -- list of strings
status            text not null default 'pending', -- pending | in_progress | completed
created_at        timestamptz not null default now(),
updated_at        timestamptz not null default now()
```

2. task_history

```
id         bigserial primary key,
task_id    uuid not null references tasks(id) on delete cascade,
action     text not null,        -- e.g. status_changed
old_value  text null,
new_value  text null,
changed_at timestamptz not null default now()
```

ER: One task → many history records (`tasks.id` = `task_history.task_id`).

## Setup Instructions

Prerequisites

- Node.js 18+
- Flutter SDK 3.16+ (Android Studio/Xcode as needed)
- Supabase project (to get URL + anon key)

Backend (Node.js + Express)

1. Create `.env` in backend/ with:

```
PORT=3000
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

2. Install and run locally

```bash
cd backend
npm install
npm run dev
```

3. Run unit tests

```bash
cd backend
npm test
```

4. Deploy to Render (Free tier)
   - Create new Web Service → connect this repo.
   - Root directory: `backend`
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Add Env Vars: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `PORT` (optional)
   - After deploy, verify health at `/` and APIs under `/api`.

Flutter App

1. Ensure the backend is reachable. The app points to:

```
flutter_app/lib/services/api_services.dart
BASE_URL = https://smart-task-manager-my9r.onrender.com/api
```

2. Install and run

```bash
cd flutter_app
flutter pub get
flutter run
```

3. Build (Android example)

```bash
cd flutter_app
flutter build apk
```

## API Documentation

Base URL: https://smart-task-manager-my9r.onrender.com/api

Common types

- status: `pending | in_progress | completed`
- category: `general | scheduling | finance | technical | safety`
- priority: `low | medium | high`

1. Preview classification

- POST /tasks/classify
  Request

```
{
	"title": "Fix pipe",
	"description": "There is a safety hazard in Zone A"
}
```

Response 200

```
{
	"category": "safety",
	"priority": "high",
	"extracted_entities": {"people":[],"locations":[],"dates":[]},
	"suggested_actions": ["Conduct inspection","File report","Notify supervisor","Update checklist"]
}
```

2. Create task

- POST /tasks
  Request

```
{
	"title": "Schedule inspection",
	"description": "Safety inspection for Plant 2 this week",
	"assigned_to": "alex",
	"due_date": "2025-12-29T00:00:00.000Z",
	"category": "safety",         // optional, auto-filled if omitted
	"priority": "medium"          // optional, auto-filled if omitted
}
```

Response 201

```
{
	"data": {
		"id": "<uuid>",
		"title": "Schedule inspection",
		"description": "Safety inspection for Plant 2 this week",
		"assigned_to": "alex",
		"due_date": "2025-12-29T00:00:00.000Z",
		"category": "safety",
		"priority": "medium",
		"extracted_entities": {"people":[],"locations":[],"dates":[]},
		"suggested_actions": ["Conduct inspection","File report","Notify supervisor","Update checklist"],
		"status": "pending"
	}
}
```

3. List tasks (with filters + pagination)

- GET /tasks?status=pending&category=safety&priority=high&limit=10&offset=0
  Response 200

```
{
	"data": [ { /* task */ }, ... ],
	"count": 42
}
```

4. Get by id

- GET /tasks/:id
  Response 200

```
{ "data": { /* task */ } }
```

5. Update task (partial)

- PATCH /tasks/:id
  Request (any subset of fields)

```
{
	"title": "Updated title",
	"status": "in_progress"
}
```

Response 200

```
{ "data": { /* updated task */ } }
```

Notes

- If `status` changes, a `task_history` record is created with old/new values.

6. Delete task

- DELETE /tasks/:id
  Response 200

```
{ "message": "Task deleted successfully" }
```

## Flutter App Features (Mandatory Set)

- Single dashboard screen with:
  - Summary cards: Pending / In Progress / Completed.
  - Task list with filters (category/priority/status), search, pull-to-refresh, infinite scrolling.
  - Create/Edit task via bottom sheet.
- State management: Provider (`TaskProvider`).
- Networking: Dio (`ApiService`).
- UI: Material 3 style widgets and theming.


```bash
cd backend
```

## Screenshots (Add in this repo)

<img width="466" height="1004" alt="image" src="https://github.com/user-attachments/assets/1a575607-76c0-471e-9c21-e279057a9182" />
<img width="477" height="1013" alt="image" src="https://github.com/user-attachments/assets/2db31db5-928a-4602-af11-62aff702ecf5" />
<img width="447" height="973" alt="image" src="https://github.com/user-attachments/assets/b8228635-5119-493d-a3e1-c2dc0a10ffaa" />
<img width="448" height="980" alt="image" src="https://github.com/user-attachments/assets/0cae7b1e-82be-4253-b954-e510c8aec56e" />


