//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Сергей Лебедь on 16.03.2025.
//

import Foundation

struct GameResult {
    let correct: Int //кол-во правильных ответов
    let total: Int // кол-во вопросов квиза
    let date: Date // дата завершения раунда
    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}

