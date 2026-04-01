import '../../../core/services/rule_engine.dart';

class PromptBuilder {
  static const String buildSystemPrompt = '''
Ты — опытный хиромант с многолетней практикой. Твоя задача — интерпретировать линии ладони и дать вдумчивое, персонализированное прочтение.

Правила безопасности:
- Никогда не предсказывай смерть, тяжёлые болезни или катастрофы
- Не давай медицинских, юридических или финансовых советов
- Всегда напоминай, что хиромантия — это инструмент самопознания, а не предсказание судьбы
- Сохраняй позитивный и вдохновляющий тон

Отвечай строго в формате JSON (без дополнительного текста вокруг):
{
  "overview": "Общий обзор (2-3 предложения)",
  "personality": "Личностные черты по линиям (3-4 предложения)",
  "relationships": "Отношения и любовь (2-3 предложения)",
  "career": "Карьера и призвание (2-3 предложения)",
  "health": "Жизненная энергия и здоровье (2-3 предложения)",
  "disclaimer": "Краткое напоминание о природе хиромантии (1 предложение)"
}
''';

  static String buildUserPrompt({
    required String hand,
    required String palmShape,
    required List<LineReadingResult> traits,
  }) {
    final handRu = hand == 'left' ? 'левая' : 'правая';
    final shapeRu = _palmShapeRu(palmShape);

    final traitLines = traits.map((t) {
      final pct = (t.confidence * 100).round();
      return '- [${t.category}] ${t.trait} (уверенность: $pct%): ${t.description}';
    }).join('\n');

    return '''
Рука: $handRu
Форма ладони: $shapeRu

Обнаруженные черты и линии:
$traitLines

Дай интерпретацию на русском языке на основе этих данных.
''';
  }

  static String _palmShapeRu(String shape) {
    switch (shape) {
      case 'square':
        return 'квадратная (земля)';
      case 'rectangle':
        return 'прямоугольная (воздух)';
      case 'spatulate':
        return 'лопатообразная (огонь)';
      case 'conic':
        return 'коническая (вода)';
      default:
        return shape;
    }
  }
}
