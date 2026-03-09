
import UIKit


class CreatePostViewController: UIViewController,UITextViewDelegate, UITextFieldDelegate{
    
    enum CreatePostMode {
        case newPost
        case editDraft
    }
    
    var mode: CreatePostMode = .newPost
    var draft: Draft?
    
    
    //@IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var imageContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var addTopicTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var removeImageButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var saveDraft: UIButton!
    
    let placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTextViewPlaceholder()
        configureForMode()
        styleSaveDraftButton()
        
        imageView.bringSubviewToFront(removeImageButton)
    }
    
    @IBAction func didTapAddImage(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func didTapRemoveImage(_ sender: UIButton) {
        removeImage()
    }
    
    //
    
    @IBAction func didTapDrafts(_ sender: Any) {
        performSegue(withIdentifier: "Drafts", sender: nil)
    }
    
    @IBAction func didTapSaveDraft(_ sender: UIButton) {
        
        
            let title = titleTextField.text
            let topic = addTopicTextField.text
            let body = bodyTextView.text
            
            let imagePath: String?
            if let image = postImageView.image {
                imagePath = saveImageToDisk(image)
            } else {
                imagePath = nil
            }
            
            switch mode {
            case .newPost:
                ThreadsDataStore.shared.saveDraft(
                    title: title,
                    topic: topic,
                    body: body,
                    imageName: imagePath
                )
                
            case .editDraft:
                guard let draft else { return }
                ThreadsDataStore.shared.updateDraft(
                    id: draft.id,
                    title: title,
                    topic: topic,
                    body: body,
                    imageName: imagePath
                )
            }
            
            // Go back to drafts without pushing a new VC
            navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func didTapPost(_ sender: UIButton) {
        
        guard
                let title = titleTextField.text, !title.isEmpty,
                let body = bodyTextView.text, !body.isEmpty
            else { return }

            let imagePath: String?
            if let image = postImageView.image {
                imagePath = saveImageToDisk(image)
            } else {
                imagePath = nil
            }

            // Parse tags from comma-separated input e.g. "iOS, Swift, UIKit"
            let rawTags = addTopicTextField.text ?? ""
            let tags = rawTags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }

            ThreadsDataStore.shared.postThreadFromCreate(
                title: title,
                body: body,
                imageName: imagePath,
                tags: tags.isEmpty ? ["General"] : tags
            )

            if mode == .editDraft, let draft {
                ThreadsDataStore.shared.deleteDraft(id: draft.id)
            }

            navigationController?.popViewController(animated: true)
        }
    
    
    
    func setupUI(){
        bodyTextView.delegate = self
        bodyTextView.isScrollEnabled = true
        
        
    }
    
    func setupTextViewPlaceholder() {
        placeholderLabel.text = "Body Text"
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyTextView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: bodyTextView.topAnchor, constant: 7),
            placeholderLabel.leadingAnchor.constraint(equalTo: bodyTextView.leadingAnchor, constant: 10),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: bodyTextView.trailingAnchor, constant: -10)
        ])
        
        bodyTextView.delegate = self  //check this
        placeholderLabel.isHidden = !bodyTextView.text.isEmpty
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    
    
    private func configureForMode() {
        
        if mode == .editDraft {
            navigationItem.title = "Draft"
            prefillDraftData()
        }
    }
    
    private func prefillDraftData() {
        guard let draft else { return }
        
        addTopicTextField.text = draft.topic
        titleTextField.text = draft.title
        bodyTextView.text = draft.body
        
        placeholderLabel.isHidden = !(draft.body?.isEmpty ?? true)
        
        // Image is optional (important)
        if let path = draft.imageName {
            let url = URL(fileURLWithPath: path)
            if let image = UIImage(contentsOfFile: url.path) {
                showDraftImage(image)
            }
        }
    }
        func styleSaveDraftButton() {
            saveDraft.setTitleColor(.systemBlue, for: .normal)
            saveDraft.layer.borderWidth = 1.5
            saveDraft.layer.borderColor = UIColor.systemBlue.cgColor
            saveDraft.layer.cornerRadius = 22
            
        }
        
        func handleSelectedImage(_ image: UIImage) {
            postImageView.image = image
            
            addImageButton.isHidden = true
            postImageView.isHidden = false
            removeImageButton.isHidden = false
            imageContainerHeight.constant = 220
            
            imageView.bringSubviewToFront(removeImageButton)
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
        
        func showDraftImage(_ image: UIImage) {
            postImageView.image = image
            
            addImageButton.isHidden = true
            postImageView.isHidden = false
            
            imageContainerHeight.constant = 220
        }
        
        func removeImage() {
            postImageView.image = nil
            
            postImageView.isHidden = true
            removeImageButton.isHidden = true
            addImageButton.isHidden = false
            
            imageContainerHeight.constant = 0
            
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        }
        
        func saveImageToDisk(_ image: UIImage) -> String? {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            
            let fileName = UUID().uuidString + ".jpg"
            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)
            
            do {
                try data.write(to: url)
                return url.path
            } catch {
                print("Failed to save image:", error)
                return nil
            }
        }
    }


extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func openImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        handleSelectedImage(image)
    }
}
