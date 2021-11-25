import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable

final class PopularViewController: UIViewController, Bindable {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    var viewModel: PopularViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = PopularViewModel.Input(loadTrigger: Driver.just(()),
                                           postTrigger: collectionView.rx.itemSelected.asDriver(),
                                           searchDidTouch: searchBar.rx.textDidBeginEditing.asDriver())
        
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.posts
            .drive(collectionView.rx.items) { collectionView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                let cell: ImageCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
                
                cell.configCell(post: item)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.navigation
            .do(onNext: { [weak self] in
                self?.searchBar.endEditing(true)
            })
            .drive()
            .disposed(by: rx.disposeBag)
    }
    
    deinit {
        print("Deinit Popular")
    }
}

//MARK: - Update UI
extension PopularViewController {
    private func configView() {
        configCollectionView()
        configSearchBar()
    }
    
    private func configCollectionView() {
        collectionView.do {
            $0.register(cellType: ImageCollectionCell.self)
            $0.delegate = self
        }
    }
    
    private func configSearchBar() {
        searchBar.layer.do {
            $0.borderColor = UIColor.white.cgColor
            $0.borderWidth = 1
        }
    }
}

//MARK: - Reactive
extension PopularViewController {

}

//MARK: - Collection View Flow Layout
extension PopularViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension PopularViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.popular.storyboard
}
