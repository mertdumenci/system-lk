//
//  main.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

func solver(sequents: [Sequent]) -> [Proof?] {
    return sequents.map { sequent in
        print("Proving sequent: \(sequent)")
        let proof = prove(sequent: sequent)
        print("Proof:")
        print(proof?.description ?? "No proof found.")
        print("---")
        
        return proof
    }
}

let tautologies = [
    // x, x ⊢ x
    Sequent(
        antecedents: [.Atomic("x"), .Atomic("x")],
        consequents: [.Atomic("x")]
    ),
    // x, !x ⊢
    Sequent(
        antecedents: [.Atomic("x"), .Negation(.Atomic("x"))],
        consequents: []
    ),
    // ⊢ x ∨ ¬x
    Sequent(
        antecedents: [],
        consequents: [
            .Disjunction(
                .Atomic("x"),
                .Negation(.Atomic("x"))
            )
        ]
    ),
    // ¬(p ∧ q) ⊢ ¬p ∨ ¬q
    Sequent(
        antecedents: [
            .Negation(
                .Conjunction(
                    .Atomic("p"),
                    .Atomic("q")
                )
            )
        ],
        consequents: [
            .Disjunction(
                .Negation(
                    .Atomic("p")
                ),
                .Negation(
                    .Atomic("q")
                )
            )
        ]
    )
]

let proofs = solver(sequents: tautologies)

