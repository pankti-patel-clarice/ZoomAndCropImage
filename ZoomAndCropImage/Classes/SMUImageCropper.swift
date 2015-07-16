//
//  SMUImageCropper.swift
//  ZoomAndCropImage
//
//  Created by Pankti Patel on 15/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.
//

import Foundation
import CoreGraphics
import Darwin

public struct SMULineSegment {
    var start:CGPoint;
    var end:CGPoint;
}

class SMUImageCropper {
    
    static let sharedInstance = SMUImageCropper()

    let SMUPointNull:CGPoint =  CGPointZero

    func SMURectCenterPoint(rect:CGRect) -> CGPoint{
        
        return CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect)/2, CGRectGetMinY(rect) + CGRectGetHeight(rect) / 2)
        
    }
    
    func SMURectScaleAroundPoint (var rect :CGRect , point:CGPoint , sx:CGFloat, sy:CGFloat) -> CGRect{
        
        var translationTransform:CGAffineTransform?
        var scaleTransform:CGAffineTransform?
        rect = CGRectApplyAffineTransform(rect,translationTransform!)
        scaleTransform = CGAffineTransformMakeScale(sx, sy)
        rect = CGRectApplyAffineTransform(rect, scaleTransform!)
        translationTransform = CGAffineTransformMakeTranslation(point.x,point.y)
        rect = CGRectApplyAffineTransform(rect,translationTransform!)
        return rect
        
    }
    internal func SMUPointIsNull(point:CGPoint) -> Bool{
        
        return CGPointEqualToPoint(point, SMUPointNull)
    }
    
    func SMUPointRotateAroundPoint(var point:CGPoint , pivot:CGPoint,angle:CGFloat) -> CGPoint{
        
        var translationTransform:CGAffineTransform?
        var rotationTransform:CGAffineTransform?
        point = CGPointApplyAffineTransform(point, translationTransform!);
        rotationTransform = CGAffineTransformMakeRotation(angle);
        point = CGPointApplyAffineTransform(point, rotationTransform!);
        translationTransform = CGAffineTransformMakeTranslation(pivot.x, pivot.y);
        point = CGPointApplyAffineTransform(point, translationTransform!);
        return point;

        
     
    }
    func SMUPointDistance(p1:CGPoint , p2:CGPoint)-> CGFloat{
        
        var dx:CGFloat = p1.x - p2.x;
        var dy:CGFloat = p1.y - p2.y;
        return sqrt(pow(dx, 2) + pow(dy, 2));

        
    }
    func SMULineSegmentMake(start1:CGPoint , end1:CGPoint)-> SMULineSegment{
        
        return SMULineSegment(start: start1, end: end1)
    }
    
    func SMULineSegmentRotateAroundPoint(line:SMULineSegment , pivot:CGPoint , angle:CGFloat) -> SMULineSegment{
        
        return SMULineSegmentMake(SMUPointRotateAroundPoint(line.start, pivot: pivot, angle: angle), end1: SMUPointRotateAroundPoint(line.end, pivot: pivot, angle: angle))
        
    }
    
    func SMULineSegmentIntersection(ls1:SMULineSegment , ls2:SMULineSegment)-> CGPoint{
        
        var x1:CGFloat = ls1.start.x;
        var y1:CGFloat = ls1.start.y;
        var x2:CGFloat = ls1.end.x;
        var y2:CGFloat = ls1.end.y;
        var x3:CGFloat = ls2.start.x;
        var y3:CGFloat = ls2.start.y;
        var x4:CGFloat = ls2.end.x;
        var y4:CGFloat = ls2.end.y;

        var numeratorA:CGFloat = (x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3);
        var numeratorB:CGFloat = (x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3);
        var denominator:CGFloat = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1);

        // Check the coincidence.
        if (fabs(numeratorA) < CGFloat(FLT_EPSILON) && fabs(numeratorB) < CGFloat(FLT_EPSILON) && fabs(denominator) < CGFloat(FLT_EPSILON)) {
            return CGPointMake((x1 + x2) * 0.5, (y1 + y2) * 0.5);
        }
        
        // Check the parallelism.
        if (fabs(denominator) < CGFloat(FLT_EPSILON)) {
            return SMUPointNull;
        }
        
        // Check the intersection.
        var uA:CGFloat = numeratorA / denominator;
        var uB:CGFloat = numeratorB / denominator;
        if (uA < 0 || uA > 1 || uB < 0 || uB > 1) {
            return SMUPointNull;
        }
        return CGPointMake(x1 + uA * (x2 - x1), y1 + uA * (y2 - y1));

    }
    
    
    
    
    
    
    
    
    
}