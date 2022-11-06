//
//  SignInViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 28.09.22.
//

import UIKit
import FirebaseAuth

// if request.auth != null
class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    
    lazy var button: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = CGPoint(x: view.center.x, y: view.frame.height - 125)
        button.backgroundColor = .systemPurple
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.alpha = 0.5
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    var userDefaults = UserDefaults.standard
    var activityIndicator: UIActivityIndicatorView!
    var isFlag = true
    var buttonCentre: CGPoint!
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.autocorrectionType = .no
//        emailTextField.autocorrectionType = .no
        buttonCentre = button.center
        view.addSubview(button)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupGestureRecognizer()
        setupActivity()
        view.addSubview(activityIndicator)
        setContinueButton(enabled: false)
        passwordTextField.enablePasswordToggle()
        
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bool = userDefaults.bool(forKey: "WarningKey")
        // должно быть !bool
        if !bool {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.setupAllertSignIn()
                self.userDefaults.set(true, forKey: "WarningKey")
            }
        }
        
    }
    

    
    
    // MARK: - Action -

    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: nil)
        
    }
    
    @IBAction func canselButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {return}
        
        
        let isValid = !(email.isEmpty) && !(password.isEmpty)
        setContinueButton(enabled: isValid)
        
    }
    
    
    
    // MARK: - @objc -
    
    
    @objc func didTapButton() {
        
        setContinueButton(enabled: false)
        
                button.setTitle("", for: .normal)
                activityIndicator.startAnimating()
        
                guard let email = emailTextField.text, let password = passwordTextField.text else {return}
    
                // имитация работы API SDKVK
                if isFlag {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2)  { [weak self] in
                        self?.setContinueButton(enabled: true)
                        self?.button.setTitle("Continue", for: .normal)
                        self?.button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                        self?.activityIndicator.stopAnimating()
                    }
        
                } else {
                    print("\(email)")
                    print("\(password)")
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
    }
    
    @objc func handleTapDismiss() {
        view.endEditing(true)
    }
    
    // этот селектор вызывается даже когда поднимается keyboard в SignUpVC(SignInVC не умерает когда поверх него ложится SignUpVC)
    @objc func keyboardWillHide(notification: Notification) {
        print("keyboardWillHide keyboardWillHide keyboardWillHide")
        button.center = buttonCentre
        activityIndicator.center = button.center
    }
    
    // этот селектор вызывается даже когда поднимается keyboard в SignUpVC
    @objc func keyboardWillShow(notification: Notification) {
        
        print("keyboardWillShow keyboardWillShow keyboardWillShow")
        
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        button.center = CGPoint(x: view.center.x, y: view.frame.height - keyboardFrame.height - 25 - button.frame.height/2)
        
        activityIndicator.center = button.center
        
    }
    
    
    // MARK: - func -
    
    
    private func setupAllertSignIn() {
        
        let allertController = UIAlertController(title: "Авторизируйтесь!", message: "Что бы ваши данные были сохранены на сервере после удаления приложения вам нужно авторизоваться", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: nil)
        
        allertController.addAction(cancelAction)
        allertController.addAction(continueAction)
        
        self.present(allertController, animated: true, completion: nil)
        
    }
    
    // почему по нажатию по continueButton не скрывается клавиатура?
    private func setupGestureRecognizer() {
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.addTarget(self, action: #selector(handleTapDismiss))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupActivity() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .gray
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        activityIndicator.center = button.center
    }
    
    
    private func setContinueButton(enabled: Bool) {
        
        if enabled {
            button.alpha = 1
            button.isEnabled = true
        } else {
            button.alpha = 0.5
            button.isEnabled = false
        }
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
////        if(textField == self.passwordTextField) {
////            self.passwordTextField.isSecureTextEntry = true }
//        print("textFieldDidBeginEditing textFieldDidBeginEditing textFieldDidBeginEditing")
//
//    }

    
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        
        if isSecureTextEntry {
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
    }
    
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
            button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
            self.rightView = button
            self.rightViewMode = .always
    }
    
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

