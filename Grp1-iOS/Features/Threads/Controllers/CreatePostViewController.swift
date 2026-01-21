
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

        bodyTextView.delegate = self
        placeholderLabel.isHidden = !bodyTextView.text.isEmpty
    }
    
    func setupUI(){
        bodyTextView.delegate = self
        bodyTextView.isScrollEnabled = true
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
            placeholderLabel.isHidden = !textView.text.isEmpty
    }
    

    
    private func configureForMode() {

        switch mode {

        case .newPost:
            postButton.setTitle("Post", for: .normal)
            saveDraft.setTitle("Save Draft", for: .normal)

        case .editDraft:
            navigationItem.title = "Draft"
            postButton.setTitle("Post", for: .normal)
            saveDraft.setTitle("Save Draft", for: .normal)
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
        if let imageName = draft.imageName,
           let image = UIImage(named: imageName) {
            showDraftImage(image)
        }
    }
    
    func styleSaveDraftButton() {
        saveDraft.setTitleColor(.systemBlue, for: .normal)
        saveDraft.layer.borderWidth = 1.5
        saveDraft.layer.borderColor = UIColor.systemBlue.cgColor
        saveDraft.layer.cornerRadius = 22
        saveDraft.backgroundColor = .clear
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
