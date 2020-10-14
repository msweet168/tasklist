//
//  ProfileView.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/9/20.
//

import UIKit

@objc protocol ProfileControllerDelegate {
    func logOutTapped(sender: UIButton)
    @objc optional func dismissTapped(sender: UIButton)
}

class ProfileView: UIView {

    // MARK: IBOutlets
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: Constants
    public static let nibName = "ProfileViewController"
    
    // MARK: Variables
    var delegate: ProfileControllerDelegate?
    var username: String
    
    // MARK: Functions
    init(frame: CGRect, username: String) {
        self.username = username
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(ProfileView.nibName, owner: self, options: nil)
        self.addSubview(view)
        view.frame = self.bounds
        
        usernameLabel.text = username
        mainView.layer.cornerRadius = TasklistStyler.mainCornerRadius
        mainView.layer.masksToBounds = true
        TasklistStyler.styleLogoutButton(button: logOutButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBActions
    @IBAction func logOutTapped(sender: UIButton) { delegate?.logOutTapped(sender: sender) }
    @IBAction func dismissTapped(sender: UIButton) {
        self.removeFromSuperview()
        delegate?.dismissTapped?(sender: sender)
    }
}
