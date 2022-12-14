//
//  ProfileViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//

import UIKit
import FirebaseAuth

    class ProfileViewController: UIViewController {
        
        var signOutButton = UIButton()

        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupButton()
            // Do any additional setup after loading the view.
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            let currentUser = Auth.auth().currentUser
            if let user = currentUser, user.isAnonymous {
                signOutButton.isEnabled = false
            } else {
                signOutButton.isEnabled = true
            }
        }
        
        @objc func didTapsignOutButton() {
           
            do {
                try Auth.auth().signOut()
            } catch {
                print("Что то пошло не так!")
                print(error)
            }
            signOutButton.isEnabled = false
            
            // Сбросить пароль - Forgot password?
//            if let user = currentUser, !user.isAnonymous {
//                if let emailUser = user.email {
//                    Auth.auth().sendPasswordReset(withEmail: emailUser) { (error) in
//                        if error != nil {
//                            print("\(emailUser)")
//                            print("Что то пошло не так попробуйте еще раз! \(String(describing: error))")
//                        }
//                    }
//                }
//            }
        }
        
        func setupButton() {
//
            view.backgroundColor = .systemBackground
            view.addSubview(signOutButton)
            signOutButton.translatesAutoresizingMaskIntoConstraints = false
            
            signOutButton.configuration = .tinted()
            signOutButton.configuration?.title = "SignOutButton"
            signOutButton.configuration?.image = UIImage(systemName: "iphone")
            signOutButton.configuration?.imagePadding = 8
            signOutButton.configuration?.baseForegroundColor = .systemTeal
            signOutButton.configuration?.baseBackgroundColor = .systemTeal
            signOutButton.addTarget(self, action: #selector(didTapsignOutButton), for: .touchUpInside)
            
            
            NSLayoutConstraint.activate([signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor), signOutButton.heightAnchor.constraint(equalToConstant: 50), signOutButton.widthAnchor.constraint(equalToConstant: 280)])
        }
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
        
    }
