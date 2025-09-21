import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - UserTask Model
struct UserTask: Identifiable {
    var id: String // Firestore document ID
    var title: String
    var date: Date
    var priority: String
    var completed: Bool = false
    var completedDate: Date? = nil
}

// MARK: - UserTaskStore
class UserTaskStore: ObservableObject {
    @Published var tasks: [UserTask] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        fetchTasks()
    }
    
    func fetchTasks() {
        guard let uid = userId else { return }
        
        listener?.remove()
        
        listener = db.collection("users").document(uid).collection("tasks")
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                self.tasks = documents.compactMap { doc -> UserTask? in
                    let data = doc.data()
                    guard
                        let title = data["title"] as? String,
                        let timestamp = data["date"] as? Timestamp,
                        let priority = data["priority"] as? String,
                        let completed = data["completed"] as? Bool
                    else { return nil }
                    
                    let completedDate = (data["completedDate"] as? Timestamp)?.dateValue()
                    
                    return UserTask(
                        id: doc.documentID,
                        title: title,
                        date: timestamp.dateValue(),
                        priority: priority,
                        completed: completed,
                        completedDate: completedDate
                    )
                }
            }
    }
    
    func addTask(_ task: UserTask) {
        guard let uid = userId else { return }
        
        let data: [String: Any] = [
            "title": task.title,
            "date": task.date,
            "priority": task.priority,
            "completed": task.completed,
            "completedDate": task.completedDate ?? NSNull()
        ]
        
        db.collection("users").document(uid).collection("tasks")
            .document(task.id)
            .setData(data)
    }
    
    func updateTask(_ task: UserTask) {
        addTask(task)
    }
    
    func deleteTask(_ task: UserTask) {
        guard let uid = userId else { return }
        db.collection("users").document(uid).collection("tasks")
            .document(task.id)
            .delete()
    }
}
