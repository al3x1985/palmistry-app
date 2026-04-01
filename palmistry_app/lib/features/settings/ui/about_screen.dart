import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О приложении')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo / header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4A148C)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withAlpha(100),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.back_hand, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Хиромантия',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Искусство чтения ладони',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // About palmistry
          const _AboutSection(
            title: 'Что такое хиромантия?',
            content: '''Хиромантия — одна из древнейших практик самопознания, известная человечеству на протяжении тысячелетий. Её истоки прослеживаются в Древней Индии, Китае, Египте и Греции.

Само слово происходит от греческих «хеир» (рука) и «мантейя» (предсказание). Однако в современном понимании хиромантия — это прежде всего инструмент для размышления о своём характере, потенциале и жизненных тенденциях.

Каждая линия, холм и форма ладони несут символическое значение. Глубокая линия сердца говорит об эмоциональной насыщенности, длинная линия головы — о широте мышления, а уверенная линия жизни отражает жизненную силу.

Хиромантия не является наукой в академическом смысле. Это язык символов, помогающий увидеть себя под другим углом, задать важные вопросы и, возможно, открыть в себе то, о чём раньше не задумывались.''',
          ),
          const SizedBox(height: 16),

          const _AboutSection(
            title: 'Как работает приложение?',
            content: '''Приложение использует компьютерное зрение для анализа снимка вашей ладони. Алгоритм обнаруживает основные линии: линию сердца, головы, жизни и судьбы — и определяет форму ладони.

На основе обнаруженных линий встроенный движок правил формирует описание характерных черт. При желании вы можете запросить расширенную интерпретацию с помощью искусственного интеллекта.

Вы также можете отредактировать линии вручную в редакторе, если автоматическое распознавание не уловило какие-то детали.

История всех ваших сканирований сохраняется на устройстве.''',
          ),
          const SizedBox(height: 16),

          // Privacy section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C3AED).withAlpha(60)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Color(0xFF7C3AED), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Конфиденциальность',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Фото ладони обрабатывается на сервере и не сохраняется. '
                  'Все результаты анализа хранятся исключительно на вашем устройстве. '
                  'Мы не передаём персональные данные третьим лицам.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white38, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Отказ от ответственности',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Приложение создано исключительно в развлекательных и образовательных '
                  'целях. Интерпретации не являются медицинскими, психологическими или '
                  'юридическими советами. Все описания носят символический характер '
                  'и предназначены для саморефлексии.',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final String content;

  const _AboutSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
