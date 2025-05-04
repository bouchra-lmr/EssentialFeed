//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 4/5/2025.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
            
    func get(
        from url: URL,
        completion: @escaping (HTTPClientResult) -> Void
    )
    
}
