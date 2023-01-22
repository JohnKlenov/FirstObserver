//
//  FBManager.swift
//  FirstObserver
//
//  Created by Evgenyi on 20.01.23.
//

import Foundation

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseStorageUI

//(success: Bool)

enum StateProfileInfo {
    
    case success
    case failed(image:Bool? = nil, name:Bool? = nil)
    case nul
}

final class FBManager {
    
    static let shared = FBManager()
    var currentUser: User?
    var urlRefDelete: StorageReference?
    
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
                print("imageChangeRequest \(imageIsFailed)")
                self.createProfileChangeRequest(name: name) { (error) in
                    let nameIsFailed = error != nil ? true: false
                    print("let nameIsFailed = error != nil ? true: false - \(nameIsFailed)")
                    if !imageIsFailed, !nameIsFailed {
                        callback?(.success)
                    } else {
                        callback?(.failed(image: imageIsFailed, name: nameIsFailed))
                    }
                }
            }
        } else if let name = name {
            print("else if let name = name {")
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
        print("±±±±±±±±±imageChangeRequest imageChangeRequest")
    
            let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).jpeg")
            _ = profileImgReference.putData(image, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("не удалось запулить data на сервак")
                    callback?(error)
                } else {
                    profileImgReference.downloadURL(completion: { (url, error) in
                        if let url = url{
                            self.urlRefDelete = profileImgReference
                            self.createProfileChangeRequest(photoURL: url) { (error) in
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
