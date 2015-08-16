//
//  CoreHarmonicModel.swift
//  Harmonic
//
//  Created by Josh Holtz on 7/11/15.
//  Copyright © 2015 Josh Holtz. All rights reserved.
//

import Foundation

import CoreData

struct CoreHarmonicManager {
	static var managedContext: NSManagedObjectContext?
}

protocol CoreHarmonicModel: HarmonicModel {
	
	static var entityName: String { get set }
	
}

extension CoreHarmonicModel {
	
	static func query() {
		guard let managedContext = CoreHarmonicManager.managedContext else { return }
		
		let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
		print("Entity - \(entity)")
	}
	
}