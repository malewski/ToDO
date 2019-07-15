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
    let priorityArray = ["low", "medium", "high",]
    
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var priorityPicker: UIPickerView!
    
    var selectedTask : Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        
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
    
    func textViewDidChange(_ textView: UITextView) {
        save()
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
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Edit taks title", message: "", preferredStyle: .alert)
        
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
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorityArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let task = selectedTask {
            do {
                try realm.write {
                    task.priority = row
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
    }
}
