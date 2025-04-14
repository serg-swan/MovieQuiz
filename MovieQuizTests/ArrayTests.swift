//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Сергей Лебедь on 05.04.2025.
//
import XCTest
import Foundation

@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        let arrey = [1,1,2,3,4,5]
        let value = arrey[safe: 2]
        XCTAssertNotNil(value)
        XCTAssertEqual(value,2)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
        let value = array[safe: 20]
        XCTAssertNil(value)
        
    }
}
