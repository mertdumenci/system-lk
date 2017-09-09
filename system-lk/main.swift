//
//  main.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

// Principium tertii exclusi.
// x \lor \not{x}
let sequent = Sequent(
    antecedents: [],
    consequents: [
        .Disjunction(
            .Atomic("x"),
            .Negation(.Atomic("x"))
        )
    ])

print(sequent)

