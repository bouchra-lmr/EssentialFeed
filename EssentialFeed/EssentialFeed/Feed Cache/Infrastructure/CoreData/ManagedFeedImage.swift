//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 12/9/2025.
//

import CoreData

@objc(ManagedFeedImage)
internal class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    internal static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { localFeedImage in
            let managed = ManagedFeedImage(context: context)
            managed.id = localFeedImage.id
            managed.imageDescription = localFeedImage.description
            managed.location = localFeedImage.location
            managed.url = localFeedImage.url
            return managed
        })
        
    }
    
    internal var local: LocalFeedImage {
        return LocalFeedImage(
            id: id,
            description: imageDescription,
            location: location,
            url: url
        )
    }
}
