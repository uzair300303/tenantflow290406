<div align="center">
  
# 🏠 TenantFlow

### *Simplifying Tenant Life, One Feature at a Time*

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

*A comprehensive tenant management application designed to streamline rental living experiences through modern technology.*

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Tech Stack](#-tech-stack) • [Team](#-team)

</div>

---

## 📖 About

**TenantFlow** is a modern, feature-rich mobile application built with Flutter that revolutionizes the tenant experience. From managing rent payments to submitting maintenance requests, TenantFlow provides an all-in-one solution for tenants to seamlessly interact with property management.

Whether you're paying rent through Razorpay, chatting with an AI-powered assistant, or tracking your payment analytics, TenantFlow has you covered with a beautiful, intuitive interface that works in both light and dark modes.

---

## ✨ Features

### 🔐 **Authentication & Security**
- Email & Password authentication
- Google Sign-In integration
- Apple Sign-In support
- Secure Firebase Authentication
- Profile verification system

### 💰 **Payment Management**
- Integrated Razorpay payment gateway
- Real-time payment tracking
- Payment history with detailed records
- Automated payment receipts
- Cloud Firestore storage for payment data
- Visual payment analytics

### 📊 **Analytics Dashboard**
- Interactive charts powered by FL Chart
- Payment trends visualization
- Spending insights
- Monthly and yearly breakdowns

### 🔧 **Maintenance & Requests**
- Submit maintenance requests with images
- Track request status
- Real-time updates via notifications
- Service rating system
- Maintenance management for landlords

### 🤖 **AI-Powered Features**
- Intelligent chatbot using Google Generative AI
- Translation bot supporting multiple languages
- Natural language processing for queries
- Context-aware responses

### 🌐 **Community & Communication**
- Community forum for tenants
- Direct communication channels
- Email integration via URL launcher
- Push notifications with Firebase Cloud Messaging

### ⚙️ **Settings & Customization**
- Dark mode / Light mode toggle
- User profile management
- Image upload for profile pictures
- Notification preferences
- Personalized dashboard

### 🔔 **Notifications**
- Local notifications
- Firebase Remote Config integration
- Scheduled reminders
- Payment due alerts
- Maintenance update notifications

---

## 📱 Screenshots

<div align="center">

| Home Screen | Payment Portal | Analytics |
|------------|---------------|-----------|
| *Beautiful carousel with property images* | *Secure Razorpay integration* | *Visual spending insights* |

| Chatbot | Profile | Dark Mode |
|---------|---------|-----------|
| *AI-powered assistance* | *Comprehensive user profiles* | *Eye-friendly dark theme* |

</div>

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Razorpay account (for payment integration)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tenantflow.git
   cd tenantflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase Console
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories
   - Enable Authentication, Firestore, and Cloud Storage

4. **Configure API Keys**
   - Add your Google Generative AI API key in `constants.dart`
   - Configure Razorpay keys in the payment page

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🛠️ Tech Stack

### **Frontend**
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management
- **Material Design** - UI components

### **Backend & Services**
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Firebase Remote Config** - Remote configuration
- **Firebase Cloud Messaging** - Push notifications

### **Payment Integration**
- **Razorpay** - Payment gateway for web

### **AI & Intelligence**
- **Google Generative AI** - Chatbot functionality
- **Translator Package** - Multi-language support

### **Additional Libraries**
- `fl_chart` - Beautiful charts and graphs
- `image_picker` - Image selection
- `flutter_local_notifications` - Local notifications
- `carousel_slider` - Image carousels
- `shared_preferences` - Local data persistence
- `url_launcher` - URL and email launching
- `permission_handler` - Runtime permissions

---

## 📁 Project Structure

```
lib/
├── components/         # Reusable UI components
│   ├── my_button.dart
│   ├── my_textfield.dart
│   └── square_tile.dart
├── models/            # Data models
│   └── payment_record.dart
├── pages/             # Application screens
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── rent_payment_page.dart
│   ├── maintenance_request_page.dart
│   ├── chatbot_page.dart
│   ├── analytics_page.dart
│   ├── community_page.dart
│   ├── tenant_profile_page.dart
│   ├── settings_page.dart
│   └── ...
├── services/          # Business logic
│   ├── auth_service.dart
│   ├── notification_service.dart
│   └── payment_storage_service.dart
├── constants.dart     # App constants
├── firebase_options.dart
└── main.dart          # Entry point
```

---

## 🔑 Key Features Explained

### 💳 Payment System
TenantFlow integrates Razorpay for secure online payments. Tenants can:
- Pay rent with a few taps
- View detailed payment history
- Download payment receipts
- Track payment analytics

### 🤖 AI Chatbot
Powered by Google's Generative AI, the chatbot can:
- Answer tenant queries
- Provide property information
- Assist with app navigation
- Support markdown formatting for rich responses

### 🌍 Translation Bot
Breaking language barriers with:
- Real-time text translation
- Support for multiple languages
- Easy-to-use interface
- Perfect for international tenants

### 📈 Analytics
Visual insights into your spending:
- Interactive pie and bar charts
- Monthly/yearly comparisons
- Payment category breakdown
- Export-ready data

---

## 🔒 Security Features

- Secure Firebase Authentication
- Encrypted data transmission
- PCI-compliant payment processing via Razorpay
- Permission-based access control
- Secure cloud storage

---

## 🌙 Theme Support

TenantFlow comes with beautiful light and dark themes:
- **Light Mode**: Clean, professional look for daytime use
- **Dark Mode**: Eye-friendly design for low-light environments
- Seamless theme switching
- Consistent color schemes

---

## 📲 Notifications

Stay updated with:
- Local push notifications
- Payment reminders
- Maintenance request updates
- Community announcements
- Customizable notification preferences

---

## 👥 Team

Developed with ❤️ by students from **RV University**:

- **Uzair Sunkad** - Developer
- **Shayan Azmi** - Developer  
- **Mohammed Fouzan** - Developer

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact & Support

For questions, suggestions, or support:
- 📧 Email: [your-email@example.com]
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/tenantflow/issues)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Razorpay for payment solutions
- Google AI for generative AI capabilities
- The open-source community

---

<div align="center">

### ⭐ Star this repository if you find it helpful!

**Made with Flutter & Firebase**

*TenantFlow - Making rental living effortless*

</div>
