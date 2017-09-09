//
//  Sequent.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

struct Sequent {
    let antecedents: [Proposition]
    let consequents: [Proposition]
}

extension Sequent: CustomStringConvertible {
    var description: String {
        let antecedentDescription = antecedents.map{ $0.description }.joined(separator: ", ")
        let consequentDescription = consequents.map{ $0.description }.joined(separator: ", ")
        
        return "\(antecedentDescription) ⊢ \(consequentDescription)"
    }
}
