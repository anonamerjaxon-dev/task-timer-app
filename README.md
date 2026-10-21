# TaskTimerApp

A comprehensive macOS task management and productivity application with Pomodoro timer, task tracking, plans management, and app blocking capabilities.

## Features

### 📋 Task Management
- **Task Creation**: Create tasks with titles, categories, priorities, due dates, and due times
- **Priority Levels**: High, Medium, and Low priorities with visual indicators
- **Task Categories**: Organize tasks into custom categories (Work, Personal, Study, Health, Other)
- **Due Date Tracking**: Track when tasks are due with visual indicators for overdue, due today, and upcoming tasks
- **Task Completion**: Mark tasks as complete with completion date tracking
- **Auto-cleanup**: Completed tasks are automatically deleted after 2 days

### ⏱️ Pomodoro Timer
- **25/5 Timer**: 25-minute work sessions with 5-minute breaks
- **Task-specific Timer**: Start timer for specific tasks
- **Floating Timer Window**: Always-on-top floating timer that can be dragged anywhere
- **Session Tracking**: Track completed Pomodoro sessions with timestamps
- **Auto-switch**: Automatically switch to timer tab when starting a session
- **Progress Visualization**: Visual progress indicator for current session

### 📅 Plans Management
- **Simple Planning**: Create plans without due dates or timers
- **Quick Actions**: Only delete/finish buttons for streamlined plan management
- **Integration**: Plans appear in the All Tasks section
- **Completion Tracking**: Track plan completion with dates

### 🚫 App Blocker
- **Block Distractions**: Block applications that interfere with your work
- **Running Apps Detection**: See all currently running applications
- **Search Functionality**: Search through running apps by name or bundle ID
- **One-click Blocking**: Block/unblock apps with a single click
- **Auto-enforcement**: Blocked apps are automatically terminated when launched
- **Self-protection**: Cannot block the TaskTimerApp itself
- **Pre-configured Blocks**: Bilibili (tv.danmaku.bili and com.bilibili.app) are blocked by default

### 🎨 User Interface
- **Dark Theme**: Clean, modern dark interface
- **Responsive Design**: Smooth animations and transitions
- **Intuitive Navigation**: Easy-to-use tab-based navigation
- **Priority Sorting**: Tasks sorted by priority first, then by due date
- **Visual Indicators**: Color-coded priorities and status indicators

## Installation

### Requirements
- macOS 13.0 or later
- Xcode 15.0 or later (for development)
- Swift 5.9 or later

### Building from Source

1. Clone the repository:
```bash
git clone <repository-url>
cd task-timer-app
```

2. Build the application:
```bash
swift build -c release
```

3. Create the app bundle:
```bash
mkdir -p TaskTimerApp.app/Contents/MacOS
mkdir -p TaskTimerApp.app/Contents/Resources
cp .build/arm64-apple-macosx/release/TaskTimerApp TaskTimerApp.app/Contents/MacOS/
```

4. Create Info.plist in TaskTimerApp.app/Contents/:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>TaskTimerApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.iflow.tasktimer</string>
    <key>CFBundleName</key>
    <string>TaskTimerApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
```

5. Sign the application:
```bash
codesign --force --deep -s - TaskTimerApp.app
```

6. Move to Applications folder:
```bash
mv TaskTimerApp.app /Applications/
```

### Auto-launch on Startup

To enable auto-launch on system startup:

1. Create a LaunchAgent plist file:
```bash
cat > ~/Library/LaunchAgents/com.tasktimerapp.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.tasktimerapp</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/TaskTimerApp.app/Contents/MacOS/TaskTimerApp</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF
```

2. Load the LaunchAgent:
```bash
launchctl load ~/Library/LaunchAgents/com.tasktimerapp.plist
```

## Usage

### Managing Tasks

1. **Create a Task**:
   - Click the blue floating button at the bottom right
   - Fill in task details (title, category, priority, due date/time)
   - Click "Add Task"

2. **Complete a Task**:
   - Click the circle icon next to the task
   - The task will be marked as complete

3. **Delete a Task**:
   - Click on a task to view details
   - Click the delete button in the detail view

4. **Manage Categories**:
   - Click the "+" button in the category bar
   - Enter category name
   - Click "Add"
   - Long-press on a category to delete it

### Using the Pomodoro Timer

1. **Start a Timer**:
   - Go to the "Timer" tab
   - Click the play button on any task
   - The floating timer window will appear

2. **Control the Timer**:
   - Click pause to pause the timer
   - Click play to resume
   - Click stop to end the session

3. **View Sessions**:
   - Sessions are tracked in the app data
   - View completion history in task details

### Managing Plans

1. **Create a Plan**:
   - Go to the "Plans" tab
   - Enter plan name in the text field
   - Click the checkmark to add

2. **Complete a Plan**:
   - Click the checkmark button next to the plan

3. **Delete a Plan**:
   - Click the trash button next to the plan

### Blocking Applications

1. **View Running Apps**:
   - Go to the "Block" tab
   - Click "Running Apps" sub-tab
   - See all currently running applications

2. **Block an App**:
   - Click the lock icon next to any app
   - The app will be terminated and prevented from running

3. **View Blocked Apps**:
   - Go to the "Block" tab
   - Click "Block" sub-tab
   - See all currently blocked apps

4. **Unblock an App**:
   - Click the unlock icon next to a blocked app
   - The app will be allowed to run again

## Project Structure

```
task-timer-app/
├── Sources/
│   └── TaskTimerApp/
│       ├── main.swift                      # App entry point and window management
│       ├── ContentView.swift                # Main view with tab navigation
│       ├── 0_Models.swift                  # Core data models and constants
│       ├── TaskManager.swift                # Task data management
│       ├── TimerManager.swift              # Pomodoro timer logic
│       ├── StorageManager.swift            # File I/O operations
│       ├── TasksView.swift                 # Task list view
│       ├── AllTasksView.swift              # All tasks overview
│       ├── PlansView.swift                 # Plans management
│       ├── TimerView.swift                 # Timer interface
│       ├── FloatingTimerWindow.swift       # Floating timer window
│       ├── AddTaskView.swift               # Task creation form
│       ├── TaskDetailView.swift            # Task details view
│       ├── AppBlockerManager.swift         # App blocking logic
│       ├── BlockerView.swift               # Blocker interface
│       ├── BlockerModels.swift             # Blocker data models
│       ├── BlockerBlockSection.swift       # Blocked apps view
│       └── BlockerRunningAppsSection.swift # Running apps view
├── Package.swift                           # Swift package configuration
└── README.md                               # This file
```

## Data Storage

The application stores data in the following location:
```
~/Library/Application Support/com.iflow.tasktimer/
├── tasks.json       # Task data
├── categories.json  # Category data
├── sessions.json    # Pomodoro session data
└── plans.json       # Plans data
```

Blocked apps are stored in:
```
~/Library/Preferences/
└── blockedApps data in UserDefaults
```

## Keyboard Shortcuts

- **Tab Navigation**: Click tabs to switch between views
- **Task Selection**: Click on a task to view details
- **Timer Control**: Click play/pause/stop buttons in the timer view
- **Category Deletion**: Long-press on a category button to delete

## Architecture

### Core Components

- **TaskManager**: Manages tasks, categories, plans, and sessions
- **TimerManager**: Handles Pomodoro timer logic and state
- **StorageManager**: Persists data to files
- **AppBlockerManager**: Manages app blocking functionality

### State Management

- Uses `@Published` properties for reactive updates
- `@EnvironmentObject` for shared state across views
- `@StateObject` for view-specific state

### Data Models

- **TaskItem**: Represents a task with metadata
- **Category**: Represents a task category
- **Plan**: Represents a simple plan
- **PomodoroSession**: Represents a timer session
- **BlockedApp**: Represents a blocked application
- **RunningApp**: Represents a running application

## Dependencies

The application uses only Swift standard library and Apple frameworks:
- SwiftUI - User interface
- AppKit - macOS-specific functionality
- Foundation - Core data types
- Combine - Reactive programming

No external dependencies required.

## Performance Optimizations

- **Lazy Loading**: Uses `LazyVStack` for efficient list rendering
- **Data Caching**: File URLs cached in StorageManager
- **Batch Operations**: Bulk data operations for efficiency
- **Generic Methods**: Reusable code for data operations
- **Computed Properties**: Efficient data transformations

## Troubleshooting

### App won't launch
- Ensure macOS 13.0 or later is installed
- Check that the app is properly signed: `codesign -vvv /Applications/TaskTimerApp.app`
- Verify the binary has execute permissions: `chmod +x /Applications/TaskTimerApp.app/Contents/MacOS/TaskTimerApp`

### Timer not working
- Check that the app has necessary permissions
- Verify no other app is interfering with timer functionality
- Restart the app if timer becomes unresponsive

### App blocking not working
- Ensure the app has accessibility permissions (if required)
- Check that the target app bundle ID is correct
- Verify the app is not already terminated

### Data not saving
- Check that Application Support directory exists
- Verify disk space is available
- Check file permissions in Application Support folder

## Development

### Running in Development Mode

```bash
cd task-timer-app
swift run
```

### Building for Debug

```bash
swift build
```

### Cleaning Build Artifacts

```bash
swift package clean
rm -rf .build
```

### Adding New Features

1. Create data models in `0_Models.swift`
2. Add manager logic in `TaskManager.swift` or create new manager
3. Create views in separate Swift files
4. Integrate views in `ContentView.swift`
5. Update this README

## Version History

### Version 1.0.0 (Current)
- Initial release with task management
- Pomodoro timer functionality
- Plans management
- App blocking capabilities
- Auto-launch on startup
- Floating timer window
- Priority-based sorting
- Automatic task cleanup

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT — see [LICENSE](./LICENSE).

## Support

For issues, questions, or feature requests, please contact the development team.

## Acknowledgments

- SwiftUI for the modern declarative UI framework
- Apple for the excellent macOS development tools
- The open-source community for inspiration and best practices

---

**Note**: This application is designed for personal productivity and focus management. Use the app blocking feature responsibly and ensure you have necessary permissions before blocking applications on your system.