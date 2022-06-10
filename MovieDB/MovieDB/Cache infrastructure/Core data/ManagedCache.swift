//
//  ManagedCache+CoreDataClass.swift
//  MovieDB
//
//  Created by Lidiomar Machado on 27/05/22.
//
//

import Foundation
import CoreData

public class ManagedCache: NSManagedObject {
    @NSManaged public var timestamp: Date?
    @NSManaged public var cache: ManagedLocalMovieRoot?
}

extension ManagedCache {
    internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}
