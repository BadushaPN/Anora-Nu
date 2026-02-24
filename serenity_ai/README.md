# Anora Nu 🔮

> **"For thinkers. Not scrollers."**

Anora Nu is a minimalist, self-learning AI companion built with Flutter. Unlike traditional AI chatbots with pre-defined personalities, Anora Nu begins as a **blank canvas**—a "newborn" entity without emotions or pre-conceived traits. It observes, remembers, and learns from you organically through conversation.

---

## 🧘 The Philosophy

Anora Nu is designed for individuals who seek reflection over distraction. The core concept revolves around **Organic AI Growth**:
1. **Blank Canvas**: The companion starts with zero knowledge of you. It doesn't have a "vibe" until you give it one through interaction.
2. **Deep Memory**: It doesn't just chat; it *listens*. It extracts goals, emotional patterns, facts, and commitments from your words.
3. **Growth Partnership**: Once it learns who you are, it becomes your growth partner. It holds you accountable, detects contradictions in your mindset, and challenges you to be the best version of yourself.

---

## 🛠️ Technical Architecture

Anora Nu is built with a focus on **privacy-first local storage** and **intelligent memory extraction**.

### Core Stack
- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform UI)
- **State Management**: [GetX](https://pub.dev/packages/get) (Reactive state & Dependency Injection)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) (High-performance NoSQL)
- **AI Engine**: [OpenAI GPT-4o-mini](https://openai.com/) (Context-aware responses & memory extraction)

### Key Modules
- **Memory extraction**: A dual-call API system. After every response, a secondary analysis pass extracts structured data (goals, facts, patterns) into local storage.
- **Memory Injection**: Dynamic system prompt construction that injects relevant past memories back into the context window.
- **Companion Evolution**: A maturity system (Newborn → Growing → Maturing → Wise) that alters the AI's behavior based on the depth of your shared history.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- An OpenAI API Key

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/anora_nu.git
   cd anora_nu
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

4. **API Setup**: Once the app is running, navigate to the **Settings** screen and enter your OpenAI API Key.

---

## 🗺️ Roadmap

- [x] **Phase 1**: Infrastructure & Memory Architecture (MVP)
- [x] **Phase 2**: Organic Learning System & Contradiction Detection
- [ ] **Phase 3**: Voice Interaction & Biometric Privacy Lock
- [ ] **Phase 4**: Multi-model support (Local LLMs via Ollama/LocalAI)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*“The more we talk, the more I understand. The more I understand, the more you grow.”*
