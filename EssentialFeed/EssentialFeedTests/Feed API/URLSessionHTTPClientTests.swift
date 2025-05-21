import XCTest

import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            
            if let error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

private final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "https://other-url.com")!

        let session = URLSessionSpy()
        
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
    
        let sut = URLSessionHTTPClient(session: session)

        sut.get(url: url, completion: { _ in })
                
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let url = URL(string: "https://other-url.com")!
        
        let session = URLSessionSpy()
        
        let task = URLSessionDataTaskSpy()
        
        let error = NSError(domain: "ANY ERROR", code: 1)
        
        session.stub(url: url, task: task, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let expectation = expectation(description: "Wait for completion")
        
        sut.get(url: url) { result in
            
            switch result {
            
            case let .failure(receivedError):
                XCTAssertEqual(error, receivedError as NSError)
                
            default:
                XCTFail("Expected failure with error: \(error), got \(result) instead")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private final class URLSessionSpy: URLSession {
                
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
                
        override func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> URLSessionDataTask {
                        
            guard let stub = stubs[url] else { fatalError("Couldn't find stub for URL: \(url)") }
            
            completionHandler(nil, nil, stub.error)
            
            return stub.task
        }
        
        func stub(
            url: URL,
            task: URLSessionDataTask = FakeURLSessionDataTask(),
            error: Error? = nil
        ) {
            let stub = Stub(task: task, error: error)
            
            stubs[url] = stub
        }
        
    }
    
    private final class FakeURLSessionDataTask: URLSessionDataTask {
        
        override func resume() {}
    }
    
    private final class URLSessionDataTaskSpy: URLSessionDataTask {
        
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }

}
