//
//  DetailsViewController.swift
//  ToDo
//
//  Created by Jan Malewski on 14/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsViewController: UIViewController, UITextViewDelegate {
    
    let realm = try! Realm()
    var categories : Results<Category>?
    let priorityArray = ["low", "medium", "high",]
    
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var priorityPicker: UIPickerView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    var selectedTask : Task?
    var category: Category?
    var categoryIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        self.details.delegate = self
        
        if let task = selectedTask {
            self.navBar.title = task.title
            self.details.text = task.details
            if task.done {
                self.doneButton.setTitle("Undo", for: .normal)
            } else {
                self.doneButton.setTitle("Done", for: .normal)
            }
            
            priorityPicker.selectRow(task.priority, inComponent: 0, animated: true)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        categories = realm.objects(Category.self)
        categoryIndex = categories!.index(of: category!)!
        categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        save()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        editButton.title = "Done"
    }
    
    @IBAction func DoneButtonPressed(_ sender: Any) {
        if let task = selectedTask {
            do {
                try realm.write {
                    task.done = !task.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func EditButtonPressed(_ sender: Any) {
        
        if editButton.title == "Done" {
            details.resignFirstResponder()
            editButton.title = "Rename"
        } else {
            
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Rename task", message: "", preferredStyle: .alert)
            
            let editAction = UIAlertAction(title: "OK", style: .default) { (action) in
                if let task = self.selectedTask {
                    do {
                        try self.realm.write {
                            task.title = textField.text!
                        }
                    } catch {
                        print("Error saving done status, \(error)")
                    }
                }
                self.navigationItem.title = textField.text!
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                
            }
            
            editAction.isEnabled = true
            alert.addAction(cancelAction)
            alert.addAction(editAction)
            
            alert.addTextField { (alertTextField) in
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: OperationQueue.main, using:
                    {_ in
                        
                        let textCount = alertTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                        let textIsNotEmpty = textCount > 0
                        
                        editAction.isEnabled = textIsNotEmpty
                })
                alertTextField.text = self.selectedTask?.title
                textField = alertTextField
            }
            present(alert, animated: true, completion: nil)
        }
    }
    
    func save(){
        if let task = selectedTask {
            do {
                try realm.write {
                    task.details = details.text
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
    }
        
}

extension DetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == priorityPicker {
            return 3
        } else if pickerView == categoryPicker {
            return categories?.count ?? 1
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == priorityPicker {
            return priorityArray[row]
        } else if pickerView == categoryPicker {
            return categories?[row].name ?? ""
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == priorityPicker {
            
            if let task = selectedTask {
                do {
                    try realm.write {
                        task.priority = row
                    }
                } catch {
                    print("Error saving done status, \(error)")
                }
            }
            
        } else if pickerView == categoryPicker {
            if categoryIndex != row {
                if let task = selectedTask {
                    do {
                        try realm.write {
                            let copyTask = Task(value: task)
                            categories?[row].tasks.append(copyTask)
                            realm.delete(task)
                            self.navigationController?.popViewController(animated: true)
                        }
                    } catch {
                        print("Error saving done status, \(error)")
                    }
                }
            } 
        }

    }
    
}
