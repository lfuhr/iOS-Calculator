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
    
    init() {
        setOperand(0)
    }
    
    private struct PendingBinaryOperation {
        let function: (numerical: (Double, Double) -> Double, visual: String)
        let firstOperand: (numerical: Double, visual: String)
        
        func perform(numerical secondOperand: Double, visual visualSecondOperand: String) -> (Double, String) {
            let numericalResult = function.numerical(firstOperand.numerical, secondOperand)
            let visualResult = "\(firstOperand.visual) \(function.visual) \(visualSecondOperand)"
            return (numericalResult, visualResult)
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
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation( - ),
        "×" : Operation.binaryOperation( * ),
        "-" : Operation.binaryOperation( - ),
        "÷" : Operation.binaryOperation( / ),
        "+" : Operation.binaryOperation( + ),
        "=" : Operation.equals
    ]
    
    private mutating func performPendingBinaryOperation() {
        if resultIsPending && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(numerical: accumulator!.numerical, visual: accumulator!.visual)
            pendingBinaryOperation = nil
            
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                setOperand(value, displaying: symbol)
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator?.numerical = function(accumulator!.numerical)
                    accumulator?.visual = symbol + "( " + accumulator!.visual + " )"
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    
                    if resultIsPending {
                        performPendingBinaryOperation()
                    }
                    
                    pendingBinaryOperation = PendingBinaryOperation(
                        function: (function, symbol), firstOperand: accumulator!)

                }
                accumulator = nil
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    mutating func setOperand(_ operand: Double, displaying symbol: String? = nil) {
        let visualOperand = symbol ?? operand.clean
        accumulator = (operand, visualOperand)
    }
    
    var result: Double? {
        get {
            return accumulator?.numerical
        }
    }
}
