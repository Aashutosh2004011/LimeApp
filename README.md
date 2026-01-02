# Shop Floor Lite

An offline-first mobile application built with Flutter for managing manufacturing shop floor operations. Operators can capture downtime events and complete maintenance tasks even without connectivity, while supervisors can monitor and manage alerts.

## Features

### Authentication & Role-Based Access
- Mock JWT authentication (accepts any email)
- Role selection: Operator or Supervisor
- Tenant isolation with unique tenant IDs

### Machine Dashboard
- Real-time status indicators (RUN, IDLE, OFF)
- Color-coded status cards
- Quick access to machine operations

### Downtime Capture (Operator)
- 2-level reason tree selection
- Optional photo attachment (auto-compressed to ≤200KB)
- Start/end workflow for precise duration tracking
- Offline queuing with auto-sync

### Maintenance Checklist (Operator)
- Task statuses: Due, Overdue, Done
- Completion with notes
- Offline support with automatic sync
- Due date tracking

### Alert Management (Supervisor)
- 3-state workflow: Created → Acknowledged → Cleared
- Severity levels: Low, Medium, High, Critical
- Acknowledgment tracking (user & timestamp)
- Tab-based organization

### Summary Reports
- Machine utilization percentage
- Total and average downtime
- Maintenance status overview
- Active and critical alert counts
- MTBF (Mean Time Between Failures)
- Shift-based analysis (last 8 hours)

## Technical Implementation

### Offline-First Architecture
- Local storage with Hive database
- Queue-based operation management
- Automatic sync on connectivity restoration
- UUID-based idempotency
- UI sync indicator

### State Management
- Riverpod for scalable state management
- Provider pattern for separation of concerns
- Reactive UI updates

### Core Services
- DatabaseService: Hive box management
- SyncService: Connectivity monitoring and background sync
- SeedDataService: Initial seed data
- ImageService: Photo capture and compression

## Setup and Run Instructions

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio or Xcode
- Android device or emulator

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate Hive adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building APK

Release build:
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Offline & Sync Strategy

The app uses a queue-based approach for offline functionality:

1. **Local Storage**: All data persists in Hive database, operations work without internet
2. **Sync Queue**: Each operation has an `isSynced` flag, pending count shown in app bar
3. **Connectivity Monitoring**: Uses `connectivity_plus` to detect network changes
4. **Auto-Sync**: Triggers automatically when connection restored
5. **Idempotency**: UUID-based IDs prevent duplicate uploads

### Testing Offline Mode

1. Enable airplane mode
2. Perform operations (capture downtime, complete tasks, etc.)
3. Check sync indicator showing pending items
4. Disable airplane mode
5. Watch auto-sync complete

## KPI Logic

The summary dashboard shows key metrics for shop floor management:

**Machine Utilization (%)**: (Running Machines / Total Machines) × 100
Measures production efficiency. Green ≥80%, Orange <80%.

**Total Downtime**: Sum of downtime durations in current shift
Identifies production losses. Green <60min, Red ≥60min.

**Average Downtime per Event**: Total Downtime / Number of Events
Shows if issues are quick fixes or systemic. Green <15min, Orange ≥15min.

**Maintenance Status**: Pending and overdue task count
Red if overdue exists, helps prevent equipment failures.

**Alert Status**: Active alerts and critical count
Red if critical alerts exist, enables proactive issue resolution.

**MTBF**: Shift Duration / Number of Downtime Events
Measures equipment reliability, higher is better.

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── user.dart                      # User model
│   ├── machine.dart                   # Machine model
│   ├── downtime.dart                  # Downtime event model
│   ├── maintenance.dart               # Maintenance task model
│   ├── alert.dart                     # Alert model
│   └── reason_tree.dart               # Downtime reason tree
├── providers/                         # Riverpod state providers
│   ├── auth_provider.dart             # Authentication state
│   ├── machine_provider.dart          # Machine state
│   ├── downtime_provider.dart         # Downtime state
│   ├── maintenance_provider.dart      # Maintenance state
│   ├── alert_provider.dart            # Alert state
│   └── sync_provider.dart             # Sync state
├── screens/                           # UI screens
│   ├── login_screen.dart              # Login & role selection
│   ├── dashboard_screen.dart          # Machine dashboard
│   ├── machine_detail_screen.dart     # Machine details
│   ├── downtime_capture_screen.dart   # Downtime capture
│   ├── maintenance_list_screen.dart   # Maintenance checklist
│   ├── alert_management_screen.dart   # Alert management
│   └── summary_screen.dart            # KPI summary
└── services/                          # Business logic services
    ├── database_service.dart          # Hive database manager
    ├── sync_service.dart              # Sync orchestration
    ├── seed_data_service.dart         # Initial data
    └── image_service.dart             # Photo capture & compression
```

## Seed Data

### Machines
- **M-101**: Cutter 1 (cutter) - RUN
- **M-102**: Roller A (roller) - IDLE
- **M-103**: Packing West (packer) - RUN

### Downtime Reasons
1. **Power**
   - Grid
   - Internal
2. **Changeover**
   - Tooling

### Maintenance Tasks
- 6 pre-configured tasks across all machines
- Mix of due, overdue, and completed states

### Alerts
- 3 sample alerts with varying severity levels
- Auto-generation every 2 minutes (for demo)

## Key Dependencies

- `flutter_riverpod` - State management
- `hive` / `hive_flutter` - Local database
- `connectivity_plus` - Network monitoring
- `image_picker` - Photo capture
- `image` - Image compression
- `uuid` - Unique ID generation

## Tech Stack

**Flutter** for cross-platform development
**Hive** for fast offline-first local storage
**Riverpod** for scalable state management
**Connectivity Plus** for network monitoring

## Usage

**Login**: Enter any email, select role (Operator/Supervisor)

**Operator**: Capture downtime, complete maintenance tasks

**Supervisor**: Manage alerts, view summary reports

**Offline Testing**: Enable airplane mode → perform operations → disable airplane mode → watch sync

## Notes

- Mock backend with simulated API delays
- Photos stored locally
- No real authentication
- Demo includes auto-generated alerts

