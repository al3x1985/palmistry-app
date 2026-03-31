# Palmistry App — Design Spec

## Overview

Мобильное приложение для анализа ладони с реальным CV-распознаванием линий, ручной корректировкой и интерпретацией по правилам хиромантии. Ключевое отличие от конкурентов — настоящее распознавание линий (не LLM-галлюцинация), возможность корректировки через bezier-редактор и rule-based интерпретация с AI-обогащением.

**Целевая аудитория:** русскоязычные пользователи, интересующиеся хиромантией — от новичков до практикующих.

**Продуктовый фокус:** точное распознавание + честная интерпретация по правилам, а не симулятор с анимацией "сканера".

## Tech Stack

**Мобильное приложение:**
- Flutter (Dart) — Android only в MVP
- BLoC (flutter_bloc) — state management
- MediaPipe Hands — реалтайм landmarks (21 точка)
- Flutter Canvas API — bezier-редактор линий
- Drift/SQLite — локальное хранение
- GoRouter — навигация
- get_it — DI
- Firebase Analytics + Crashlytics

**Сервер (CV Pipeline):**
- Python 3.12 + FastAPI
- OpenCV — предобработка, edge detection, контурный анализ
- Rule-based классификация линий (по позиции относительно landmarks)
- Docker → Google Cloud Run (автоскейл, pay-per-use)

**AI интерпретация:**
- Firebase Cloud Function → Claude API (как в таро-приложении)

## Architecture

### Пайплайн (5 шагов)

1. **Камера + MediaPipe (на устройстве)** — реалтайм детекция руки, 21 landmark, контур ладони. Пользователь видит точки мгновенно.
2. **Cloud Run — CV Pipeline (Python)** — предобработка → Canny edge detection → контурный анализ → rule-based классификация линий → bezier fitting → вычисление характеристик (длина, глубина, кривизна, начало/конец).
3. **Bezier-редактор (на устройстве)** — распознанные линии показаны как цветные кривые с контрольными точками. Пользователь может перетаскивать точки, удалять линию, добавлять новую.
4. **Rule Engine (на устройстве)** — ~65 правил хиромантии (JSON-конфиг) вычисляют профиль из 15-20 характеристик с confidence score.
5. **Claude API (Cloud Function)** — получает структурированный профиль → генерирует связную персонализированную интерпретацию на русском.

### CV Pipeline (сервер, подробно)

1. **Предобработка:** grayscale, CLAHE (контраст), Gaussian blur, ROI crop по landmarks
2. **Edge detection:** Canny + adaptive threshold → бинарная карта линий
3. **Контурный анализ:** findContours → фильтрация по длине/площади → кандидаты линий
4. **Классификация (rule-based в MVP):** позиция контура относительно landmarks определяет тип. Линия между средним и указательным пальцем на высоте 60-70% ладони → линия сердца. В v2 заменяется на CNN.
5. **Bezier fitting:** аппроксимация каждой линии кубической кривой Безье (4-8 контрольных точек)
6. **Характеристики:** длина (в пикселях, нормализованная к размеру ладони), глубина (по интенсивности пикселей вдоль линии), кривизна, начальная/конечная точка (относительно landmarks/бугорков)

### Структура проекта

```
palmistry_app/
├── lib/
│   ├── app/                    — роутинг, тема, DI
│   ├── features/
│   │   ├── scanner/            — камера, MediaPipe, захват фото
│   │   ├── editor/             — просмотр линий, bezier-редактор
│   │   ├── reading/            — интерпретация, rule engine, Claude
│   │   ├── history/            — история сканирований
│   │   ├── reference/          — справочник хиромантии
│   │   ├── onboarding/         — первый запуск
│   │   └── settings/           — настройки, о приложении
│   ├── core/                   — модели, правила хиромантии, DI
│   └── data/                   — SQLite, API клиенты
├── assets/
│   ├── rules/                  — JSON-конфиги правил хиромантии
│   └── content/                — справочные тексты
├── server/
│   ├── cv_pipeline/            — Python FastAPI + OpenCV
│   ├── Dockerfile
│   └── requirements.txt
└── firebase/
    └── functions/              — Cloud Function (Claude proxy)
```

## Screens & Navigation

Bottom Tab Bar с 4 табами: Сканер, История, Справочник, Настройки.

### Основной флоу: Сканирование → Редактирование → Интерпретация

**1. Сканер (камера)**
- Камера с MediaPipe landmarks в реалтайме
- Рамка-подсказка для позиционирования ладони
- Статус "Рука найдена" / "Расположите ладонь в рамке"
- Кнопка "Сканировать" + выбор из галереи
- Выбор руки: левая / правая

**2. Обработка (2-5 секунд)**
- Прогресс по шагам: контур → форма → линии → классификация
- Анимация сканирования

**3. Редактор линий**
- Фото ладони с наложенными bezier-линиями
- Каждая линия — свой цвет: сердца (красный), головы (синий), жизни (зелёный), судьбы (жёлтый)
- Контрольные точки: endpoint (круг) + handle (пустой круг)
- Перетаскивание пальцем любой точки
- Список распознанных линий с кнопкой удаления (✕)
- Кнопка "+ Добавить линию" (выбрать тип → поставить точки)
- Кнопка "Далее →"

**4. Результат**
- Форма ладони (бейдж: "Квадратная ладонь — практичность, надёжность")
- Сводка по каждой линии (rule engine): тип + характеристика + описание
- Общая AI-интерпретация (Claude)
- Кнопки: "Задать вопрос" (чат) + "Сохранить"

### Таб: История
- Хронологический список сканирований
- Каждая запись: рука (левая/правая), форма ладони, кол-во линий, дата
- Тап → открывает сохранённый результат

### Таб: Справочник
- Линия сердца — значения, варианты
- Линия головы
- Линия жизни
- Линия судьбы
- Формы ладони (4 стихии)
- Формы пальцев

### Таб: Настройки
- О приложении (полный текст о хиромантии)
- Тема
- Версия

## Data Model

### Локальная БД (Drift / SQLite)

**PalmScan (Сканирование)**
- id: String (PK)
- hand: enum — left / right
- imagePath: String (локальный файл)
- palmShape: String? — square / rectangle / spatulate / conic
- palmWidthRatio: double?
- fingerProportionsJson: String? (JSON)
- status: enum — processing / editing / completed
- aiInterpretationJson: String? (JSON: {overview, personality, relationships, career, health, disclaimer?})
- createdAt: DateTime

**PalmLine (Линия)**
- id: String (PK)
- scanId: String (FK → PalmScan)
- lineType: enum — heart / head / life / fate
- controlPointsJson: String (JSON array of {x, y} bezier points)
- length: double? (нормализованная)
- depth: String? — deep / medium / faint
- curvature: String? — straight / curved / steep
- startPoint: String? (описание: "у бугорка Юпитера")
- endPoint: String? (описание)
- isUserEdited: bool

**LineReading (Характеристика от rule engine)**
- id: String (PK)
- scanId: String (FK → PalmScan)
- lineId: String? (FK → PalmLine, null для формы ладони)
- category: String — personality / love / career / health
- trait: String — "Идеализм в любви"
- confidence: double — 0.0–1.0
- ruleId: String (какое правило сработало)
- description: String (краткое пояснение)

**ScanMessage (Чат)**
- id: String (PK)
- scanId: String (FK → PalmScan)
- role: enum — user / assistant
- content: String
- createdAt: DateTime

### Статусы PalmScan

- `processing` — фото отправлено на сервер, ждём результат
- `editing` — линии распознаны, пользователь в редакторе
- `completed` — интерпретация получена и сохранена

### Формат aiInterpretationJson

```json
{
  "overview": "Общий портрет по ладони",
  "personality": "Черты характера и темперамент",
  "relationships": "Отношения и эмоциональная сфера",
  "career": "Карьера и призвание",
  "health": "Здоровье и витальность (рефлексивно, не диагнозы)",
  "disclaimer": "Опциональный дисклеймер"
}
```

## Rule Engine

### Архитектура

Правила хранятся как JSON-файлы в `assets/rules/`:
- `heart_line.json` (~15 правил)
- `head_line.json` (~12 правил)
- `life_line.json` (~12 правил)
- `fate_line.json` (~10 правил)
- `palm_shape.json` (~10 правил)
- `fingers.json` (~6 правил)

**Итого: ~65 правил в MVP.**

### Формат правила

```json
{
  "id": "heart_long_curved_jupiter",
  "conditions": {
    "lineType": "heart",
    "length": "long",
    "curvature": "curved",
    "endPoint": "jupiter"
  },
  "result": {
    "category": "love",
    "trait": "Идеализм в любви",
    "confidence": 0.85,
    "description": "Длинная изогнутая линия сердца, заканчивающаяся у бугорка Юпитера, говорит о высоких стандартах в отношениях и романтическом идеализме."
  }
}
```

### Как определяются условия

**length:** нормализованная длина линии / ширина ладони. short < 0.5, medium 0.5-0.75, long > 0.75
**depth:** средняя интенсивность пикселей вдоль линии. deep/medium/faint
**curvature:** максимальное отклонение от прямой. straight < 5%, curved 5-15%, steep > 15%
**startPoint / endPoint:** ближайший landmark. "jupiter" = бугорок Юпитера (под указательным), "saturn" = под средним, etc.

### Профиль характеристик

Rule engine выдаёт 15-20 характеристик с confidence. Этот профиль:
1. Показывается пользователю как "сводка по линиям" (офлайн)
2. Передаётся в Claude для связной интерпретации (онлайн)

## AI Interpretation

### Системный промпт

Аналогичен таро-приложению: роль хироманта, safety rules, JSON формат ответа.

**Safety rules:**
- Не ставить медицинских диагнозов
- Не предсказывать смерть или тяжёлые болезни
- Хиромантия как инструмент самопознания, не предсказание судьбы
- Рефлексивный, поддерживающий тон
- Disclaimer по здоровью: "Это символическая интерпретация, не медицинское заключение"

### Промпт для интерпретации

```
Система: Ты — опытный хиромант. Интерпретируешь ладонь по правилам классической хиромантии.

Данные:
- Рука: {левая/правая}
- Форма ладони: {тип} — {базовое значение}
- Характеристики: [{trait: "...", category: "...", confidence: 0.85, description: "..."}]

Ответь JSON: {overview, personality, relationships, career, health, disclaimer?}
```

## Приватность

- Фото ладони хранятся ТОЛЬКО локально на устройстве
- На сервер отправляется фото для обработки, НЕ сохраняется после ответа
- Дисклеймер в онбординге: "Фото вашей ладони обрабатывается на сервере и не сохраняется"
- Privacy Policy обязателен (биометрические данные)

## Analytics & Metrics

**CV качество:**
- Доля сканов с 4 найденными линиями
- Доля ручных корректировок (меньше = лучше CV)
- Время обработки на сервере (<5 сек)

**Engagement:**
- Completion rate (сканер → результат)
- Доля follow-up вопросов
- Доля повторных сканирований
- D1/D7/D30 retention

**Events:** `scan_started`, `scan_completed`, `lines_edited`, `lines_edit_count`, `interpretation_generated`, `followup_asked`, `scan_saved`

## Testing

- **Unit:** rule engine (правило → характеристика), bezier math, модели данных
- **Widget:** editor (контрольные точки), результат, сканер-состояния
- **Integration:** полный флоу scan → edit → interpret → save
- **CV Pipeline:** отдельные Python-тесты с fixture-изображениями

## Deployment

- **Cloud Run:** Docker-контейнер с Python CV pipeline, автоскейл
- **Cloud Function:** Claude API proxy (как в таро)
- **CI/CD:** GitHub Actions — Flutter test + build APK + Docker build/push
- **Google Play + RuStore**

## Non-goals MVP

- Второстепенные линии (здоровья, интуиции, Солнца, брака)
- Анализ холмов (бугорков) — требует 3D
- Сравнение сканирований (diff UI)
- Firebase Auth / облачная синхронизация
- Английский язык
- iOS-версия
- Монетизация
- On-device CNN (TFLite)

**Критерий включения в MVP:** только то, что нужно для корректного распознавания 4 линий, их корректировки и осмысленной интерпретации.

## Roadmap

**v1.0 (MVP):** 4 линии (rule-based), форма ладони + пальцы, bezier-редактор, rule engine + Claude, история, справочник

**v2.0:** CNN-классификация, второстепенные линии, сравнение сканов, EN, iOS

**v3.0:** Холмы (3D-анализ), on-device CNN, совместимость пар, монетизация
