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
    override func viewWillAppear(_ animated: Bool) {
        
        loadTasks()
//        self.tableView.reloadData()
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        if let task = tasks?[indexPath.row] {
            
            cell.textLabel?.text = task.title
            
            cell.accessoryType = task.done ? .checkmark: .none
        } else {
            cell.textLabel?.text = "There is no task to do!"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DetailsViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedTask = tasks?[indexPath.row]
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new task", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newTask = Task()
            newTask.title = textField.text!
            self.save(task: newTask)
            let indexPath = IndexPath(row: self.tasks!.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            self.performSegue(withIdentifier: "showDetails", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        addAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(addAction)

        alert.addTextField { (alertTextField) in
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: OperationQueue.main, using:
                {_ in
                    
                    let textCount = alertTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0

                    addAction.isEnabled = textIsNotEmpty
            })
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
        loadTasks()
//        tableView.reloadData()
    }
    
    func loadTasks() {
        
        tasks = realm.objects(Task.self).sorted(byKeyPath: "priority", ascending: false)
        
        tableView.reloadData()
    }
}
