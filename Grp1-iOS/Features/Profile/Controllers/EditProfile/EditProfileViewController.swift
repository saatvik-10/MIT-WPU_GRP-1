//
//  EditProfileViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/12/25.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        populateProfile()
        
        // Do any additional setup after loading the view.
    }
    
    var onProfileUpdated: (() -> Void)?
    
    private var isEditingProfile = false
    private var profile = User.current
    
    private func setupUI() {
        [nameField, emailField, phoneField].forEach {
            $0?.isUserInteractionEnabled = false
            $0?.borderStyle = .none
        }
        
        emailField.keyboardType = .emailAddress
        phoneField.keyboardType = .phonePad
    }
    
    private func populateProfile() {
        nameField.text = profile.name
        emailField.text = profile.email
        phoneField.text = profile.phone
        userImage.image = UIImage(named: profile.image)
    }
    
    private func enableEditing() {
        [nameField, emailField, phoneField].forEach {
            $0?.isUserInteractionEnabled = true
            $0?.borderStyle = .roundedRect
        }
        nameField.becomeFirstResponder()
    }
    
    private func disableEditing() {
        [nameField, emailField, phoneField].forEach {
            $0?.isUserInteractionEnabled = false
            $0?.borderStyle = .none
        }
        view.endEditing(true)
    }
    
    private func saveProfile() {
        User.current = UserProfile(
            image: profile.image,
            name: nameField.text ?? "",
            phone: phoneField.text ?? "",
            email: emailField.text ?? "",
            level: profile.level
        )

        onProfileUpdated?()
        dismiss(animated: true)
    }

    
    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        isEditingProfile.toggle()
        
        if isEditingProfile {
            enableEditing()
            sender.title = "Save"
        } else {
            saveProfile()
            disableEditing()
            sender.title = "Edit"
        }
    }
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
