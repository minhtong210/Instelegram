import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable
import SDWebImage
import Then

final class AccountViewController: UIViewController, Bindable {
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var postNumberLabel: UILabel!
    @IBOutlet private weak var followerNumberLabel: UILabel!
    @IBOutlet private weak var followingNumberLabel: UILabel!
    @IBOutlet private weak var bioLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var followButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: AccountViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = AccountViewModel.Input(loadTrigger: Driver.just(()),
                                           logoutTrigger: logoutButton.rx.tap.asDriver(),
                                           backTrigger: backButton.rx.tap.asDriver(),
                                           editTrigger: editButton.rx.tap.asDriver(),
                                           followTrigger: followButton.rx.tap.asDriver(),
                                           sendTrigger: sendButton.rx.tap.asDriver(),
                                           postTrigger: collectionView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [unowned self] index in
                if index == 0 {
                    tableView.isHidden = true
                    collectionView.isHidden = false
                } else {
                    tableView.isHidden = false
                    collectionView.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        output.isCurrentUser
            .drive(isCurrentUserBinder)
            .disposed(by: rx.disposeBag)
        
        output.accountInfo
            .drive(accountInfoBinder)
            .disposed(by: rx.disposeBag)
        
        output.isFollowing
            .drive(isFollowingBinder)
            .disposed(by: rx.disposeBag)
        
        output.followTrigger
            .drive()
            .disposed(by: rx.disposeBag)
        
        output.posts
            .drive(collectionView.rx.items) { collectionView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: ImageCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
                
                cell.configCell(post: item)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.posts
            .drive(tableView.rx.items) { [unowned self] tableView, index, item in
                let useCase = viewModel.useCase
                let currentUserId = FBaseAuth.share.getCurrentUser().userId
                
                let indexPath = IndexPath(row: index, section: 0)
                let cell: NewsFeedTableCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configCell(currentUserId: currentUserId, post: item)
                
                cell.likeButton.rx.tap.asDriver()
                    .drive(onNext: {
                        if let isliked = item.likes[currentUserId] {
                            isliked ?
                                useCase.likePost(false, post: item) :
                                useCase.likePost(true, post: item)
                        } else {
                            useCase.likePost(true, post: item)
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.commentButton.rx.tap.asDriver()
                    .do(onNext: {
                        viewModel.navigator.toComment(post: item)
                    })
                    .drive()
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("Deinit Account")
    }
}

//MARK: - Reactive
extension AccountViewController {
    private var accountInfoBinder: Binder<(User, Int, Int, Int)> {
        return Binder(self) { vc, accountInfo in
            vc.updateProfile(from: accountInfo)
        }
    }
    
    private var isCurrentUserBinder: Binder<Bool> {
        return Binder(self) { vc, bool in
            [vc.sendButton, vc.followButton, vc.backButton].forEach {
                $0?.isHidden = bool
            }
            [vc.editButton, vc.logoutButton].forEach {
                $0?.isHidden = !bool
            }
        }
    }
    
    private var isFollowingBinder: Binder<Bool> {
        return Binder(self) { vc, bool in
            let text = bool ? "Unfollow" : "Follow"
            vc.followButton.setTitle(text, for: .normal)
        }
    }
}

//MARK: - Update UI
extension AccountViewController {
    private func configView() {
        configButtons()
        configCollectionView()
        configTableView()
    }
    
    private func configButtons() {
        [editButton, followButton].forEach {
            $0?.yellowBorder(width: 2)
        }
    }
    
    private func configCollectionView() {
        collectionView.do {
            $0.register(cellType: ImageCollectionCell.self)
            $0.delegate = self
        }
    }
    
    private func configTableView() {
        tableView.do {
            $0.register(cellType: NewsFeedTableCell.self)
            $0.rowHeight = tableView.frame.width
        }
    }
    
    private func updateProfile(from accountInfo: (User, Int, Int, Int)) {
        postNumberLabel.text = String(accountInfo.1)
        usernameLabel.text = accountInfo.0.username
        bioLabel.text = accountInfo.0.bio
        followerNumberLabel.text = String(accountInfo.2)
        followingNumberLabel.text = String(accountInfo.3)
        userImageView.sd_setImage(with: URL(string: accountInfo.0.profileImageUrl), completed: nil)
    }
}
//MARK: - Collection View Flow Layout
extension AccountViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension AccountViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.account.storyboard
}
