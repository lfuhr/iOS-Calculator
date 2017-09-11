//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Ludwig Fuhr on 10.09.17.
//  Copyright © 2017 Ludwig Fuhr. All rights reserved.
//

import Foundation

struct CalculatorBrain {    
    
    private var accumulator: Double?
    
    init() {
        setOperand(0)
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var visualFirstOperand: String
        var visualOperator: String
        
        func perform(numerical secondOperand: Double, visual visualSecondOperand: String) -> (Double, String) {
            let numericalResult = function(firstOperand, secondOperand)
            let visualResult = "\(visualFirstOperand) \(visualOperator) \(visualSecondOperand)"
            return (numericalResult, visualResult)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending: Bool {
        get {  return pendingBinaryOperation != nil }
    }
    
    private var visualAccumulator: String = ""
    
    var description: String {
        get {
            if let pendingBinaryOperation = pendingBinaryOperation {
                return "\(pendingBinaryOperation.visualFirstOperand) \(pendingBinaryOperation.visualOperator) \(visualAccumulator) ..."
            } else {
                return visualAccumulator + " ="
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
            let r = pendingBinaryOperation!.perform(numerical: accumulator!, visual: visualAccumulator)
            accumulator = r.0
            visualAccumulator = r.1
            pendingBinaryOperation = nil
            
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                setOperand(value, displaying: symbol)
            case .unaryOperation(let function):
                if let a = accumulator {
                    accumulator = function(a)
                    visualAccumulator = symbol + "( " + visualAccumulator + " )"
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    
                    if resultIsPending {
                        performPendingBinaryOperation()
                    }
                    
                    pendingBinaryOperation = PendingBinaryOperation(
                        function: function,  firstOperand: accumulator!,
                        visualFirstOperand: visualAccumulator,   visualOperator: symbol)
                    visualAccumulator = ""
                }
                accumulator = nil
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    mutating func setOperand(_ operand: Double, displaying symbol: String? = nil) {
        let visualOperand = symbol ?? operand.clean
        accumulator = operand
        if !resultIsPending {
             visualAccumulator = ""
        }
        visualAccumulator = visualOperand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}
