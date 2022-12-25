//
//  ProfileViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//


import UIKit
import FirebaseAuth

    class ProfileViewController: UIViewController {
        
        @IBOutlet weak var imageUser: UIImageView!
        
        @IBOutlet weak var editOrDoneButton: UIButton!
        
        @IBOutlet weak var cancelButton: UIButton!
       
        @IBOutlet weak var userNameTextField: UITextField!
        
        @IBOutlet weak var emailUserTextField: UITextField!
        
        @IBOutlet weak var radiusViewForTopView: UIView!
       
        @IBOutlet weak var signOutButton: UIButton!
        
        @IBOutlet weak var deleteAccountButton: UIButton!
        
//        var currentUser: User? = {
//            return Auth.auth().currentUser
//        } ()
        var currentUser: User?
        
        var isEditButton = true
        var isTimer = false {
            didSet {
                editOrDoneButton.setNeedsUpdateConfiguration()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            shadowTopView()
            configureButton()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            
            currentUser = Auth.auth().currentUser
            if let user = currentUser, !user.isAnonymous {
                emailUserTextField.text = user.email
                userNameTextField.text = "John"
                cancelButton.isHidden = true
                userNameTextField.isUserInteractionEnabled = false
                emailUserTextField.isUserInteractionEnabled = false
            } else {
                editOrDoneButton.isHidden = true
                cancelButton.isHidden = true
                userNameTextField.text = "User is anonymous"
                userNameTextField.isUserInteractionEnabled = false
                emailUserTextField.isHidden = true
                signOutButton.isHidden = true
                deleteAccountButton.isHidden = true
               
            }
        }
        
       
       
        @IBAction func didTapEditOrDone(_ sender: UIButton) {
           
            if isEditButton {
                switchSaveButton(isSwitch: !isEditButton)
                cancelButton.isHidden = false
                emailUserTextField.isUserInteractionEnabled = true
                userNameTextField.isUserInteractionEnabled = true
                isEditButton = !isEditButton
            } else {
                editOrDoneButton.configurationUpdateHandler = { button in
                    var config = button.configuration
                    config?.showsActivityIndicator = self.isTimer
                    config?.title = self.isTimer ? "" : "Edit"
                    button.isUserInteractionEnabled = !self.isTimer
                    button.configuration = config
                    if !self.isTimer {
                        self.editOrDoneButton.configurationUpdateHandler = nil
                    }
                }
                isTimer = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isTimer = false
                    self.switchEditButton(isSwitch: !self.isEditButton)
                    self.cancelButton.isHidden = true
                    self.emailUserTextField.isUserInteractionEnabled = false
                    self.userNameTextField.isUserInteractionEnabled = false
                    self.isEditButton = !self.isEditButton
                }
            }
            
        }

        @IBAction func didTapCancel(_ sender: UIButton) {
            
            cancelButton.isHidden = true
            emailUserTextField.text = currentUser?.email
            userNameTextField.text = "John"
            switchEditButton(isSwitch: true)
            userNameTextField.isUserInteractionEnabled = false
            emailUserTextField.isUserInteractionEnabled = false
            isEditButton = !isEditButton
            }
        
       
       
        @IBAction func didTapSignOut(_ sender: UIButton) {
            
            do {
                try Auth.auth().signOut()
                
            } catch {
                print("Что то пошло не так!")
                print(error)
            }
            
            if let user = Auth.auth().currentUser?.isAnonymous, user == true {
                print("user == true")
                editOrDoneButton.isHidden = true
                cancelButton.isHidden = true
                userNameTextField.text = "User is anonymous"
                userNameTextField.isUserInteractionEnabled = false
                emailUserTextField.isHidden = true
                signOutButton.isHidden = true
                deleteAccountButton.isHidden = true
            } else {
                print("user != true")
            }
        }
  
        @IBAction func didTapSignInSignUp(_ sender: UIButton) {
        }
           
        @IBAction func didTapDeleteAccount(_ sender: UIButton) {
        }

        @IBAction func didChangeTextFieldNameOrEmail(_ sender: UITextField) {
            isValidTextField { (isValid) in
                setEditOrDoneButton(enabled: isValid)
            }
        }

        
        
        private func setEditOrDoneButton(enabled: Bool) {
            if enabled {
                switchSaveButton(isSwitch: enabled)
            } else {
                switchSaveButton(isSwitch: enabled)
            }
        }
        
        
        private func isValidTextField(comletion: (Bool) -> Void) {
            guard let email = emailUserTextField.text, let name = userNameTextField.text, let emailUser = currentUser?.email else { return }
            let isValid = (!(email.isEmpty) && email != emailUser) || (!(name.isEmpty) && name != "John")
            comletion(isValid)
        }
        
        private func configureButton() {
            print("configureButton")
            var configButton = UIButton.Configuration.plain()
            configButton.title = "Edit"
            configButton.baseForegroundColor = .systemPurple
            configButton.titleAlignment = .trailing
            configButton.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incomig in

                var outgoing = incomig
                outgoing.font = UIFont.systemFont(ofSize: 17, weight: .medium)
                return outgoing
            }
            
            editOrDoneButton.configuration = configButton
            

           
        }
        
        private func switchSaveButton(isSwitch: Bool) {
            editOrDoneButton.configuration?.title = "Save"
            editOrDoneButton.configuration?.baseForegroundColor = isSwitch ? .systemPurple : .lightGray
            editOrDoneButton.isUserInteractionEnabled = isSwitch ? true : false
        }
        
        private func switchEditButton(isSwitch: Bool) {
            editOrDoneButton.configuration?.title = "Edit"
            editOrDoneButton.configuration?.baseForegroundColor = isSwitch ? .systemPurple : .lightGray
            editOrDoneButton.isUserInteractionEnabled = isSwitch ? true : false
        }
        
        private func shadowTopView() {
            radiusViewForTopView.layer.shadowOffset = CGSize(width: 0, height: 10)
            radiusViewForTopView.layer.shadowOpacity = 0.7
            radiusViewForTopView.layer.shadowRadius = 5
            radiusViewForTopView.layer.shadowColor = CGColor(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1)
        }
        
    }






// при переходе по ссылке подтверждает свой электронный адрес isEmailVerified
// можем пока не подтвердит не создавать ему Accaunt

//let currentUser = Auth.auth().currentUser
//currentUser?.reload(completion: { (error) in
//    if error == nil {
//        if let isEmailVerified = currentUser?.isEmailVerified {
//            print("Вы подтвердили свою регистрацию - \(isEmailVerified)")
//        }
//    }
//})


//        @objc func didTapsignOutButton() {
//
//            do {
//                try Auth.auth().signOut()
//            } catch {
//                print("Что то пошло не так!")
//                print(error)
//            }
//            signOutButton.isEnabled = false
//        }
        
//        func setupButton() {
////
//            view.backgroundColor = .systemBackground
//            view.addSubview(signOutButton)
//            signOutButton.translatesAutoresizingMaskIntoConstraints = false
//
//            signOutButton.configuration = .tinted()
//            signOutButton.configuration?.title = "SignOutButton"
//            signOutButton.configuration?.image = UIImage(systemName: "iphone")
//            signOutButton.configuration?.imagePadding = 8
//            signOutButton.configuration?.baseForegroundColor = .systemTeal
//            signOutButton.configuration?.baseBackgroundColor = .systemTeal
//            signOutButton.addTarget(self, action: #selector(didTapsignOutButton), for: .touchUpInside)
//
//
//            NSLayoutConstraint.activate([signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor), signOutButton.heightAnchor.constraint(equalToConstant: 50), signOutButton.widthAnchor.constraint(equalToConstant: 280)])
//        }
