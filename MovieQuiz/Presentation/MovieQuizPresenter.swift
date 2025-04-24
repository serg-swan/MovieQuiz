//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 11.04.2025.
//
import UIKit
import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private Properties
    
    private var currentQuestion: QuizQuestion?
    private  let questionsAmount: Int = 10 // всего вопросов
    private var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex: Int = 0
    private  weak var viewController: MovieQuizViewControllerProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Initializers
    
    init(viewController: MovieQuizViewControllerProtocol?) {
        self .viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        statisticService = StatisticService(controller: self)
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
        viewController?.showNetworkError()
    }
    
    // метод скрытия индикатора загрузки
    func hideLoadingIndicator() {
        viewController?.hideLoadingIndicator()
    }
    
    // MARK: - Public Methods
    
    func showLoadingIndicator(){
        viewController?.showLoadingIndicator()
    }
    
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
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        buttonLock()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    func buttonLock() {
        viewController?.buttonLock()
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        guard let statisticService else {
            return ""
        }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        return [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
    }
    
    // MARK: - Private Methods
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func proceedToNextQuestionOrResults() {
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
    
    // приватный метод, который меняет цвет рамки
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self else { return } // разворачиваем слабую ссылку
            // код, который мы хотим вызвать через 1 секунду
            showLoadingIndicator()
            proceedToNextQuestionOrResults()
        }
    }
}

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResult(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError()
    func buttonLock()
    
}


