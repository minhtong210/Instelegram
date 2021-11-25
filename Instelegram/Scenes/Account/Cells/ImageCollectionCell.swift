import UIKit
import Reusable
import SDWebImage

final class ImageCollectionCell: UICollectionViewCell, NibReusable {
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configCell(post: Post) {
        imageView.sd_setImage(with: URL(string: post.mediaUrl), completed: nil)
    }
    
}
