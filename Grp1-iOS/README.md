# Project Structure

This project is organized by features.  
Each feature keeps its own screens, UI components, and models so the code stays clean and easy to expand as the app grows.

---

## Features/
All the main parts of the app live here.  
Each feature has:
- Screens/ → view controllers (full screens)
- Views/   → reusable UI components (cells, headers, custom views)

### Chatbot/
Chat-related screens and UI.
- Screens/ → Chat screen, chat detail, etc.
- Views/   → chat input view, reusable chat UI

### Home/
Everything related to the home page.
- Screens/ → home root screen, home detail screens
- Views/   → cells or UI blocks used inside Home

### Profile/
User profile screens.
- Screens/ → main profile screen, interests, achievements, bookmarks
- Views/   → header view, profile option cell

### Threads/
Screens for user threads or posts.
- Screens/ → thread list, thread detail
- Views/   → thread cells or other UI pieces

---

## Models/
Data structures used by each feature.
Organized by feature so models don’t get mixed.

- ChatBotModel/
- HomeModel/
- ProfileModel/
- ThreadsModel/

---

## MockData/
Temporary hard-coded data for testing the UI until backend/API is ready.

---

## App Root Files
Basic project configuration.

- AppDelegate.swift  
- SceneDelegate.swift  
- LaunchScreen.storyboard  
- Main.storyboard  
- Assets.xcassets  
- Info.plist  

---

## Purpose
This folder layout keeps each feature independent, easy to read, and easy to grow.  
Screens stay inside Screens/, reusable views inside Views/, and models stay grouped by feature.  
Perfect when each feature has multiple screens and its own UI/client logic.

