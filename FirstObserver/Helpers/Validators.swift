//
//  Validators.swift
//  FirstObserver
//
//  Created by Evgenyi on 6.10.22.
//

import Foundation

class Validators {
    
    static func isFilled(name: String?, email: String?, password: String?, reNamePassword: String?) -> Bool {
        
        guard !(name ?? "").isEmpty, !(email ?? "").isEmpty, !(password ?? "").isEmpty, !(reNamePassword ?? "").isEmpty else {return false}
        
        return true
    }
    
    static func isReNamePassword(password: String?, reNamePassword: String?) -> Bool {
        guard password == reNamePassword else {return false}
        return true
    }
    
    static func isValidEmailAddr(strToValidate: String) -> Bool {
      let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"

      let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)

      return emailValidationPredicate.evaluate(with: strToValidate)
    }
    
    // мы проверяем, содержит ли пароль хотя бы одну cтрочную и прописную латинскую букву, цифру.
    static func isValidPassword(passwordText: String) -> Bool {
        let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?!.*\\s).*$")
        let isBool = password.evaluate(with: passwordText)
        print("isValidPassword \(isBool)")
        return password.evaluate(with: passwordText)
    }
}

