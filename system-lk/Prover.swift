//
//  Proof.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

typealias Proof = Inference

/**
 * Takes the set difference of `left` and `right`.
 */
fileprivate func -(left: PropositionList, right: PropositionList) -> PropositionList? {
    if left.count == 0 || right.count == 0 {
        return nil
    }
    
    var uniqueLeft = left
    for prop in right {
        if let idx = left.index(of: prop) {
            uniqueLeft.remove(at: idx)
        }
    }
    
    return uniqueLeft
}

/**
 * Attempts to prove a sequent. (Might return an incomplete proof.)
 *
 * Applies the inference rules bottom-up in a backwards manner, trying to reach an
 * axiomatic sequent. If it can find one, the sequent is proven since one can
 * apply the same inference rules in top-down order and reach the initial sequent
 * from an axiom.
 */
fileprivate func tryProve(sequent: Sequent) -> Proof? {
    var antecedents = sequent.antecedents
    var consequents = sequent.consequents
    
    // Try to apply the `Identity` inference rule bottom-up.
    // Check equality of the antecedents with the consequents.
    if antecedents == consequents {
        //
        // ------------- (Id)
        //     Γ ⊢ Γ
        //
        return .Linear(
            nil,
            .Identity,
            sequent
        )
    }
    
    // Try to apply the `WeakeningLeft` inference rule bottom-up.
    if let difference = antecedents - consequents,
        difference != antecedents {
        // Since we're applying the inference rule bottom-up, we need to strengthen
        // the antecedents as we know that it's weakened (antecedents - consequents ≠ ∅)
        antecedents.remove(at: antecedents.index(of: difference.first!)!)
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: If Γ concludes Δ, then Γ and A also concludes Δ.
        //
        //     Γ ⊢ Δ
        // ------------- (WL)
        //    Γ, A ⊢ Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .WeakeningLeft,
            sequent
        )
    }
    
    // Try to apply the `WeakeningRight` inference rule bottom-up.
    if let difference = consequents - antecedents,
        difference != consequents {
        // Since we're applying the inference rule bottom-up, we need to strengthen
        // the consequents as we know that it's weakened (consequents - antecedents ≠ ∅)
        consequents.remove(at: consequents.index(of: difference.first!)!)
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: If Γ concludes Δ, then Γ also concludes Δ or A.
        //
        //     Γ ⊢ Δ
        // ------------- (WR)
        //    Γ ⊢ A, Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .WeakeningRight,
            sequent
        )
    }
    
    // Try to apply the `NotLeft` inference rule bottom-up.
    if let index = antecedents.index(where: { $0.isNegation }) {
        // Unpack the negated proposition.
        // ¬A -> A
        guard case let .Negation(prop) = antecedents[index] else {
            fatalError("Prover hit error state.")
        }
        
        antecedents.remove(at: index)
        consequents.append(prop)
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: If Γ concludes A or Δ, then Γ and ¬A
        // concludes Δ.
        //
        //   Γ ⊢ A, Δ
        // ------------- (¬L)
        //   Γ, ¬A ⊢ Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .NotLeft,
            sequent
        )
    }
    
    // Try to apply the `NotRight` inference rule bottom-up.
    if let index = consequents.index(where: { $0.isNegation }) {
        // Unpack the negated proposition.
        // ¬A -> A
        guard case let .Negation(prop) = consequents[index] else {
            fatalError("Prover hit error state.")
        }
        
        consequents.remove(at: index)
        antecedents.append(prop)
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: If Γ and A concludes Δ, then Γ concludes Δ or ¬A.
        //
        //   Γ, A ⊢ Δ
        // ------------- (¬R)
        //   Γ ⊢ ¬A, Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .NotRight,
            sequent
        )
    }
    
    // Try to apply the `AndLeft` inference rule bottom-up.
    if let index = antecedents.index(where: { $0.isConjunction }) {
        // Unpack the connected propositions.
        // A ∧ B -> A, B
        guard case let .Conjunction(a, b) = antecedents[index] else {
            fatalError("Prover hit error state.")
        }
        
        antecedents.remove(at: index)
        antecedents.append(contentsOf: [a, b])
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: The comma in the antecedents can be read as 'and',
        // hence the drop of ∧.
        //
        //  Γ, A, B ⊢ Δ
        // ------------- (∧L)
        // Γ, (A ∧ B) ⊢ Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .AndLeft,
            sequent
        )
    }
    
    // Try to apply the `OrRight` inference rule bottom-up.
    if let index = consequents.index(where: { $0.isDisjunction }) {
        // Unpack the connected propositions.
        // A ∨ B -> A, B
        guard case let .Disjunction(a, b) = consequents[index] else {
            fatalError("Prover hit error state.")
        }
        
        consequents.remove(at: index)
        consequents.append(contentsOf: [a, b])
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: The comma in the consequents can be read as 'or',
        // hence the drop of ∨.
        //
        //  Γ ⊢ A, B, Δ
        // ------------- (∨R)
        // Γ ⊢ (A ∨ B), Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .OrRight,
            sequent
        )
    }
    
    // Try to apply the `ImpliesRight` inference rule bottom-up.
    if let index = consequents.index(where: { $0.isConditional }) {
        // Unpack the connected propositions.
        // A → B -> A, B
        guard case let .Conditional(a, b) = consequents[index] else {
            fatalError("Prover hit error state.")
        }
        
        consequents.remove(at: index)
        antecedents.append(a)
        consequents.append(b)
        
        let inferredFrom = Sequent(
            antecedents: antecedents,
            consequents: consequents
        )
        
        // Intuition: The turnstile in the sequent can be read as 'implies',
        // hence the drop of '→'.
        //
        //  Γ, A ⊢ B, Δ
        // ------------- (→R)
        // Γ ⊢ (A → B), Δ
        //
        return .Linear(
            tryProve(sequent: inferredFrom),
            .ImpliesRight,
            sequent
        )
    }
    
    // Try to apply the `OrLeft` inference rule bottom-up.
    if let index = antecedents.index(where: { $0.isDisjunction }) {
        // Unpack the connected propositions.
        // A ∨ B -> A, B
        guard case let .Disjunction(a, b) = antecedents[index] else {
            fatalError("Prover hit error state.")
        }
        
        antecedents.remove(at: index)
        
        let leftAntecedents = antecedents + [a]
        let rightAntecedents = antecedents + [b]
        
        let leftSequent = Sequent(
            antecedents: leftAntecedents,
            consequents: consequents
        )
        
        let rightSequent = Sequent(
            antecedents: rightAntecedents,
            consequents: consequents
        )
        
        // Intuition: If A concludes Δ and B concludes Π,
        // then A or B concludes Δ or Π.
        //
        //  Γ, A ⊢ Δ          Σ, B ⊢ Π
        // ----------------------------- (∨L)
        //     Γ, Σ, (A ∨ B) ⊢ Δ, Π
        //
        return .Branch(
            tryProve(sequent: leftSequent),
            tryProve(sequent: rightSequent),
            .OrLeft,
            sequent
        )
    }
    
    // Try to apply the `AndRight` inference rule bottom-up.
    if let index = consequents.index(where: { $0.isConjunction }) {
        // Unpack the connected propositions.
        // A ∧ B -> A, B
        guard case let .Conjunction(a, b) = consequents[index] else {
            fatalError("Prover hit error state.")
        }
        
        consequents.remove(at: index)
        
        let leftConsequents = consequents + [a]
        let rightConsequents = consequents + [b]
        
        let leftSequent = Sequent(
            antecedents: antecedents,
            consequents: leftConsequents
        )
        
        let rightSequent = Sequent(
            antecedents: antecedents,
            consequents: rightConsequents
        )
        
        // Intuition: If Γ concludes A and Σ concludes B,
        // Γ and Σ conclude A and B.
        //
        //  Γ ⊢ A, Δ           Σ ⊢ B, Π
        // ----------------------------- (∧R)
        //     Γ, Σ ⊢ (A ∧ B), Δ, Π
        //
        return .Branch(
            tryProve(sequent: leftSequent),
            tryProve(sequent: rightSequent),
            .AndRight,
            sequent
        )
    }
    
    // Try to apply the `ImpliesLeft` inference rule bottom-up.
    if let index = antecedents.index(where: { $0.isConditional }) {
        // Unpack the connected propositions.
        // A → B -> A, B
        guard case let .Conditional(a, b) = antecedents[index] else {
            fatalError("Prover hit error state.")
        }
        
        antecedents.remove(at: index)
        
        let leftConsequents = consequents + [a]
        let rightAntecedents = antecedents + [b]
        
        let leftSequent = Sequent(
            antecedents: antecedents,
            consequents: leftConsequents
        )
        
        let rightSequent = Sequent(
            antecedents: rightAntecedents,
            consequents: consequents
        )
        
        // Intuition: If we can conclude A, we can assume B.
        //
        //  Γ ⊢ A, Δ           Σ, B ⊢ Π
        // ----------------------------- (→L)
        //     Γ, Σ, (A → B) ⊢ Δ, Π
        //
        return .Branch(
            tryProve(sequent: leftSequent),
            tryProve(sequent: rightSequent),
            .ImpliesLeft,
            sequent
        )
    }
    
    return nil
}

/**
 * Checks if a given proof attempt is complete/successful.
 */
func checkCompleteness(maybeProof: Proof?) -> Bool {
    guard let maybeProof = maybeProof else {
        return false
    }
    
    // Checks if the first inference rule[s] (top-down) are `Identity`.
    // If not, the prover couldn't prove `sequent`.
    switch (maybeProof) {
    case let .Linear(i, r, _):
        if case .Identity = r {
            return true
        }
        
        return checkCompleteness(maybeProof: i)
    case let .Branch(il, ir, r, _):
        if case .Identity = r {
            return true
        }
        
        return checkCompleteness(maybeProof: il)
            || checkCompleteness(maybeProof: ir)
    }
}

/**
 * Attempts to prove a sequent. Wraps around `tryProve` to check
 * for proof completion, and returns `nil` for incomplete proof
 * attempts.
 */
func prove(sequent: Sequent) -> Proof? {
    // Try to prove `sequent`.
    let maybeProof = tryProve(sequent: sequent)
    
    // Check for the completeness of `maybeProof`.
    return checkCompleteness(maybeProof: maybeProof) ? maybeProof : nil
}
