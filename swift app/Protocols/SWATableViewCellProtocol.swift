//
//  SWATableViewCellProtocol.swift
//  swift app
//
//  Created by Carlos Knopel on 3/26/20.
//  Copyright © 2020 Carlos Knopel. All rights reserved.
//

import Foundation

protocol SWATableViewCellProtocol {
    associatedtype ConfigurableObject
    func configureCell(_ object: ConfigurableObject)
}
