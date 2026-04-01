import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/interpretation.dart';
import '../../../core/services/rule_engine.dart';
import '../../../data/local/database.dart';
import '../bloc/reading_bloc.dart';
import 'follow_up_chat.dart';

class ReadingResultScreen extends StatelessWidget {
  final int scanId;

  const ReadingResultScreen({super.key, required this.scanId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReadingBloc()..add(LoadReading(scanId)),
      child: _ReadingResultView(scanId: scanId),
    );
  }
}

class _ReadingResultView extends StatelessWidget {
  final int scanId;

  const _ReadingResultView({required this.scanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ReadingBloc, ReadingState>(
        builder: (context, state) {
          if (state is ReadingLoading || state is ReadingInitial) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF7C3AED)),
                  SizedBox(height: 16),
                  Text(
                    'Читаем линии ладони...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          if (state is ReadingError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ReadingBloc>().add(LoadReading(scanId)),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is ReadingTraitsLoaded) {
            return _TraitsView(
              scanId: scanId,
              traits: state.traits,
              scanData: state.scanData,
            );
          }

          if (state is ReadingInterpretationLoaded) {
            return _FullReadingView(
              scanId: scanId,
              traits: state.traits,
              interpretation: state.interpretation,
              scanData: state.scanData,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Traits view — before AI interpretation
// ---------------------------------------------------------------------------

class _TraitsView extends StatelessWidget {
  final int scanId;
  final List<LineReadingResult> traits;
  final PalmScan scanData;

  const _TraitsView({
    required this.scanId,
    required this.traits,
    required this.scanData,
  });

  @override
  Widget build(BuildContext context) {
    final shape = _palmShapeLabel(scanData.palmShape);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Прочтение ладони'),
            background: _headerGradient(),
          ),
          leading: const BackButton(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PalmShapeBadge(label: shape),
                const SizedBox(height: 24),
                _TraitCategorySection(
                  title: 'Любовь и отношения',
                  icon: Icons.favorite,
                  color: const Color(0xFFE91E63),
                  traits: traits.where((t) => t.category == 'love').toList(),
                ),
                _TraitCategorySection(
                  title: 'Личность',
                  icon: Icons.psychology,
                  color: const Color(0xFF7C3AED),
                  traits:
                      traits.where((t) => t.category == 'personality').toList(),
                ),
                _TraitCategorySection(
                  title: 'Карьера',
                  icon: Icons.work,
                  color: const Color(0xFF2196F3),
                  traits: traits.where((t) => t.category == 'career').toList(),
                ),
                _TraitCategorySection(
                  title: 'Здоровье',
                  icon: Icons.favorite_border,
                  color: const Color(0xFF4CAF50),
                  traits: traits.where((t) => t.category == 'health').toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context
                        .read<ReadingBloc>()
                        .add(GenerateInterpretation(scanId)),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Получить интерпретацию ИИ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Full reading view — with AI interpretation
// ---------------------------------------------------------------------------

class _FullReadingView extends StatelessWidget {
  final int scanId;
  final List<LineReadingResult> traits;
  final PalmInterpretation interpretation;
  final PalmScan scanData;

  const _FullReadingView({
    required this.scanId,
    required this.traits,
    required this.interpretation,
    required this.scanData,
  });

  @override
  Widget build(BuildContext context) {
    final shape = _palmShapeLabel(scanData.palmShape);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Прочтение ладони'),
            background: _headerGradient(),
          ),
          leading: const BackButton(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PalmShapeBadge(label: shape),
                const SizedBox(height: 24),

                // Overview card
                _InterpretationCard(
                  title: 'Общий обзор',
                  content: interpretation.overview,
                  icon: Icons.auto_awesome,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7C3AED)],
                  ),
                ),
                const SizedBox(height: 12),

                // Personality
                _InterpretationCard(
                  title: 'Личность',
                  content: interpretation.personality,
                  icon: Icons.psychology,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF311B92), Color(0xFF5E35B1)],
                  ),
                ),
                const SizedBox(height: 12),

                // Relationships
                _InterpretationCard(
                  title: 'Отношения',
                  content: interpretation.relationships,
                  icon: Icons.favorite,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF880E4F), Color(0xFFE91E63)],
                  ),
                ),
                const SizedBox(height: 12),

                // Career
                _InterpretationCard(
                  title: 'Карьера',
                  content: interpretation.career,
                  icon: Icons.work,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF2196F3)],
                  ),
                ),
                const SizedBox(height: 12),

                // Health
                _InterpretationCard(
                  title: 'Здоровье и энергия',
                  content: interpretation.health,
                  icon: Icons.spa,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  ),
                ),

                if (interpretation.disclaimer != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.white38,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            interpretation.disclaimer!,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Trait summary
                const Text(
                  'Обнаруженные черты',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: traits
                      .map((t) => _TraitChip(trait: t))
                      .toList(),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openFollowUp(context),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Задать вопрос'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                          side: const BorderSide(color: Color(0xFF7C3AED)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Сохранить'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openFollowUp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FollowUpChatSheet(
        scanId: scanId,
        palmShape: scanData.palmShape ?? 'square',
        hand: scanData.hand,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

Widget _headerGradient() {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A148C), Color(0xFF1A1A2E)],
      ),
    ),
    child: const Center(
      child: Icon(Icons.back_hand, color: Colors.white24, size: 80),
    ),
  );
}

String _palmShapeLabel(String? shape) {
  switch (shape) {
    case 'square':
      return 'Квадратная ладонь (Земля)';
    case 'rectangle':
      return 'Прямоугольная ладонь (Воздух)';
    case 'spatulate':
      return 'Лопатообразная ладонь (Огонь)';
    case 'conic':
      return 'Коническая ладонь (Вода)';
    default:
      return 'Форма ладони неизвестна';
  }
}

class _PalmShapeBadge extends StatelessWidget {
  final String label;

  const _PalmShapeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.back_hand, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TraitCategorySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<LineReadingResult> traits;

  const _TraitCategorySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.traits,
  });

  @override
  Widget build(BuildContext context) {
    if (traits.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...traits.map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: color, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.trait,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    _ConfidenceDots(confidence: t.confidence),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ConfidenceDots extends StatelessWidget {
  final double confidence;

  const _ConfidenceDots({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final filled = (confidence * 5).round().clamp(1, 5);
    return Row(
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.only(left: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < filled
                ? const Color(0xFF7C3AED)
                : Colors.white.withAlpha(40),
          ),
        );
      }),
    );
  }
}

class _InterpretationCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Gradient gradient;

  const _InterpretationCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final LineReadingResult trait;

  const _TraitChip({required this.trait});

  Color _categoryColor(String category) {
    switch (category) {
      case 'love':
        return const Color(0xFFE91E63);
      case 'career':
        return const Color(0xFF2196F3);
      case 'health':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(trait.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        trait.trait,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
