# TaskTimerApp - Code Wiki

> 一份全面的 macOS 任务管理与生产力应用代码文档

---

## 目录

1. [项目概览](#1-项目概览)
2. [整体架构](#2-整体架构)
3. [项目结构](#3-项目结构)
4. [核心模块详解](#4-核心模块详解)
   - [4.1 入口层 (main.swift)](#41-入口层-maintswift)
   - [4.2 数据模型层 (0_Models.swift)](#42-数据模型层-0_modelsswift)
   - [4.3 枚举与扩展 (Extensions.swift)](#43-枚举与扩展-extensionsswift)
   - [4.4 协议定义 (Protocols.swift)](#44-协议定义-protocolsswift)
   - [4.5 管理器层](#45-管理器层)
     - [TaskManager](#taskmanager)
     - [TimerManager](#timermanager)
     - [StorageManager](#storagemanager)
     - [AppBlockerManager](#appblockermanager)
   - [4.6 视图层](#46-视图层)
     - [ContentView](#contentview)
     - [TasksView](#tasksview)
     - [AllTasksView](#alltasksview)
     - [PlansView](#plansview)
     - [TimerView](#timerview)
     - [FloatingTimerWindow](#floatingtimerwindow)
     - [AddTaskView](#addtaskview)
     - [TaskDetailView](#taskdetailview)
     - [BlockerView / BlockSection / RunningAppsSection](#blockerview--blocksection--runningappssection)
   - [4.7 设计系统 (DesignSystem.swift)](#47-设计系统-designsystemswift)
   - [4.8 共享组件 (SharedComponents.swift)](#48-共享组件-sharedcomponentsswift)
5. [依赖关系图](#5-依赖关系图)
6. [数据流与状态管理](#6-数据流与状态管理)
7. [数据持久化](#7-数据持久化)
8. [运行与构建](#8-运行与构建)
9. [性能优化策略](#9-性能优化策略)
10. [安全注意事项](#10-安全注意事项)

---

## 1. 项目概览

| 属性 | 值 |
|------|-----|
| **项目名称** | TaskTimerApp |
| **类型** | macOS 桌面应用 (SwiftUI) |
| **最低系统** | macOS 13.0+ |
| **Swift 版本** | 5.9 |
| **构建系统** | Swift Package Manager (SPM) |
| **外部依赖** | 无（仅使用 Apple 原生框架） |
| **Bundle ID** | `com.iflow.tasktimer` |

**核心功能**：
- 任务管理（创建、分类、优先级、截止日期、子任务、重复模式）
- 番茄钟计时器（25 分钟工作 / 5 分钟休息）
- 计划管理（无截止日期的简单计划项）
- 应用屏蔽（阻止分散注意力的应用运行）
- 浮动计时器窗口（始终置顶、可拖拽）
- 不可关闭模式（防止应用被意外退出）

---

## 2. 整体架构

采用 **MVVM (Model-View-ViewModel)** 架构模式，结合 SwiftUI 的响应式数据绑定。

```
┌─────────────────────────────────────────────────────────────┐
│                        main.swift                            │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────────┐  │
│  │ TaskTimerApp  │  │  AppDelegate  │  │FloatingTimerMgr│  │
│  │   (App)       │  │ (NSApplication│  │  (Singleton)   │  │
│  │               │  │   Delegate)   │  │                │  │
│  └───────┬───────┘  └───────┬───────┘  └───────┬────────┘  │
│          │                  │                   │            │
│          └──────────────────┼───────────────────┘            │
│                             │                                │
│                    ┌────────▼────────┐                       │
│                    │   ContentView    │  ← Tab Navigation     │
│                    │  (5 Tabs)        │                       │
│                    └────────┬────────┘                       │
│         ┌─────────┬────────┼────────┬─────────┐              │
│         ▼         ▼        ▼        ▼         ▼              │
│    TasksView  TimerVw  AllTasksVw PlansVw  BlockerVw        │
│         │         │        │        │         │              │
│         └─────────┴────────┴────────┴─────────┘              │
│                        │                                     │
│              ┌─────────▼─────────┐                           │
│              │  Manager Layer    │                           │
│              │  ┌──────────────┐ │                           │
│              │  │ TaskManager  │ │  ← @Published State       │
│              │  │ TimerManager │ │                           │
│              │  │ AppBlockerMgr│ │                           │
│              │  └──────┬───────┘ │                           │
│              │         │         │                           │
│              │  ┌──────▼───────┐ │                           │
│              │  │StorageManager│ │  ← JSON/SQLite 持久化     │
│              │  └──────────────┘ │                           │
│              └───────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

**架构特点**：
- **单向数据流**：视图通过 `@EnvironmentObject` 读取管理器状态，通过方法调用修改状态
- **响应式更新**：管理器使用 `@Published` 属性，SwiftUI 自动重绘相关视图
- **单例模式**：`StorageManager.shared` 和 `FloatingTimerManager.shared` 使用单例
- **依赖注入**：`TimerManager` 通过构造函数注入 `TaskManager`

---

## 3. 项目结构

```
task-timer-app/
├── Package.swift                          # SPM 包配置
├── Sources/TaskTimerApp/
│   ├── main.swift                         # 应用入口、窗口管理、AppDelegate
│   ├── 0_Models.swift                     # 核心数据模型与常量
│   ├── Extensions.swift                   # 枚举定义与扩展方法
│   ├── Protocols.swift                    # 协议定义与一致性声明
│   ├── TaskManager.swift                  # 任务/计划/分类/会话管理
│   ├── TimerManager.swift                 # 番茄钟计时器逻辑
│   ├── StorageManager.swift               # JSON 文件持久化
│   ├── AppBlockerManager.swift            # 应用屏蔽管理
│   ├── BlockerModels.swift                # 屏蔽器数据模型
│   ├── DesignSystem.swift                 # 设计系统（颜色、字体、间距、样式）
│   ├── SharedComponents.swift             # 可复用 UI 组件
│   ├── ContentView.swift                  # 主视图（Tab 导航）
│   ├── TasksView.swift                    # 任务列表视图
│   ├── AllTasksView.swift                 # 全部任务视图
│   ├── PlansView.swift                    # 计划管理视图
│   ├── TimerView.swift                    # 计时器视图
│   ├── FloatingTimerWindow.swift          # 浮动计时器窗口
│   ├── AddTaskView.swift                  # 添加任务表单
│   ├── TaskDetailView.swift               # 任务详情视图
│   ├── BlockerView.swift                  # 屏蔽器主视图
│   ├── BlockerBlockSection.swift          # 已屏蔽应用列表
│   └── BlockerRunningAppsSection.swift    # 运行中应用列表
├── build_with_icon.sh                     # 构建脚本
├── create_bundle.sh                       # 打包脚本
└── check_tools.sh                         # 工具检查脚本
```

---

## 4. 核心模块详解

### 4.1 入口层 (main.swift)

**文件**: [main.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/main.swift)

#### `TaskTimerWindow` (NSWindow 子类)
自定义窗口类，支持 **不可关闭模式 (Unclosable Mode)**：
- 覆盖 `close()`、`orderOut()`、`miniaturize()` — 阻止关闭/隐藏/最小化
- 覆盖 `setFrameOrigin()`、`setFrame()` — 阻止移动/调整大小
- 覆盖 `zoom()` — 阻止缩放
- 覆盖 `keyDown()` — 拦截 Cmd+W / Cmd+M 快捷键
- 覆盖 `update()` — 持续强制窗口保持可见
- 使用透明覆盖层禁用红绿灯按钮（关闭、最小化、缩放）

#### `TaskTimerApp` (App 协议)
SwiftUI 应用入口：
- 使用 `@NSApplicationDelegateAdaptor` 绑定 `AppDelegate`
- 创建 `AppBlockerManager` 作为 `@StateObject` 并通过 `.environmentObject()` 注入
- 设置窗口样式：隐藏标题栏、内容自适应大小
- 配置窗口跨所有桌面空间显示 (`canJoinAllSpaces`)

#### `FloatingTimerManager` (Singleton)
管理浮动计时器窗口：
- `showFloatingTimer()` — 创建无边框 `NSWindow`，居中显示在屏幕顶部
- `hideFloatingTimer()` / `closeFloatingTimer()` — 隐藏/关闭浮动窗口
- `updateFloatingTimer()` — 刷新浮动窗口内容
- 窗口属性：`.floating` 层级、可拖拽、暗色外观、跨桌面显示

#### `AppDelegate` (NSApplicationDelegate)
应用生命周期管理：
- `applicationDidFinishLaunching()` — 设置暗色外观、激活应用
- `applicationShouldTerminate()` — 不可关闭模式下阻止终止
- `applicationShouldTerminateAfterLastWindowClosed()` — 不可关闭模式下阻止终止
- `applicationDidResignActive()` — 不可关闭模式下强制重新激活
- `applicationDidHide()` — 不可关闭模式下强制取消隐藏
- `applicationWillTerminate()` — 清理资源（停止监控、刷新待保存数据）

---

### 4.2 数据模型层 (0_Models.swift)

**文件**: [0_Models.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/0_Models.swift)

#### `AppConstants`
应用常量配置：
| 常量 | 值 | 说明 |
|------|-----|------|
| `pomodoroWorkDuration` | 25 × 60 秒 | 番茄钟工作时间 |
| `pomodoroBreakDuration` | 5 × 60 秒 | 番茄钟休息时间 |
| `daysBeforeAutoDeleteCompletedTasks` | 2 | 完成任务的自动清理天数 |

#### `Priority` (枚举)
任务优先级：`high`(0) > `medium`(1) > `low`(2)
- `sortIndex` — 排序权重
- `colorName` — 对应颜色名称

#### `RecurringPattern` (枚举)
重复模式：`none` / `daily` / `weekly` / `monday`~`sunday`
- `shouldCreateNewInstance(for:)` — 判断指定日期是否应创建新实例
- 基于 `Calendar.current.component(.weekday, from:)` 判断星期几

#### `Subtask` (结构体)
子任务模型：`id`、`title`、`isCompleted`

#### `TaskItem` (结构体) — 核心任务模型
| 属性 | 类型 | 说明 |
|------|------|------|
| `id` | UUID | 唯一标识 |
| `title` | String | 任务标题 |
| `category` | String | 所属分类 |
| `priority` | Priority | 优先级 |
| `subtasks` | [Subtask] | 子任务列表 |
| `dueDate` | Date? | 截止日期 |
| `dueTime` | Date? | 截止时间 |
| `recurringPattern` | RecurringPattern | 重复模式 |
| `isCompleted` | Bool | 是否完成 |
| `createdAt` | Date | 创建时间 |
| `completedAt` | Date? | 完成时间 |

**计算属性**：
- `isOverdue` — 是否过期（未完成且截止日期 < 今天开始）
- `isDueToday` — 是否今天到期
- `formattedDueDate` / `formattedDueDateShort` — 格式化日期显示
- `completedSubtasksCount` / `totalSubtasksCount` — 子任务统计

#### `Category` (结构体)
分类模型：`id`、`name`、`color`
- 静态默认分类：Work、Personal、Study、Health、Other

#### `PomodoroSession` (结构体)
番茄钟会话：`id`、`taskId`、`startTime`、`endTime`、`duration`、`isCompleted`

#### `Plan` (结构体)
计划模型：`id`、`title`、`isCompleted`、`createdAt`、`completedAt`

---

### 4.3 枚举与扩展 (Extensions.swift)

**文件**: [Extensions.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/Extensions.swift)

#### `TimerState` (枚举)
计时器状态机：`idle` → `running` ⇄ `paused`，`running` → `breakTime`

#### `TaskStatus` (枚举)
任务状态：`active` / `completed` / `overdue` / `dueToday`

#### `SortOption` (枚举)
排序选项：`priority` / `dueDate` / `title` / `category` / `created`

#### `FilterOption` (枚举)
筛选选项：`all` / `active` / `completed` / `overdue` / `dueToday`

#### 扩展方法
- **Date 扩展**：`isToday`、`isYesterday`、`isTomorrow`、`startOfDay`、`timeAgo()`、`formatted(style:)`
- **String 扩展**：`trimmed`、`isNotEmpty`、`truncated(to:)`
- **Array 扩展**：`chunked(into:)`、`[safe:]` 安全访问、`removeFirst(where:)`
- **Color 扩展**：`taskPriority()`、`taskStatus()` 工厂方法
- **View 扩展**：`if()` 条件修饰符、`hapticFeedback()` 触觉反馈（iOS 兼容）

---

### 4.4 协议定义 (Protocols.swift)

**文件**: [Protocols.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/Protocols.swift)

| 协议 | 用途 | 使用者 |
|------|------|--------|
| `StorageManagerProtocol` | 持久化操作接口 | `StorageManager` |
| `TimerManagerProtocol` | 计时器操作接口 | `TimerManager` |
| `TaskManagerProtocol` | 任务/计划/分类/会话管理接口 | `TaskManager` |
| `AppBlockerManagerProtocol` | 应用屏蔽操作接口 | `AppBlockerManager` |

---

### 4.5 管理器层

#### TaskManager

**文件**: [TaskManager.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/TaskManager.swift)

`ObservableObject`，作为 `@EnvironmentObject` 注入视图树。**核心职责：任务 CRUD、分类管理、计划管理、会话管理、重复任务生成、自动清理**。

**Published 属性**：
- `tasks: [TaskItem]`、`categories: [Category]`、`sessions: [PomodoroSession]`、`plans: [Plan]`

**计算属性（缓存优化）**：
- `activeTasks` / `completedTasks` — 带缓存的任务分区
- `overdueTasks` / `tasksDueToday` — 过滤排序结果
- `activePlans` / `completedPlans` — 计划分区
- `uniqueCategories` — 分类名列表
- 统计属性：`totalTasksCount`、`completionRate`、`totalSessionsCount`

**关键方法**：

| 方法 | 说明 |
|------|------|
| `addTask(_:)` | 添加任务，自动创建分类 |
| `updateTask(_:)` | 更新任务 |
| `deleteTask(_:)` | 删除任务 |
| `toggleTaskCompletion(_:)` | 切换完成状态，立即保存 |
| `addCategory(_:)` / `deleteCategory(_:)` | 分类增删 |
| `addPlan(_:)` / `deletePlan(_:)` / `togglePlanCompletion(_:)` | 计划管理 |
| `addSession(_:)` / `getSessions(forTaskId:)` | 会话管理 |
| `searchTasks(containing:)` | 搜索任务 |
| `lookupTasks(query:dueBefore:status:)` | 高级查询 |
| `saveAllData()` / `cleanupStaleData()` | 持久化与清理 |
| `checkForNewRecurringTasks()` | 检查并创建重复任务实例 |

**缓存机制**：
- 使用 `cachedActiveTasks` / `cachedCompletedTasks` 避免重复过滤
- `cacheValid` 标志 + `tasksVersion` 版本号控制失效
- `invalidateCache()` 在数据变更时调用

**重复任务逻辑**：
- 每小时定时器 (`Timer.scheduledTimer`) 检查重复任务
- `checkAndCreateRecurringInstances()` 遍历所有非完成重复任务，根据 `RecurringPattern.shouldCreateNewInstance(for:)` 判断是否创建新实例
- 防重复检测：`hasTaskInstanceForDate()` / `hasTaskInstanceForWeek()`

---

#### TimerManager

**文件**: [TimerManager.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/TimerManager.swift)

`ObservableObject`，管理番茄钟计时器。**核心职责：计时器状态机、工作/休息会话切换、会话记录**。

**Published 属性**：
- `state: TimerState` — 当前状态
- `currentTask: TaskItem?` — 当前关联任务
- `remainingTime: TimeInterval` — 剩余时间
- `elapsedSessionTime: TimeInterval` — 已用时间

**计算属性**：
- `isTimerActive`、`sessionProgress`（0.0~1.0）、`formattedRemainingTime`、`formattedElapsedTime`

**状态机**：
```
idle ──startTimer()──▶ running ──pauseTimer()──▶ paused
                          │ │                      │
                          │ └──resumeTimer()───────┘
                          │
                          ├──▶ (剩余时间到0) ──▶ breakTime ──▶ (剩余时间到0) ──▶ idle
                          │
                          └──skipToBreak()──▶ breakTime
```

**计时器实现**：
- 使用 `DispatchSourceTimer`（非 `Timer.scheduledTimer`）以提升性能
- 在 `DispatchQueue(label: "com.iflow.tasktimer.timer", qos: .userInitiated)` 上运行
- 每秒触发 `processTimerTick()`，在 `DispatchQueue.main` 上更新 UI
- `deinit` 中调用 `stopTimerSource()` 避免内存泄漏

**通知**：
- `.timerDidStart` / `.timerDidStop` / `.timerDidComplete` / `.timerDidPause` / `.timerDidResume`

---

#### StorageManager

**文件**: [StorageManager.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/StorageManager.swift)

单例 (`shared`)，负责应用数据的 JSON 文件持久化。**核心职责：文件 I/O、防抖保存、错误恢复**。

**存储文件类型** (`StorageFileType` 枚举)：
| 类型 | 文件名 | 内容 |
|------|--------|------|
| `.tasks` | `tasks.json` | `[TaskItem]` |
| `.categories` | `categories.json` | `[Category]` |
| `.sessions` | `sessions.json` | `[PomodoroSession]` |
| `.plans` | `plans.json` | `[Plan]` |

**存储路径**：
```
~/Library/Application Support/com.iflow.tasktimer/
```

**关键特性**：
- **防抖保存** (`saveDebounced`)：0.5 秒延迟，取消同类型待保存操作
- **原子写入**：`Data.write(to:options: .atomic)`
- **错误恢复**：写入失败时尝试重建目录后重试
- **URL 缓存**：`fileCache` 字典预加载文件 URL，避免重复计算
- **后台队列**：`DispatchQueue.global(qos: .utility)` 上执行 I/O
- **日志**：使用 OSLog (`Logger`) 记录操作
- **`flushPendingSaves()`**：应用终止前执行所有待保存操作

**公共方法**：
- `saveTasks(_:)` / `loadTasks()` — 任务持久化
- `saveCategories(_:)` / `loadCategories()` — 分类持久化（默认值：5 个预设分类）
- `saveSessions(_:)` / `loadSessions()` — 会话持久化
- `savePlans(_:)` / `loadPlans()` — 计划持久化
- `clearAllData()` — 清除所有数据
- `exportData(...)` — 导出所有数据为单个 JSON 文件

---

#### AppBlockerManager

**文件**: [AppBlockerManager.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/AppBlockerManager.swift)

`ObservableObject`，管理应用屏蔽功能。**核心职责：运行应用检测、屏蔽/解除屏蔽、进程终止、监控轮询**。

**Published 属性**：
- `blockedApps: [BlockedApp]` — 已屏蔽应用列表
- `runningApps: [RunningApp]` — 运行中应用列表
- `isMonitoring: Bool` — 是否正在监控
- `searchText: String` — 搜索文本
- `isUnclosableMode: Bool` — 不可关闭模式

**数据持久化**：
- `blockedApps` 通过 `UserDefaults` 存储（JSON 编码）
- `isUnclosableMode` 通过 `UserDefaults` 存储

**关键方法**：

| 方法 | 说明 |
|------|------|
| `refreshRunningApps()` | 通过 `NSWorkspace.shared.runningApplications` 获取运行中的应用 |
| `blockApp(_:)` | 屏蔽应用：标记为已屏蔽、缓存、保存、终止进程、启动监控 |
| `unblockApp(_:)` | 解除屏蔽：取消标记、清除缓存、保存、按需停止监控 |
| `stopBlocking(apps:)` | 批量停止屏蔽 |
| `killApp(_:)` | 终止指定 Bundle ID 的应用进程 |
| `startMonitoring()` | 启动 2 秒间隔的定时监控 |
| `stopMonitoring()` | 停止监控 |
| `toggleUnclosableMode()` | 切换不可关闭模式 |

**默认屏蔽**：
- 哔哩哔哩 (`tv.danmaku.bili` 和 `com.bilibili.app`)

**自我保护**：
- 过滤 `selfBundleID` (`com.iflow.tasktimer`)，防止屏蔽自身

**计算属性**：
- `filteredRunningApps` — 根据 `searchText` 过滤（支持名称和 Bundle ID 搜索）
- `currentlyBlockedApps` — 当前已屏蔽的应用
- `isAnyAppBlocked` — 是否有任何应用被屏蔽

---

### 4.6 视图层

#### ContentView

**文件**: [ContentView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/ContentView.swift)

应用主视图，5 个 Tab 导航：

| Tab | 枚举值 | 视图 | 图标 |
|-----|--------|------|------|
| Tasks | `.categories` | `TasksView` | `list.bullet` |
| Plans | `.plans` | `PlansView` | `calendar` |
| Timer | `.timer` | `TimerView` | `timer` |
| All | `.allTasks` | `AllTasksView` | `tray.full` |
| Block | `.block` | `BlockerView` | `hand.raised` |

**初始化流程**：
1. 创建 `TaskManager` → 创建 `TimerManager(taskManager:)` 注入依赖
2. 通过 `.environmentObject()` 将三个管理器注入视图树
3. 监听 `.timerDidStart` / `.timerDidStop` 通知自动显示/隐藏浮动计时器

**`TabButton`**：自定义 Tab 按钮，含选中状态样式

---

#### TasksView

**文件**: [TasksView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/TasksView.swift)

任务列表视图，核心功能：
- **分类过滤**：水平滚动分类选择器（"All" + 自定义分类），支持右键删除分类
- **任务排序**：优先级（高→中→低）→ 截止日期（最近优先）→ 创建时间
- **任务行**：`TaskRow` 组件，显示优先级色条、标题、分类、截止状态、子任务进度、操作按钮（启动计时器、标记完成）
- **浮动添加按钮**：右下角白色圆形 "+" 按钮
- **Sheet 弹窗**：`AddTaskView`（添加任务）、`TaskDetailView`（任务详情）、添加分类对话框

**`CategoryButton`**：分类胶囊按钮，支持 `contextMenu` 删除（"All" 除外）

**`TaskRow`**：单行任务展示，含：
- 优先级左侧色条 (4px)
- 截止日期状态标签（Overdue / Today / 日期）
- 重复任务图标
- 子任务进度条
- 播放按钮（启动计时器）和完成切换按钮

---

#### AllTasksView

**文件**: [AllTasksView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/AllTasksView.swift)

全部任务与计划总览视图，分区展示：
- **Overdue**（红色）— 过期任务
- **Today**（橙色）— 今日到期任务
- **Upcoming**（蓝色）— 即将到来的任务
- **Active Plans**（紫色）— 活跃计划
- **Completed Plans**（灰色）— 已完成计划
- **Completed**（绿色）— 已完成任务

**`TaskSection`** / **`PlanSection`**：分区容器，含标题、计数、卡片列表

**`TaskCard`** / **`PlanCard`**：卡片式展示，支持播放计时器、完成切换、删除操作

---

#### PlansView

**文件**: [PlansView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/PlansView.swift)

计划管理视图：
- **添加计划**：顶部输入框 + 确认按钮
- **即将到期任务**：显示未来 7 天内到期的任务（最多 200px 高度）
- **计划列表**：活跃计划 + 已完成计划分区

**`PlanRow`**：计划行，含完成按钮、标题、删除按钮

**`UpcomingTaskRow`**：即将到期任务行，显示优先级点、标题、分类、截止日期智能标签（Today/Tomorrow/日期）

---

#### TimerView

**文件**: [TimerView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/TimerView.swift)

番茄钟计时器界面：
- **环形进度条**：280x280 大圆环，外部轨道（`surfaceLight`），内部进度（根据状态着色）
- **时间显示**：超大等宽字体（56pt, ultralight）
- **任务名称**：当前关联任务标题
- **控制按钮**：暂停/继续、停止
- **会话信息卡片**：已用时间、状态标签

---

#### FloatingTimerWindow

**文件**: [FloatingTimerWindow.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/FloatingTimerWindow.swift)

浮动计时器窗口（SwiftUI 视图）：
- 紧凑布局：340x80 尺寸
- 显示任务标题、剩余时间、运行状态指示灯
- 暂停/播放 + 关闭按钮
- **拖拽支持**：`DragGesture` 监听全局坐标变化，更新 `NSWindow` 位置
- **右键菜单**：关闭计时器
- 半透明黑色背景 + 白色边框

---

#### AddTaskView

**文件**: [AddTaskView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/AddTaskView.swift)

添加任务表单（Sheet 弹窗，500x600）：
- **标题输入**：`TextField`，自动聚焦
- **分类**：输入框 + 下拉选择已有分类
- **优先级**：`Picker` 选择 High/Medium/Low
- **截止日期**：`Toggle` 开关 + `DatePicker`
- **截止时间**：仅在有截止日期时显示
- **重复模式**：`Picker` 选择 Never/Daily/Weekly/Weekday
- **子任务**：输入框 + 添加按钮，列表显示已添加子任务，支持删除
- **创建按钮**：`createTaskItem()` 构建 `TaskItem` 并调用 `taskManager.addTask()`

---

#### TaskDetailView

**文件**: [TaskDetailView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/TaskDetailView.swift)

任务详情编辑视图（Sheet 弹窗，500x600）：
- 可编辑标题、分类、优先级
- 截止日期显示/移除
- 重复模式选择
- 子任务列表（可切换完成状态）
- 状态操作：标记完成、快速完成
- 删除任务按钮
- 保存更改按钮

---

#### BlockerView / BlockSection / RunningAppsSection

**文件**: [BlockerView.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/BlockerView.swift)
[BlockerBlockSection.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/BlockerBlockSection.swift)
[BlockerRunningAppsSection.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/BlockerRunningAppsSection.swift)

**`BlockerView`**：双 Tab 容器（Block / Running Apps）

**`BlockSection`**（已屏蔽应用）：
- 已屏蔽应用列表，每行显示图标、名称、Bundle ID、屏蔽时间
- 解除屏蔽按钮
- 空状态提示
- **不可关闭模式开关**：底部 Toggle，启用后应用无法被关闭/最小化/隐藏

**`RunningAppsSection`**（运行中应用）：
- 搜索栏（支持名称和 Bundle ID 搜索）
- 刷新按钮
- 运行中应用列表，每行显示图标、名称、Bundle ID、PID
- 屏蔽/解除屏蔽按钮切换

---

### 4.7 设计系统 (DesignSystem.swift)

**文件**: [DesignSystem.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/DesignSystem.swift)

集中式设计系统，统一 UI 风格。

**`DesignSystem.Colors`** — OLED 优化纯黑主题：
- 背景：纯黑 `Color.black`、`surface`(0.05)、`surfaceLight`(0.08)、`surfaceLighter`(0.12)
- 文字：`textPrimary`(white)、`textSecondary`(0.85)、`textTertiary`(0.65)、`textQuaternary`(0.45)
- 优先级色彩：高(红 0.9/0.3/0.3)、中(橙 0.9/0.6/0.2)、低(绿 0.3/0.8/0.4)
- 计时器色彩：`timerActive`(软蓝)、`timerBreak`(软绿)、`timerPaused`(软橙)
- 交互状态：`interactive`(0.1)、`interactiveHover`(0.15)、`interactivePressed`(0.2)

**`DesignSystem.Typography`** — 字体系统（Inter 风格）：
- 标题：`largeTitle`(34pt light) ~ `caption2`(11pt medium)
- 计时器：`timerLarge`(56pt ultralight)、`monospacedLarge`(56pt ultralight monospaced)

**`DesignSystem.Spacing`** — 8pt 网格间距系统：xs(4) ~ xxxl(64)

**`DesignSystem.CornerRadius`**：small(6) ~ circle(999)

**`DesignSystem.LineWidth`**：hairline(0.5) ~ bold(4.0)

**`DesignSystem.Animation`**：quick(0.12s)、standard(0.2s)、gentle(0.3s)

**`DesignSystem.Shadows`**：subtle(0.2)、medium(0.4)、strong(0.6)

**按钮样式**：
- `MinimalButtonStyle`：5 种变体（primary/secondary/destructive/ghost/success），3 种尺寸（small/medium/large）
- `TabButtonStyle`：选中/未选中状态切换

**其他样式**：
- `CardStyle`：卡片背景 + 圆角 + 描边 + 阴影
- `ClockIcon`：自定义时钟图标组件

**View 扩展**：
- `.minimalButtonStyle()`、`.cardStyle()`、`.tabButtonStyle()`
- `.sectionPadding()`、`.contentPadding()`、`.cardPadding()`

---

### 4.8 共享组件 (SharedComponents.swift)

**文件**: [SharedComponents.swift](file:///Users/jackson/Desktop/%20%20%20%20%20/claude/task-timer-app/Sources/TaskTimerApp/SharedComponents.swift)

可复用 UI 组件：

| 组件 | 说明 |
|------|------|
| `PriorityBadge` | 优先级小圆点（8x8） |
| `TaskRowView` | 标准任务行（完成按钮、标题、分类、截止日期、删除） |
| `SectionHeaderView` | 分区标题（含可选操作按钮） |
| `EmptyStateView` | 空状态占位（图标、标题、副标题） |
| `LoadingView` | 加载指示器 |
| `ConfirmationDialog` | 确认对话框（取消/确认按钮） |

---

## 5. 依赖关系图

```
┌──────────────────────────────────────────────────────────────────┐
│                        外部依赖                                   │
│  SwiftUI    AppKit    Foundation    Combine    OSLog    Dispatch  │
└──────────────────────────┬───────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────────┐
          ▼                ▼                    ▼
   ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐
   │ DesignSystem │ │ 0_Models     │ │ SharedComponents │
   │  (纯静态)     │ │  (纯数据)     │ │   (纯 UI)        │
   └──────┬───────┘ └──────┬───────┘ └────────┬─────────┘
          │                │                   │
          ▼                ▼                   ▼
   ┌──────────────────────────────────────────────────┐
   │                   View Layer                      │
   │  ContentView → TasksView / TimerView / PlansView │
   │              / AllTasksView / BlockerView         │
   │  AddTaskView / TaskDetailView / FloatingTimerWnd  │
   └──────────────────────┬───────────────────────────┘
                          │ @EnvironmentObject
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
   ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐
   │ TaskManager  │ │ TimerManager │ │ AppBlockerManager│
   │  @Published  │ │  @Published  │ │   @Published     │
   └──────┬───────┘ └──────┬───────┘ └────────┬─────────┘
          │                │                   │
          │          ┌─────┘                   │
          ▼          ▼                         ▼
   ┌──────────────────────┐          ┌─────────────────┐
   │   StorageManager     │          │   UserDefaults  │
   │   (Singleton)        │          │   (blockedApps) │
   │   JSON File I/O      │          │                 │
   └──────────────────────┘          └─────────────────┘
```

**依赖方向**：视图 → 管理器 → 持久化层

**关键依赖关系**：
- `TimerManager` 依赖 `TaskManager`（通过构造函数注入），用于保存会话
- `ContentView` 创建并持有 `TaskManager` 和 `TimerManager`
- `TaskTimerApp`（App 入口）创建并持有 `AppBlockerManager`
- `StorageManager` 是单例，被 `TaskManager` 和 `TimerManager` 直接使用
- `AppDelegate` 持有 `AppBlockerManager` 引用以检查不可关闭模式

---

## 6. 数据流与状态管理

### 状态管理方案

| 机制 | 用途 | 示例 |
|------|------|------|
| `@StateObject` | 视图树根节点创建和持有 ObservableObject | `ContentView` 创建 `TaskManager` |
| `@EnvironmentObject` | 跨视图层级共享状态 | 所有子视图读取 `taskManager` |
| `@ObservedObject` | 接收外部传入的 ObservableObject | `FloatingTimerWindow` 接收 `TimerManager` |
| `@Published` | 管理器属性变更自动通知视图 | `TaskManager.tasks` 变更触发 UI 更新 |
| `@State` | 视图内部局部状态 | `selectedTab`、`showingAddTask` |
| `@FocusState` | 输入框焦点管理 | `AddTaskView` 中自动聚焦标题 |
| `NotificationCenter` | 跨模块事件通知 | 计时器开始/停止通知 |
| `UserDefaults` | 简单键值持久化 | 已屏蔽应用列表、不可关闭模式 |

### 数据流示例

```
用户点击"添加任务"
  → AddTaskView.createTaskItem()
    → taskManager.addTask(task)
      → tasks.append(task)
      → 自动创建分类（如不存在）
      → invalidateCache()
      → saveAllData()
        → storage.saveDebounced(tasks, .tasks)
          → 0.5s 后异步写入 JSON 文件
      → @Published 属性变化
        → SwiftUI 自动重绘 TasksView / AllTasksView
```

```
用户启动计时器
  → TaskRow: timerManager.startTimer(for: task)
    → state = .running
    → startTimerSource() (DispatchSourceTimer)
    → NotificationCenter.post(.timerDidStart)
      → ContentView 监听到通知
        → selectedTab = .timer
        → FloatingTimerManager.showFloatingTimer()
    → 每秒 processTimerTick()
      → remainingTime -= 1
      → @Published 触发 TimerView 和 FloatingTimerWindow 重绘
    → 时间到 → completeWorkSession()
      → savePomodoroSession(for: task)
        → taskManager.addSession(session)
      → startBreakSession()
```

---

## 7. 数据持久化

### 存储位置

```
~/Library/Application Support/com.iflow.tasktimer/
├── tasks.json          ← [TaskItem] JSON 数组
├── categories.json     ← [Category] JSON 数组
├── sessions.json       ← [PomodoroSession] JSON 数组
├── plans.json          ← [Plan] JSON 数组
└── chat_history.db     ← SQLite 数据库（聊天历史）

~/Library/Preferences/
└── UserDefaults: "blockedApps" key  ← [BlockedApp] JSON 编码
    UserDefaults: "unclosableMode" key ← Bool
```

### 编码格式
- JSON 编码器：`JSONEncoder`，`dateEncodingStrategy: .iso8601`
- JSON 解码器：`JSONDecoder`，`dateDecodingStrategy: .iso8601`
- 写入策略：`Data.write(to:options: .atomic)` 确保原子性
- 防抖延迟：0.5 秒

### 数据生命周期
- **自动清理**：已完成任务在完成后 2 天自动删除（`cleanupStaleData()`）
- **重复任务**：每小时检查并创建重复任务的新实例
- **应用终止**：`AppDelegate.applicationWillTerminate()` 调用 `flushPendingSaves()`

---

## 8. 运行与构建

### 环境要求
- macOS 13.0+
- Xcode 15.0+（开发用）
- Swift 5.9+

### 开发运行

```bash
# 进入项目目录
cd task-timer-app

# 直接运行（开发模式）
swift run

# Debug 构建
swift build

# Release 构建
swift build -c release

# 清理构建产物
swift package clean && rm -rf .build
```

### 打包为 .app

```bash
# 一键构建 + 打包 + 安装到 /Applications
./create_bundle.sh

# 或手动步骤：
swift build -c release
mkdir -p TaskTimerApp.app/Contents/MacOS
mkdir -p TaskTimerApp.app/Contents/Resources
cp .build/arm64-apple-macosx/release/TaskTimerApp TaskTimerApp.app/Contents/MacOS/
cp icon.icns TaskTimerApp.app/Contents/Resources/
# 创建 Info.plist ...
codesign --force --deep -s - TaskTimerApp.app
mv TaskTimerApp.app /Applications/
```

### 测试打包版应用

```bash
open /Applications/TaskTimerApp.app
```

### 开机自启动

```bash
# 创建 LaunchAgent
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

launchctl load ~/Library/LaunchAgents/com.tasktimerapp.plist
```

### 重置数据

```bash
rm -rf ~/Library/Application\ Support/com.iflow.tasktimer/
rm -rf ~/Library/Preferences/com.iflow.tasktimer.*
```

---

## 9. 性能优化策略

| 策略 | 实现位置 | 说明 |
|------|----------|------|
| **LazyVStack** | TasksView、AllTasksView、PlansView | 延迟加载大列表，只渲染可见行 |
| **缓存机制** | TaskManager | `cachedActiveTasks`/`cachedCompletedTasks` 避免重复过滤 |
| **防抖保存** | StorageManager | 0.5s 延迟，取消同类型重复保存 |
| **后台 I/O** | StorageManager | `DispatchQueue.global(qos: .utility)` |
| **DispatchSourceTimer** | TimerManager | 比 `Timer.scheduledTimer` 更高效 |
| **弱引用** | TimerManager、TaskManager | `[weak self]` 避免循环引用 |
| **URL 缓存** | StorageManager | `fileCache` 字典预加载文件路径 |
| **deinit 清理** | TimerManager、TaskManager、AppBlockerManager | 释放定时器、清空缓存 |
| **原子写入** | StorageManager | `Data.write(to:options: .atomic)` 防数据损坏 |
| **JSON 压缩** | StorageManager | `outputFormatting: []` 不格式化输出 |

---

## 10. 安全注意事项

- **代码签名**：macOS 分发需要正确的代码签名
- **辅助功能权限**：应用屏蔽功能可能需要系统设置中的辅助功能权限
- **沙盒存储**：数据存储在 `~/Library/Application Support/` 沙盒目录
- **自我保护**：无法屏蔽 TaskTimerApp 自身（通过 Bundle ID 检查）
- **UserDefaults**：已屏蔽应用列表存储在 UserDefaults 中，敏感数据建议迁移到加密存储
- **数据局部性**：所有数据本地存储，不会外部传输

---

> **文档版本**: 1.0  
> **生成日期**: 2026-08-10  
> **对应项目版本**: TaskTimerApp 1.0.0