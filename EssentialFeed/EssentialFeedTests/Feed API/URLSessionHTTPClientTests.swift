import XCTest

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

private final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        
        let url = URL(string: "https://other-url.com")!

        let session = URLSessionSpy()
        
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
    
        let sut = URLSessionHTTPClient(session: session)

        sut.get(url: url)
                
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private final class URLSessionSpy: URLSession {
                
        private var stubs = [URL: URLSessionDataTaskSpy]()
                
        override func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> URLSessionDataTask {
                        
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        func stub(url: URL, task: URLSessionDataTaskSpy) {
            stubs[url] = task
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
