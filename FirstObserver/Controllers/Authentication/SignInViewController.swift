//
//  SignInViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 28.09.22.
//

import UIKit
import FirebaseAuth
import Firebase



protocol SignInViewControllerDelegate : AnyObject {
    func userIsPermanent()
}

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
    var buttonCentre: CGPoint!
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    var addedToCardProducts: [PopularProduct] = []
    private let encoder = JSONEncoder()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    weak var productDelegate: ProductViewControllerDelegate?
    var isInvalidSignIn:Bool = false
    var currentUser: User?
    weak var profileDelegate:SignInViewControllerDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         
        currentUser = Auth.auth().currentUser
        
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
        
        productDelegate?.allProductsToCard(completionHandler: { (deleteCartProducts) in
            addedToCardProducts = deleteCartProducts
        })
        
        print("SignInViewController viewWillAppear addedToCardProducts - \(addedToCardProducts)")
        
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
//                self.setupAllertSignIn()
                self.setupAlert(title: "Log In!", message: "In order for your data to be saved on the server after deleting the application, you need to log in.", isCancelButton: true, comletionHandler: nil)
                self.userDefaults.set(true, forKey: "WarningKey")
            }
        }
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSignUp" {
            if let vc = segue.destination as? SignUpViewController {
                vc.delegate = self
                vc.isInvalidSignIn = isInvalidSignIn
            }
        }
    }
    
    
    // MARK: - Action -

    @IBAction func signUpButton(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: nil)
        
    }
    
    @IBAction func canselButton(_ sender: Any) {
        
        self.saveRemuveCartProductFB()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func forgotPasswordButton(_ sender: Any) {
        self.sendPasswordReset(title: "We will send you a link to reset your password", placeholder: "Enter your email") { (enteredEmail) in
            Auth.auth().sendPasswordReset(withEmail: enteredEmail) { (error) in
                if error != nil {
                    self.createTopView(textWarning: "Incorrect email. Please try again.", color: .systemRed) { (alertView) in

                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {alertView.frame.origin = CGPoint(x: 0, y: -20)}) { (isFinished) in
                            if isFinished {
                                // возможно придется скрыть cancel button
                                UIView.animate(withDuration: 0.5, delay: 5, options: .curveEaseOut, animations: {alertView.frame.origin = CGPoint(x: 0, y: -64)}, completion: nil)
                            }
                        }
                    }
                } else {
                    self.createTopView(textWarning: "Password was reset. Please check you email.", color: .systemGreen) { (alertView) in

                        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.1, options: .curveEaseIn, animations: {alertView.frame.origin = CGPoint(x: 0, y: -20)}) { (isFinished) in
                            if isFinished {
                                UIView.animate(withDuration: 0.5, delay: 5, options: .curveEaseOut, animations: {alertView.frame.origin = CGPoint(x: 0, y: -64)}, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createTopView(textWarning:String, color: UIColor, comletionHandler: (AlertTopView) -> Void) {
        let alert = AlertTopView(frame: CGRect(origin: CGPoint(x: 0, y: -64), size: CGSize(width: self.view.frame.width, height: 64)))
        alert.setupAlertTopView(labelText: textWarning, backgroundColor: color)
        self.view.addSubview(alert)
        comletionHandler(alert)
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
        //        var anonymusUser: User?
        if let currentUser = currentUser {
            if currentUser.isAnonymous {
                    setupAlert(title: "Log In", message: "You are now an anonymous user!", isCancelButton: true) {
                        self.signIn(anonymous: currentUser)
                    }
                } else {
                    signIn(anonymous: nil)
                }
        }
       
        


    }
    
    
    private func signIn(anonymous: User?) {
        
        button.setTitle("", for: .normal)
        activityIndicator.startAnimating()
        
        // данная логика invalid -> если мы не вспомним логин и пороль для signIn мы удалим
        if let anonymusUser = anonymous {
            let uidUser = anonymusUser.uid
            Database.database().reference().child("usersAccaunt").child(uidUser).removeValue()
        }
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in

            if error != nil {

                let error = error as! AuthErrorCode

                switch error.errorCode {

                case 17011:
                    self?.setupAlert(title: "Error!", message: "Invalid email", isCancelButton: false, comletionHandler: nil)
                    self?.isInvalidSignIn = true
                case 17009:
                    self?.setupAlert(title: "Error!", message: "Invalid password", isCancelButton: false, comletionHandler: nil)
                    self?.isInvalidSignIn = true
                default:
                    self?.setupAlert(title: "Error!", message: "Something went wrong try again", isCancelButton: false, comletionHandler: nil)
                    self?.isInvalidSignIn = true
                    print("что то пошло не так!!!")
                }
            } else {
                self?.setContinueButton(enabled: true)
                self?.button.setTitle("Continue", for: .normal)
                self?.button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                self?.activityIndicator.stopAnimating()
                if let anonymusUser = anonymous {
                    print("delete anonymusUser \(anonymusUser) ")
                    self?.deleteAnonymusUSer(anonymusUser: anonymusUser)
                }
                self?.presentingViewController?.dismiss(animated: true, completion: nil)
            }

//            if result?.user != nil {
//                self?.setContinueButton(enabled: true)
//                self?.button.setTitle("Continue", for: .normal)
//                self?.button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
//                self?.activityIndicator.stopAnimating()
//                if let anonymusUser = anonymous {
//                    print("delete anonymusUser \(anonymusUser) ")
//                    self?.deleteAnonymusUSer(anonymusUser: anonymusUser)
//                }
//                self?.presentingViewController?.dismiss(animated: true, completion: nil)
//            }
        }
    }
    
    
    
    @objc func handleTapDismiss() {
        view.endEditing(true)
    }
    
    // этот селектор вызывается даже когда поднимается keyboard в SignUpVC(SignInVC не умерает когда поверх него ложится SignUpVC)
    @objc func keyboardWillHide(notification: Notification) {
        button.center = buttonCentre
        activityIndicator.center = button.center
    }
    
    // этот селектор вызывается даже когда поднимается keyboard в SignUpVC
    @objc func keyboardWillShow(notification: Notification) {
        
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        button.center = CGPoint(x: view.center.x, y: view.frame.height - keyboardFrame.height - 25 - button.frame.height/2)
        
        activityIndicator.center = button.center
        
    }
    
    
    // MARK: - func -
    
    
    private func deleteAnonymusUSer(anonymusUser:User) {
       
        
        anonymusUser.delete { (error) in
            if error != nil {
            } else {
            }
        }
    }
    
    private func setupAlert(title:String, message:String, isCancelButton: Bool, comletionHandler: (() -> Void)?) {
        
        let allertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            if comletionHandler != nil {
                comletionHandler!()
                
            } else {
                if isCancelButton == false {
                    self?.activityIndicator.stopAnimating()
                    self?.button.setTitle("Continue", for: .normal)
                    self?.button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
                    self?.setContinueButton(enabled: true)
                    
            }
            }
        }
        allertController.addAction(continueAction)
       
        if isCancelButton {
            allertController.addAction(cancelAction)
        }
        
        
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

    
    deinit {
        self.saveRemuveCartProductFB()
    }
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

extension SignInViewController: SignUpViewControllerDelegate {
    
    func saveRemuveCartProductFB() {
       
        if let currentUser = currentUser, currentUser.isAnonymous, isInvalidSignIn {
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
    
    
    func anonymousUserDidRegistered() {
        print("anonymousUserDidRegistered anonymousUserDidRegistered anonymousUserDidRegistered")
        profileDelegate?.userIsPermanent()
    }
}
