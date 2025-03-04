//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Bouchra Bekkouche on 4/3/2025.
//

import XCTest

protocol HTTPClient {
            
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoader {
        
    let client: HTTPClient
    
    let url: URL
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

class RemoteFeeLoaderTests: XCTest {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClientSpy()
        let url = URL(string: "https://example.com/feed")!
         
        _ = RemoteFeedLoader(client: client, url: url)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func testLoad_requestDataFromURL() {
        
        let client = HTTPClientSpy()
        let url = URL(string: "https://example.com/feed")!
        let sut = RemoteFeedLoader(client: client, url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
        
    }
}
