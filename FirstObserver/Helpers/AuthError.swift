//
//  AuthError.swift
//  FirstObserver
//
//  Created by Evgenyi on 6.10.22.
//

import Foundation


enum AuthResult {
    case success
    case failure(Error)
}

enum AuthError {
    case notFilled
    case invalidEmail
    case notEqualPassword
    case serverError
}

// LocalizedError наследуется от Error. Специализированная ошибка, предоставляющая локализованные сообщения с описанием ошибки и причиной ее возникновения.
extension AuthError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .invalidEmail:
            return NSLocalizedString("email_is_not_valid", comment: "")
        case .notEqualPassword:
            return NSLocalizedString("Пароль должен содержать хотя бы одну cтрочную и прописную латинскую букву и одну цифру!", comment: "")
        case .serverError:
            return NSLocalizedString("server_error", comment: "")
        }
    }
}


