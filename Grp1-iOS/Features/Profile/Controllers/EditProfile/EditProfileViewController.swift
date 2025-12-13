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
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userPhone: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var userName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupUI()
//        populateProfile()

        // Do any additional setup after loading the view.
    }
    
    private var isEditingProfile = false

//    private func populateProfile() {
//        nameField.text = profile.name
//        emailField.text = profile.email
//        phoneField.text = profile.phone
//        userImage.image = UIImage(named: profile.imageName)
//    }
//
//    @IBAction func editTapped(_ sender: UIButton) {
//        isEditingProfile.toggle()
//
//        if isEditingProfile {
//            enableEditing()
//            sender.setTitle("Save", for: .normal)
//        } else {
//            saveProfile()
//            disableEditing()
//            sender.setTitle("Edit", for: .normal)
//        }
//    }

}
