import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - IBOutlet
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    // MARK: - Private Properties
    private let questionsAmount: Int = 10 // всего вопросов
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0 //счетчик правильных ответов
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad() // Вызов реализации родительского класса
        showLoadingIndicator()
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0) //увеличиваем индикатор
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        alertPresenter = AlertPresenter(controller: self)
        statisticService = StatisticService(controller: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // успешная загрузка
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    // загрузка не удалась
    func didFailToLoadData() {
        showNetworkError() // возьмём в качестве сообщения описание ошибки
    }
    
    // метод скрытия индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - IBAction
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)// Проверяем ответ
        // выключаем кнопки
        buttonLock()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)// Проверяем ответ
        // выключаем кнопки
        buttonLock()
    }
    
    // MARK: - Private Methods
    // приватный метод выключения кнопок
    private func buttonLock() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0 //гасим рамку
        //  включаем кнопки
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self else { return } // разворачиваем слабую ссылку
            // код, который мы хотим вызвать через 1 секунду
            self.showLoadingIndicator()
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n" +
            "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)\n" +
            "Рекорд: \((statisticService?.bestGame.correct ?? 0)) /\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? "" ))\n " +
            "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0.00))%"
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз")
            {[weak self] in
                guard let self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            alertPresenter?.showResult(quiz: viewModel)
            
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    // метод показа индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func showNetworkError() {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Что то пошло не так(",
                               message: "Невозможно загрузить данные",
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.loadData()
        }
        showLoadingIndicator()
        alertPresenter?.showResult(quiz: model)
    }
    
}
