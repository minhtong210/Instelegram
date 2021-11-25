import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable
import Then

final class ChatListViewController: UIViewController, Bindable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var backButton: UIButton!
    
    var viewModel: ChatListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = ChatListViewModel.Input(loadTrigger: Driver.just(()),
                                            backTrigger: backButton.rx.tap.asDriver(),
                                            chatSelected: tableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.chatList
            .drive(tableView.rx.items) { tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: NotificationTableCell = tableView.dequeueReusableCell(for: indexPath)

                cell.configChatListCell(chatList: item)
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] in
                self?.tableView.deselectRow(at: $0, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
    
}

extension ChatListViewController {
    private func configView() {
        configTableView()
    }
    
    private func configTableView() {
        tableView.do {
            $0.register(cellType: NotificationTableCell.self)
            $0.rowHeight = 50
        }
    }
}

extension ChatListViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.chatList.storyboard
}
