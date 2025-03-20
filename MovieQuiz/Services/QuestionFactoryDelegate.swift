//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 10.03.2025.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
