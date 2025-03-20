//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 16.03.2025.
//

import Foundation
final class StatisticService: StatisticServiceProtocol {
    weak var controller: MovieQuizViewController? // Инъектируем контроллер
    init(controller: MovieQuizViewController) {
        self.controller = controller
    }
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct = "correct"
        case total = "total"
        case date = "date"
        case gamesCount = "gamesCount"
        case correctAnswers = "correctAnswers"
        case totalAccuracy = "totalAccuracy"
    }
    private var correctAnswers: Int {  // переменная хранения общего кол-ва правильных ответов
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return   GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    var totalAccuracy: Double {
        if gamesCount > 0 {
            return  Double( correctAnswers) / Double(gamesCount * 10) * 100
        } else {
            return 0.0 // Возвращаем 0, если игр не было
        }
    }
    
    func store(correct count: Int, total amount: Int) { // метод мохранения текушего результата игры
        gamesCount += 1 // увеличиваем счетчик игр за все время
        correctAnswers += count //увеличиваем счетчик правильных ответов за все время
        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
        
    }
    
}

