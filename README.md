# system-lk

`system-lk` is a propositional theorem prover in Swift, based on [Wang's Algorithm](http://www.cs.bham.ac.uk/research/projects/poplog/doc/popteach/wang). I wrote `system-lk` to better understand the inference rules in sequent calculus after reading @joom's [WangsAlgorithm](https://github.com/joom/WangsAlgorithm).

## Author
Mert Dumenci `mert@dumenci.me`

## Usage
```swift
// Construct a `Sequent`.
let lawOfTheExcludedMiddle = Sequent(
    antecedents: [],
    consequents: [
        .Disjunction(
            .Atomic("x"),
            .Negation(.Atomic("x"))
        )
    ]
)

// Prove it using `prove`.
let proof = prove(sequent: lawOfTheExcludedMiddle)
```

## Notes
Check out [WangsAlgorithm](https://github.com/joom/WangsAlgorithm) for a much more complete version of this project. `system-lk` is heavily inspired by `WangsAlgorithm`, and doesn't implement half of its features: LaTeX proof output, parser for sequents, etc.
