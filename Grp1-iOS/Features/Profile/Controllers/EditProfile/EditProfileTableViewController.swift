//
//  EditProfileTableViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populate()
    }
    
    var onProfileUpdated: (() -> Void)?
    
    private func setupUI() {
        let fields = [nameField, phoneField, emailField, dobField, genderField]
        
        for textField in fields {
            textField?.borderStyle = .none
            textField?.textAlignment = .right
            textField?.isUserInteractionEnabled = false
            textField?.textColor = .secondaryLabel
        }
        
        phoneField.keyboardType = .numberPad
        emailField.keyboardType = .emailAddress
    }
    
    private func populate() {
        let user = User.current
        
        userImage.image = UIImage(named: user.image)
        nameField.text = user.name
        phoneField.text = user.phone
        emailField.text = user.email
        dobField.text = user.dob
        genderField.text = user.gender.rawValue
        
        userImage.layer.cornerRadius =
        userImage.bounds.width / 2
        userImage.clipsToBounds = true
        userImage.contentMode = .scaleAspectFill
    }
    
    private var isEditingProfile = false
    
    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        isEditingProfile.toggle()
        sender.title = isEditingProfile ? "Save" : "Edit"
        
        setEditingState(isEditingProfile)
        
        if !isEditingProfile {
            save()
        }
    }
    private func setEditingState(_ enabled: Bool) {
        let fields = [nameField, phoneField, emailField, dobField, genderField]
        
        for textField in fields {
            textField?.isUserInteractionEnabled = enabled
            textField?.textColor = enabled ? .label : .secondaryLabel
        }
        
        if enabled {
            nameField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Save
    
    private func save() {
        User.current = UserProfile(
            image: User.current.image,
            name: nameField.text ?? "",
            phone: phoneField.text ?? "",
            email: emailField.text ?? "",
            level: User.current.level,
            dob: dobField.text ?? "",
            gender: Gender(rawValue: genderField.text ?? "") ?? .male
        )
        onProfileUpdated?()
    }
    
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
// MARK: - Table View

override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
}
}
