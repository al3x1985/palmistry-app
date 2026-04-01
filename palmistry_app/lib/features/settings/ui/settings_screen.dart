import 'package:flutter/material.dart';

import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          const _SectionLabel(label: 'Оформление'),
          // ignore: prefer_const_constructors
          _SettingsTile(
            icon: Icons.dark_mode,
            iconColor: const Color(0xFF7C3AED),
            title: 'Тёмная тема',
            subtitle: 'Единственный доступный режим',
            // ignore: prefer_const_constructors
            trailing: Switch(
              value: true,
              onChanged: null, // dark only for MVP
              activeThumbColor: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 8),

          // About section
          const _SectionLabel(label: 'Информация'),
          _SettingsTile(
            icon: Icons.auto_stories,
            iconColor: const Color(0xFF9C27B0),
            title: 'О приложении',
            subtitle: 'Хиромантия — искусство чтения ладони',
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AboutScreen(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            icon: Icons.info_outline,
            iconColor: Colors.white38,
            title: 'Версия',
            subtitle: '1.0.0',
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // Legal section
          const _SectionLabel(label: 'Юридическое'),
          const _SettingsTile(
            icon: Icons.security,
            iconColor: Color(0xFF2196F3),
            title: 'Конфиденциальность',
            subtitle: 'Фото не сохраняется на сервере',
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          const _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: Colors.white38,
            title: 'Отказ от ответственности',
            subtitle: 'Приложение не даёт медицинских советов',
            trailing: SizedBox.shrink(),
          ),
          const SizedBox(height: 32),

          // Footer
          const Center(
            child: Column(
              children: [
                Icon(Icons.back_hand, color: Color(0xFF7C3AED), size: 32),
                SizedBox(height: 8),
                Text(
                  'Palmistry',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Сделано с ✦ для саморефлексии',
                  style: TextStyle(
                    color: Color(0x32FFFFFF),
                    fontSize: 12,
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

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
