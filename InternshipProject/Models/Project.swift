//
//  Project.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 18.07.2025.
//

import Foundation

struct Project {
    let id: UUID
    var name: String
    var tasks: [TaskCard] = []
}
