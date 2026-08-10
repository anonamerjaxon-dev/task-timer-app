# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ CRITICAL: Data Preservation Policy
**NEVER ALTER OR DELETE EXISTING USER DATA**

User data is stored in `~/Library/Application Support/com.iflow.tasktimer/` and includes tasks, plans, sessions, categories, and chat history. Always preserve existing data and only make additive changes.

See `DATA_PRESERVATION.md` for complete guidelines.

## Project Overview

TaskTimerApp is a comprehensive macOS task management and productivity application built with SwiftUI. It features task management, Pomodoro timer, plans management, app blocking capabilities, and AI-powered chat assistance. The app targets macOS 13.0+ and uses only Apple frameworks with no external dependencies.

## Build and Development Commands

### Building and Testing
```bash
# Build for release (primary method for testing)
swift build -c release

# Build for debug
swift build

# Run in development
swift run

# Clean build artifacts
swift package clean && rm -rf .build

# Create app bundle and install to /Applications/
./create_bundle.sh

# Test the bundled app (ALWAYS use this for testing, not swift run)
open /Applications/TaskTimerApp.app
```

### Testing Workflow
1. Make code changes in the source
2. Run `./create_bundle.sh` to build and install
3. Test using `open /Applications/TaskTimerApp.app`
4. The icon is automatically preserved in the Resources folder

### Package Configuration
- Swift tools version 5.9, targets macOS 13.0+
- Executable target with no external dependencies
- SQLite3 linked as system library for chat history storage

### Auto-launch Setup
```bash
# Create LaunchAgent for auto-start
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

# Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.tasktimerapp.plist
```

## Code Architecture

### Core Architecture
- **SwiftUI-based**: Modern declarative UI framework with dark theme
- **MVVM Pattern**: Model-View-ViewModel with `@Published`, `@StateObject`, and `@EnvironmentObject`
- **Modular Design**: Separated concerns across specialized managers and views
- **Reactive Programming**: Combine framework for state management
- **Tab-based Navigation**: 5 main sections (Tasks, Timer, All Tasks, Plans, Block)
- **Window Management**: Main window + floating timer window with drag support
- **Data Flow**: Centralized state management through EnvironmentObjects with automatic persistence

### Key Components

#### Managers (Core Business Logic)
- **TaskManager**: Task lifecycle, categories, plans, sessions, and data caching. Handles priority sorting and auto-cleanup of completed tasks after 2 days. Central state management for all task operations.
- **TimerManager**: Pomodoro timer logic using `DispatchSourceTimer` for efficiency. Manages 25/5 minute cycles with session tracking. Works with `FloatingTimerManager` for floating window.
- **StorageManager**: File I/O operations with debounced saves and background queues. Uses JSON for most data, SQLite for chat history. Handles all persistence layer operations.
- **AppBlockerManager**: Application blocking functionality with running app detection and search. Integrates with macOS system APIs for process monitoring.

#### Data Models (0_Models.swift)
- **TaskItem**: Tasks with priorities (High/Medium/Low), categories, due dates, and completion tracking
- **Category**: Task organization with custom categories (Work, Personal, Study, Health, Other)
- **Plan**: Simple planning items without due dates or timers
- **PomodoroSession**: Timer session tracking with timestamps
- **BlockedApp**: Blocked application representation with bundle ID and name
- **RunningApp**: Running application representation with process info

#### Views (UI Layer)
- **ContentView**: Main tab navigation with 5 tabs (Tasks, Timer, All Tasks, Plans, Block)
- **TasksView**: Task list management with priority sorting and category filtering
- **TimerView**: Pomodoro timer interface with task-specific timers
- **PlansView**: Plans management with simple add/delete/complete actions
- **BlockerView**: App blocking interface with Running Apps/Block sub-tabs
- **FloatingTimerWindow**: Always-on-top draggable timer window
- **AddTaskView**: Modal task creation form with all metadata fields
- **TaskDetailView**: Task details with completion and deletion actions
- **DesignSystem.swift**: UI design system constants, colors, and styles

### Data Storage

#### Application Data
```
~/Library/Application Support/com.iflow.tasktimer/
├── tasks.json       # Task data with priorities and due dates
├── categories.json  # Category data (Work, Personal, Study, Health, Other)
├── sessions.json    # Pomodoro session data with timestamps
├── plans.json       # Plans data (simple items without dates)
└── chat_history.db  # SQLite database for AI chat sessions
```

#### System Data
```
~/Library/Preferences/
└── blockedApps data in UserDefaults
```

### Performance Optimizations

- **Lazy Loading**: `LazyVStack` for efficient list rendering
- **Background Queues**: I/O operations use `DispatchQueue.global(qos: .utility)`
- **Debounced Saves**: 0.5s delay on storage operations
- **Memory Management**: `[weak self]` in async closures, timer invalidation in `deinit`
- **Data Caching**: Computed properties and cached file URLs
- **Efficient Timers**: `DispatchSourceTimer` instead of `Timer.scheduledTimer`

## Common Development Patterns

### Adding New Features
1. Create data models in `0_Models.swift` if needed
2. Add manager logic in appropriate manager file or create new manager
3. Create views in separate Swift files following existing patterns
4. Integrate views in `ContentView.swift` tab navigation
5. Update DesignSystem.swift for any new UI constants
6. Rebuild the bundled app using `./create_bundle.sh`
7. **Test using the bundled app**: `open /Applications/TaskTimerApp.app`

### State Management
- Use `@Published` properties for reactive updates in managers
- Use `@EnvironmentObject` for shared state across views (TaskManager, TimerManager, etc.)
- Use `@StateObject` for view-specific state that needs to persist
- Use `@ObservedObject` for passed-in state objects
- Use `@State` for local UI state within views

### Error Handling
- Storage operations handle errors gracefully with try-catch blocks
- API calls include proper error handling and user feedback via alerts
- Timer operations include safety checks and proper invalidation
- Network calls use proper timeouts and error propagation

### Background Operations
```swift
// Use utility queue for I/O
DispatchQueue.global(qos: .utility).async {
    // File operations
}

// Use background queue for heavy computations
DispatchQueue.global(qos: .background).async {
    // Heavy processing
}
```

## Troubleshooting Guide

### Build Issues
- **App bundle creation fails**: Ensure directory structure exists before copying files. Run `mkdir -p` commands first if needed.
- **Icon not showing**: The icon is automatically preserved in Resources folder during rebuild
- **Code signing fails**: Verify binary exists and has execute permissions (`chmod +x` if needed)
- **Model deprecation**: Current working Groq model is `llama-3.3-70b-versatile`. Check Groq dashboard for model updates.
- **SQLite linking errors**: Ensure sqlite3 library is available on the system (`brew install sqlite` if using Homebrew)
- **Bundled app not updating**: Always test using `/Applications/TaskTimerApp.app`, not `swift run`
- **Swift version mismatch**: Ensure Swift 5.9+ is installed and active

### Runtime Issues
- **Timer not working**: Check app permissions and restart if unresponsive. Verify `DispatchSourceTimer` is properly initialized.
- **App blocking not working**: Verify accessibility permissions in System Settings > Privacy & Security > Accessibility
- **Data not saving**: Check Application Support directory permissions (`~/Library/Application Support/com.iflow.tasktimer/`)
- **AI chat errors**: Verify Groq API key and model availability. Check network connectivity and API rate limits.
- **Floating window issues**: Check window level and screen bounds. Ensure `NSPanel` is configured correctly.
- **Memory leaks**: Monitor memory usage and ensure all timers are invalidated in `deinit` methods

### Common Bugs
- **Empty messages array**: Use `currentSession` directly, not passed parameters
- **Layout glitches**: Use fixed-width containers for hover states
- **Closure variables**: Use `$0` not `$Item` in forEach closures
- **Timer memory leaks**: Always invalidate timers in `deinit`
- **Data race conditions**: Use proper queue management for async operations

## File Organization

```
Sources/TaskTimerApp/
├── main.swift                      # App entry point and window management
├── ContentView.swift               # Main view with tab navigation
├── 0_Models.swift                  # Core data models and constants
├── TaskManager.swift               # Task data management
├── TimerManager.swift              # Pomodoro timer logic
├── StorageManager.swift            # File I/O operations with SQLite support
├── AppBlockerManager.swift         # App blocking logic
├── TasksView.swift                 # Task list view
├── AllTasksView.swift              # All tasks overview
├── PlansView.swift                 # Plans management
├── TimerView.swift                 # Timer interface
├── FloatingTimerWindow.swift       # Floating timer window
├── AddTaskView.swift               # Task creation form
├── TaskDetailView.swift            # Task details view
├── BlockerView.swift               # Blocker interface
├── BlockerModels.swift             # Blocker data models
├── BlockerBlockSection.swift       # Blocked apps view
├── BlockerRunningAppsSection.swift # Running apps view
└── DesignSystem.swift              # UI design system and constants
```

## Dependencies

- **Swift Standard Library**: Core functionality
- **SwiftUI**: User interface framework with dark theme
- **AppKit**: macOS-specific functionality (window management, app blocking)
- **Foundation**: Core data types and operations
- **Combine**: Reactive programming for state management

No external Swift Package Manager dependencies required. All dependencies are Apple frameworks.

## Performance Considerations

- **Thread Priority**: Main thread for UI only, utility queue for I/O, background for heavy work
- **Memory**: Clear caches when data changes, use weak references in closures
- **Storage**: Debounced saves prevent I/O bottlenecks
- **UI**: Lazy loading for large lists, efficient computed properties
- **Network**: Proper error handling and timeouts for API calls
- **Database**: SQLite with proper indexing and foreign key constraints for chat history

## Memory System Integration

This project integrates with the global Claude Code memory system:

### Global Configuration
- **Primary Location**: `/Users/jackson/Desktop/     /claude` (multiple spaces between Desktop and claude)
- **User Preferences**: Stored in `../projects/-Users-jackson/memory/user_preferences.md`
- **MCP Servers**: 7 servers available (6 migrated + 1 built-in)
- **CLI-Anything**: 23 tools available via `cli-anything-<name>`

### Memory Types
- **User**: Role, preferences, and knowledge context
- **Feedback**: Development guidance and best practices
- **Project**: Current work context and goals
- **Reference**: External system pointers

### Memory Usage
When working with this project:
- Check existing memories before making assumptions about user preferences
- Update memories when learning new information about user workflow
- Use memory for cross-session context, not for codebase structure (use git/reading instead)

## Security Notes

- Application requires proper code signing for macOS distribution
- App blocking functionality may require accessibility permissions (System Settings > Privacy & Security > Accessibility)
- API keys are stored in code (LongCatService). For production, consider externalizing to environment variables or keychain
- File operations use sandboxed Application Support directory (`~/Library/Application Support/com.iflow.tasktimer/`)
- Cannot block the TaskTimerApp itself (self-protection via bundle ID check)
- Pre-configured blocks for Bilibili apps (tv.danmaku.bili, com.bilibili.app)
- UserDefaults used for blocked apps list - consider migration to encrypted storage for sensitive data
- Chat database uses SQLite with foreign key cascade delete for referential integrity
- Chat history is stored locally and not transmitted externally

## Icon Preservation
The app icon (`icon.icns`) is automatically preserved during the build process and copied to `/Applications/TaskTimerApp.app/Contents/Resources/`. No manual intervention is needed to maintain the icon.

## Quick Reference Commands

```bash
# Complete development workflow
./create_bundle.sh && open /Applications/TaskTimerApp.app

# Reset app data (for testing)
rm -rf ~/Library/Application\ Support/com.iflow.tasktimer/
rm -rf ~/Library/Preferences/com.iflow.tasktimer.*

# Check running processes
ps aux | grep TaskTimerApp

# Unload auto-launch
launchctl unload ~/Library/LaunchAgents/com.tasktimerapp.plist

# View chat database (requires sqlite3)
sqlite3 ~/Library/Application\ Support/com.iflow.tasktimer/chat_history.db "SELECT * FROM chat_sessions;"

# Reset chat history (for testing)
rm ~/Library/Application\ Support/com.iflow.tasktimer/chat_history.db

# Monitor app logs
tail -f ~/Library/Logs/com.iflow.tasktimer.log
```
