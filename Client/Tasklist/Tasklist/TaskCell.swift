//
//  TaskCell.swift
//  Tasklist
//
//  Created by Mitchell Sweet on 10/8/20.
//

import UIKit

class TaskCell: BaseViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet private weak var taskTextLabel: UILabel!
    
    // MARK: Constants
    public static let defaultHeight: CGFloat = 70
    public static let nibName = "TaskCell"
    public static let identifier = "TaskCell"
    
    // MARK: Variables
    var attributeString: NSMutableAttributedString?

    override func awakeFromNib() {
        super.awakeFromNib()
        TasklistStyler.styleTaskCell(cell: self)
    }
    
    func setText(text: String) {
        taskTextLabel.text = text
        attributeString = NSMutableAttributedString(string: text)
    }
    
    func setCompleted(completed: Bool) {
        guard let attString = attributeString else { return }
        if completed {
            completedImageView.image = UIImage(systemName: "checkmark.circle.fill")
            completedImageView.tintColor = UIColor.systemGray5
            attString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attString.length))
            taskTextLabel.attributedText = attString
        } else {
            completedImageView.image = UIImage(systemName: "circle")
            completedImageView.tintColor = UIColor.systemBlue
            taskTextLabel.attributedText = nil
            attString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attString.length))
            taskTextLabel.attributedText = attString
        }
        
    }
}
