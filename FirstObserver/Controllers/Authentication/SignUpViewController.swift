//
//  SignUpViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 28.09.22.
//

import UIKit
import FirebaseAuth
import Firebase

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
        
        registerUser(email: emailTextField.text, password: passwordTextField.text) { result in
            switch result {
                
            case .success:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.setContinueButton(enabled: true)
                    self.continueButton.setTitle("Continue", for: .normal)
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Успешно!", message: "Вы авторизованы") {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                }
            case .failure( let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.setContinueButton(enabled: true)
                    self.continueButton.setTitle("Continue", for: .normal)
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
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
    
    
    private func registerUser(email: String?, password: String?, completion: @escaping (AuthResult) -> Void) {
        
        guard let email = emailTextField.text, Validators.isValidEmailAddr(strToValidate: email) else {
            completion(AuthResult.failure(AuthError.invalidEmail))
            return
        }
        
        guard let password = password, Validators.isValidPassword(passwordText: password) else {
            completion(.failure(AuthError.notEqualPassword))
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("SignUpViewController - user not!!!")
            return
        }
        
        if user.isAnonymous {
           
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            user.link(with: credential, completion: { (result, error) in

                guard error == nil else {
                    print("SignUpViewController - НЕ приобразовали анонимную учетную запись в постоянную!!!")
                    print("\(String(describing: error))")
                    return
                }
                
                guard let user = result?.user else {
                    print("SignUpViewController Result - НЕ приобразовали анонимную учетную запись в постоянную!!!")
                    return
                }
                
                let uid = user.uid
                let refFBR = Database.database().reference()
                refFBR.child("usersAccaunt/\(uid)").updateChildValues(["uidPermanent":user.uid])
                refFBR.child("usersAccaunt/\(uid)/uidAnonymous").setValue(nil)
            })
            
        } else {
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in

                guard error == nil else {
                    print("SignUpViewController - Permanent user Not Create Accaunt!!!")
                    print("\(String(describing: error))")
                    return
                }

                guard let user = result?.user else {
                    print("SignUpViewController Result - Permanent user is not Create!")
                    return
                }

                let uid = user.uid
                let refFBR = Database.database().reference()
                refFBR.child("usersAccaunt/\(uid)").setValue(["uidPermanent":user.uid])
            }
            
        }
        completion(.success)
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

