import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable

final class SearchViewController: UIViewController, Bindable {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    var viewModel: SearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        
    }
    
    func bindViewModel() {
        let input = SearchViewModel.Input(loadTrigger: Driver.just(()),
                                          cancelTrigger: cancelButton.rx.tap.asDriver(),
                                          searchText: searchBar.rx.text.orEmpty.asDriver(),
                                          userSelected: tableView.rx.itemSelected.asDriver())
        
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.filterUsers
            .drive(tableView.rx.items) { tableView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: ImageAndNameTableCell = tableView.dequeueReusableCell(for: indexPath)
                
                cell.configCell(user: item)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .drive()
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("Deinit Search")
    }
}

//MARK: - Update UI
extension SearchViewController {
    private func configView() {
        configTableView()
        configSearchBar()
    }
    
    private func configTableView() {
        tableView.do {
            $0.register(cellType: ImageAndNameTableCell.self)
            $0.rowHeight = 76
        }
    }
    
    private func configSearchBar() {
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { [weak self] _ in
            self?.searchBar.becomeFirstResponder()
        }
        
        searchBar.layer.do {
            $0.borderColor = UIColor.white.cgColor
            $0.borderWidth = 1
        }
        
    }
}

//MARK: - Reactive
extension SearchViewController {
//    private var name1: Binder<String> {
//        return Binder(self) { vc, b in
//            vc.name.text = b
//        }
//    }
}

extension SearchViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.search.storyboard
}
