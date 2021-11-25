import UIKit
import Reusable
import SDWebImage

final class NotificationTableCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userActionLabel: UILabel!
    @IBOutlet private weak var timeAgoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configNoticeCell(notice: Notification) {
        userNameLabel.text = notice.username
        userActionLabel.text = notice.content
        timeAgoLabel.text = Date(timeIntervalSince1970: notice.timestamp).timeAgo()
        userImageView.sd_setImage(with: URL(string: notice.profileUrl), completed: nil)
    }
    
    func configChatListCell(chatList: Chat) {
        userNameLabel.text = chatList.username
        userActionLabel.text = chatList.lastTextMessage
        timeAgoLabel.text = Date(timeIntervalSince1970: chatList.timestamp).timeAgo()
        userImageView.sd_setImage(with: URL(string: chatList.profileUrl), completed: nil)
    }
}
