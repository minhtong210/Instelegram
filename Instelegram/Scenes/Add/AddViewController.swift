import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable

class AddViewController: UIViewController, Bindable {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var addImageButton: UIButton!
    @IBOutlet private weak var postButton: UIButton!
    @IBOutlet private weak var captionTextView: UITextView!
    private var placeholderLabel: UILabel!
    
    var viewModel: AddViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = AddViewModel.Input(captionText: captionTextView.rx.text.orEmpty.asDriver(),
                                       addImageTrigger: addImageButton.rx.tap.asDriver(),
                                       postTrigger: postButton.rx.tap.asDriver(),
                                       userImageView: Driver.just(imageView))
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.postImage
            .drive(imageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        output.isPostEnable
            .drive(isPostEnableBinder)
            .disposed(by: rx.disposeBag)
        
        output.postTrigger
            .drive(didPosted)
            .disposed(by: rx.disposeBag)
        
        captionTextView.rx.didChange.asDriver()
            .drive(captionDidChange)
            .disposed(by: rx.disposeBag)
        
    }
}
//MARK: - Reactive
extension AddViewController {
    private var isPostEnableBinder: Binder<Bool> {
        return Binder(self) { vc, bool in
            vc.postButton.do {
                $0.isEnabled = bool
                $0.alpha = bool ? 1 : 0.5
            }
        }
    }
    
    private var captionDidChange: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.captionTextView.do {
                vc.placeholderLabel.isHidden = !$0.text.isEmpty
            }
        }
    }
    
    private var didPosted: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.imageView.image = nil
            vc.captionTextView.text = nil
        }
    }
}

//MARK: - Update UI
extension AddViewController {
    private func configView() {
        configBorder()
        configPostButton()
        configTextView()
    }
    
    private func configBorder() {
        [captionTextView, imageView].forEach {
            $0?.yellowBorder(width: 1)
        }
    }
    
    private func configTextView() {
        placeholderLabel = UILabel().then {
            if let textSize = captionTextView.font?.pointSize {
                $0.text = "Write something ..."
                $0.font = UIFont.italicSystemFont(ofSize: textSize)
                $0.sizeToFit()
                $0.frame.origin = CGPoint(x: 5, y: textSize / 2)
                $0.textColor = UIColor.lightGray
                $0.isHidden = !captionTextView.text.isEmpty
            }
        }
        captionTextView.addSubview(placeholderLabel)
    }
    
    private func configPostButton() {
        postButton.do {
            $0.isEnabled = false
            $0.alpha = 0.5
        }
    }
}

extension AddViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.add.storyboard
}
