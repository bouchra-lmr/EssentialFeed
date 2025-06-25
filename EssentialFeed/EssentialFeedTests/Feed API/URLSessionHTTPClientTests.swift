import XCTest

import EssentialFeed

protocol HTTPSession {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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

        let session = HTTPSessionSpy()
        
        let task = HTTPSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
    
        let sut = URLSessionHTTPClient(session: session)

        sut.get(url: url, completion: { _ in })
                
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let url = URL(string: "https://other-url.com")!
        
        let session = HTTPSessionSpy()
        
        let task = HTTPSessionDataTaskSpy()
        
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
    
    private final class HTTPSessionSpy: HTTPSession {
                
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
                
        func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> HTTPSessionTask {
                        
            guard let stub = stubs[url] else { fatalError("Couldn't find stub for URL: \(url)") }
            
            completionHandler(nil, nil, stub.error)
            
            return stub.task
        }
        
        func stub(
            url: URL,
            task: HTTPSessionTask = FakeURLSessionDataTask(),
            error: Error? = nil
        ) {
            let stub = Stub(task: task, error: error)
            
            stubs[url] = stub
        }
        
    }
    
    private final class FakeURLSessionDataTask: HTTPSessionTask {
        
        func resume() {}
    }
    
    private final class HTTPSessionDataTaskSpy: HTTPSessionTask {
        
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }

}
