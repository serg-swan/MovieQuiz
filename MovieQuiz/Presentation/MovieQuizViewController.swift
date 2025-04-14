import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - IBOutlet
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad() // Вызов реализации родительского класса
        showLoadingIndicator()
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0) //увеличиваем индикатор
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20 // радиус скругления углов рамки
        alertPresenter = AlertPresenter(controller: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    
    // MARK: - IBAction
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    // MARK: - MovieQuizViewControllerProtocol
   
    
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showResult(quiz result: QuizResultsViewModel) {
            let message = presenter.makeResultsMessage()
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
    
    // метод выключения кнопок
    func buttonLock() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
}
