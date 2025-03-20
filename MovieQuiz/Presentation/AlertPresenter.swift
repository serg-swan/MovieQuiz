//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 12.03.2025.
//

import Foundation
import UIKit
final class AlertPresenter {
    weak var controller: MovieQuizViewController? // Инъектируем контроллер
    init(controller: MovieQuizViewController) {
        self.controller = controller
    }
    
     func showResult(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion?()
        }
        
        alert.addAction(action)
        controller?.present(alert, animated: true, completion: nil)
    }
}
