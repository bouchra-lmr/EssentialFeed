//
//  CacheFeedUseCaseTests.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 24/8/2025.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    
    var deleteCacheFeedCallCount = 0
    
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        
        let store = FeedStore()
        
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
        
    }
    
}
