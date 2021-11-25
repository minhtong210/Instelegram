import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable
import Then

final class PostViewController: UIViewController, Bindable {
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var timeAgoLabel: UILabel!
    @IBOutlet private weak var likesLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var usernameButton: UIButton!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var commentButton: UIButton!
    @IBOutlet private weak var commentsTableView: UITableView!
    
    var viewModel: PostViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = PostViewModel.Input(loadTrigger: Driver.just(()),
                                        likeTrigger: likeButton.rx.tap.asDriver(),
                                        commentTrigger: commentButton.rx.tap.asDriver(),
                                        backTrigger: backButton.rx.tap.asDriver(),
                                        usernameTrigger: usernameButton.rx.tap.asDriver())
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.post
            .drive(postBinder)
            .disposed(by: rx.disposeBag)
        
        output.comments
            .drive(commentsTableView.rx.items) { tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: CommentTableCell = tableView.dequeueReusableCell(for: indexPath)
                
                cell.configCellAtPost(comment: item)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
            
        
        output.likeTrigger
            .drive()
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
}

//MARK: - Reactive
extension PostViewController {
    private var postBinder: Binder<Post> {
        return Binder(self) { vc, post in
            vc.updateDetail(from: post)
        }
    }
}

//MARK: - Update UI
extension PostViewController {
    private func configView() {
        configTableView()
    }
    
    private func configTableView() {
        commentsTableView.do {
            $0.register(cellType: CommentTableCell.self)
        }
    }
    
    private func updateDetail(from post: Post) {
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
            if let isliked = post.likes[viewModel.currentUserId] {
                $0.tintColor = isliked ? .red : .white
            } else {
                $0.tintColor = .white
            }
        }
        
        [likeButton,commentButton].forEach {
            $0.backgroundColor = AppConstraints.Color.yellow
        }
    }
}

extension PostViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.post.storyboard
}
