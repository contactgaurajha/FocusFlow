import SwiftUI

// Task model
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var priority: String
    var date: Date
    var completed: Bool = false
    var completedDate: Date? = nil   // <-- Add this
}
// Shared task store
class TaskStore: ObservableObject {
    @Published var tasks: [Task] = []
}

// The "SwiftUIView" where tasks are created
struct SwiftUIView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var title = ""
    @State private var date = Date()
    @State private var priority = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack{
            Color(red: 242/255, green: 247/255, blue: 252/255)
                .ignoresSafeArea()
            VStack(spacing: 10) {
                //Spacer(minLength: 20)
                Image("FFLogoUpdated")
                    .resizable()
                    .frame(width: 200, height: 50)
                    .padding(.top, 20)
                
                
                TextField("Enter task title...", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                DatePicker("Due Date", selection: $date, displayedComponents: .date)
                    .padding()
                    .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                
                Menu(priority.isEmpty ? "Click to select priority" : priority) {
                    Button("High") { priority = "High" }
                    Button("Medium") { priority = "Medium" }
                    Button("Low") { priority = "Low" }
                }
                .padding()
                .background(Color(red: 75/255, green: 139/255, blue: 191/255).opacity(0.2))
                .foregroundColor(Color(red: 75/255, green: 139/255, blue: 191/255))
                .cornerRadius(8)
                
                
                
                Button("Create Task") {
                    if priority.isEmpty {
                        showAlert = true
                    } else {
                        let newTask = Task(title: title, priority: priority, date: date, completed: false)
                        taskStore.tasks.append(newTask)
                        
                        // Reset input fields
                        title = ""
                        priority = ""
                        date = Date()
                    }
                }
                .padding()
                .font(.headline)
                .foregroundColor(Color(red: 75/255, green: 139/255, blue: 191/255))
                .alert("Please select a priority before creating a task.",
                       isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                }
                
                Text("Recently added tasks:")
                    .padding(.top, 10)
                    .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                
                ForEach(taskStore.tasks.suffix(5).reversed()) { task in
                    HStack {
                        Text(task.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                        Text(task.priority)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                        Text(task.date, style: .date)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                    }
                    .padding(.vertical, 1)
                    
                    
                    
                }
                .padding()
            }
        }
    }
}
