import UIKit
import Reusable
import SDWebImage
import RxSwift
import RxCocoa

final class NewsFeedTableCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var timeAgoLabel: UILabel!
    @IBOutlet private weak var likesLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configCell(currentUserId: String, post: Post) {
        userImageView.sd_setImage(with: URL(string: post.profileURL), completed: nil)
        postImageView.sd_setImage(with: URL(string: post.mediaUrl), completed: nil)
        usernameButton.setTitle(post.username, for: .normal)
        usernameButton.setImage(UIImage(), for: .normal)
        timeAgoLabel.text = Date(timeIntervalSince1970: post.date).timeAgo()
        statusLabel.attributedText = NSMutableAttributedString()
            .bold(post.username + " ")
            .light(post.caption)

        likesLabel.do {
            if post.likeCount != 0 {
                $0.text = String(format: "%d likes", post.likeCount)
                $0.isHidden = false
            } else {
                $0.text = ""
                $0.isHidden = true
            }
        }

        likeButton.do {
            $0.backgroundColor = AppConstraints.Color.yellow
            if let isliked = post.likes[currentUserId] {
                $0.tintColor = isliked ? .red : .white
            } else {
                $0.tintColor = .white
            }
        }
        
        commentButton.backgroundColor = AppConstraints.Color.yellow
    }
}
