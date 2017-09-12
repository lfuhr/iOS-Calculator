//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ludwig Fuhr on 10.09.17.
//  Copyright © 2017 Ludwig Fuhr. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: (numerical: Double, visual: String)?
    var result: Double? { return accumulator?.numerical}
    
    init() {
        setOperand(0)
    }
    
    private struct PendingBinaryOperation {
        let function: (numerical: (Double, Double) -> Double, visual: String)
        let firstOperand: (numerical: Double, visual: String)
        
        func perform(with accumulator: (Double, String)?) -> (Double, String)? {
            if let (numericalSecondOperand, visualSecondOperand) = accumulator {
                let numericalResult = function.numerical(firstOperand.numerical, numericalSecondOperand)
                let visualResult = "\(firstOperand.visual) \(function.visual) \(visualSecondOperand)"
                return (numericalResult, visualResult)
            } else {
                return nil
            }
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending: Bool {
        get {  return pendingBinaryOperation != nil }
    }
    
    var description: String {
        get {
            if let pendingBinaryOperation = pendingBinaryOperation {
                return "\(pendingBinaryOperation.firstOperand.visual) \(pendingBinaryOperation.function.visual) \(accumulator?.visual ?? "") ..."
            } else {
                return accumulator!.visual + " ="
            }
        }
    }
    
    mutating func setOperand(_ operand: Double, displaying symbol: String? = nil) {
        let visualOperand = symbol ?? operand.description // Can be overridden
        accumulator = (operand, visualOperand)
    }
    
    
    mutating func performOperation(_ symbol: String) {
        
        enum Operation {
            case constant(Double)
            case unaryOperation((Double) -> Double)
            case binaryOperation((Double, Double) -> Double)
            case equals
        }
        
        var operations: Dictionary<String,Operation> = [
            "π" : Operation.constant(Double.pi),
            "e" : Operation.constant(M_E),
            "√" : Operation.unaryOperation(sqrt),
            "sin" : Operation.unaryOperation(sin),
            "cos" : Operation.unaryOperation(cos),
            "tan" : Operation.unaryOperation(tan),
            "^" : Operation.binaryOperation(pow),
            "±" : Operation.unaryOperation( - ),
            "×" : Operation.binaryOperation( * ),
            "-" : Operation.binaryOperation( - ),
            "÷" : Operation.binaryOperation( / ),
            "+" : Operation.binaryOperation( + ),
            "=" : Operation.equals
        ]
        
        var changeSymbol = [ "±": "-"]
        
        func performPendingOperation() { accumulator = pendingBinaryOperation?.perform(with: accumulator) ?? accumulator }
        
        if let operation = operations[symbol] {
            let symbol = changeSymbol[symbol] ?? symbol
            
            switch operation {
            case .constant(let value):
                setOperand(value, displaying: symbol)
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator?.numerical = function(accumulator!.numerical)
                    accumulator?.visual = symbol + " ( " + accumulator!.visual + " )"
                }
            case .binaryOperation(let function):
                performPendingOperation()
                if let accumulator = accumulator {
                    pendingBinaryOperation = PendingBinaryOperation(
                        function: (function, symbol), firstOperand: accumulator)
                }
                accumulator = nil
            case .equals:
                performPendingOperation()
                pendingBinaryOperation = nil
            }
        }
    }
}
