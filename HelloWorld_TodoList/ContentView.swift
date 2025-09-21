import SwiftUI




struct ContentView: View {
    @StateObject private var taskStore = TaskStore()
    @State private var newTaskTitle = ""

    private let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 242/255, green: 247/255, blue: 252/255)
                                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Logo
                    Image("logo")
                        .resizable()
                        .frame(width: 200, height: 50)
                        .padding(.top, 20)
                    
                    // Title
                    Text("Welcome To FocusFlow!")
                        .font(.system(size: 28).bold())
                        .padding(.top, 5)
                        .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                    
                    // Plus button and table label
                    HStack {
                        Text("Create New Task:")
                            .font(.title.bold())
                            .padding()
                            .foregroundColor(Color(red: 75/255, green: 139/255, blue: 191/255))
                        
                        NavigationLink(destination: SwiftUIView().environmentObject(taskStore)) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(red: 75/255, green: 139/255, blue: 191/255))
                        }
                        .padding()
                    }
                    
                    // Task list with rounded rectangle background
                    ZStack {
                        VStack(spacing: 0) {
                        // Header (non-scrolling)
                        HStack(spacing: 10) {
                            Text("Done").bold() .frame(width: 50) .foregroundColor(Color(red: 242/255, green: 247/255, blue: 252/255))
                            Text("Due").bold()  .frame(width: 100) .foregroundColor(Color(red: 242/255, green: 247/255, blue: 252/255))
                            Text("Title").bold().frame(maxWidth: .infinity, alignment: .leading) .foregroundColor(Color(red: 242/255, green: 247/255, blue: 252/255))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(red: 6/255, green: 67/255, blue: 117/255))
                        //.opacity(0.12)
                        // The List (scrolls)
                        List {
                            ForEach(filteredTasks) { task in
                                ZStack(alignment: .leading) {
                                    HStack(spacing: 10) {
                                        Button(action: { markTaskCompleted(task) }) {
                                            Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(task.completed ? .blue : .gray)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .frame(width: 50, alignment: .center)

                                        Text(taskDateFormatter.string(from: task.date))
                                            .frame(width: 100, alignment: .center)
                                            .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))

                                        Text(task.title)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(4)
                                            .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(priorityColor(for: task.priority), lineWidth: 2)
                                            )
                                    }
                                    .padding(.vertical, 4)

                                    if task.completed {
                                        Rectangle()
                                            .fill(Color.gray)
                                            .frame(height: 2)
                                            .offset(y: 0)
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                .listRowSeparator(.hidden)
                                .background(Color.clear)
                            }
                            .onDelete { indexSet in
                                taskStore.tasks.remove(atOffsets: indexSet)
                            }
                        }
                        .listStyle(.plain)
                        .frame(maxHeight: .infinity) // <- lets List claim remaining space so it can scroll
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                    .overlay(
                        // Make sure the decorative border does not block touches
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            .allowsHitTesting(false) // <- important if you saw taps/scroll blocked
                    )
                    .padding(.horizontal, 10)

                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            removeExpiredTasks()
        }
    }

    // MARK: - Helpers

    private var filteredTasks: [Task] {
        // Filter out tasks that were completed more than 5 days ago
        let validTasks = taskStore.tasks.filter { task in
            if let completedDate = task.completedDate {
                return Date().timeIntervalSince(completedDate) < 5 * 24 * 60 * 60
            }
            return true
        }

        // Sort tasks: incomplete first, then by date, then by priority
        return validTasks.sorted { t1, t2 in
            if t1.completed != t2.completed {
                return !t1.completed // incomplete tasks first
            }

            if Calendar.current.isDate(t1.date, inSameDayAs: t2.date) {
                // Same date, sort by priority
                return priorityValue(for: t1.priority) > priorityValue(for: t2.priority)
            } else {
                return t1.date < t2.date
            }
        }
    }

    // Helper function to convert priority to numeric value for sorting
    private func priorityValue(for priority: String) -> Int {
        switch priority {
        case "High": return 3
        case "Medium": return 2
        case "Low": return 1
        default: return 0
        }
    }
    private func markTaskCompleted(_ task: Task) {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            if taskStore.tasks[index].completed {
                // Unmark as completed
                taskStore.tasks[index].completed = false
                taskStore.tasks[index].completedDate = nil
            } else {
                // Mark as completed
                taskStore.tasks[index].completed = true
                taskStore.tasks[index].completedDate = Date()
            }
        }
    }


    private func removeExpiredTasks() {
        taskStore.tasks.removeAll { task in
            if let completedDate = task.completedDate {
                return Date().timeIntervalSince(completedDate) >= 5 * 24 * 60 * 60
            }
            return false
        }
    }

   
    private func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .yellow
        default: return .gray
        }
    }
}
