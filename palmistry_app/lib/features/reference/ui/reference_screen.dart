import 'package:flutter/material.dart';

class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Справочник хиромантии')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader(
            title: 'Линии ладони',
            subtitle: 'Основные линии и их значение',
          ),
          _ReferenceSection(
            title: 'Линия сердца',
            icon: Icons.favorite,
            color: Color(0xFFE91E63),
            content: '''Линия сердца — горизонтальная линия в верхней части ладони, отражающая эмоциональную сферу человека: любовь, отношения, сердечные привязанности.

Длинная и глубокая линия говорит о страстной, преданной натуре, способной на глубокие чувства. Такой человек ценит стабильность в отношениях и склонен к долгосрочным связям.

Прямая линия сердца указывает на практичный подход к любви. Человек ценит рациональность и предпочитает спокойные, устойчивые отношения.

Изогнутая, восходящая линия означает открытость, теплоту и щедрость в чувствах. Такие люди легко выражают эмоции и создают уютную атмосферу вокруг себя.

Короткая линия может указывать на склонность к самодостаточности и независимости в отношениях. Это не плохой знак — просто человек ценит личное пространство.

Наличие мелких веточек и ответвлений обогащает линию: каждая ветвь символизирует значимый эмоциональный опыт.''',
          ),
          SizedBox(height: 12),
          _ReferenceSection(
            title: 'Линия головы',
            icon: Icons.psychology,
            color: Color(0xFF2196F3),
            content: '''Линия головы проходит горизонтально через среднюю часть ладони и отражает мыслительные способности, стиль мышления и интеллектуальные склонности.

Длинная линия головы свидетельствует о широком кругозоре, стратегическом мышлении и способности удерживать в уме множество идей одновременно.

Прямая линия говорит об аналитическом, логическом уме. Такой человек мыслит структурированно, хорошо работает с числами и фактами.

Наклонная или изогнутая линия указывает на творческое мышление, богатое воображение и художественный вкус. Таким людям хорошо даются искусство, писательство, музыка.

Глубокая линия означает концентрацию и способность к сосредоточенной работе. Раздвоение в конце («вилка писателя») — знак умения видеть ситуацию с разных сторон.

Короткая, но отчётливая линия говорит о чёткости мышления и умении быстро принимать решения.''',
          ),
          SizedBox(height: 12),
          _ReferenceSection(
            title: 'Линия жизни',
            icon: Icons.spa,
            color: Color(0xFF4CAF50),
            content: '''Линия жизни — дугообразная линия, огибающая основание большого пальца. Вопреки распространённому мифу, она не предсказывает продолжительность жизни, а отражает жизненную энергию, здоровье и качество жизненного пути.

Длинная и глубокая линия жизни означает крепкое здоровье, высокую жизненную энергию и стойкость. Такой человек восстанавливается быстро и редко болеет.

Широкая дуга указывает на энтузиазм, оптимизм и жажду жизни. Такие люди любят приключения и открыты новому опыту.

Узкая дуга, прижатая к большому пальцу, говорит о бережном расходовании сил. Это не слабость — просто человек живёт в своём ритме и не разбрасывается энергией.

Ответвления, идущие вверх, символизируют взлёты и новые начинания. Ответвления вниз могут указывать на периоды восстановления и переосмысления.

Наличие двойной линии жизни — дополнительной «защитной» линии рядом — традиционно считается знаком внутренней силы и поддержки близких.''',
          ),
          SizedBox(height: 12),
          _ReferenceSection(
            title: 'Линия судьбы',
            icon: Icons.stars,
            color: Color(0xFFFFB300),
            content: '''Линия судьбы (линия Сатурна) — вертикальная линия в центре ладони. Она есть не у всех, и её отсутствие не несёт негативного смысла — просто такие люди строят жизнь более свободно, без жёсткого предназначения.

Чёткая, непрерывная линия судьбы говорит о ясном жизненном пути, устойчивой профессиональной идентичности и внутренней направленности.

Начало линии у основания ладони указывает на раннее осознание своего призвания. Начало в середине ладони — путь начинается позже, после периода поиска себя.

Прерывистая линия отражает перемены в жизненном курсе: смены профессии, переезды, кардинальные решения. Это не плохой знак — это гибкость и способность меняться.

Раздвоение линии в конце указывает на множество путей в зрелости, творческую разносторонность или совмещение разных сфер деятельности.

Соединение линии судьбы с линией сердца традиционно трактуется как гармония между призванием и личными ценностями.''',
          ),
          SizedBox(height: 24),
          _SectionHeader(
            title: 'Формы ладони',
            subtitle: 'Четыре стихии в хиромантии',
          ),
          _ReferenceSection(
            title: 'Формы ладони',
            icon: Icons.back_hand,
            color: Color(0xFF9C27B0),
            content: '''В классической хиромантии выделяют четыре формы ладони, связанных с четырьмя стихиями.

Земля (квадратная ладонь): широкая, квадратная форма с относительно короткими пальцами. Характеризует людей практичных, надёжных, укоренённых. Они ценят стабильность, труд и результат. Хорошие организаторы и исполнители.

Воздух (прямоугольная ладонь): прямоугольная форма с длинными пальцами. Указывает на интеллектуальную природу: общительность, любознательность, умение анализировать и коммуницировать. Такие люди любят идеи и разговоры.

Огонь (лопатообразная ладонь): широкая ладонь с расширяющимися к кончикам пальцами. Символ энергии, предприимчивости и страсти. Люди-«огонь» действуют быстро, зажигают других своим энтузиазмом, любят риск.

Вода (коническая ладонь): узкая, вытянутая ладонь с длинными коническими пальцами. Говорит о чуткости, интуиции, эмпатии и творческой натуре. Такие люди тонко чувствуют атмосферу и настроение других.

Важно помнить: каждый человек уникален, и форма ладони — лишь одна грань характера.''',
          ),
          SizedBox(height: 24),
          _DisclaimerCard(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ReferenceSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String content;

  const _ReferenceSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
  });

  @override
  State<_ReferenceSection> createState() => _ReferenceSectionState();
}

class _ReferenceSectionState extends State<_ReferenceSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: widget.color, width: 3),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.color.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.white38, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Хиромантия — это древнее искусство самопознания. Все интерпретации носят '
              'символический характер и не являются предсказаниями. Используйте их как '
              'приглашение к размышлению о себе.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
