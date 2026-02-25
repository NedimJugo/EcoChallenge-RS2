# 🌱 EcoChallenge

<div align="center">

![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white)

**A platform for participating in environmental challenges and contributing to environmental preservation**

*Developed as part of Software Development 2 (Razvoj Softvera 2)*

---

</div>

## 📖 About

**EcoChallenge** is a comprehensive platform designed to promote environmental awareness and action through gamified ecological challenges. Users can participate in various environmental challenges, submit proof of completed tasks, and contribute to preserving the environment while earning recognition for their efforts.

Built with ASP.NET Core backend and Flutter frontend (supporting both desktop and mobile platforms), the application provides a complete ecosystem for managing environmental initiatives. Administrators can create and manage challenges, review user submissions, and approve or reject proof submissions, while users can track their progress and make donations to support environmental causes.

The platform integrates Stripe for secure payment processing, RabbitMQ for asynchronous messaging, and Docker for containerized deployment. With features like automated email notifications, proof validation workflows, and comprehensive challenge management, EcoChallenge makes environmental action accessible and engaging.

---

## ✨ Features

### 🌍 User Features
- **Challenge Participation** - Browse and join environmental challenges
- **Proof Submission** - Upload evidence of completed tasks
- **Progress Tracking** - Monitor challenge completion and achievements
- **Donation System** - Support environmental causes via Stripe integration
- **Profile Management** - Track personal environmental impact
- **Notifications** - Receive updates on challenge status and approvals

### 👔 Administrator Features
- **Challenge Management** - Create, edit, and manage environmental challenges
- **Request Handling** - Review and process user challenge requests
- **Proof Validation** - Approve or reject submitted evidence
- **User Administration** - Manage user accounts and permissions
- **Analytics Dashboard** - Monitor platform engagement and impact
- **Content Moderation** - Ensure quality and authenticity of submissions

### 🔔 Notification System
- **Password Reset** - Automated email with reset code
- **Request Status** - Notifications for request approval/rejection
- **Proof Status** - Updates on submitted evidence review
- **Challenge Updates** - Alerts for new challenges and deadlines
- **Achievement Notifications** - Celebrate completed challenges

### 💳 Payment Integration
- **Stripe Processing** - Secure donation handling
- **Test Environment** - Full Stripe test mode support
- **Transaction History** - Track all donation records
- **Multiple Payment Methods** - Support for various payment options

---

## 🛠️ Built With

| Technology | Purpose |
|------------|---------|
| ![.NET](https://img.shields.io/badge/ASP.NET_Core-512BD4?style=flat&logo=dotnet&logoColor=white) | Backend Web API |
| ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) | Cross-Platform Frontend |
| ![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=flat&logo=microsoft-sql-server&logoColor=white) | Database |
| ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white) | Containerization |
| ![RabbitMQ](https://img.shields.io/badge/RabbitMQ-FF6600?style=flat&logo=rabbitmq&logoColor=white) | Message Broker |
| **Stripe** | Payment Processing |

---

## 🚀 Getting Started

### Prerequisites

- Docker Desktop installed
- Android Emulator (for mobile app testing)
- Windows OS (for desktop application)
- Archive extraction tool supporting password-protected .zip files

### Installation

#### Backend Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/EcoChallenge_RS2.git
   cd EcoChallenge_RS2
   ```

2. **Navigate to Backend Folder**
   ```bash
   cd EcoChallengeBackend
   ```

3. **Extract Environment Configuration**
   - Locate `env.zip` archive in `EcoChallengeBackend` folder
   - Extract the `.env` file to the same folder (`EcoChallenge_RS2/EcoChallengeBackend`)
   - **Password:** `fit`

4. **Extract WebAPI Configuration**
   - Navigate to `EcoChallenge.WebAPI` folder
   - Locate the second `env.zip` archive
   - Extract to `EcoChallenge.WebAPI` folder
   - **Password:** `fit`

5. **Start Backend Services**
   ```bash
   docker compose up --build
   ```
   - Wait for all services to build and start successfully
   - Backend will be available once container initialization completes

#### Frontend Setup

##### Desktop Application

1. **Navigate to Project Root**
   ```bash
   cd EcoChallenge_RS2
   ```

2. **Extract Build Archive**
   - Locate `fit-build-25-08-24.zip` archive
   - Extract the archive (contains `Release` and `flutter-apk` folders)

3. **Run Desktop Application**
   - Open the `Release` folder
   - Run `ecochallenge_desktop.exe`

##### Mobile Application

1. **Prepare Android Emulator**
   - Launch Android emulator or connect physical device
   - Ensure device is properly configured and visible via `adb devices`

2. **Install APK**
   - Open `flutter-apk` folder from extracted archive
   - Transfer `app-release.apk` to emulator/device
   - **Important:** Uninstall any previous version before installing

3. **Install and Launch**
   - Wait for installation to complete
   - Launch EcoChallenge app from device

---

## 🔐 Login Credentials

### Administrator Account

| Field | Value |
|-------|-------|
| **Username** | `dekstop` |
| **Password** | `test` |

**Permissions:** Full system access, challenge management, proof validation, user administration

### Regular User Account

| Field | Value |
|-------|-------|
| **Username** | `mobile` |
| **Password** | `test` |

**Permissions:** Challenge participation, proof submission, donations

> 💡 **Note:** Administrator account can also log in as a regular user to test user-facing features

---

## 💳 Stripe Test Payment Details

The mobile application supports donations through Stripe integration. For testing purposes, use the following test card credentials:

### Test Card Information

| Field | Value |
|-------|-------|
| **Card Number** | `4242 4242 4242 4242` |
| **Expiration Date** | Any future date (e.g., `12/34`) |
| **CVC** | Any 3-digit number (e.g., `123`) |
| **ZIP Code** | Any valid code (e.g., `10000`) |

> ⚠️ **Important:** These credentials only work in Stripe's test environment and will not process real payments.

---

## 🔧 Microservices Architecture

### RabbitMQ Message Broker

The application uses **RabbitMQ** as a message broker for asynchronous communication and automated email notifications.

#### Automated Email Notifications

**Password Reset:**
- User requests password reset
- System generates secure reset code
- Email sent automatically with code and instructions

**Challenge Request Status:**
- Administrator approves/rejects challenge request
- User receives immediate notification
- Email includes decision details and next steps

**Proof Validation Status:**
- Administrator reviews submitted proof
- Approval/rejection triggers notification
- User receives feedback and reasoning

#### Benefits

- **Asynchronous Processing** - Non-blocking email operations
- **Scalability** - Handle high volumes of notifications
- **Reliability** - Message queue ensures delivery
- **Decoupling** - Separation of concerns between services

---

## 📁 Project Structure

```
EcoChallenge_RS2/
│
├── 📂 EcoChallengeBackend/
│   ├── 📂 EcoChallenge.WebAPI/       # API Layer
│   │   ├── 📂 Controllers/           # API endpoints
│   │   ├── 📂 DTOs/                  # Data transfer objects
│   │   ├── env.zip                   # Environment config (extract)
│   │   └── Program.cs                # Application entry
│   ├── 📂 EcoChallenge.Services/     # Business logic
│   ├── 📂 EcoChallenge.Models/       # Domain models
│   ├── 📂 EcoChallenge.Infrastructure/ # Data access
│   ├── docker-compose.yml            # Container orchestration
│   └── env.zip                       # Main environment config
│
├── 📂 fit-build-25-08-24/            # Frontend builds (extract)
│   ├── 📂 Release/
│   │   └── ecochallenge_desktop.exe  # Desktop application
│   └── 📂 flutter-apk/
│       └── app-release.apk           # Mobile application
│
└── 📄 README.md
```

---

## 🎯 Key Workflows

### User Challenge Workflow

1. **Browse Challenges** - User explores available environmental challenges
2. **Join Challenge** - User registers for a specific challenge
3. **Complete Task** - User performs the environmental action
4. **Submit Proof** - User uploads photo/document evidence
5. **Wait for Review** - Administrator validates submission
6. **Receive Notification** - Email confirmation of approval/rejection
7. **Track Progress** - View completed challenges and impact

### Administrator Workflow

1. **Create Challenge** - Define new environmental challenge
2. **Monitor Requests** - Review incoming challenge registrations
3. **Validate Proofs** - Examine submitted evidence
4. **Approve/Reject** - Make decision on submission validity
5. **Send Notification** - Automated email via RabbitMQ
6. **Analytics Review** - Monitor platform engagement

---

## 🔮 Future Enhancements

- [ ] Social features (user profiles, leaderboards, friend challenges)
- [ ] Gamification elements (badges, points, levels)
- [ ] Community forums and discussion boards
- [ ] Integration with environmental organizations
- [ ] Carbon footprint calculator
- [ ] Challenge templates and categories
- [ ] Advanced analytics and impact reporting
- [ ] Multi-language support
- [ ] Push notifications for mobile app
- [ ] Integration with social media platforms
- [ ] Recurring challenge subscriptions
- [ ] Team-based challenges

---

## 🐳 Docker Services

The application runs the following services via Docker Compose:

- **Backend API** - ASP.NET Core Web API
- **SQL Server** - Database service
- **RabbitMQ** - Message broker with management UI
- **RabbitMQ Management UI** - Available at `http://localhost:15672`

### Docker Commands

**Start all services:**
```bash
docker compose up --build
```

**Stop all services:**
```bash
docker compose down
```

**View logs:**
```bash
docker compose logs -f
```

**Rebuild specific service:**
```bash
docker compose up --build [service-name]
```

---

## 💡 Usage Tips

**For Administrators:**
- Regularly review pending proof submissions
- Create diverse challenges to maintain user engagement
- Provide clear feedback when rejecting submissions
- Monitor analytics to identify popular challenge types

**For Users:**
- Submit clear, high-quality proof photos
- Read challenge requirements carefully before participating
- Check email regularly for status updates
- Complete challenges before deadlines

**For Developers:**
- Check Docker logs if services fail to start
- Ensure .env files are properly extracted
- Verify Stripe test mode is active
- Monitor RabbitMQ queue for message processing

---

## 🎓 Academic Context

This project was developed as a semester assignment for the **Software Development 2 (Razvoj Softvera 2)** course at the Faculty of Information Technologies, University of Mostar.

**Course Focus:**
- Full-stack application development
- Microservices architecture
- Containerization with Docker
- Message-driven architecture
- Payment integration
- Cross-platform development

---

## 📝 License

This project was created for educational purposes as part of the Software Development 2 course.

---

## 🙏 Acknowledgments

- Faculty of Information Technologies, University of Mostar
- Course instructors for guidance and requirements
- Stripe for payment processing infrastructure
- RabbitMQ team for messaging platform
- Flutter team for cross-platform framework
- Docker for containerization technology
- Microsoft for .NET Core and SQL Server

---

<div align="center">

**⭐ If you find this project useful, give it a star! ⭐**

*Developed with 🌱 for Software Development 2 - 2024*

</div>
