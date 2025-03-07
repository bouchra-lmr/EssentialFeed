//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 7/3/2025.
//

import Foundation

public protocol HTTPClient {
            
    func get(from url: URL)
}

public class RemoteFeedLoader {
        
    private let client: HTTPClient
    
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
