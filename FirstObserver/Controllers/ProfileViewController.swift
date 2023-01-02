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
        var addedToCardProducts: [PopularProduct] = []
        var isEditButton = true
        var isTimer = false {
            didSet {
                editOrDoneButton.setNeedsUpdateConfiguration()
            }
        }
        private let encoder = JSONEncoder()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            shadowTopView()
            configureButton()
        }
        
        private func currentUserIsAnonymous() {
            editOrDoneButton.isHidden = true
            cancelButton.isHidden = true
            userNameTextField.text = "User is anonymous"
            userNameTextField.isUserInteractionEnabled = false
            emailUserTextField.isHidden = true
            signOutButton.isHidden = true
            deleteAccountButton.isHidden = true
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            
           currentUser = Auth.auth().currentUser
            print("viewWillAppear \(String(describing: currentUser?.uid))")
            if let user = currentUser, !user.isAnonymous {
                emailUserTextField.isHidden = false
                emailUserTextField.text = user.email
                userNameTextField.text = user.displayName
                cancelButton.isHidden = true
                userNameTextField.isUserInteractionEnabled = false
                emailUserTextField.isUserInteractionEnabled = false
                signOutButton.isHidden = false
                deleteAccountButton.isHidden = false
            } else {
                currentUserIsAnonymous()
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
                print(error.localizedDescription)
            }
            
            if let isUser = Auth.auth().currentUser?.isAnonymous, isUser == true {
                print("user == true")
                editOrDoneButton.isHidden = true
                cancelButton.isHidden = true
                userNameTextField.text = "User is anonymous"
                userNameTextField.isUserInteractionEnabled = false
                emailUserTextField.isHidden = true
                signOutButton.isHidden = true
                deleteAccountButton.isHidden = true
                currentUser = Auth.auth().currentUser
            } else {
                print("user != true")
            }
        }
  
        @IBAction func didTapSignInSignUp(_ sender: UIButton) {
        }
           
        
        @IBAction func didTapDeleteAccount(_ sender: UIButton) {
            
            getFetchDataHVC()
            setupDeleteAlert(title: "Warning", message: "Deleting your account will permanently lose your data!") { isDelete in
                if isDelete {
                    self.deleteUserProducts()
                    // delete data user products
                    self.deleteAccountButton.configuration?.showsActivityIndicator = true
                    self.deleteAccaunt { error in
                        if error != nil {
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            if let error = error as NSError? {
                                // пока решение отлавливать error.code = 17014
                                print("error.code - \(error.code)")
                                switch error.code {
                                case 17014:
                                    self.wrapperOverDeleteAlert(title: "Error", message: "Enter the password for \(self.emailUserTextField.text ?? "the current account") to delete your account!")
                                default:
//                                    self.deleteAccountButton.configuration?.showsActivityIndicator = false
                                    self.setupFailedAlertDeleteAccount(title: "Failed", message: "Something went wrong. Try again!")
                                }
                            }
                        } else {
                            self.setupAlert(title: "Success", message: "Current accaunt delete!")
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.currentUserIsAnonymous()
                            self.currentUser = Auth.auth().currentUser
                        }
                    }
                } else {
                    print("Cancel delete Accaunt!")
                    self.addedToCardProducts = []
                }
            }
        }
        
        private func wrapperOverDeleteAlert(title:String, message: String) {
            self.setupAlertRecentLogin(title: title, message: message, placeholder: "enter password") { password in
                if let user = Auth.auth().currentUser, let email = self.emailUserTextField.text {
                    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                    self.deleteAccountButton.configuration?.showsActivityIndicator = true
                    user.reauthenticate(with: credential) { (result, error) in
                        if let error = error as NSError? {
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            print("error.code - \(error.code)")
                            print("reauthenticate - \(String(describing: error.localizedDescription))")
                            switch error.code {
                            case 17009:
                                self.wrapperOverDeleteAlert(title: "Invalid password", message: "Enter the password for \(self.emailUserTextField.text ?? "the current account") to delete your account!")
                            default:
                                self.setupFailedAlertDeleteAccount(title: "Failed", message: "Something went wrong. Try again later!")
                            }
                            
                        } else {
                            self.deleteAccaunt { error in
                                if error == nil {
                                    self.deleteAccountButton.configuration?.showsActivityIndicator = false
                                    self.currentUserIsAnonymous()
                                    self.setupAlert(title: "Success", message: "Current accaunt delete!")
                                    self.currentUser = Auth.auth().currentUser
                                } else {
                                    self.deleteAccountButton.configuration?.showsActivityIndicator = false
                                    self.setupFailedAlertDeleteAccount(title: "Failed", message: "Something went wrong. Try again!")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        private func deleteAccaunt(_ callBack: @escaping (Error?) -> Void) {
          
            if let currentUser = Auth.auth().currentUser {

                currentUser.delete { error in
                    print("deleteAccaunt error - \(String(describing: error?.localizedDescription))")
                    callBack(error)
                }
            }
            
        }

        @IBAction func didChangeTextFieldNameOrEmail(_ sender: UITextField) {
            isValidTextField { (isValid) in
                switchSaveButton(isSwitch: isValid)
            }
        }

        // Log in again before retrying this request
        private func setupAlertRecentLogin(title:String, message:String, placeholder: String, completionHandler: @escaping (String) -> Void ) {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default) { action in
                print("did OK")
                let textField = alertController.textFields?.first
                guard let text = textField?.text else {return}
                completionHandler(text)
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("did cancel")
                // save data user remuveProducts
            }
            
            alertController.addAction(actionOK)
            alertController.addAction(actionCancel)
            alertController.addTextField { textField in
                textField.placeholder = placeholder
            }
            present(alertController, animated: true, completion: nil)
        }
        
        private func setupAlert(title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        private func setupFailedAlertDeleteAccount(title: String, message: String) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                // save data user remuveProducts
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        private func setupAlertDeleteContinue(title: String, message: String, completionHandler: @escaping () -> Void) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            let continueAction = UIAlertAction(title: "Continue", style: .destructive) { action in
                print("did Continue")
                completionHandler()
            }
            alert.addAction(cancelAction)
            alert.addAction(continueAction)
            present(alert, animated: true, completion: nil)
        }
        
        private func setupDeleteAlert(title: String, message: String, isDeleteCompletion: @escaping (Bool) -> Void) {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "DELETE", style: .destructive) { action in
                print(" Did Delete")
                isDeleteCompletion(true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                print("Did Cancel")
                isDeleteCompletion(false)
            }
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true) {
                print("Did Delete Accaunt")
            }
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
        
        private func getFetchDataHVC() {

            guard let tabBarVCs = tabBarController?.viewControllers else { return }
            tabBarVCs.forEach { (vc) in
                if let nc = vc as? UINavigationController {
                    if let homeVC = nc.topViewController as? HomeViewController {
                        self.addedToCardProducts = homeVC.addedToCardProducts
                        print("getFetchDataHVC -  \(addedToCardProducts)")
                    }
                }
            }
        }
        
        private func deleteUserProducts() {
            if let user = currentUser {
                let uid = user.uid
                Database.database().reference().child("usersAccaunt").child(uid).removeValue()
            }
        }
        
        
        private func saveRemuveCartProductFB() {

            if let currentUser = currentUser, currentUser.isAnonymous {
                let uid = currentUser.uid

                let refFBR = Database.database().reference()
                refFBR.child("usersAccaunt/\(uid)").setValue(["uidAnonymous":uid])
                var removeCartProduct: [String:AddedProduct] = [:]

                addedToCardProducts.forEach { (cartProduct) in
                    let productEncode = AddedProduct(product: cartProduct)
                    print("cartProduct - \(productEncode)")
                    removeCartProduct[cartProduct.model] = productEncode
                }

                removeCartProduct.forEach { (addedProduct) in
                    do {
                        let data = try encoder.encode(addedProduct.value)
                        let json = try JSONSerialization.jsonObject(with: data)
                        let ref = Database.database().reference(withPath: "usersAccaunt/\(uid)/AddedProducts")
                        ref.updateChildValues([addedProduct.key:json])

                    } catch {
                        print("an error occured", error)
                    }
                }
            }
        }

    
        private func updateProfileInfo(withImage image: Data? = nil, name: String? = nil, email: String? = nil, _ callback: ((Error?) -> ())? = nil) {
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
        
       
    




