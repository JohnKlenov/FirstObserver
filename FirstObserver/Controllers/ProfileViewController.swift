//
//  ProfileViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//


import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseStorageUI

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
                userNameTextField.text = user.displayName
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
                stateEditSaveButton(isSwitch: isEditButton)
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
                // проверка email and name на validation neaded
                updateProfileInfo(withImage: nil, name: userNameTextField.text != currentUser?.displayName ? userNameTextField.text : nil , email: emailUserTextField.text != currentUser?.email ? emailUserTextField.text : nil) { error in
                    if error != nil {
                        print("\(String(describing: error))")
                        if let error = error as NSError? {
                            self.editOrDoneButton.configuration?.showsActivityIndicator = false
                            self.editOrDoneButton.configurationUpdateHandler = nil
                            self.switchSaveButton(isSwitch: false)
                            self.setupAlert(title: "Error", message: error.localizedDescription)
                        }
                    } else {
                        self.isTimer = false
                        self.stateEditSaveButton(isSwitch: self.isEditButton)
                        self.setupAlert(title: "Success", message: "Data changed!")
                    }
                    
                }
            }
        }
                
        

        @IBAction func didTapCancel(_ sender: UIButton) {
            
            cancelButton.isHidden = true
            emailUserTextField.text = currentUser?.email
            userNameTextField.text = currentUser?.displayName
            switchEditButton(isSwitch: true)
            userNameTextField.isUserInteractionEnabled = false
            emailUserTextField.isUserInteractionEnabled = false
            isEditButton = !isEditButton
            }
        
       
       
        @IBAction func didTapSignOut(_ sender: UIButton) {
            
            do {
                try Auth.auth().signOut()
                
            } catch {
                print("Что то пошло не так c didTapSignOut!")
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
                switchSaveButton(isSwitch: isValid)
            }
        }

        
        
        private func setupAlert(title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        
        private func isValidTextField(comletion: (Bool) -> Void) {
            guard let email = emailUserTextField.text, let name = userNameTextField.text, let emailUser = currentUser?.email else { return }
            let isValid = (!(email.isEmpty) && email != emailUser) || (!(name.isEmpty) && name != currentUser?.displayName)
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
        
        private func stateEditSaveButton(isSwitch: Bool) {
           
            isSwitch ? switchSaveButton(isSwitch: isSwitch) : switchEditButton(isSwitch: isSwitch)
            self.switchSaveButton(isSwitch: !isSwitch)
            self.cancelButton.isHidden = !isSwitch
            self.emailUserTextField.isUserInteractionEnabled = isSwitch
            self.userNameTextField.isUserInteractionEnabled = isSwitch
            self.isEditButton = !isSwitch
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
        
        
        
        private func createProfileChangeRequest(name: String? = nil, photoURL: URL? = nil,_ callBack: ((Error?) -> Void)? = nil) {
           
            if let request = Auth.auth().currentUser?.createProfileChangeRequest() {
                if let name = name {
                    request.displayName = name
                }
                
                if let photoURL = photoURL {
                    request.photoURL = photoURL
                }
                
                request.commitChanges { error in
                    callBack?(error)
                }
            }
        }
        
    
        func updateProfileInfo(withImage image: Data? = nil, name: String? = nil, email: String? = nil, _ callback: ((Error?) -> ())? = nil) {
            guard let user = Auth.auth().currentUser else {
                return
            }

            if let image = image{
                let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).png")

                _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("putData не удалось передать image в виде data")
                        callback?(error)
                        return
                    } else {
                        profileImgReference.downloadURL(completion: { (url, error) in
                            if let url = url{
                                self.createProfileChangeRequest(photoURL: url, { (error) in
                                    print("createProfileChangeRequest не изменил url")
                                    callback?(error)
                                    return
                                })
                            }else{
                                print("downloadURL не вернул url")
                                callback?(error)
                                return
                            }
                        })
                    }
                }
            }
            
            if let name = name {
                self.createProfileChangeRequest(name: name) { error in
                    print("createProfileChangeRequest сработал")
                    callback?(error)
                }
            }
            
            if let email = email {
                user.updateEmail(to: email) { error in
                    print("updateEmail сработал")
                    callback?(error)
                }
            }
        }
    }


//        func updateProfile(withImage image: Data? = nil, name: String? = nil, _ callback: ((Error?) -> ())? = nil){
//            guard let user = Auth.auth().currentUser else {
//                callback?(nil)
//                return
//            }
//
//            if let image = image{
//                let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).png")
//
//                _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
//                    if let error = error {
//                        callback?(error)
//                    } else {
//                        profileImgReference.downloadURL(completion: { (url, error) in
//                            if let url = url{
//                                self.createProfileChangeRequest(name: name, photoURL: url, { (error) in
//                                    callback?(error)
//                                })
//                            }else{
//                                callback?(error)
//                            }
//                        })
//                    }
//                }
//            }else if let name = name{
//                self.createProfileChangeRequest(name: name, { (error) in
//                    callback?(error)
//                })
//            }else{
//                callback?(nil)
//            }
//        }
        
        //
    

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
