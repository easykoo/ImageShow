//
//  ImageController.swift
//  ImageShow
//
//  Created by Steven on 9/19/14.
//  Copyright (c) 2014 Steven. All rights reserved.
//

import UIKit
import Alamofire


class ShowController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    var ip:String!
    var name:String!
    var timer : NSTimer?
    var info : String?
    var color : String?
    var imageArray : NSMutableArray?
    var pictures : String?
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if touches.count > 3 {
            self.timer = nil
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().idleTimerDisabled = true;
        self.view.multipleTouchEnabled = true
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        YLGIFImage.setPrefetchNum(5)
        checkInfo()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector:Selector("checkInfo"), userInfo:nil, repeats:true);
    }
    
    func checkInfo() {
        var error : NSError?
        let url:NSURL = NSURL(string: "http://\(self.ip!)/pad/\(self.name!)/info")!
        var request = NSURLRequest(URL:url)
        var response = NSURLConnection.sendSynchronousRequest(request, returningResponse:nil, error:&error)
        if error != nil {
            println(error)
            return
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
                return
            default:
                let success = res["success"].bool
                if !success! {
                    return
                }
            }
            
            var pad = res["Pad"]
            var info = pad["Description"].string
            if self.info == nil || !(info == self.info!) {
                self.info = info
                updateInfo()
            }
            
            var color = pad["Color"].string
            if self.color == nil || !(color == self.color!) {
                self.color = color
                updateColor()
            }
            
            var pictures = pad["pictures"].string
            if self.pictures == nil || !(pictures == self.pictures!) {
                self.pictures = pictures
                updateImage()
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func updateInfo() {
        self.infoLabel.text = self.info
    }
    
    func updateColor() {
        self.infoLabel.textColor = getColor(self.color!)
    }
    
    func updateImage() {
        var error : NSError?
        let url:NSURL = NSURL(string: "http://\(self.ip!)\(self.imageUrl!)")!
        var request = NSURLRequest(URL:url)
        var response = NSURLConnection.sendSynchronousRequest(request, returningResponse:nil, error:&error)
        if error != nil {
            println(error)
            return
        }
        if response != nil {
            if self.imageUrl!.hasSuffix(".gif") {
                imageView.image = YLGIFImage(data: response!)
            } else {
                self.imageView.image = UIImage(data: response!)
            }
        }
    }
    
    func getColor(color:NSString) -> UIColor{
        switch color {
        case "red": return UIColor.redColor()
        case "black":return UIColor.blackColor()
        case "white":return UIColor.whiteColor()
        case "blue":return UIColor.blueColor()
        case "yellow":return UIColor.yellowColor()
        case "gray":return UIColor.grayColor()
        case "green":return UIColor.greenColor()
        default: return UIColor.blackColor()
        }
    }
    
}