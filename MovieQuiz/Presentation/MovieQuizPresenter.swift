//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 11.04.2025.
//
import UIKit
import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10 // всего вопросов
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex: Int = 0
    private  weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self .viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    // успешная загрузка
    func didLoadDataFromServer() {
      hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    // загрузка не удалась
    func didFailToLoadData() {
        viewController?.showNetworkError() // 
    }
    
    // метод скрытия индикатора загрузки
    func hideLoadingIndicator() {
        viewController?.hideLoadingIndicator()
    }
   
    // MARK:
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
    
   private func didAnswer(isYes: Bool) {
       guard let currentQuestion else {return}
       let givenAnswer = isYes
       viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
       viewController?.buttonLock()
    }
    
    func yesButtonClicked() {
      didAnswer(isYes: true)
    }
    
     func noButtonClicked() {
      didAnswer(isYes: false)
    }
 
    
    // приватный метод, который содержит логику перехода в один из сценариев
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            // идём в состояние "Результат квиза"
          let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.showResult(quiz: viewModel)
            
        } else {
            self.switchToNextQuestionIndex()
            questionFactory?.requestNextQuestion()
        }
    }
   
    func restartGame() {
           currentQuestionIndex = 0
           correctAnswers = 0
           questionFactory?.requestNextQuestion()
       }
}
