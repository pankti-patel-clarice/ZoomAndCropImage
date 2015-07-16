//
//  SMUImageExtension.swift
//  ZoomAndCropImage
//
//  Created by Pankti Patel on 15/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    func fixOrientation() -> UIImage{
        
        // No-op if the orientation is already correct.
        if (imageOrientation == UIImageOrientation.Up) {
            return self;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransformIdentity;
        
        switch (self.imageOrientation) {
        case UIImageOrientation.Down:
            break
        case UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI));
            break;
            
        case UIImageOrientation.Left:
            break
        case UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2));
            break;
            
        case UIImageOrientation.Right:
            break
        case UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2));
            break;
        case UIImageOrientation.Up:
            break
        case UIImageOrientation.UpMirrored:
            break;
        }
        
        switch (self.imageOrientation) {
        case UIImageOrientation.UpMirrored:
            break
        case UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientation.LeftMirrored:
            break
        case UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientation.Up:
            break
        case UIImageOrientation.Down:
            break
        case UIImageOrientation.Left:
            break
        case UIImageOrientation.Right:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)

        let ctx = CGBitmapContextCreate(nil,CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage), CGImageGetBitsPerComponent(self.CGImage), 0, colorSpace, bitmapInfo)
        
        CGContextConcatCTM(ctx, transform);
        switch (self.imageOrientation) {
        case UIImageOrientation.Left:
            break
        case UIImageOrientation.LeftMirrored:
            break
        case UIImageOrientation.Right:
            break
        case UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
        }
        
        // And now we just create a new UIImage from the drawing context.
        var cgimg:CGImageRef = CGBitmapContextCreateImage(ctx);
        var img:UIImage = UIImage(CGImage: cgimg)!
        
        return img;


    }
    
    func rotateByAngle(angleInRadians:CGFloat) -> UIImage{
        
        var contextSize:CGSize = self.size;
        
        UIGraphicsBeginImageContextWithOptions(contextSize, false, self.scale);
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        
        CGContextTranslateCTM(context, 0.5 * contextSize.width, 0.5 * contextSize.height);
        CGContextRotateCTM(context, angleInRadians);
        CGContextTranslateCTM(context, -0.5 * contextSize.width, -0.5 * contextSize.height);
        self.drawAtPoint(CGPointZero)
        
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;

    }
}