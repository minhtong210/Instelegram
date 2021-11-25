import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable

final class CommentViewController: UIViewController, Bindable {
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var commentTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: CommentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = CommentViewModel.Input(loadTrigger: Driver.just(()),
                                           contentText: commentTextField.rx.text.orEmpty.asDriver(),
                                           backTrigger: backButton.rx.tap.asDriver(),
                                           sendTrigger: sendButton.rx.tap.asDriver())
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.comments
            .do(onNext: { [unowned self] in
                if $0.count != 0 {
                    let indexPath = IndexPath(item: $0.count - 1, section: 0)
                    DispatchQueue.main.async {
                        finishSending(indexPath: indexPath)
                    }
                }
            })
            .drive(tableView.rx.items) { tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: CommentTableCell = tableView.dequeueReusableCell(for: indexPath)
                
                cell.configCell(comment: item)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.isSendEnable
            .drive(isSendEnableBinder)
            .disposed(by: rx.disposeBag)
        
        output.sendTrigger
            .drive()
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
}
//MARK: - Reactive
extension CommentViewController {
    private var isSendEnableBinder: Binder<Bool> {
        return Binder(self) { vc, bool in
            vc.sendButton.do {
                $0.isEnabled = bool
                $0.alpha = bool ? 1 : 0.7
            }
        }
    }
}

//MARK: - Update UI
extension CommentViewController {
    private func configView() {
        configTableView()
    }
    
    private func configTableView() {
        tableView.do {
            $0.register(cellType: CommentTableCell.self)
        }
    }
    
    private func finishSending(indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        commentTextField.text = ""
        sendButton.isEnabled = false
    }
}

extension CommentViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.comment.storyboard
}
