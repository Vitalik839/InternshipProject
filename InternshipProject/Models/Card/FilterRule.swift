//
//  FilterRule.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 27.07.2025.
//

import Foundation


enum FilterType: Codable, Hashable {
    case textContains(String)
    
    case numberRange(start: Double?, end: Double?)
    
    case dateRange(start: Date?, end: Date?)
    
    case selectionContains(Set<String>)
    
    case isNotEmpty
}
