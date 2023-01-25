//
//  FBManager.swift
//  FirstObserver
//
//  Created by Evgenyi on 20.01.23.
//

import Foundation

import UIKit
//import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseStorageUI

//(success: Bool)

enum StateProfileInfo {
    
    case success
    case failed(image:Bool? = nil, name:Bool? = nil)
    case nul
}

enum StateCallback {
    case success
    case failed
}

enum StateDeleteAccaunt {
    case success
    case failed
    case failedRequiresRecentLogin
}
enum StateReauthenticateUser {
    case wrongPassword
    case success
    case failed
}

enum ResetProfile {
    case name
    case photoURL
}

final class FBManager {
    
    static let shared = FBManager()
    var currentUser: User?
    var avatarRef: StorageReference?
//    var storage = Storage.storage()
    
    
    func userListener(currentUser: @escaping (User?) -> Void) {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            self.currentUser = user
            currentUser(user)
        }
    }
    

    func updateProfileInfo(withImage image: Data? = nil, name: String? = nil, _ callback: ((StateProfileInfo) -> ())? = nil) {
        guard let user = currentUser else {
            return
        }
        
        if let image = image{
            imageChangeRequest(user: user, image: image) { (error) in
                let imageIsFailed = error != nil ? true: false
                self.createProfileChangeRequest(name: name) { (error) in
                    let nameIsFailed = error != nil ? true: false
                    if !imageIsFailed, !nameIsFailed {
                        callback?(.success)
                    } else {
                        callback?(.failed(image: imageIsFailed, name: nameIsFailed))
                    }
                }
            }
        } else if let name = name {
            self.createProfileChangeRequest(name: name) { error in
                let nameIsFailed = error != nil ? true: false
                if !nameIsFailed {
                    callback?(.success)
                } else {
                    callback?(.failed(name: nameIsFailed))
                }
            }
        } else {
            callback?(.nul)
        }
    }
    
    func imageChangeRequest(user:User, image:Data,  _ callback: ((Error?) -> ())? = nil) {
        // если пытаемся добавить image когда нет wifi
        // при Database.database().isPersistenceEnabled = true error в profileImgReference.putData не возвращается ждет сети
            let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).jpeg")
            _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("не удалось запулить data на сервак")
                    callback?(error)
                } else {
                    profileImgReference.downloadURL(completion: { (url, error) in
                        if let url = url{
                            self.avatarRef = profileImgReference
                            self.createProfileChangeRequest(photoURL: url) { (error) in
                                // если сдесь произошла ошибка что делать с image в storage и urlRefDelete?
                                callback?(error)
                            }
                        }else{
                            callback?(error)
                        }
                    })
                }
            }
        }
    
    
    func createProfileChangeRequest(name: String? = nil, photoURL: URL? = nil,_ callBack: ((Error?) -> Void)? = nil) {
       
        print("createProfileChangeRequest")
        if let request = currentUser?.createProfileChangeRequest() {
            if let name = name {
                request.displayName = name
            }
            
            if let photoURL = photoURL {
                request.photoURL = photoURL
            }
            
            request.commitChanges { error in
                print("request.commitChanges ")
                    callBack?(error)
            }
        }
    }
    
    func resetProfileChangeRequest(reset: ResetProfile,_ callBack: ((Error?) -> Void)? = nil) {
        
        if let request = Auth.auth().currentUser?.createProfileChangeRequest() {
            
            switch reset {
                
            case .name:
                request.displayName = nil
            case .photoURL:
                request.photoURL = nil
            }
            request.commitChanges { error in
                callBack?(error)
            }
        }
    }
    func removeAvatarFromDeletedUser() {
        
        avatarRef?.delete(completion: { error in
                self.avatarRef = nil
        })
    }
    func removeAvatarFromCurrentUser(_ callback: @escaping (StateCallback) -> Void) {
        avatarRef?.delete(completion: { error in
            if error == nil {
                self.avatarRef = nil
                self.resetProfileChangeRequest(reset: .photoURL) { error in
                    if error != nil {
                        print("Не удалось удалить старую photoURL в currentUser")
//                        callback(.failed)
//                        return
                    }
                }
                callback(.success)
            } else {
                callback(.failed)
            }
        })
    }
    
    func addUidFromCurrentUserAccount() {
        guard let currentUser = currentUser else {
            return
        }
        let refFBR = Database.database().reference()
        refFBR.child("usersAccaunt/\(currentUser.uid)").setValue(["uidCurrentUser":currentUser.uid])
    }
    
    func addProductsToANonRemoteUser(products: [String:Any]) {
        guard let currentUser = currentUser else {
            return
        }
        let ref = Database.database().reference(withPath: "usersAccaunt/\(currentUser.uid)/AddedProducts")
        ref.updateChildValues(products)
    }
    
    func cacheImageRemoveMemoryAndDisk(imageView: UIImageView) {
        if let cacheKey = imageView.sd_imageURL?.absoluteString {
            SDImageCache.shared.removeImageFromDisk(forKey: cacheKey)
            SDImageCache.shared.removeImageFromMemory(forKey: cacheKey)
        }
    }
    
    func updateEmail(to: String, callBack: @escaping (Error?) -> Void) {
        currentUser?.updateEmail(to: to, completion: { (error) in
           
            
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .invalidEmail:
                    print("адрес электронной почты имеет неверный формат")
                case .emailAlreadyInUse:
                    print("электронная почта уже используется другой учетной записью")
                case .requiresRecentLogin:
                    print("требуется недавний вход пользователя в систему - reauthenticate(with:)")
                default:
                    print("Try again!")
                }
            }
            callBack(error)
        })
    }
    
    func signOut(_ callback: (StateCallback) -> Void) {
        do {
            try Auth.auth().signOut()
            callback(.success)
        } catch {
            // AuthErrorCodeKeychainError` — Указывает, что произошла ошибка при доступе к цепочке ключей. Поле NSLocalizedFailureReasonErrorKey в словаре userInfo будет содержать дополнительную информацию
            callback(.failed)
        }
    }
    
    func deleteAccaunt(_ callback: @escaping (StateDeleteAccaunt) -> Void) {
        
        guard let user = currentUser else {return}
        
        user.delete { (error) in
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .requiresRecentLogin:
                    callback(.failedRequiresRecentLogin)
                default:
                    callback(.failed)
                }
            } else {
                callback(.success)
            }
        }
    }
    
    func deleteCurrentUserProducts() {
        if let user = currentUser {
            let uid = user.uid
            Database.database().reference().child("usersAccaunt").child(uid).removeValue()
        }
    }
    
    func reauthenticateUser(password: String, callback: @escaping (StateReauthenticateUser) -> Void) {
        guard let user = currentUser, let email = user.email else {return}
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.reauthenticate(with: credential) { (result, error) in
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .wrongPassword:
                    callback(.wrongPassword)
                default:
                    callback(.failed)
                }
            } else {
                callback(.success)
            }
        }
    }
    
}


extension UIImageView {
    
  
    
    func fetchingImageWithPlaceholder(url: String, placeholder: String) {
        let storage = Storage.storage()
        let urlRef = storage.reference(forURL: url)
        self.sd_setImage(with: urlRef, maxImageSize: 1024*1024, placeholderImage: UIImage(named: placeholder), options: .refreshCached) { (image, error, cashType, storageRef) in
            FBManager.shared.avatarRef = storageRef
            if error != nil {
                self.image = UIImage(named: placeholder)
            }
        }
    }
}


/*
 user.updateEmail(to: email)
 
 Примечание
 
 Может произойти сбой, если уже существует учетная запись с этим адресом электронной почты, созданная с использованием проверки подлинности по электронной почте и паролю.
 Примечание
 
 Возможные коды ошибок:
 + `AuthErrorCodeInvalidRecipientEmail` — указывает, что в запросе был отправлен неверный адрес электронной почты получателя. + `AuthErrorCodeInvalidSender` — указывает, что для этого действия в консоли задан неверный адрес электронной почты отправителя. + `AuthErrorCodeInvalidMessagePayload` — указывает на недопустимый шаблон электронной почты для отправки электронной почты с обновлением. + `AuthErrorCodeEmailAlreadyInUse` — указывает, что электронная почта уже используется другой учетной записью. + `AuthErrorCodeInvalidEmail` — указывает, что адрес электронной почты имеет неверный формат. + `AuthErrorCodeRequiresRecentLogin` — обновление электронной почты пользователя является важной операцией с точки зрения безопасности, для которой требуется недавний вход пользователя в систему. Эта ошибка указывает на то, что пользователь не входил в систему достаточно давно. Чтобы решить эту проблему, повторите аутентификацию пользователя, вызвав `reauthenticate(with:)`.
 Примечание
 
 См. AuthErrors для списка кодов ошибок, общих для всех пользовательских методов.
 Параметры
 
 Эл. адрес
 Электронный адрес пользователя.
 завершение
 По выбору; блок, вызываемый после завершения изменения профиля пользователя. Вызывается асинхронно в основном потоке в будущем.
 -
 Без описания.
 */


//            let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).jpeg")
//            _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    callback?(error, .image)
//                } else {
//                    profileImgReference.downloadURL(completion: { (url, error) in
//                        if let url = url{
//                            self.urlRefDelete = profileImgReference
//                            self.createProfileChangeRequest(photoURL: url) { (error) in
//                                if error == nil {
//                                    self.createProfileChangeRequest(name: name) { (error) in
//                                        print("Сработал createProfileChangeRequest(name: name)")
//                                        if error == nil {
//                                            print("createProfileChangeRequest(name: name)")
//                                            callback?(error, .success)
//                                        } else {
//                                            callback?(error, .name)
//                                        }
//                                    }
//                                } else {
//                                    callback?(error, .image)
//                                }
//                            }
//                        }else{
//                            callback?(error, .image)
//                        }
//                    })
//                }
//            }


//    func imageChangeRequest(_ callback: (Error?, StateProfileInfo) -> Void) {
//
//        let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).jpeg")
//        _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
//            if let error = error {
//                callback?(error)
//            } else {
//                profileImgReference.downloadURL(completion: { (url, error) in
//                    if let url = url{
//                        self.urlRefDelete = profileImgReference
//                        self.createProfileChangeRequest(name: name, photoURL: url) { (error) in
//                            callback?(error)
//                        }
//                    }else{
//                        callback?(error)
//                    }
//                })
//            }
//        }
//    }
