//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 11.04.2025.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    let questionsAmount: Int = 10 // всего вопросов
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
     func resetQuestionIndex() {
         currentQuestionIndex = 0
    }
    
    func switchToNextQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    // метод конвертации, который принимает моковый вопрос
    // и возвращает вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
}
