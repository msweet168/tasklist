//
//  BaseViewController.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/8/20.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    let api = API.shared
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    func viewSetup() {
        overrideUserInterfaceStyle = .light
        if let spinner = loadingSpinner {
            spinner.stopAnimating()
            spinner.hidesWhenStopped = true
        }
    }
    
    func startLoading() {
        isLoading = true
        loadingSpinner.startAnimating()
    }
    
    func stopLoading() {
        isLoading = false
        loadingSpinner.stopAnimating()
    }
    
    @IBAction func dismissButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
