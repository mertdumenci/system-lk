//
//  Proposition.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

indirect enum Proposition {
    case Atomic(String)
    case Negation(Proposition)
    case Conjunction(Proposition, Proposition)
    case Disjunction(Proposition, Proposition)
    case Conditional(Proposition, Proposition)
}

extension Proposition: Equatable {
    static func ==(lhs: Proposition, rhs: Proposition) -> Bool {
        switch(lhs, rhs) {
        case let (.Atomic(p1), .Atomic(p2)): return p1 == p2
        case let (.Negation(p1), .Negation(p2)): return p1 == p2
        case let (.Conjunction(l1, r1), .Conjunction(l2, r2)): return l1 == l2 && r1 == r2
        case let (.Disjunction(l1, r1), .Disjunction(l2, r2)): return l1 == l2 && r1 == r2
        case let (.Conditional(l1, r1), .Conditional(l2, r2)): return l1 == l2 && r1 == r2
        case (.Atomic, _),
             (.Negation, _),
             (.Conjunction, _),
             (.Disjunction, _),
             (.Conditional, _):
            return false
        }
    }
}

extension Proposition: CustomStringConvertible {
    var description: String {
        switch(self) {
        case .Atomic(let p):
            return p
        case .Negation(let p):
            return "¬\(p)"
        case .Conjunction(let l, let r):
            return "(\(l)) ∧ (\(r))"
        case .Disjunction(let l, let r):
            return "(\(l)) ∨ (\(r))"
        case .Conditional(let a, let c):
            return "(\(a)) → (\(c))"
        }
    }
}
