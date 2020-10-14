//
//  LoginViewController.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/7/20.
//

import UIKit

class LoginViewController: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    // MARK: Functions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if api.isLoggedIn() { loadTaskView() }
        self.usernameField.isEnabled = true
        self.passwordField.isEnabled = true
        self.usernameField.clear()
        self.passwordField.clear()
    }
    
    override func viewSetup() {
        super.viewSetup()
        popupView.layer.cornerRadius = TasklistStyler.largeCornerRadius
        popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        TasklistStyler.styleLargeTextField(textField: usernameField)
        TasklistStyler.styleLargeTextField(textField: passwordField)
        TasklistStyler.styleRoundedButton(button: loginButton)
        TasklistStyler.styleRoundedButton(button: signUpButton, backgroundColor: .white)
        signUpButton.layer.borderWidth = 2
        signUpButton.layer.borderColor = UIColor.themeBlue.cgColor
        passwordField.isSecureTextEntry = true
        
    }
    
    // TODO: Login and signup are too similar
    func login() {
        guard let username = usernameField.safeText else {
            usernameField.backgroundColor = .faintRed
            return
        }
        guard let password = passwordField.safeText else {
            passwordField.backgroundColor = .faintRed
            return
        }
        api.login(username: username, password: password) { (success) in
            guard success == true else {
                self.showBanner(with: "Incorrect username or password...")
                return
            }
            self.usernameField.isEnabled = false
            self.passwordField.isEnabled = false
            self.loadTaskView()
        }
    }
    
    func signup() {
        guard let username = usernameField.safeText else {
            usernameField.backgroundColor = .faintRed
            return
        }
        guard let password = passwordField.safeText else {
            passwordField.backgroundColor = .faintRed
            return
        }
        api.signUp(username: username, password: password) { (success) in
            guard success == true else {
                self.showBanner(with: "Error creating account, please try again...")
                return
            }
            self.usernameField.clear()
            self.passwordField.clear()
            self.showBanner(with: "User successfully created")
        }
    }
    
    func loadTaskView() {
        let controller = (storyboard?.instantiateViewController(withIdentifier: TaskViewController.storyboardId))! as? TaskViewController
        controller?.modalPresentationStyle = .fullScreen
        present(controller!, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func loginTapped() { login() }
    @IBAction func signupTapped() { signup() }
    
    @IBAction func usernameFieldReturned(sender: UITextField) {
        sender.backgroundColor = .systemGray6
        passwordField.becomeFirstResponder()
    }
    
    @IBAction func passwordFieldReturned(sender: UITextField) {
        sender.backgroundColor = .systemGray6
        sender.dismissKeyboard()
    }

}
