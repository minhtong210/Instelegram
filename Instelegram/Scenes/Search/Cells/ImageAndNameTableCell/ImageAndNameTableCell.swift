import UIKit
import SDWebImage
import Reusable

final class ImageAndNameTableCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(user: User) {
        usernameLabel.text = user.username
        userImageView.sd_setImage(with: URL(string: user.profileImageUrl), completed: nil)
    }
}
