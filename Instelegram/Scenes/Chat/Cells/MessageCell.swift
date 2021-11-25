import UIKit
import SDWebImage
import Reusable

final class MessageCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var receiverImageView: UIImageView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(currentUser: User, message: Message) {
        receiverImageView.sd_setImage(with: URL(string: message.profileUrl), completed: nil)
        messageLabel.text = message.textMessage
        
        if currentUser.userId != message.senderId {
            receiverImageView.isHidden = false
            bubbleView.backgroundColor = AppConstraints.Color.outerCircleAddItem
        } else {
            receiverImageView.isHidden = true
            bubbleView.backgroundColor = AppConstraints.Color.yellow
        }
    }
}
