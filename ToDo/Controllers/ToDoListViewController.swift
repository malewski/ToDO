//
//  ToDoListViewController.swift
//  ToDo
//
//  Created by Jan Malewski on 14/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var tasks : Results<Task>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        cell.textLabel?.text = tasks?[indexPath.row].title ?? "There is no task to do!"
        
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: self)
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add task", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add task", style: .default) { (action) in
            
            let newTask = Task()
            newTask.title = textField.text!
            
            self.save(task: newTask)
        }
        
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func save(task: Task) {
        
        do {
            try realm.write {
                realm.add(task)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadTasks() {
        
        tasks = realm.objects(Task.self)
        
        tableView.reloadData()
    }
}
