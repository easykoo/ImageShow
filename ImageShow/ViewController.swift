//
//  ViewController.swift
//  ImageShow
//
//  Created by Steven on 9/19/14.
//  Copyright (c) 2014 Steven. All rights reserved.
//

import UIKit

let IP = "IP"
let NAME = "NAME"

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var ipField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var btn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.btn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
//        self.btn.layer.backgroundColor = UIColor(red: 134, green: 270, blue: 134, alpha: 100).CGColor
//        self.btn.layer.cornerRadius = 5
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        self.ipField.text = userDefaults.stringForKey(IP)
        self.nameField.text = userDefaults.stringForKey(NAME)
        self.ipField.delegate = self
        self.nameField.delegate = self
        
        UIApplication.sharedApplication().idleTimerDisabled = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func show(sender: UIButton) {
        self.nameField.resignFirstResponder()
    }
    func saveInfo() {
        self.correctInfo()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if self.ipField.text != nil {
            userDefaults.setObject(self.ipField.text as String, forKey: IP)
        }
        if self.nameField.text != nil {
            userDefaults.setObject(self.nameField.text as String, forKey: NAME)
        }
        userDefaults.synchronize()
    }
    
    func correctInfo() {
        self.ipField.text = self.ipField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.nameField.text = self.nameField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        self.saveInfo()
        
        var error : NSError?
        let url:NSURL = NSURL(string: "http://\(self.ipField.text!)/pad/\(self.nameField.text!)/info")!
   
        var request = NSURLRequest(URL:url)
        
        var response = NSURLConnection.sendSynchronousRequest(request, returningResponse:nil, error:&error)
        if error != nil {
            println(error)
            let alert = UIAlertView()
            alert.title = "错误"
            alert.message = "连接不上服务器!"
            alert.addButtonWithTitle("确定")
            alert.show()
            return false;
        }
        if response != nil {
            
            let res = JSONValue(response)
            switch res{
            case .JInvalid:
                let alert = UIAlertView()
                alert.title = "错误"
                alert.message = "服务器错误!"
                alert.addButtonWithTitle("确定")
                alert.show()
                return false;
            default:
                let success = res["success"].bool
                if !success! {
                    let alert = UIAlertView()
                    alert.title = "错误"
                    alert.message = "此IPad未登记!"
                    alert.addButtonWithTitle("确定")
                    alert.show()
                    return false;
                }
            }
        } else {
            let alert = UIAlertView()
            alert.title = "错误"
            alert.message = "连接不上服务器!"
            alert.addButtonWithTitle("确定")
            alert.show()
            return false;
        }

        
        return true;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "display" {
            if segue.destinationViewController.isKindOfClass(ShowController) {
                var displayer = segue.destinationViewController as ShowController
                displayer.ip = self.ipField.text
                displayer.name = self.nameField.text
            }
        }
    }
}

