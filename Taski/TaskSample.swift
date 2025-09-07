import FirebaseFirestore

struct TaskItem: Codable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var level: Int
    var isCompleted: Bool
}

class FirestoreClient {
    
    static var wishes: CollectionReference = Firestore.firestore().collection("tasks")
    
    //全部async awaitで！！！　↓こういう書き方
    static func aaaa() {
        Task {
            do {
                try await ....
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    static func fetchAll() async -> [TaskItem] {
        //ユーザーのuserIdでフィルターする
        wishes.whereField("userId", isEqualTo: /*userId*/).getDocuments()
    }
    
    static func add(task: TaskItem) {
        wishes.addDocument....
    }
    
    static func update(task: TaskItem) {
        wishes.document(...).set
    }
    
    static func delete(task: TaskItem) {
        wishes....
    }
    
}


struct ContentView: View {
    
    @State var tasks: [TaskItem] = []
    
    var body: some View {
        VStack {
            ForEach(tasks) { task in
                Text(task.name)
            }
        }
        .task {
            tasks = FirestoreClient.fetchAll()
        }
    }
}
