//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Bouchra Bekkouche on 4/3/2025.
//

import XCTest
import EssentialFeed

class RemoteFeeLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        
        let url = URL(string: "https://example.com/feed")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        
    }
    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)

        expect(
            sut: sut,
            toCompleteWith: .failure(.connectivity),
            when: {
                client.complete(with: clientError)
            }
        )
    }
    
    func test_load_deliversErrorOnNon200Error() {
        
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(
                sut: sut,
                toCompleteWith: .failure(.invalidData),
                when: {
                    let json = makeItemsJSON([])
                    client.complete(withStatusCode: code, data: json, at: index)
                }
            )
        }
    }
    
    func test_load_deliversErrorOn200HTTPReponseWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(
            sut: sut,
            toCompleteWith: .failure(.invalidData),
            when: {
                let invalidJSON = Data("Invalid JSON".utf8)
                
                client.complete(withStatusCode: 200, data: invalidJSON)
            }
        )
    }
    
    func test_load_deliversNoItemsOn200HTTPReponseWithEmptyJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(
            sut: sut,
            toCompleteWith: .success([]),
            when: {
                let emptyListJSON = makeItemsJSON([])
                client.complete(withStatusCode: 200, data: emptyListJSON)
            }
        )
    }
    
    func test_load_deliversItemsOn200HTTPReponseWithValidJSON() {
        
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!
        )
        
        let items = [item1, item2]
        
        expect(
            sut: sut,
            toCompleteWith: .success(items.map(\.model)),
            when: {
                let jsonData = makeItemsJSON([item1.json, item2.json] )
                
                client.complete(
                    withStatusCode: 200,
                    data: jsonData
                )
            }
        )
        
    }
        
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://example.com/feed")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, client)
    }
    
    private func trackForMemoryLeaks(
        _ instance: AnyObject?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance,
                "Instance should have been dealocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
    
    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
    ) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data  {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(
        sut: RemoteFeedLoader,
        toCompleteWith result: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(
            capturedResults,
            [result],
            file: file,
            line: line
        )
    }
    
    class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
                
        func get(
            from url: URL,
            completion: @escaping (HTTPClientResult) -> Void
        ) {
            
            messages.append((url, completion))
            
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
            
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
}
