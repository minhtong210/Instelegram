import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable
import Then

final class HomeViewController: UIViewController, Bindable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sendButton: UIButton!
    
    var viewModel: HomeViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = HomeViewModel.Input(loadTrigger: Driver.just(()),
                                        sendTrigger: sendButton.rx.tap.asDriver())
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.posts
            .drive(tableView.rx.items) { [unowned self] tableView, index, item in
                let useCase = viewModel.useCase
                let currentUserId = viewModel.currentUserId
                
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
                
                cell.usernameButton.rx.tap.asDriver()
                    .do(onNext: {
                        if viewModel.currentUserId != item.ownerId {
                            viewModel.navigator.toAccount(userId: item.ownerId)
                        }
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
        print("Deinit Home")
    }
    
}
//MARK: - Update UI
extension HomeViewController {
    private func configView() {
        configTableView()
    }
    
    private func configTableView() {
        tableView.do {
            $0.register(cellType: NewsFeedTableCell.self)
            $0.rowHeight = tableView.frame.width - 20
        }
    }
}

extension HomeViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.home.storyboard
}
