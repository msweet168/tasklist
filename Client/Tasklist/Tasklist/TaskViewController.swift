//
//  TaskViewController.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/7/20.
//

import UIKit

class TaskViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, ProfileControllerDelegate, NewTaskViewDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newTaskButton: UIButton!
    
    // MARK: Constants
    public static let storyboardId = "taskview"
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: Variables
    var tasks = [Task]()
    var profileView: ProfileView!

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        tableViewSetup()
        
        profileView = ProfileView(frame: CGRect(x: 10, y: 60, width: self.view.frame.width-20, height: 180), username: api.getUsername() ?? "User")
        profileView.delegate = self
    }
    
    override func viewSetup() {
        super.viewSetup()
        welcomeLabel.text = "Hi There \(api.getUsername()?.capitalized ?? "")!"
        welcomeLabel.font = UIFont.rounded(ofSize: 30, weight: .heavy)
    }
    
    func getData() {
        startLoading()
        api.getTasks { (maybeTasks) in
            guard let tasks = maybeTasks else {
                self.showBanner(with: "Error fetching tasks...")
                return
            }
            self.stopLoading()
            self.tasks = tasks
            self.tableView.reloadData()
        }
        
    }
    
    func toggleTaskCompleted(task: Task) {
        api.toggleTaskCompletion(task: task) { (success) in
            guard success == true else {
                self.showBanner(with: "Error completing task...")
                return
            }
            self.getData()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableViewSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: TaskCell.nibName, bundle: nil), forCellReuseIdentifier: TaskCell.identifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tasks.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.identifier, for: indexPath) as! TaskCell
        let currentTask = tasks[indexPath.row]
        
        cell.setText(text: currentTask.text)
        cell.setCompleted(completed: currentTask.completed)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        generator.impactOccurred()
        toggleTaskCompleted(task: tasks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            api.deleteTask(task: tasks[indexPath.row]) { (success) in
                if success {
                    self.getData()
                } else {
                    self.showBanner(with: "Error deleting task..." )
                }
            }
        }
    }
    
    // MARK: NewTaskViewDelegate
    func showNewTaskView() {
        let newTaskVC = NewTaskViewController()
        newTaskVC.delegate = self
        self.present(newTaskVC, animated: true, completion: nil)
    }
    
    func taskAddedSuccessfully() { getData() }
    
    // MARK: ProfileControllerDelegate
    func showProfileView() {
        profileView.alpha = 0
        self.view.addSubview(profileView)
        UIView.animate(withDuration: 0.3) { self.profileView.alpha = 1 }
    }
    
    func logOutTapped(sender: UIButton) {
        api.logOut { (success) in
            guard success == true else {
                self.showBanner(with: "Error logging user out...")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: IBActions
    @IBAction func addTaskTapped() { showNewTaskView() }
    @IBAction func profileButtonTapped() { showProfileView() }
}
