//
//  ViewController.swift
//  ZoomAndCropImage
//
//  Created by Pankti Patel on 15/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let  kPhotoDiameter: CGFloat = 130.0
    
    var photoFrameView:UIView?
    var  addPhotoButton:UIButton?
    var  didSetupConstraints:Bool?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.navigationController?.navigationBarHidden = true
        
        // ---------------------------
        // Add the frame of the photo.
        // ---------------------------
        
        self.photoFrameView = UIView();
        self.photoFrameView!.backgroundColor = UIColor(red: 182/255.0, green: 182/255.0, blue: 187/255.0, alpha: 1.0)
        self.photoFrameView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.photoFrameView!.layer.masksToBounds = true
        self.photoFrameView!.layer.cornerRadius = (kPhotoDiameter + 2) / 2
        self.view.addSubview(self.photoFrameView!)
        
        // ---------------------------
        // Add the button "add photo".
        // ---------------------------
        
        self.addPhotoButton = UIButton()
        self.addPhotoButton!.backgroundColor = UIColor.whiteColor()
        self.addPhotoButton!.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addPhotoButton!.layer.masksToBounds = true;
        self.addPhotoButton!.layer.cornerRadius = kPhotoDiameter / 2;
        self.addPhotoButton!.imageView!.contentMode = UIViewContentMode.ScaleAspectFit;
        self.addPhotoButton!.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.addPhotoButton!.titleLabel!.textAlignment = NSTextAlignment.Center;
        self.addPhotoButton!.setTitle("add\nphoto" ,forState:UIControlState.Normal)
        self.addPhotoButton!.setTitleColor((UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)), forState:UIControlState.Normal)
        self.addPhotoButton!.addTarget(self, action:"onAddPhotoButtonTouch:" , forControlEvents:UIControlEvents.TouchUpInside)
        self.view.addSubview(self.addPhotoButton!)
        
        // ----------------
        // Add constraints.
        // ----------------
        
        self.view.setNeedsUpdateConstraints()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "photoRecieved:", name:"photoRecieved", object: nil)

        
        
    }
    
    override func updateViewConstraints()
    {
        super.updateViewConstraints()
        
        if (self.didSetupConstraints != nil) {
            return
        }
        
        // ---------------------------
        // The frame of the photo.
        // ---------------------------
        
        var constraint:NSLayoutConstraint = NSLayoutConstraint(item: self.photoFrameView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: (self.photoFrameView!.layer.cornerRadius * 2))
        self.photoFrameView!.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.photoFrameView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: (self.photoFrameView!.layer.cornerRadius * 2))
        
        self.photoFrameView!.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.photoFrameView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.photoFrameView!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        
        
        self.view.addConstraint(constraint)
        
        // ---------------------------
        // The button "add photo".
        // ---------------------------
        
        constraint = NSLayoutConstraint(item: self.addPhotoButton!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: (self.addPhotoButton!.layer.cornerRadius * 2))
        
        
        self.addPhotoButton!.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.addPhotoButton!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: (self.addPhotoButton!.layer.cornerRadius * 2))
        
        
        self.addPhotoButton!.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.addPhotoButton!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.photoFrameView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.addPhotoButton!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.photoFrameView, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        
        self.view.addConstraint(constraint)
        
        self.didSetupConstraints = true;
    }
    
    //#pragma mark - Action handling
    
    func onAddPhotoButtonTouch(sender:UIButton)
    {
        
        let photo:UIImage = UIImage(named: "photo.png")!
        let imageVC:SMUImageCropViewController = SMUImageCropViewController()
        imageVC.initWithImage(originalImage: photo, cropMode: SMUImageCropMode.Circle)
        self.navigationController?.pushViewController(imageVC, animated: true)
    }
    
    func photoRecieved(notification: NSNotification){
     
        let userInfo : Dictionary<String,UIImage> = notification.userInfo as! Dictionary<String,UIImage>
        if !userInfo.isEmpty{
        
            self.addPhotoButton!.setImage(userInfo["image"], forState:UIControlState.Normal)
        }
        
        self.navigationController!.popViewControllerAnimated(true)

    }

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

