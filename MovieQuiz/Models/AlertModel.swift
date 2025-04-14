//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 13.03.2025.
//

import Foundation

struct AlertModel {
    let id: String
    let title: String
    let message: String
    let buttonText: String
    var completion: (() -> Void)?
}
