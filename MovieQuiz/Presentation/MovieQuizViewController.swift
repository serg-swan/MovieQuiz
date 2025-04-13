import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    var alertPresenter: AlertPresenter?
    var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad() // Вызов реализации родительского класса
        showLoadingIndicator()
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0) //увеличиваем индикатор
        //questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
      //  questionFactory?.loadData()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        alertPresenter = AlertPresenter(controller: self)
        statisticService = StatisticService(controller: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
  /*  // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
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
    */
    // MARK: - IBAction
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
    // приватный метод выключения кнопок
    func buttonLock() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
  
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0 //гасим рамку
        //  включаем кнопки
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // приватный метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
        }
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self else { return } // разворачиваем слабую ссылку
            // код, который мы хотим вызвать через 1 секунду
            self.showLoadingIndicator()
            presenter.showNextQuestionOrResults()
        }
    }
    
    func showResult(quiz result: QuizResultsViewModel) {
        var message = result.text
        
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            message = resultMessage
        }
        let model = AlertModel(
            id: "Game results",
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
                self.presenter.restartGame()
        }

        alertPresenter?.showAlert(quiz: model)
        
    }
    
    /*
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // идём в состояние "Результат квиза"
          let text = "_"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResult(quiz: viewModel)
            
        } else {
            self.presenter.switchToNextQuestionIndex()
            self.questionFactory?.requestNextQuestion()
        }
    }
     */
    // метод показа индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    // метод скрытия индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError() {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(
            id: " ",
            title: "Что то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self else { return }
                self.presenter.restartGame()
            }
        showLoadingIndicator()
        alertPresenter?.showAlert(quiz: model)
    }
    
}
