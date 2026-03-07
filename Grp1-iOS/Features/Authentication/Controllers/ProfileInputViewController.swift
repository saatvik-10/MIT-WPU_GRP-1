//
//  ProfileInputViewController.swift
//  Grp1-iOS
//

import UIKit

class ProfileInputViewController: UIViewController {

    // MARK: - UI Elements

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete Your Profile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell us a bit about yourself"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let nameField = ProfileInputViewController.makeTextField(placeholder: "Full Name", icon: "person.fill")
    private let emailField = ProfileInputViewController.makeTextField(placeholder: "Email", icon: "envelope.fill", keyboard: .emailAddress)
    private let phoneField = ProfileInputViewController.makeTextField(placeholder: "Phone Number", icon: "phone.fill", keyboard: .phonePad)
    private let dobField = ProfileInputViewController.makeTextField(placeholder: "Date of Birth", icon: "calendar")

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.maximumDate = Date()
        return picker
    }()

    private let genderSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Male", "Female"])
        segment.selectedSegmentIndex = 0
        segment.selectedSegmentTintColor = .systemBlue
        return segment
    }()

    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Gender"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupDatePicker()
        setupActions()
        prefillFromSession()
    }

    // MARK: - Prefill from Apple Sign In data

    private func prefillFromSession() {
        if let user = SessionManager.shared.currentUser {
            nameField.text = user.name
            emailField.text = user.email
        }
    }

    // MARK: - Date Picker

    private func setupDatePicker() {
        dobField.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(datePickerDone))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        dobField.inputAccessoryView = toolbar
    }

    @objc private func datePickerDone() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobField.text = formatter.string(from: datePicker.date)
        dobField.resignFirstResponder()
    }

    // MARK: - Actions

    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func continueTapped() {
        // Validate fields
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let dob = dobField.text, !dob.isEmpty else {

            showAlert(title: "Missing Info", message: "Please fill in all fields.")
            return
        }

        let selectedGender: Gender = genderSegment.selectedSegmentIndex == 0 ? .male : .female

        // Create the UserProfile matching your Prisma schema
        let profile = UserProfile(
            image: "",
            name: name,
            phone: phone,
            email: email,
            level: .beginner,
            dob: dob,
            gender: selectedGender
        )

        // Save to UserDefaults (local storage for now)
        saveProfileLocally(profile)

        print("✅ Profile saved:")
        print("  Name: \(profile.name)")
        print("  Email: \(profile.email)")
        print("  Phone: \(profile.phone)")
        print("  DOB: \(profile.dob)")
        print("  Gender: \(profile.gender.rawValue)")
        print("  Level: \(profile.level.rawValue)")

        // TODO: Navigate to onboarding interests or home screen
        // For now, dismiss this screen
        showAlert(title: "Profile Saved! ✅", message: "Welcome, \(name)!") { [weak self] in
            // Navigate to onboarding or home
            self?.dismiss(animated: true)
        }
    }

    // MARK: - Save Locally

    private func saveProfileLocally(_ profile: UserProfile) {
        let defaults = UserDefaults.standard
        defaults.set(profile.name, forKey: "user_name")
        defaults.set(profile.email, forKey: "user_email")
        defaults.set(profile.phone, forKey: "user_phone")
        defaults.set(profile.dob, forKey: "user_dob")
        defaults.set(profile.gender.rawValue, forKey: "user_gender")
        defaults.set(profile.level.rawValue, forKey: "user_level")
        defaults.set(true, forKey: "profileComplete")
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    private static func makeTextField(placeholder: String, icon: String, keyboard: UIKeyboardType = .default) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .none
        field.font = .systemFont(ofSize: 16)
        field.keyboardType = keyboard
        field.autocapitalizationType = keyboard == .emailAddress ? .none : .words
        field.backgroundColor = .secondarySystemBackground
        field.layer.cornerRadius = 12

        // Left icon
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
        iconView.frame = CGRect(x: 12, y: 0, width: 20, height: 24)
        container.addSubview(iconView)
        field.leftView = container
        field.leftViewMode = .always

        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return field
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            makeSpacer(height: 20),
            nameField,
            emailField,
            phoneField,
            dobField,
            makeSpacer(height: 8),
            genderLabel,
            genderSegment,
            makeSpacer(height: 30),
            continueButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            continueButton.heightAnchor.constraint(equalToConstant: 52),
            genderSegment.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}
