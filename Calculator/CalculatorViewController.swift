//
//  ViewController.swift
//  Calculator
//
//  Created by Ludwig Fuhr on 10.09.17.
//  Copyright © 2017 Ludwig Fuhr. All rights reserved.
//

import UIKit

extension Double {
    var description: String { // override
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var calcMethod: UITextView!
    
    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    private var variables: [String: Double] = [:]
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = newValue.description
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            display.text = display.text! + digit
        }
        else {
            display.text = digit == "." ?  "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    
        
    @IBAction func setMemory(_: Any) {
        variables["M"] = displayValue
        userIsInTheMiddleOfTyping = false
        sync()
    }

    @IBAction func getMemory(_: Any) {
        brain.setOperand(named: "M")
        sync()
    }
    
    @IBAction func undo(_: Any) {
        if userIsInTheMiddleOfTyping {
            let t = display.text!
            display.text!.remove(at: t.index(before: t.endIndex))
        } else {
            brain.undo()
        }
        sync()
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
        }
        
        userIsInTheMiddleOfTyping = false
        brain.performOperation(sender.currentTitle!)
        sync()
    }
    
    private func sync() {
        let tuple = brain.evaluate(using: variables)
        displayValue = tuple.result ?? displayValue
        calcMethod.text = tuple.description
    }
    
    @IBAction func clear(_ sender: Any) {
        display.text = "0"
        calcMethod.text = ""
        brain = CalculatorBrain()
        userIsInTheMiddleOfTyping = false
        variables = [:]
    }
    
}

