//
//  Proof.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

// Proof helpers
func difference(_ left: [Proposition], _ right: [Proposition]) -> [Proposition]? {
    if left.count == 0 || right.count == 0 {
        return nil
    }
    
    var uniqueLeft: [Proposition] = []
    
    for x in left {
        if !right.contains(x) {
            uniqueLeft.append(x)
        }
    }
    
    return uniqueLeft.count > 0 ? uniqueLeft : nil
}

func hasNot(propositions: [Proposition]) -> Int? {
    for (i, prop) in propositions.enumerated() {
        if case .Negation = prop {
            return i
        }
    }
    
    return nil
}

typealias Proof = Inference

func prove(sequent: Sequent) -> Proof? {
    let antecedents = sequent.antecedents
    let consequents = sequent.consequents
    
    // Check equality of the antecedents with the consequents.
    // (Γ ⊢ Γ) true
    if antecedents == consequents {
        return .Linear(nil, .Identity, sequent)
    }
    
    // Try to weaken the antecedents.
    if let difference = difference(antecedents, consequents) {
        var weakenedAntecedents = antecedents
        weakenedAntecedents.remove(at: weakenedAntecedents.index(of: difference.first!)!)
        
        let weakenedSequent = Sequent(
            antecedents: weakenedAntecedents,
            consequents: consequents
        )
        
        return .Linear(prove(sequent: weakenedSequent), .WeakeningLeft, sequent)
    }
    
    // Try to weaken the consequents.
    if let difference = difference(consequents, antecedents) {
        var weakenedConsequents = consequents
        weakenedConsequents.remove(at: weakenedConsequents.index(of: difference.first!)!)
        
        let weakenedSequent = Sequent(
            antecedents: antecedents,
            consequents: weakenedConsequents
        )
        
        return .Linear(prove(sequent: weakenedSequent), .WeakeningRight, sequent)
    }
    
    // Drop the negations in antecedents and move to consequents
    if let notIndex = hasNot(propositions: antecedents) {
        guard case let .Negation(prop) = antecedents[notIndex] else {
            fatalError("Prover hit error state.")
        }

        var newAntecedents = antecedents
        var newConsequents = consequents
        
        newAntecedents.remove(at: notIndex)
        newConsequents.append(prop)
        
        let swappedSequent = Sequent(
            antecedents: newAntecedents,
            consequents: newConsequents
        )
        
        return .Linear(prove(sequent: swappedSequent), .NotLeft, sequent)
    }
    
    // Drop the negations in consequents and move to antecedents
    if let notIndex = hasNot(propositions: consequents) {
        guard case let .Negation(prop) = consequents[notIndex] else {
            fatalError("Prover hit error state.")
        }
        
        var newAntecedents = antecedents
        var newConsequents = consequents
        
        newConsequents.remove(at: notIndex)
        newAntecedents.append(prop)
        
        let swappedSequent = Sequent(
            antecedents: newAntecedents,
            consequents: newConsequents
        )
        
        return .Linear(prove(sequent: swappedSequent), .NotRight, sequent)
    }
    
    return nil
}
