//
//  Task.swift
//  ToDo
//
//  Created by Jan Malewski on 14/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var details: String = ""
    @objc dynamic var priority: Int = 0
}
