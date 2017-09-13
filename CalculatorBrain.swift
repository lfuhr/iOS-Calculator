//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ludwig Fuhr on 10.09.17.
//  Copyright © 2017 Ludwig Fuhr. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var formula: [Operation] = [Operation.constant(0, "0")]
    
    @available(*, deprecated)
    var result: Double? { return evaluate().result}
    
    mutating func undo() {
        if !formula.isEmpty { formula.removeLast() }
    }
    
    func evaluate(using variables: Dictionary<String,Double> = [:]) -> (result: Double?, isPending: Bool, description: String) {
        
        struct PendingBinaryOperation {
            let perform: (Double) -> Double
            let describe: (String) -> String
            
            func eval(with secondArg: (numerical: Double, visual: String)) -> (Double, String) {
                return (self.perform(secondArg.numerical), self.describe(secondArg.visual))
            }
        }
        var pendingBinaryOperation: PendingBinaryOperation?
        var resultIsPending : Bool { return pendingBinaryOperation != nil }
        
        var accumulator: (numerical: Double, visual: String)?
        
        for operation in formula {
            
            if let acc = accumulator { // Calculator has an argument to perform an operation
                
                switch operation {
                case .unaryOperation(let function, let printer):
                    accumulator = (function(acc.numerical), printer(acc.visual))
                case .binaryOperation(let function, let printer):
                    accumulator = pendingBinaryOperation?.eval(with: acc) ?? acc
                    let acc = accumulator! // update
                    pendingBinaryOperation = PendingBinaryOperation(
                        perform: { function(acc.numerical, $0) }, describe: { printer(acc.visual, $0) })
                    accumulator = nil
                case .equals:
                    accumulator = pendingBinaryOperation?.eval(with: acc) ?? acc
                    pendingBinaryOperation = nil
                default:
                    assert(false)
                }
            } else { // Calculator needs an argument
                
                switch operation {
                case .constant(let value, let symbol):
                    accumulator = (value, symbol)
                case .symbol(let symbol):
                    accumulator = (variables[symbol] ?? 0, symbol)
                default:
                    assert(false)
                }
            }
        }
        
        let description = pendingBinaryOperation?.describe("...") ?? accumulator?.visual.appending(" =") ?? ""
        return (accumulator?.numerical, resultIsPending, description)
    }
    
    @available(*, deprecated)
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    @available(*, deprecated)
    var description: String {
        return evaluate().description
    }
    
    mutating func setOperand(_ operand: Double?, named symbol: String? = nil) {
        if !evaluate().isPending { formula = []}
        if let operand = operand {
            formula.append(Operation.constant(operand, operand.description))
        } else {
            formula.append(Operation.symbol(symbol!))
        }
    }
    
    private enum Operation {
        case constant(Double, String)
        case unaryOperation((Double) -> Double, (String) -> String )
        case binaryOperation((Double, Double) -> Double, (String, String) -> String )
        case equals
        case symbol(String)
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "√"  : Operation.unaryOperation(sqrt,{  "√(\($0))"} ),
        "sin": Operation.unaryOperation(sin, {"cos(\($0))"} ),
        "cos": Operation.unaryOperation(cos, {"cos(\($0))"} ),
        "tan": Operation.unaryOperation(tan, {"tan(\($0))"} ),
        "log": Operation.unaryOperation(log10, {"log(\($0))"} ),
        "±"  : Operation.unaryOperation( - , {  "-(\($0))"} ),
        "cos⁻¹": Operation.unaryOperation(acos, {"cos⁻¹(\($0))"} ),
        "^" : Operation.binaryOperation(pow, {"\($0)^\($1)"}),
        "×" : Operation.binaryOperation( * , {"\($0) x \($1)"} ),
        "-" : Operation.binaryOperation( - , {"\($0) - \($1)"} ),
        "÷" : Operation.binaryOperation( / , {"\($0) ÷ \($1)"} ),
        "+" : Operation.binaryOperation( + , {"\($0) + \($1)"} ),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        switch operations[symbol]! {
        case .constant(let numerical, let visual):
            setOperand(numerical, named: visual)
        case .binaryOperation:
            if case .binaryOperation = formula.last! { undo() }
            fallthrough
        default:
            formula.append(operations[symbol]!)
        }
        
    }
}
