//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Bouchra Bekkouche on 4/3/2025.
//

import XCTest
 import EssentialFeed

class RemoteFeeLoaderTests: XCTest {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
                         
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func testLoad_requestsDataFromURL() {
        
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
        
    }
    
    func testLoadTwice_requestsDataFromURLTwice() {
        
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        client.error = NSError(domain: "Test", code: 0)
         
        var capturedError: RemoteFeedLoader.Error?
        
        sut.load { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com/feed")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        var requestedURLs = [URL]()
        var error: NSError?
        
        func get(
            from url: URL,
            completion: @escaping (Error) -> Void
        ) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
}
