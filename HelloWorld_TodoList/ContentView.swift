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

                // Plus button and table label
                HStack {
                    Text("Task Table")
                        .font(.title.bold())
                        .padding()

                    NavigationLink(destination: SwiftUIView().environmentObject(taskStore)) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }

                // Table header
                HStack(spacing: 10) {
                    Text("Done")
                        .bold()
                        .frame(width: 50, alignment: .center)

                    Text("Due Date")
                        .bold()
                        .frame(width: 100, alignment: .center)

                    Text("Title")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                // Task list
                // Replace this part in your body:

                // Task list with rounded rectangle background
                ZStack {
                    // Rounded rectangle behind the table
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2) // border color
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white)) // optional fill
                        .padding(.horizontal, 10)

                    // The List itself
                    List {
                        ForEach(filteredTasks) { task in
                            ZStack(alignment: .leading) {
                                HStack(spacing: 10) {
                                    // Completed button
                                    Button(action: { markTaskCompleted(task) }) {
                                        Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(task.completed ? .blue : .gray)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(width: 50, alignment: .center)

                                    // Due date
                                    Text(taskDateFormatter.string(from: task.date))
                                        .frame(width: 100, alignment: .center)

                                    // Title with priority color
                                    Text(task.title)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(priorityColor(for: task.priority), lineWidth: 2)
                                        )
                                }
                                .padding(.vertical, 4)

                                // Overlay strikethrough line if completed
                                if task.completed {
                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(height: 2)
                                        .offset(y: 0)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            taskStore.tasks.remove(atOffsets: indexSet)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal, 10) // padding to match the rounded rectangle
                }


                Spacer()
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
