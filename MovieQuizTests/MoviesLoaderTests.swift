//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Сергей Лебедь on 05.04.2025.
//
import XCTest
import Foundation

@testable import MovieQuiz


final class MoviesLoaderTests: XCTestCase {
    func testSucessLoading() throws {
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        let expectation = expectation(description: "Loading expectation")
        loader.loadMovies { result in
            switch result {
            case .success(_): //(let movies)?
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            switch result {
            case .success(_):
                XCTFail( "Unexpected success")
                
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
        
    }
}


