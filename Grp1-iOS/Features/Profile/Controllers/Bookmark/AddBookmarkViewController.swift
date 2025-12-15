//
//  AddBookmarkViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class AddBookmarkViewController: UIViewController {

    @IBOutlet weak var bookmarkTextField: UITextField!
    
    var onSave: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Textfield styling if needed
        bookmarkTextField.autocorrectionType = .no
        bookmarkTextField.spellCheckingType = .no
        bookmarkTextField.clearButtonMode = .whileEditing
        bookmarkTextField.becomeFirstResponder()
    }

    // MARK: - Save Button
    @IBAction func saveTapped(_ sender: UIButton) {
        let text = bookmarkTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !text.isEmpty else {
            
            return
        }

        onSave?(text)
        dismiss(animated: true)
    }

    // If you want a cancel gesture or button later
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
