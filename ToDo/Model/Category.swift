//
//  Category.swift
//  ToDo
//
//  Created by Jan Malewski on 16/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    let tasks = List<Task>()
}
