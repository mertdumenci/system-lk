//
//  main.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

// Redundant antecedents.
// x, x ⊢ x
let redundantAntecedents = Sequent(
    antecedents: [.Atomic("x"), .Atomic("x")],
    consequents: [.Atomic("x")]
)

print("Solving \(redundantAntecedents)")
print(prove(sequent: redundantAntecedents) ?? "No proof steps")
print("--")

// Unconditional tautology
// x, !x ⊢
let unconditionalTautology = Sequent(
    antecedents: [.Atomic("x"), .Negation(.Atomic("x"))],
    consequents: []
)

print("Solving \(unconditionalTautology)")
print(prove(sequent: unconditionalTautology) ?? "No proof steps")
print("--")

// Principium tertii exclusi.
// x \lor \not{x}
let lawOfTheExcludedMiddle = Sequent(
    antecedents: [],
    consequents: [
        .Disjunction(
            .Atomic("x"),
            .Negation(.Atomic("x"))
        )
    ])

print("Solving \(lawOfTheExcludedMiddle)")
print("--")
