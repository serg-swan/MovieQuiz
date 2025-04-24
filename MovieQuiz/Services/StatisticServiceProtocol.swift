//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 16.03.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get } // кол-во завершенных игр
    var bestGame: GameResult { get } // информация о лучшей попытке
    var totalAccuracy: Double { get } // процент правильных ответов за все игры
    func store(correct count: Int, total amount: Int) //  метод для сохранения текущего результата игры
}
