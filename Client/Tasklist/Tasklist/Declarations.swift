//
//  Declarations.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/7/20.
//

import Foundation
import UIKit

// MARK: Globals
struct Keys {
    public static let authTokenKey = "authtoken"
    public static let usernameKey = "username"
}


// MARK: UIColor
extension UIColor {
    @nonobjc static var themeBlue: UIColor { return #colorLiteral(red: 0.2039215686, green: 0.2862745098, blue: 0.368627451, alpha: 1) }
    @nonobjc static var faintRed: UIColor { return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.6531415053)}
}

// MARK: UITextField
extension UITextField {
    /// Sets textfield text to an empty string.
    func clear() { self.text = "" }
    func dismissKeyboard() { self.resignFirstResponder() }
    
    func setLeftPaddingPoints(_ amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setColoredPlaceholder(text: String, placeholderColor: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
    }
    
    func containsValidText(sizeLimit: Int? = nil) -> Bool {
        guard let text = self.text else { return false }
        guard text.count > 0 else { return false }
        if let limit = sizeLimit { if text.count > limit { return false }}
        // Add any other necessary checks here...
        return true
    }
    
    var safeText: String? {
        get {
            if self.containsValidText() { return self.text!}
            return nil
        }
    }
}

// MARK: UIViewController
extension UIViewController {
    // TODO: Too many magic variables, add this to the styler
    func showBanner(with text: String, for duration: Double = 3) {
        let bannerView = UILabel(frame: CGRect(x: 10, y: 15, width: self.view.frame.width-20, height: 50))
        bannerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8027068662)
        bannerView.text = text
        bannerView.textColor = .themeBlue
        bannerView.font = UIFont.systemFont(ofSize: 15)
        bannerView.textAlignment = .center
        bannerView.minimumScaleFactor = 0.5
        bannerView.alpha = 0
        bannerView.layer.cornerRadius = TasklistStyler.mainCornerRadius
        bannerView.clipsToBounds = true
        self.view.addSubview(bannerView)
        UIView.animate(withDuration: 0.5) {
            bannerView.alpha = 1
        } completion: { (_) in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveLinear) {
                bannerView.alpha = 0
            } completion: { (_) in
                bannerView.removeFromSuperview()
            }
        }
    }
}

// MARK: UIFont
extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}
