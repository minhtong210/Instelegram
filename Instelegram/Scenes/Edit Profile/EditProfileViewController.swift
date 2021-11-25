import UIKit
import Foundation
import RxCocoa
import RxSwift
import MGArchitecture
import NSObject_Rx
import Reusable
import SDWebImage
import Then

final class EditProfileViewController: UIViewController, Bindable {
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var bioTextView: UITextView!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var changeImageButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    
    private var placeholderLabel: UILabel!
    
    var viewModel: EditProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func bindViewModel() {
        let input = EditProfileViewModel.Input(loadTrigger: Driver.just(()),
                                               usernameText: usernameTextField.rx.text.orEmpty.asDriver(),
                                               bioText: bioTextView.rx.text.orEmpty.asDriver(),
                                               userImageView: Driver.just(userImageView),
                                               addImageTrigger: changeImageButton.rx.tap.asDriver(),
                                               doneTrigger: doneButton.rx.tap.asDriver(),
                                               backTrigger: backButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input, disposeBag: rx.disposeBag)
        
        output.profile
            .drive(profileBinder)
            .disposed(by: rx.disposeBag)
        
        output.userImage
            .drive(userImageView.rx.image)
            .disposed(by: rx.disposeBag)
    
        output.isDoneEnable
            .drive(isDoneEnableBinder)
            .disposed(by: rx.disposeBag)
        
        output.doneTrigger
            .drive()
            .disposed(by: rx.disposeBag)
        
        output.toBackView
            .drive()
            .disposed(by: rx.disposeBag)
        
        bioTextView.rx.didChange.asDriver()
            .drive(bioDidChange)
            .disposed(by: rx.disposeBag)
    }
}

//MARK: - Update UI
extension EditProfileViewController {
    private func configView() {
        configBorder()
        
    }
    
    private func configBorder() {
        [usernameTextField, bioTextView].forEach {
            $0?.yellowBorder(width: 1)
        }
    }
    
    private func configTextView() {
        placeholderLabel = UILabel().then {
            if let textSize = bioTextView.font?.pointSize {
                $0.text = "Write something ..."
                $0.font = UIFont.italicSystemFont(ofSize: textSize)
                $0.sizeToFit()
                $0.frame.origin = CGPoint(x: 5, y: textSize / 2)
                $0.textColor = UIColor.lightGray
                $0.isHidden = !bioTextView.text.isEmpty
            }
        }
        bioTextView.addSubview(placeholderLabel)
    }
    
    private func updateProfile(from user: User) {
        usernameTextField.text = user.username
        userImageView.sd_setImage(with: URL(string: user.profileImageUrl), completed: nil)
        bioTextView.text = user.bio
        configTextView()
    }
}

//MARK: - Reactive
extension EditProfileViewController {
    private var profileBinder: Binder<(User)> {
        return Binder(self) { vc, profile in
            vc.updateProfile(from: profile)
        }
    }
    
    private var isDoneEnableBinder: Binder<Bool> {
        return Binder(self) { vc, bool in
            vc.doneButton.do {
                $0.isEnabled = bool
                $0.alpha = bool ? 1 : 0.5
            }
        }
    }
    
    private var bioDidChange: Binder<Void> {
        return Binder(self) { vc, _ in
            vc.bioTextView.do {
                vc.placeholderLabel.isHidden = !$0.text.isEmpty
            }
        }
    }
}

extension EditProfileViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryboardName.editProfile.storyboard
}
