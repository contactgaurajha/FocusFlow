import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @StateObject private var taskStore = UserTaskStore()
    @State private var isLoggedIn = false
    
    private let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
    
    var body: some View {
        Group {
            if isLoggedIn {
                NavigationStack {
                    ZStack {
                        Color(red: 242/255, green: 247/255, blue: 252/255)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            // Logo
                            Image("FFLogoUpdated")
                                .resizable()
                                .frame(width: 200, height: 50)
                                .padding(.top, 20)
                            
                            // Title
                            Text("Welcome To FocusFlow!")
                                .font(.system(size: 28).bold())
                                .padding(.top, 5)
                                .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                            
                            // Plus button and label
                            HStack {
                                Text("Create New Task:")
                                    .font(.title.bold())
                                    .padding()
                                    .foregroundColor(Color(red: 75/255, green: 139/255, blue: 191/255))
                                
                                NavigationLink(destination: AddTaskView().environmentObject(taskStore)) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color(red: 75/255, green: 139/255, blue: 191/255))
                                }
                                .padding()
                            }
                            
                            // Full Task List
                            ZStack {
                                VStack(spacing: 0) {
                                    HStack(spacing: 10) {
                                        Text("Done").bold().frame(width: 50).foregroundColor(.white)
                                        Text("Due").bold().frame(width: 100).foregroundColor(.white)
                                        Text("Title").bold().frame(maxWidth: .infinity, alignment: .leading).foregroundColor(.white)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(red: 6/255, green: 67/255, blue: 117/255))
                                    
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
                                            indexSet.forEach { i in
                                                taskStore.deleteTask(filteredTasks[i])
                                            }
                                        }
                                    }
                                    .listStyle(.plain)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                        .allowsHitTesting(false)
                                )
                                .padding(.horizontal, 10)
                            }
                            
                            Spacer()
                        }
                    }
                    .navigationTitle("Tasks")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Logout") {
                                logout()
                            }
                        }
                    }
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            isLoggedIn = Auth.auth().currentUser != nil
            
            Auth.auth().addStateDidChangeListener { _, user in
                isLoggedIn = (user != nil)
            }
        }
    }
    
    // MARK: - Helpers
    private var filteredTasks: [UserTask] {
        let validTasks = taskStore.tasks.filter { task in
            if let completedDate = task.completedDate {
                return Date().timeIntervalSince(completedDate) < 5 * 24 * 60 * 60
            }
            return true
        }
        
        return validTasks.sorted { t1, t2 in
            if t1.completed != t2.completed {
                return !t1.completed
            }
            if Calendar.current.isDate(t1.date, inSameDayAs: t2.date) {
                return priorityValue(for: t1.priority) > priorityValue(for: t2.priority)
            } else {
                return t1.date < t2.date
            }
        }
    }
    
    private func priorityValue(for priority: String) -> Int {
        switch priority {
        case "High": return 3
        case "Medium": return 2
        case "Low": return 1
        default: return 0
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
    
    private func markTaskCompleted(_ task: UserTask) {
        if let index = taskStore.tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = taskStore.tasks[index]
            updatedTask.completed.toggle()
            updatedTask.completedDate = updatedTask.completed ? Date() : nil
            taskStore.updateTask(updatedTask)
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}

// MARK: - AddTaskView
struct AddTaskView: View {
    @EnvironmentObject var taskStore: UserTaskStore
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var date = Date()
    @State private var priority = "Medium"
    
    private let taskDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 10) {
            Form {
                Section("Title") {
                    TextField("Task title", text: $title)
                }
                Section("Due Date") {
                    DatePicker("", selection: $date, displayedComponents: .date)
                }
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Text("High").tag("High")
                        Text("Medium").tag("Medium")
                        Text("Low").tag("Low")
                    }
                    .pickerStyle(.segmented)
                }
                
                Button("Add Task") {
                    let newTask = UserTask(
                        id: UUID().uuidString,
                        title: title,
                        date: date,
                        priority: priority
                    )
                    taskStore.addTask(newTask)
                    title = ""
                    date = Date()
                    priority = "Medium"
                }
                .font(.headline)
                .padding(.vertical, 8)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            // Recently Added Tasks (below button)
            if !taskStore.tasks.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recently Added Tasks")
                        .font(.headline)
                        .padding(.leading, 16)
                    
                    List {
                        ForEach(taskStore.tasks.sorted(by: { $0.date > $1.date }).prefix(5)) { task in
                            HStack {
                                Text(task.title)
                                    .foregroundColor(.black)
                                Spacer()
                                Text(taskDateFormatter.string(from: task.date))
                                    .foregroundColor(.gray)
                            }
                            .padding(4)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(min(taskStore.tasks.count, 5)) * 44)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("Add Task")
        .padding(.top, 10)
    }
}
