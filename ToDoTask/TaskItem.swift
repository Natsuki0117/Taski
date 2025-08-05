//
//  TaskItem.swift
//  ToDoTask
//
//  Created by 金井菜津希 on 2024/08/21.
//

import FirebaseFirestore

struct TaskItem: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var slider: String
    var title: String
    var dueDate: Date
    var doTime: Int
    
    init(id: String? = nil, userId: String = "", name: String, slider: String, title: String, dueDate: Date, doTime: Int) {
        self.id = id
        self.userId = userId
        self.name = name
        self.slider = slider
        self.title = title
        self.dueDate = dueDate
        self.doTime = doTime 
    }
}

extension Encodable {
    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}


