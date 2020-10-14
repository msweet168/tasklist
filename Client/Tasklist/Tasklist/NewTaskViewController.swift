//
//  NewTaskViewController.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/14/20.
//

import UIKit

protocol NewTaskViewDelegate {
    func taskAddedSuccessfully()
}

class NewTaskViewController: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var taskField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var sampleTaskView: UIView!
    @IBOutlet weak var sampleTaskLabel: UILabel!
    
    // MARK: Constants
    public static let nibName = "NewTaskViewController"
    
    // MARK: Variables
    var delegate: NewTaskViewDelegate?

    // MARK: Functions
    init() {
        super.init(nibName: NewTaskViewController.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewSetup() {
        super.viewSetup()
        
        TasklistStyler.styleRoundedButton(button: addButton, backgroundColor: .systemBlue)
        TasklistStyler.styleLargeTextField(textField: taskField)
        sampleTaskView.layer.cornerRadius = TasklistStyler.mainCornerRadius
        sampleTaskLabel.text = ""
    }
    
    func addTask() {
        guard taskField.containsValidText() else {
            taskField.backgroundColor = .faintRed
            return
        }
        api.addTask(taskText: taskField.text!) { (success) in
            if success {
                self.delegate?.taskAddedSuccessfully()
                self.dismiss(animated: true, completion: nil)
            } else {
                self.showBanner(with: "Error creating task...")
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func textFieldDismissed(sender: UITextField) {
        sender.dismissKeyboard()
        sender.backgroundColor = .systemGray6
    }
    @IBAction func addButtonTapped() { addTask() }
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        self.sampleTaskLabel.text = sender.text
    }
}
