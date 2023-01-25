//
//  ProfileViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//


import UIKit
//import FirebaseAuth
import Firebase
//import FirebaseStorage
//import FirebaseStorageUI

    class ProfileViewController: UIViewController {
        
        @IBOutlet weak var imageUser: UIImageView!
        
        @IBOutlet weak var editOrDoneButton: UIButton!
        
        @IBOutlet weak var cancelButton: UIButton!
       
        @IBOutlet weak var userNameTextField: UITextField!
        
        @IBOutlet weak var emailUserTextField: UITextField!
        
        @IBOutlet weak var radiusViewForTopView: UIView!
       
        @IBOutlet weak var signOutButton: UIButton!
        
        @IBOutlet weak var deleteAccountButton: UIButton!
        
        @IBOutlet weak var signInSignUp: UIButton!
        
        
        private var addedToCardProducts: [PopularProduct] = []
        private var isStateEditButton = true
        private var isAnimateDeleteButtonAnonUser = false

        private let encoder = JSONEncoder()
        private let tapGestureRecognizer = UITapGestureRecognizer()
        private var imageIsChanged = false
        private var imageData: Data?
        var imageReturn: UIImage?
        
        // MARK: FB property
        let managerFB = FBManager.shared
        private var currentUser: User?
//        private var storage:Storage!
//        var urlRefDelete: StorageReference?
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
//            testClosure {
//                print("end testClosure")
//            }
            
//            storage = Storage.storage()

            managerFB.userListener { [weak self] (user) in
                self?.currentUser = user
                
                if let user = user, !user.isAnonymous {
                    self?.userIsPermanentUpdateUI(user)
                } else {
                    self?.UserIsAnonymousUpdateUI()
                }
            }
            
            shadowRadiusView()
            configureButton()
            configureTapGestureRecognizer()
        }
        
        
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.addedToCardProducts = []
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "signInVCfromProfile" {
                getFetchDataHVC()
                let destination = segue.destination as! SignInViewController
                destination.addedToCardProducts = self.addedToCardProducts
                destination.profileDelegate = self
            }
        }
       
    
        // MARK: - helper methods for func managerFB.updateProfileInfo() -
       
        private func failedUpdateImage() {
            editOrDoneButton.configuration?.showsActivityIndicator = false
            switchSaveButton(isSwitch: false)
            if imageIsChanged {
                imageData = nil
                imageUser.image = imageReturn
                imageIsChanged = false
                imageReturn = nil
            }
        }
        private func successUpdateImage() {
            if imageIsChanged {
//                cacheImageRemoveMemoryAndDisk()
                managerFB.cacheImageRemoveMemoryAndDisk(imageView: imageUser)
                imageIsChanged = false
                imageData = nil
                imageReturn = nil
            }
        }
        
        private func failedUpdateName() {
            self.userNameTextField.text = self.currentUser?.displayName
        }
        
        
        
        
        // MARK: - @IBAction func -

        
        @IBAction func didTapEditOrDone(_ sender: UIButton) {
            
            if isStateEditButton {
                stateEditSaveButton(isSwitch: isStateEditButton)
            } else {
                editOrDoneButton.configuration?.title = ""
                editOrDoneButton.configuration?.showsActivityIndicator = true
                editOrDoneButton.isUserInteractionEnabled = false
  
                let image = imageIsChanged ? imageData : nil
                // if currentUser = nil ???
                let name = userNameTextField.text != currentUser?.displayName ? userNameTextField.text : nil

                managerFB.updateProfileInfo(withImage: image, name: name) { (state) in
                    
                    switch state {
                        
                    case .success:
                        self.editOrDoneButton.configuration?.showsActivityIndicator = false
                        self.stateEditSaveButton(isSwitch: self.isStateEditButton)
                        self.setupAlert(title: "Success", message: "Data changed!")
                        self.successUpdateImage()
                        
                    case .failed(image: let image, name: let name):
                        if let image = image, let name = name {
                            if image && name {
                                self.failedUpdateImage()
                                self.failedUpdateName()
                                self.setupAlert(title: "Error", message: "Something went wrong! Try again!")
                            } else if image {
                                self.failedUpdateImage()
                                self.setupAlert(title: "Error", message: "Avatar not saved! Try again!")
                                
                            } else if name {
                                
                                self.editOrDoneButton.configuration?.showsActivityIndicator = false
                                self.switchSaveButton(isSwitch: false)
                                self.failedUpdateName()
                                self.successUpdateImage()
                                self.setupAlert(title: "Error", message: "Name not saved! Try again!")
                            }
                        } else if let name = name, name {
                            self.editOrDoneButton.configuration?.showsActivityIndicator = false
                            self.switchSaveButton(isSwitch: false)
                            self.failedUpdateName()
                            self.setupAlert(title: "Error", message: "Name not saved! Try again!")
                        }
                    case .nul:
                        self.editOrDoneButton.configuration?.showsActivityIndicator = false
                        self.switchSaveButton(isSwitch: false)
                        self.setupAlert(title: "Error", message: "Something went wrong! Try again!")
                    }
            }
            }
        }
        

        @IBAction func didTapCancel(_ sender: UIButton) {
            
            if imageIsChanged {
                imageData = nil
                imageUser.image = imageReturn
                imageIsChanged = false
                imageReturn = nil
            }
            cancelButton.isHidden = true
            userNameTextField.text = currentUser?.displayName
            switchEditButton(isSwitch: true)
            userNameTextField.isUserInteractionEnabled = false
            imageUser.isUserInteractionEnabled = false
            isStateEditButton = !isStateEditButton
        }
        
       
        @IBAction func didTapSignOut(_ sender: UIButton) {
            isAnimateDeleteButtonAnonUser = true
            signOutButton.configuration?.showsActivityIndicator = true
            
            managerFB.signOut { (stateCallback) in
                
                switch stateCallback {
                case .success:
                    setupAlert(title: "Success", message: "You are logged out!")
                case .failed:
                    signOutButton.configuration?.showsActivityIndicator = false
                    isAnimateDeleteButtonAnonUser = false
                    setupAlert(title: "Failed SignOut", message: "Something went wrong! Try again!")
                }
            }
        }
  
        @IBAction func didTapSignInSignUp(_ sender: UIButton) {
            
            performSegue(withIdentifier: "signInVCfromProfile", sender: nil)
//            let isBoolFlag = UserDefaults.standard.bool(forKey: "WarningKey")
//            if !isBoolFlag {
//                UserDefaults.standard.set(true, forKey: "WarningKey")
//            }
        }
        
        
        @objc func handleTapSingleGesture() {
            setupAlertEditImageAvatar()
        }

        @IBAction func didTapDeleteAccount(_ sender: UIButton) {
            
            
            getFetchDataHVC()
            setupDeleteAlert(title: "Warning", message: "Deleting your account will permanently lose your data!") { isDelete in
                
                if isDelete {
                    self.isAnimateDeleteButtonAnonUser = true
//                     удаляем корзину user и в случае не успеха deleteAccaunt должны ее вернуть
                    self.managerFB.deleteCurrentUserProducts()
                    self.deleteAccountButton.configuration?.showsActivityIndicator = true
                    
                    self.managerFB.deleteAccaunt { (stateCallback) in
                        switch stateCallback {
                            
                        case .success:
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.managerFB.removeAvatarFromDeletedUser()
                            self.setupAlert(title: "Success", message: "Current accaunt delete!")
                        case .failed:
                            // сохранить данные обратно в корзину?
                            
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.isAnimateDeleteButtonAnonUser = false
                            self.setupFailedAlertDeleteAccount(title: "Failed", message: "Something went wrong. Try again!")
                        case .failedRequiresRecentLogin:
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.wrapperOverDeleteAlert(title: "Error", message: "Enter the password for \(self.currentUser?.email ?? "the current account") to delete your account!")
                        }
                    }
                    
                } else {
                    self.isAnimateDeleteButtonAnonUser = false
                    print("Cancel delete Accaunt!")
                }
            }
        }
        
        
        @IBAction func didChangeTextFieldNameOrEmail(_ sender: UITextField) {
            isValidTextField { (isValid) in
                switchSaveButton(isSwitch: isValid)
            }
        }
        
        
        
        // MARK: - helper methods -
        
        private func userIsPermanentUpdateUI(_ user:User) {
            editOrDoneButton.isHidden = false
            emailUserTextField.isHidden = false
            emailUserTextField.text = user.email
            userNameTextField.text = user.displayName
            cancelButton.isHidden = true
            userNameTextField.isUserInteractionEnabled = false
            emailUserTextField.isUserInteractionEnabled = false
            imageUser.isUserInteractionEnabled = false
            
            signOutButton.isHidden = false
            deleteAccountButton.isHidden = false
            
            if let photoURL = user.photoURL?.absoluteString {
                imageUser.fetchingImageWithPlaceholder(url: photoURL, placeholder: "DefaultImage")
//                let urlRef = storage.reference(forURL: photoURL)
//                imageUser.sd_setImage(with: urlRef, maxImageSize: 1024*1024, placeholderImage: UIImage(named: "DefaultImage"), options: .refreshCached) { (image, error, cashType, storageRef) in
//                    self.urlRefDelete = storageRef
//                    if error != nil {
//                        self.imageUser.image = UIImage(named: "DefaultImage")
//                    }
//                }
            } else {
                self.imageUser.image = UIImage(named: "DefaultImage")
            }
        }
        
        private func UserIsAnonymousUpdateUI() {
            editOrDoneButton.isHidden = true
            cancelButton.isHidden = true
            userNameTextField.text = "User is anonymous"
            userNameTextField.isUserInteractionEnabled = false
            imageUser.image = UIImage(named: "DefaultImage")
            imageUser.isUserInteractionEnabled = false
            emailUserTextField.isHidden = true
            signInSignUp.isHidden = false
            signOutButton.configuration?.showsActivityIndicator = false
            if isAnimateDeleteButtonAnonUser {
                print("if isAnimateDeleteButtonAnonUser")
                UIView.animate(withDuration: 0.2) {
                    self.signOutButton.isHidden = true
                    self.deleteAccountButton.isHidden = true
                    self.isAnimateDeleteButtonAnonUser = false
                }
            } else {
                signOutButton.isHidden = true
                deleteAccountButton.isHidden = true
            }
            
        }
        
        private func configureTapGestureRecognizer() {
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.addTarget(self, action: #selector(handleTapSingleGesture))
            imageUser.addGestureRecognizer(tapGestureRecognizer)
        }
        
        private func startRemoveAvatarUpdateUI() {
            editOrDoneButton.configuration?.title = ""
            editOrDoneButton.configuration?.showsActivityIndicator = true
            editOrDoneButton.isUserInteractionEnabled = false
        }
        
        private func endRemoveAvatarUpdateUI() {
            self.editOrDoneButton.configuration?.showsActivityIndicator = false
            self.stateEditSaveButton(isSwitch: self.isStateEditButton)
            self.setupAlert(title: "Success", message: "Profile avatar is delete!")
            self.imageIsChanged = false
        }
        
        private func failedRemoveAvatarUpdateUI() {
            self.editOrDoneButton.configuration?.showsActivityIndicator = false
            self.switchSaveButton(isSwitch: false)
            self.setupAlert(title: "Error", message: "Failed to delete profile avatar")
        }
        
        
        
        private func isValidTextField(comletion: (Bool) -> Void) {
            // logic valid email need not
            guard let email = emailUserTextField.text, let name = userNameTextField.text, let emailUser = currentUser?.email else { return }
            let isValid = (!(email.isEmpty) && email != emailUser) || (!(name.isEmpty) && name != currentUser?.displayName)
            comletion(isValid)
        }
        
        private func configureButton() {
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
             isSwitch ? switchSaveButton(isSwitch: !isSwitch) : switchEditButton(isSwitch: !isSwitch)
             self.cancelButton.isHidden = !isSwitch
             self.userNameTextField.isUserInteractionEnabled = isSwitch
             self.imageUser.isUserInteractionEnabled = isSwitch
             self.isStateEditButton = !isSwitch
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
        
        private func shadowRadiusView() {
            radiusViewForTopView.layer.shadowOffset = CGSize(width: 0, height: 10)
            radiusViewForTopView.layer.shadowOpacity = 0.7
            radiusViewForTopView.layer.shadowRadius = 5
            radiusViewForTopView.layer.shadowColor = CGColor(red: 255.0/255.0, green: 45.0/255.0, blue: 85.0/255.0, alpha: 1)
        }
        
        private func getFetchDataHVC() {

            guard let tabBarVCs = tabBarController?.viewControllers else { return }
            tabBarVCs.forEach { (vc) in
                if let nc = vc as? UINavigationController {
                    if let homeVC = nc.topViewController as? HomeViewController {
                        self.addedToCardProducts = homeVC.addedToCardProducts
                    }
                }
            }
        }
        
//        private func cacheImageRemoveMemoryAndDisk() {
//            if let cacheKey = self.imageUser.sd_imageURL?.absoluteString {
//                SDImageCache.shared.removeImageFromDisk(forKey: cacheKey)
//                SDImageCache.shared.removeImageFromMemory(forKey: cacheKey)
//            }
//        }
        
        
        // MARK: - FB methods -
        
        
        private func saveRemuveCartProductFB() {

            // i think here error - !currentUser.isAnonymous and setValue(["permanentUser":uid])
            if let currentUser = currentUser, !currentUser.isAnonymous {
//                let uid = currentUser.uid

//                let refFBR = Database.database().reference()
//                refFBR.child("usersAccaunt/\(uid)").setValue(["uidAnonymous":uid])
                managerFB.addUidFromCurrentUserAccount()
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
                        managerFB.addProductsToANonRemoteUser(products: [addedProduct.key:json])
//                        let ref = Database.database().reference(withPath: "usersAccaunt/\(uid)/AddedProducts")
//                        ref.updateChildValues([addedProduct.key:json])

                    } catch {
                        print("an error occured", error)
                    }
                }
            }
        }
    }

extension ProfileViewController: SignInViewControllerDelegate {
    func userIsPermanent() {
        guard let user = currentUser else {return}
        self.userIsPermanentUpdateUI(user)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source:UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let originImage = info[.editedImage] as? UIImage
        let size = CGSize(width: 400, height: 400)
        // а что если compressedImage придет nil?
        let compressedImage = originImage?.thumbnailOfSize(size)
        imageReturn = imageUser.image
        imageUser.image = compressedImage
        imageUser.contentMode = .scaleAspectFill
        imageUser.clipsToBounds = true
        imageData = compressedImage?.jpegData(compressionQuality: 0.2)
        imageIsChanged = true
        switchSaveButton(isSwitch: true)
        dismiss(animated: true, completion: nil)
        
    }
}
        




// MARK: - extension Alerts -

private extension ProfileViewController {
    
    func setupAlertEditImageAvatar() {
        
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.overrideUserInterfaceStyle = .dark
        
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            self.chooseImagePicker(source: .camera)
        }
        
        let gallery = UIAlertAction(title: "Gallery", style: .default) { action in
            self.chooseImagePicker(source: .photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        
        let deleteAvatar = UIAlertAction(title: "Delete Avatar", style: .destructive) { action in
            self.startRemoveAvatarUpdateUI()
            self.managerFB.removeAvatarFromCurrentUser { state in
                switch state {
                    
                case .success:
//                    self.cacheImageRemoveMemoryAndDisk()
                    self.managerFB.cacheImageRemoveMemoryAndDisk(imageView: self.imageUser)
                    self.endRemoveAvatarUpdateUI()
                    self.imageUser.image = UIImage(named: "DefaultImage")
                case .failed:
                    self.failedRemoveAvatarUpdateUI()
                }
            }
        }
        
        let titleAlertController = NSAttributedString(string: "Add image to avatar", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)])
        alert.setValue(titleAlertController, forKey: "attributedTitle")
        
        
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
       
        if let _ = managerFB.avatarRef, imageIsChanged == false {
            alert.addAction(deleteAvatar)
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // Log in again before retrying this request
    func setupAlertRecentLogin(title:String, message:String, placeholder: String, completionHandler: @escaping (String) -> Void ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) { action in
            print("did OK")
            let textField = alertController.textFields?.first
            guard let text = textField?.text else {return}
            completionHandler(text)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("did cancel")
            // isDelete = false
            self.saveRemuveCartProductFB()
        }
        
        alertController.addAction(actionOK)
        alertController.addAction(actionCancel)
        alertController.addTextField { textField in
            textField.placeholder = placeholder
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    func wrapperOverDeleteAlert(title:String, message: String) {
        self.setupAlertRecentLogin(title: title, message: message, placeholder: "enter password") { password in
            
            self.deleteAccountButton.configuration?.showsActivityIndicator = true
            
            self.managerFB.reauthenticateUser(password: password) { (stateCallback) in
                
                switch stateCallback {
                    
                case .success:
                    
                    self.managerFB.deleteAccaunt { (state) in
                        switch state {
                            
                        case .success:
                            self.managerFB.removeAvatarFromDeletedUser()
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.setupAlert(title: "Success", message: "Current accaunt delete!")
                        case .failed:
                            self.isAnimateDeleteButtonAnonUser = false
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.setupFailedAlertDeleteAccount(title: "Failed", message: "Something went wrong. Try again!")
                        case .failedRequiresRecentLogin:
                            self.deleteAccountButton.configuration?.showsActivityIndicator = false
                            self.wrapperOverDeleteAlert(title: "Error", message: "Enter the password for \(self.currentUser?.email ?? "the current account") to delete your account!")
                        }
                    }
                case .failed:
                    self.deleteAccountButton.configuration?.showsActivityIndicator = false
                    // тут вызвать вместо setupFailedAlertDeleteAccount -> user.reauthenticate(with: credential)
                    // потому что иначе мы заново будем создавать удаление -> deleteAccaunt { error in } а оно уже вызвано и привело сюда.
                    // или написать [weak self] в setupAlertRecentLogin
                    
                    self.isAnimateDeleteButtonAnonUser = false
                    self.setupFailedAlertDeleteAccount(title: "Failed", message: "Something went wrong. Try again later!")
                case .wrongPassword:
                    self.deleteAccountButton.configuration?.showsActivityIndicator = false
                    self.wrapperOverDeleteAlert(title: "Invalid password", message: "Enter the password for \(self.currentUser?.email ?? "the current account") to delete your account!")
                }
            }
        }
    }
    
    
    func setupAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setupFailedAlertDeleteAccount(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            // save data user remuveProducts
            self.saveRemuveCartProductFB()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func setupDeleteAlert(title: String, message: String, isDeleteCompletion: @escaping (Bool) -> Void) {
        
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
    
}




//        private func updateProfileInfo(withImage image: Data? = nil, name: String? = nil, email: String? = nil, _ callback: ((Error?) -> ())? = nil) {
//            guard let user = Auth.auth().currentUser else {
//                return
//            }
//
//            // мы можем маркировать ошбки пришедшие из image или из name
//            // error image -> любая -> delete imageView устаавливаем defaultImage, imageIsChanged = false, switchSaveButton(isSwitch: false)
//            if let image = image{
//                let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).jpeg")
//                _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
//                    if let error = error {
//                        callback?(error)
//                        return
//                    } else {
//                        profileImgReference.downloadURL(completion: { (url, error) in
//                            if let url = url{
//                                self.urlRefDelete = profileImgReference
//                                self.createProfileChangeRequest(photoURL: url, { (error) in
//                                    callback?(error)
//                                    return
//                                })
//                            }else{
//                                callback?(error)
//                                return
//                            }
//                        })
//                    }
//                }
//            }
//
//            if let name = name {
//                self.createProfileChangeRequest(name: name) { error in
//                    callback?(error)
//                }
//            }
//
//            if let email = email {
//                user.updateEmail(to: email) { error in
//                    print("updateEmail сработал")
//                    callback?(error)
//                }
//            }
//        }

//            self.urlRefDelete?.delete(completion: { error in
//                if error == nil {
//                    self.cacheImageRemoveMemoryAndDisk()
//                    self.urlRefDelete = nil
//                    self.resetProfileChangeRequest(reset: .photoURL) { error in
//                        print("self.resetProfileChangeRequest(reset: .photoURL) - \(String(describing: error?.localizedDescription))")
//                    }
//                    self.endDeleteRefImageUpdateUI()
//                    self.imageUser.image = UIImage(named: "DefaultImage")
//                    print("storageImage delete")
//                } else {
//                        self.errorDeleteRefImageUpdateUI()
//                }
//            })
            
//
//        private func deleteAccaunt(_ callBack: @escaping (Error?) -> Void) {
//
//            if let currentUser = Auth.auth().currentUser {
//
//                currentUser.delete { error in
//                    print("deleteAccaunt error - \(String(describing: error?.localizedDescription))")
//                    callBack(error)
//                }
//            }
//        }
        
//            Auth.auth().addStateDidChangeListener { (auth, user) in
//                print("Get User - \(String(describing: user?.uid))")
//            self.currentUser = user
//
//            if let user = user, !user.isAnonymous {
//                self.currentUserisPermanent(user)
//            } else {
//                self.currentUserIsAnonymous()
//            }
//
//        }
            
//
//        private func createProfileChangeRequest(name: String? = nil, photoURL: URL? = nil,_ callBack: ((Error?) -> Void)? = nil) {
//
//            if let request = Auth.auth().currentUser?.createProfileChangeRequest() {
//                if let name = name {
//                    request.displayName = name
//                }
//
//                if let photoURL = photoURL {
//                    request.photoURL = photoURL
//                }
//
//                request.commitChanges { error in
//                    callBack?(error)
//                }
//            }
//        }
