# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A SwiftUI iOS flashcard application for learning foreign languages. Users browse topic folders, study cards (word on front, translation + examples on back), and take spaced-repetition tests.

## Build & Run

Open `FlashCards.xcodeproj` in Xcode. All commands assume Xcode 15+ and iOS 17+ deployment target.

```bash
# Build from CLI
xcodebuild -project FlashCards.xcodeproj -scheme FlashCards -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -project FlashCards.xcodeproj -scheme FlashCards -destination 'platform=iOS Simulator,name=iPhone 15'

# Run a single test class
xcodebuild test -project FlashCards.xcodeproj -scheme FlashCards -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FlashCardsTests/SpacedRepetitionTests

# Lint (if SwiftLint is configured)
swiftlint lint --config .swiftlint.yml
```

## Architecture

### Pattern: MVVM + Repository

- **Models** — pure Swift structs/enums, `Codable`, no UI imports
- **Repositories** — data access layer; abstract over SwiftData/CoreData persistence
- **ViewModels** — `@Observable` classes owned by views; contain business logic, call repositories
- **Views** — SwiftUI views; receive ViewModels via `@State` or environment

### Core Modules

**`Models/`**
- `Topic` — folder-like container: `id`, `name`, `language`, `targetLanguage`, `createdAt`
- `Card` — `id`, `topicId`, `word`, `translation`, `examples: [Example]`, `notes`
- `Example` — `sentence`, `translation`
- `ReviewRecord` — per-card SRS state: `cardId`, `interval`, `easeFactor`, `dueDate`, `repetitions`, `lastResult`

**`Persistence/`**
- `FlashCardsStore` — SwiftData `ModelContainer` configuration; single source of truth
- `TopicRepository` — CRUD for `Topic`
- `CardRepository` — CRUD for `Card`; queries by `topicId`
- `ReviewRepository` — fetch/update `ReviewRecord`; query cards due today

**`SRS/`** (Spaced Repetition System)
- `SRSEngine` — stateless struct implementing the SM-2 algorithm
  - `Rating` enum: `.bad`, `.okay`, `.good`
  - `func nextReview(record: ReviewRecord, rating: Rating) -> ReviewRecord`
  - Bad resets interval to 1 day; Okay applies a reduced ease multiplier; Good follows standard SM-2
- `DueCardSelector` — fetches `ReviewRecord`s with `dueDate <= Date.now`, sorted by overdue amount

**`ViewModels/`**
- `TopicListViewModel` — loads all topics, handles create/delete/rename
- `CardListViewModel(topicId:)` — loads cards for a topic, handles add/edit/delete
- `StudyViewModel(topicId:)` — drives card-flip study mode (no rating, just review)
- `TestViewModel(topicId:)` — drives SRS test session: presents due cards, accepts `.bad/.okay/.good`, updates `ReviewRecord` via `SRSEngine`, persists via `ReviewRepository`
- `CardEditorViewModel` — form state for creating/editing a card and its examples

**`Views/`**
- `TopicListView` — grid or list of topic folders
- `TopicDetailView` — card list inside a topic + entry points for study and test
- `CardDetailView` — full card with flip animation showing word → translation + examples
- `StudyView` — sequential card viewer, no rating
- `TestView` — SRS session: shows word, user flips, taps Bad/Okay/Good
- `CardEditorView` — form for word, translation, examples, notes
- `StatisticsView` — per-topic: total cards, due today, average ease, retention rate

### Data Persistence

SwiftData is the persistence layer. All four model types (`Topic`, `Card`, `Example`, `ReviewRecord`) are annotated with `@Model`. A single `ModelContainer` is injected into the SwiftUI environment at app startup via `.modelContainer(FlashCardsStore.shared.container)`.

`ReviewRecord` is created on first review of a card; absence means the card has never been tested and is always considered due.

### SRS Algorithm (SM-2 variant)

- **Good**: `newInterval = max(1, interval * easeFactor)`, `easeFactor += 0.1`, `repetitions += 1`
- **Okay**: `newInterval = max(1, interval * easeFactor * 0.8)`, easeFactor unchanged, `repetitions += 1`
- **Bad**: `newInterval = 1`, `easeFactor = max(1.3, easeFactor - 0.2)`, `repetitions = 0`
- `dueDate = Date.now + newInterval days`
- Minimum ease factor: 1.3. New cards start with `easeFactor = 2.5`, `interval = 1`.

### Navigation

Uses SwiftUI `NavigationStack` with a typed `NavigationPath`. Route enum lives in `AppRouter`. Deep-link pattern: `Topic → TopicDetail → [Study | Test | CardEditor]`.

### Statistics

`StatisticsService` computes from `ReviewRecord`s: cards due today, 7-day retention rate (Good+Okay / total reviews in window), average ease factor. Exposed to `StatisticsView` via `StatisticsViewModel`.

## Key Conventions

- All `@Model` classes use UUID primary keys; foreign key relationships use stored `UUID` fields, not SwiftData `@Relationship`, to keep deletion rules explicit.
- `SRSEngine` is a pure function — no side effects, fully unit-testable without SwiftData.
- ViewModels use `@MainActor`; repositories are `Sendable` structs that receive a `ModelContext`.
- Test targets: `FlashCardsTests` (unit — SRS logic, ViewModels with in-memory SwiftData), `FlashCardsUITests` (UI smoke tests).
