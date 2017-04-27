//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hector Villarreal on 4/24/17.
//  Copyright © 2017 HVS. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var resultIsPending = false
    private var description = " "
    
    private enum Operation {
        case constant(Double)  // associated values in enums...
        case unaryOperation((Double) -> Double)  // function is also a type in swift.
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),  // you can set the associated value of the enum.
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "%": Operation.unaryOperation({ $0 / 100 }),
        "±": Operation.unaryOperation({ -$0 }),
        "x²": Operation.unaryOperation({ $0 * $0 }),
        "×": Operation.binaryOperation({ $0 * $1 }),
        "÷": Operation.binaryOperation({ $0 / $1 }),
        "-": Operation.binaryOperation({ $0 - $1 }),
        "+": Operation.binaryOperation({ $0 + $1 }),
        "mod": Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }),
        "=": Operation.equals,
        "C": Operation.clear
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):  // this way we set the associated value
                accumulator = value
            case .unaryOperation(let function):
                if accumulator == nil { break }
                
                accumulator = function(accumulator!)
            case .binaryOperation(let function):
                if accumulator == nil { break }
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                accumulator = nil
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                accumulator = nil
                
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation == nil || accumulator == nil { return }
    
        accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        pendingBinaryOperation = nil
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
}
