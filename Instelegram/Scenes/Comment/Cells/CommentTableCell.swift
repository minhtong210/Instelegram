import UIKit
import Reusable
import SDWebImage
import RxSwift
import RxCocoa

final class CommentTableCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var timeAgoLabel: UILabel!
    @IBOutlet private weak var userButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configCell(comment: Comment) {
        userImageView.sd_setImage(with: URL(string: comment.profileImage), completed: nil)
        contentLabel.attributedText = NSMutableAttributedString()
            .bold(comment.username + " ")
            .light(comment.content)
        timeAgoLabel.text = Date(timeIntervalSince1970: comment.date).timeAgo()
    }
    
    func configCellAtPost(comment: Comment) {
        [timeAgoLabel,userImageView].forEach {
            $0.isHidden = true
        }
        contentLabel.do {
            $0.alpha = 0.75
            $0.attributedText = NSMutableAttributedString()
                .bold(comment.username + " ")
                .light(comment.content)
        }
        
    }
}
