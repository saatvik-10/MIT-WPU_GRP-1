
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
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var addTopicTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var saveDraft: UIButton!
    
    let placeholderLabel = UILabel()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
            setupUI()
            setupTextViewPlaceholder()
            configureForMode()
            styleSaveDraftButton()
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
        if let imageName = draft.imageName {
            // If you already have an imageView, set it here
            // imageView.image = UIImage(named: imageName)
        }
    }
    
    func styleSaveDraftButton() {
        saveDraft.setTitleColor(.systemBlue, for: .normal)
        saveDraft.layer.borderWidth = 1.5
        saveDraft.layer.borderColor = UIColor.systemBlue.cgColor
        saveDraft.layer.cornerRadius = 22
        saveDraft.backgroundColor = .clear
    }

}
