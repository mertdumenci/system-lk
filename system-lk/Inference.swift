//
//  Inference.swift
//  system-lk
//
//  Created by Mert Dumenci on 9/8/17.
//  Copyright © 2017 Mert Dumenci. All rights reserved.
//

import Foundation

// System LK (klassische Prädikatenlogik)
enum InferenceRule {
    // Structural rules
    case Identity
    case WeakeningLeft
    case WeakeningRight
    
    // Logical rules
    case NotLeft
    case NotRight
    case AndLeft
    case AndRight
    case OrLeft
    case OrRight
    case ImpliesLeft
    case ImpliesRight
}

indirect enum Inference {
    case Linear(Inference?, InferenceRule, Sequent)
    case Branch(Inference, Inference, InferenceRule, Sequent)
}
