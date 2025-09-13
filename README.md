# Dr-Teragotchi (Emogotchi)
**AI-Powered Virtual Pet Companion for Emotional Wellbeing**

A comprehensive therapeutic application that combines virtual pet care with advanced AI emotional analysis. The system provides personalized emotional support and wellness tracking through an interactive pet companion experience.

## 📋 Table of Contents
- [🌟 Overview](#-overview)
- [🏗️ Project Structure](#️-project-structure)
- [📱 Applications](#-applications)
- [🚀 Key Features](#-key-features)
- [🛠️ Technical Stack](#️-technical-stack)
- [📊 Application Flow](#-application-flow)
- [🌍 Supported Platforms](#-supported-platforms)
- [🔧 Backend API Functions](#-backend-api-functions)
- [📈 Features in Detail](#-features-in-detail)
- [🔒 Privacy & Security](#-privacy--security)
- [📱 App Store Information](#-app-store-information)

## 🌟 Overview
The Dr-Teragotchi project is an innovative AI-driven emotional wellness application that combines the nostalgic appeal of virtual pet care with modern therapeutic technology. Users interact with personalized AI companions that analyze emotional states, provide supportive responses, and evolve based on user engagement and self-care activities.

## 🏗️ Project Structure
This repository contains two main components:

```
Dr-Teragotchi/
├── Emogotchi-FE/              # Flutter Mobile Application
├── Emogotchi-BE/              # Backend API (FastAPI/Python)
```

## 📱 Applications

### 1. Mobile App (Flutter)
- **Location**: `Emogotchi-FE/`
- **Framework**: Flutter (Dart)
- **Platforms**: iOS, Android, Web, macOS, Windows, Linux
- **Features**:
  - Cross-platform compatibility
  - Real-time AI conversation analysis
  - Virtual pet evolution system
  - Emotional state tracking
  - Gamification with points and levels
  - Local notifications and reminders
  - Offline data persistence with cloud sync

### 2. Backend API
- **Location**: `Emogotchi-BE/`
- **Framework**: FastAPI (Python)
- **Features**:
  - RESTful API endpoints
  - OpenAI GPT integration for conversations
  - Emotional analysis and pet assignment algorithms
  - User data management with Supabase
  - Diary generation system
  - Real-time chat processing

## 🚀 Key Features

### AI Emotional Analysis
- Advanced natural language processing with OpenAI GPT models
- Real-time emotion detection from conversation patterns
- Therapeutic response generation based on emotional state
- Context-aware conversation memory across sessions

### Virtual Pet Ecosystem
- 5 unique character types: Tiger, Penguin, Hamster, Pig, Dog
- AI-driven pet assignment based on emotional compatibility
- Pet evolution from egg to adult through user engagement
- Dynamic emotional states reflecting user's wellbeing

### Gamification & Progress
- Points-based reward system for meaningful conversations
- Level progression tied to consistent app engagement
- Rice feeding mechanic using earned points
- Streak tracking for daily emotional check-ins

### Wellness Features
- Auto-generated diary entries from conversation history
- Emotional calendar with pattern visualization
- Progress tracking and personal insights
- Gentle notification system for wellness reminders

## 🛠️ Technical Stack

### Frontend Technologies
- **Mobile**: Flutter, Dart
- **UI Components**: Material Design, Custom Animations
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **Animations**: Lottie, Custom Flutter animations
- **Notifications**: Flutter Local Notifications

### Backend Technologies
- **Framework**: FastAPI, Python 3.9+
- **Database**: Supabase (PostgreSQL)
- **AI/ML**: OpenAI GPT-4 API
- **Data Validation**: Pydantic
- **Server**: Uvicorn ASGI

### Development Tools
- **Mobile**: Android Studio, Xcode
- **Backend**: Python, FastAPI
- **Version Control**: Git
- **Package Management**: pub (Dart), pip (Python)

## 📊 Application Flow

1. **User Onboarding**: Welcome screens and initial profile setup
2. **Conversation Analysis**: 4-message AI analysis for personality assessment
3. **Pet Assignment**: AI assigns compatible virtual companion based on emotional patterns
4. **Daily Interactions**: Users chat with their pet for emotional support and guidance
5. **Progress Tracking**: Pet evolves and levels up based on user engagement
6. **Diary Generation**: AI automatically creates reflective diary entries from conversations
7. **Wellness Monitoring**: Track emotional patterns and personal growth over time

## 🌍 Supported Platforms

### Mobile Platforms
- iOS (iPhone, iPad)
- Android (Phones, Tablets)

### Desktop Platforms
- Windows
- macOS
- Linux

### Web Platforms
- Progressive Web App (PWA) support
- Chrome, Firefox, Safari, Edge compatibility

## 🔧 Backend API Functions

### Core Endpoints
| Endpoint | Method | Description | Parameters |
|----------|--------|-------------|------------|
| `/onboarding` | POST | User Registration - Creates new user profile and returns UUID | `nickname` |
| `/chat` | POST | AI Conversation Processing - Analyzes messages and returns therapeutic responses | `message`, `uuid`, `emotion` |
| `/user/{uuid}` | GET | User Profile Retrieval - Returns complete user data and pet status | `uuid` |
| `/user/update/points` | PUT | Points Management - Updates user points from conversations | `uuid`, `points` |
| `/user/update/level` | PUT | Level Progression - Manages pet evolution and level updates | `uuid`, `level` |
| `/diary/generate` | POST | Diary Generation - Creates reflective entries from chat history | `uuid` |

### API Function Details

#### 🤖 AI Conversation Processing
- **Purpose**: Core AI function that analyzes user emotions and generates therapeutic responses
- **Process**:
  - Receives user messages and emotional context
  - Applies OpenAI GPT models for conversation analysis
  - Detects emotional states (Happy, Sad, Angry, Anxious, Neutral)
  - Generates contextually appropriate, supportive responses
  - Awards points based on conversation quality (0-5 points)
- **Response**: `{ response, emotion, animal, points, isFifth }`

#### 👤 User Management & Pet Assignment
- **Purpose**: Manages user profiles and assigns compatible virtual pets
- **Process**:
  - Analyzes conversation patterns over 4 initial exchanges
  - Uses AI algorithms to match users with suitable pet companions
  - Validates user data and maintains profile consistency
- **Response**: User profile data with assigned pet information

#### 🏆 Progress Tracking System
- **Purpose**: Monitors user engagement and pet development
- **Features**:
  - Real-time points calculation and distribution
  - Pet level progression based on user activity
  - Evolution triggers when pets reach level 5
- **Usage**: Gamification system that encourages consistent emotional wellness practices

#### 📝 Diary Generation System
- **Purpose**: Creates personalized reflection content from user conversations
- **Process**:
  - Analyzes conversation history and emotional patterns
  - Generates meaningful diary entries using AI
  - Provides insights into emotional growth and patterns
- **Response**: Formatted diary entries with emotional summaries

### Technical Implementation
- **Framework**: FastAPI with async/await support
- **Authentication**: UUID-based user identification
- **AI Integration**: OpenAI GPT-4 with custom therapeutic prompts
- **Database**: Supabase PostgreSQL with real-time capabilities
- **Error Handling**: Comprehensive HTTP status codes and timeout management

## 📈 Features in Detail

### Virtual Pet Evolution System
- **Character Types**: 5 unique pets (Tiger, Penguin, Hamster, Pig, Dog) with distinct personalities
- **Evolution Stages**: Pets evolve from eggs to adults at level 5 with celebration animations
- **Emotional States**: Dynamic pet emotions reflecting user's wellbeing (Happy, Sad, Angry, Anxious, Neutral)
- **Interactive Care**: Rice feeding mechanic using earned points (40 points = 1 rice = level progress)

### AI Conversation Engine
- **Emotion Detection**: Real-time analysis of user emotional state from conversation patterns
- **Therapeutic Responses**: Contextually appropriate, supportive responses tailored to user needs
- **Conversation Memory**: Maintains context across multiple chat sessions for deeper understanding
- **Points System**: 0-5 points awarded based on conversation engagement and therapeutic value

### Progress & Gamification
- **Level Progression**: Pet levels increase through consistent user engagement and care
- **Points Economy**: Earn points through conversations, spend on pet care and feeding
- **Streak Tracking**: Monitor daily engagement with emotional wellness practices
- **Visual Feedback**: Smooth animations and celebrations for achievements and milestones

### Wellness Tracking
- **Auto-Generated Diaries**: AI creates reflective diary entries from conversation history
- **Emotional Calendar**: Visual timeline showing emotional patterns and progress over time
- **Personal Insights**: Track emotional triggers, growth patterns, and wellness improvements
- **Privacy-Focused**: Local data storage with optional cloud synchronization

## 🔒 Privacy & Security
- Conversations processed but not permanently stored on servers
- User data anonymization and UUID-based identification
- Local device storage with optional cloud backup
- GDPR compliance considerations for user privacy protection
- Secure API communications with proper authentication
