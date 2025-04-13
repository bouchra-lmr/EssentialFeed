//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 7/3/2025.
//

import Foundation

public protocol HTTPClient {
            
    func get(
        from url: URL,
        completion: @escaping (Error) -> Void
    )
}

public class RemoteFeedLoader {
        
    private let client: HTTPClient
    
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
