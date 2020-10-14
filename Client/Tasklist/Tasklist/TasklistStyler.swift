//
//  TasklistStyler.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/7/20.
//

import Foundation
import UIKit

class TasklistStyler {
    
    // MARK: Values
    public static let mainCornerRadius: CGFloat = 12
    public static let largeCornerRadius: CGFloat = 20
    
    // MARK: Functions
    public static func styleRoundedButton(button: UIButton, backgroundColor: UIColor = .themeBlue) {
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = mainCornerRadius
    }
    
    public static func styleLogoutButton(button: UIButton) {
        self.styleRoundedButton(button: button)
        button.backgroundColor = .faintRed
        button.setTitleColor(.white, for: .normal)
    }
    
    public static func styleLargeTextField(textField: UITextField) {
        textField.setLeftPaddingPoints(20)
        textField.layer.cornerRadius = mainCornerRadius
    }
    
    public static func styleTaskCell(cell: TaskCell) {
        cell.mainView.layer.cornerRadius = largeCornerRadius
        cell.backgroundColor = .clear
        cell.mainView.backgroundColor = .white
        cell.bottomConstraint.constant = 3
        cell.topConstraint.constant = 3
        cell.leftConstraint.constant = 10
        cell.rightConstraint.constant = 10
        cell.selectionStyle = .none
    }
    
    
}
