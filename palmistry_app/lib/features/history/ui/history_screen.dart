import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/history_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryBloc()..add(const LoadHistory()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История сканирований'),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<HistoryBloc>().add(const LoadHistory()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading || state is HistoryInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
            );
          }

          if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<HistoryBloc>()
                        .add(const LoadHistory()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is HistoryLoaded) {
            if (state.entries.isEmpty) {
              return _EmptyState();
            }
            return _HistoryList(entries: state.entries);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7C3AED).withAlpha(30),
            ),
            child: const Icon(
              Icons.history,
              color: Color(0xFF7C3AED),
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Сканирований пока нет',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Перейдите на вкладку Сканер,\nчтобы начать первое чтение',
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryEntry> entries;

  const _HistoryList({required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, i) => _HistoryCard(entry: entries[i]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;

  const _HistoryCard({required this.entry});

  String _shapeLabel(String? shape) {
    switch (shape) {
      case 'square':
        return 'Квадратная (Земля)';
      case 'rectangle':
        return 'Прямоугольная (Воздух)';
      case 'spatulate':
        return 'Лопатообразная (Огонь)';
      case 'conic':
        return 'Коническая (Вода)';
      default:
        return 'Неизвестная форма';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = entry.scan;
    final isLeft = scan.hand == 'left';
    final dateStr =
        DateFormat('d MMM yyyy, HH:mm', 'ru').format(scan.createdAt);
    final hasInterpretation = scan.aiInterpretationJson != null;

    return Dismissible(
      key: Key('scan_${scan.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            title: const Text(
              'Удалить запись?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Это действие нельзя отменить.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<HistoryBloc>().add(DeleteHistoryEntry(scan.id));
      },
      child: GestureDetector(
        onTap: () => context.push('/result/${scan.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasInterpretation
                  ? const Color(0xFF7C3AED).withAlpha(60)
                  : Colors.white.withAlpha(15),
            ),
          ),
          child: Row(
            children: [
              // Hand icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Transform.scale(
                  scaleX: isLeft ? -1.0 : 1.0,
                  child: const Icon(
                    Icons.back_hand,
                    color: Color(0xFF7C3AED),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isLeft ? 'Левая рука' : 'Правая рука',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        if (hasInterpretation) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF7C3AED),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shapeLabel(scan.palmShape),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timeline, color: Colors.white38, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.lineCount} линий',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, color: Colors.white38, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
