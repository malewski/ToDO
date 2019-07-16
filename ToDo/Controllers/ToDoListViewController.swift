//
//  ToDoListViewController.swift
//  ToDo
//
//  Created by Jan Malewski on 14/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ToDoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var tasks : Results<Task>?
    
    var selectedCategory : Category? {
        didSet{
            loadTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        
        loadTasks()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadTasks()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        if let task = tasks?[indexPath.row] {
            
            cell.textLabel?.text = task.title
            
            cell.accessoryType = task.done ? .checkmark: .none
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
            destinationVC.category = selectedCategory
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new task", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newTask = Task()
                        newTask.title = textField.text!
                        currentCategory.tasks.append(newTask)
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: self.tasks!.count-1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                        self.performSegue(withIdentifier: "showDetails", sender: self)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
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
    
    func loadTasks() {
        
        tasks = selectedCategory?.tasks.sorted(byKeyPath: "priority", ascending: false)
        
        tableView.reloadData()
    }
}

extension ToDoListViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            if let taskForDeletion = self.tasks?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(taskForDeletion)
                    }
                } catch {
                    print("Error deleting task, \(error)")
                }
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}
