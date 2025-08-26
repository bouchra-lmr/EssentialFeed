//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 26/8/2025.
//
import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
