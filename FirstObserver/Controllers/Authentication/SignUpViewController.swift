//
//  SignUpViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 28.09.22.
//

import UIKit
import FirebaseAuth
import Firebase
import Foundation

@objc protocol SignUpViewControllerDelegate: AnyObject {
    @objc optional func saveRemuveCartProductFB()
    @objc optional func anonymousUserDidRegistered()
    
}

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnterTextField: UITextField!
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = CGPoint(x: view.center.x, y: view.frame.height - 125)
        button.backgroundColor = .systemPurple
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.layer.cornerRadius = 4
        button.alpha = 0.5
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    var buttonCenter: CGPoint!
    var isFlag = false
    weak var delegate: SignUpViewControllerDelegate?
    var isInvalidSignIn:Bool = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func didBackVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        buttonCenter = continueButton.center

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        reEnterTextField.delegate = self
        
        view.addSubview(activityIndicator)
        setupActivity()
        
        
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        reEnterTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        passwordTextField.enablePasswordToggle()
        reEnterTextField.enablePasswordToggle()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideUp), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowUp(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - keyboardFrame.height - 25 - continueButton.frame.height/2)
        activityIndicator.center = continueButton.center
    }
    
    @objc func keyboardWillHideUp(notification: Notification) {
        continueButton.center = buttonCenter
        activityIndicator.center = continueButton.center
    }
    
    @objc func didTapButton() {
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        registerUser(email: emailTextField.text, password: passwordTextField.text, name: nameTextField.text) { [weak self] (result) in
            switch result {
                
            case .success:
                
                self?.setContinueButton(enabled: true)
                self?.continueButton.setTitle("Continue", for: .normal)
                self?.activityIndicator.stopAnimating()
                self?.showAlert(title: "Success!", message: "An email has been sent to \(self?.emailTextField.text ?? "email"), please confirm your email address.") {
                    self?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                
            case .failure( let error):
                self?.setContinueButton(enabled: true)
                self?.continueButton.setTitle("Continue", for: .normal)
                self?.activityIndicator.stopAnimating()
                self?.showAlert(title: "Error", message: error.localizedDescription)
                
            }
        }
        
    }
    
    @objc func textFieldChanged() {
        
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let rePassword = reEnterTextField.text else {return}
        let isValid = !(name.isEmpty) && !(email.isEmpty) && !(password.isEmpty) && password == rePassword
        setContinueButton(enabled: isValid)
        
    }
    
    func showAlert(title: String, message: String, completion: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "ok", style: .default) { (_) in
            completion()
        }
        alert.addAction(actionOK)
        self.present(alert, animated: true, completion: nil)
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
                if error != nil {
                    print("createProfileChangeRequest return error!!!")
                    callBack?(error)
                } else {
                    // configure profile success
                    self.delegate?.anonymousUserDidRegistered?()
                }
            }
        }
    }
    
    private func registerUser(email: String?, password: String?, name: String?, completion: @escaping (AuthResult) -> Void) {
        
        guard let email = email, Validators.isValidEmailAddr(strToValidate: email) else {
            completion(AuthResult.failure(AuthError.invalidEmail))
            return
        }
        
        guard let password = password, Validators.isValidPassword(passwordText: password) else {
            completion(.failure(AuthError.notEqualPassword))
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            // return error in completion
            return
        }
        
        if user.isAnonymous {
            
            if isInvalidSignIn {
                delegate?.saveRemuveCartProductFB?()
            }
           
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.link(with: credential, completion: { (result, error) in

                guard error == nil else {
                    // return error
                    return
                }
                
                guard let user = result?.user else {
                    // return error
                    return
                }
                
                self.createProfileChangeRequest(name: name, photoURL: nil) { error in
                    self.delegate?.anonymousUserDidRegistered?()                }
                
                let uid = user.uid
                let refFBR = Database.database().reference()
                refFBR.child("usersAccaunt/\(uid)").updateChildValues(["uidPermanent":user.uid])
                refFBR.child("usersAccaunt/\(uid)/uidAnonymous").setValue(nil)
                self.verificationEmail()
                completion(.success)
            })
            
            
        } else {
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in

                guard error == nil else {
                    return
                }

                guard let user = result?.user else {
                    return
                }
                self.createProfileChangeRequest(name: name)

                let uid = user.uid
                let refFBR = Database.database().reference()
                refFBR.child("usersAccaunt/\(uid)").setValue(["uidPermanent":user.uid])
                self.verificationEmail()
                completion(.success)
            }
            
        }
//        completion(.success)
    }
    
    // Отправить пользователю электронное письмо с подтверждением регистрации
    func verificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if error != nil {
                print("sendEmailVerification - Что то пошло не так!!!!")
            } else {
                print("sendEmailVerification - Мы отправили подтверждение на email")
            }
        })
    }
    
    
    private func setContinueButton(enabled: Bool) {
        if enabled {
            continueButton.alpha = 1
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    private func setupActivity() {
        
        activityIndicator.color = .gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        activityIndicator.center = continueButton.center
    }
    
    deinit {
        //
    }
   
}

extension SignUpViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            reEnterTextField.becomeFirstResponder()
        case reEnterTextField:
            textField.resignFirstResponder()
        default:
            print("Error")
        }
        return true
    }

}

