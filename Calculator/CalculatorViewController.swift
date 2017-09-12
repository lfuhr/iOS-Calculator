//
//  ViewController.swift
//  Calculator
//
//  Created by Ludwig Fuhr on 10.09.17.
//  Copyright © 2017 Ludwig Fuhr. All rights reserved.
//

import UIKit

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    @IBOutlet weak var calcMethod: UITextView!
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = newValue.clean
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let maybenewDisplaytext = display.text! + digit
            if Double(maybenewDisplaytext) != nil {
                display.text = maybenewDisplaytext
            }
        }
        else {
            display.text = digit == "." ?  "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        brain.performOperation(sender.currentTitle!)
            
        if let result = brain.result {
            displayValue = result
        }
        calcMethod.text = brain.description
    }
    
    
    @IBAction func clear(_ sender: Any) {
        display.text = "0"
        calcMethod.text = ""
        brain = CalculatorBrain()
        userIsInTheMiddleOfTyping = false
    }
    
}

