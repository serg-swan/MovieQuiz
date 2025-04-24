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
    
    func showAlert(quiz model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.view.accessibilityIdentifier = model.id
        alert.addAction(action)
        controller?.present(alert, animated: true, completion: nil)
    }
}
