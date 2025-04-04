//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 10.03.2025.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData() // сообщение об ошибке загрузки
    func hideLoadingIndicator()
}
