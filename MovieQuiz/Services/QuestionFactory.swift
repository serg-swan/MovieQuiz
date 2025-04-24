//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 09.03.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.hideLoadingIndicator()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData()
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomRating = Int.random(in: 6...8)
            let text = "Рейтинг этого фильма больше чем \(randomRating)?"
            let correctAnswer = rating > Float(randomRating)
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(_):
                    self.delegate?.didFailToLoadData() // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
        }
    }
}
