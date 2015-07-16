//
//  SMUImageCropViewController.swift
//  ZoomAndCropImage
//
//  Created by Pankti Patel on 15/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit


enum SMUImageCropMode{
    
    case Circle
    case Square
    
}


public class SMUImageCropViewController: UIViewController,UIGestureRecognizerDelegate {
    
     var _originalImage:UIImage?
     var maskLayerColor:UIColor?
     var maskRect:CGRect?
     var maskPath:UIBezierPath?
    
    
     var _cropMode:SMUImageCropMode = SMUImageCropMode.Circle
     var cropRect:CGRect?
     var rotationAngle:CGFloat = 0
     var zoomScale:CGFloat?
     var avoidEmptySpaceAroundImage:Bool?
     var applyMaskToCroppedImage:Bool?
     var rotationEnabled:Bool?
    
     var moveAndScaleLabel:UILabel?
     var cancelButton:UIButton?
     var chooseButton:UIButton?
     var isRotationEnabled:Bool?
    
    let kPortraitCircleMaskRectInnerEdgeInset:CGFloat = 15.0
    let kPortraitSquareMaskRectInnerEdgeInset:CGFloat = 20.0
    let kPortraitMoveAndScaleLabelVerticalMargin:CGFloat = 64.0
    let kPortraitCancelAndChooseButtonsHorizontalMargin:CGFloat = 13.0
    let kPortraitCancelAndChooseButtonsVerticalMargin:CGFloat = 21.0
    
    let kResetAnimationDuration:CGFloat = 0.4;
    let kLayoutImageScrollViewAnimationDuration:CGFloat = 0.25;
    
   var imageScrollView:SMUImageScrollView?
   var overlayView:SMUTouchView?
   var maskLayer:CAShapeLayer?
   
   var doubleTapGestureRecognizer:UITapGestureRecognizer?
   var rotationGestureRecognizer:UIRotationGestureRecognizer?
   
   var didSetupConstraints:Bool = false
   var moveAndScaleLabelTopConstraint:NSLayoutConstraint?
   var cancelButtonBottomConstraint:NSLayoutConstraint?
   var chooseButtonBottomConstraint:NSLayoutConstraint?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        
    }

    
     required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initWithSetImage(originalImage:UIImage){
        _originalImage = originalImage
        initializeViews()
        
    }
    internal func initWithImage(#originalImage:UIImage, cropMode:SMUImageCropMode){
        initWithSetImage(originalImage)
        _cropMode = cropMode
        
    }
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor();
        self.view.clipsToBounds = true;
        
        self.navigationController?.navigationBarHidden = true
        
        avoidEmptySpaceAroundImage = false;
        applyMaskToCroppedImage = false;
        rotationEnabled = false;

        self.view.addSubview(imageScrollView!)
        self.view.addSubview(overlayView!)
        self.view.addSubview(moveAndScaleLabel!)
        self.view.addSubview(cancelButton!)
        self.view.addSubview(chooseButton!)
        self.view.addGestureRecognizer(doubleTapGestureRecognizer!)
        self.view.addGestureRecognizer(rotationGestureRecognizer!)
        
    }
    
    override public func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    override public func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        
    }
    
    override public func viewWillDisappear(animated: Bool){
        
        super.viewWillDisappear(animated)
    }
    
    override public func viewWillLayoutSubviews(){
        
        super.viewWillLayoutSubviews()
        
        updateMaskRect()
        layoutImageScrollView()
        layoutOverlayView()
        updateMaskPath()
        getOriginalImage()
        getMaskPath()
        getCropRect()
        getRotatingAngle()
        getZoomScale()
        ifAvoidEmptySpaceAroundImage()
        ifRotationEnabled()

        self.view.setNeedsUpdateConstraints()
        
    }
    
    override public func viewDidLayoutSubviews(){
        
        if (imageScrollView!.zoomView == nil) {
            displayImage()
        }
    }
    
    override public func updateViewConstraints(){
        
        super.updateViewConstraints()
        if didSetupConstraints == false {
            
            var constraint:NSLayoutConstraint = NSLayoutConstraint(item: self.moveAndScaleLabel!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
            self.view.addConstraint(constraint)
            
            var constant:CGFloat = kPortraitMoveAndScaleLabelVerticalMargin;
            self.moveAndScaleLabelTopConstraint = NSLayoutConstraint(item:self.moveAndScaleLabel! ,attribute:NSLayoutAttribute.Top, relatedBy:NSLayoutRelation.Equal
                ,toItem:self.view ,attribute:NSLayoutAttribute.Top ,multiplier:1.0,
                constant:constant)
            
            self.view.addConstraint(moveAndScaleLabelTopConstraint!)
            
            // --------------------
            // The button "Cancel".
            // --------------------
            
            constant = kPortraitCancelAndChooseButtonsHorizontalMargin;
            constraint = NSLayoutConstraint(item:self.cancelButton!, attribute:NSLayoutAttribute.Left, relatedBy:NSLayoutRelation.Equal
                , toItem:self.view ,attribute:NSLayoutAttribute.Left ,multiplier:1.0
                , constant:constant)
            self.view.addConstraint(constraint)
            
            constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
            self.cancelButtonBottomConstraint = NSLayoutConstraint(item:self.cancelButton!, attribute:NSLayoutAttribute.Bottom, relatedBy:NSLayoutRelation.Equal,
                toItem:self.view, attribute:NSLayoutAttribute.Bottom, multiplier:1.0,
                constant:constant)
            self.view.addConstraint(cancelButtonBottomConstraint!)
            
            // --------------------
            // The button "Choose".
            // --------------------
            
            constant = -kPortraitCancelAndChooseButtonsHorizontalMargin;
            constraint = NSLayoutConstraint(item:self.chooseButton!, attribute:NSLayoutAttribute.Right, relatedBy:NSLayoutRelation.Equal
                , toItem:self.view, attribute:NSLayoutAttribute.Right, multiplier:1.0,
                constant:constant)
            self.view.addConstraint(constraint)
            
            constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
            self.chooseButtonBottomConstraint = NSLayoutConstraint(item:self.chooseButton!, attribute:NSLayoutAttribute.Bottom ,relatedBy:NSLayoutRelation.Equal
                ,toItem:self.view ,attribute:NSLayoutAttribute.Bottom, multiplier:1.0,
                constant:constant)
            self.view.addConstraint(chooseButtonBottomConstraint!)
            
            self.didSetupConstraints = true;
        } else {
            self.moveAndScaleLabelTopConstraint!.constant = kPortraitMoveAndScaleLabelVerticalMargin;
            self.cancelButtonBottomConstraint!.constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
            self.chooseButtonBottomConstraint!.constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
        }
        
        
        
    }
    
    func initializeViews(){
        
        if (imageScrollView == nil){
            
            imageScrollView = SMUImageScrollView()
            imageScrollView?.clipsToBounds = false
            imageScrollView?.aspectFill = avoidEmptySpaceAroundImage
        }
        
        if (overlayView == nil){
            
            overlayView = SMUTouchView()
            overlayView!.receiver = imageScrollView
            overlayView?.layer.addSublayer(getMaskLayer())
        }
        if (moveAndScaleLabel == nil) {
            moveAndScaleLabel = UILabel();
            moveAndScaleLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
            moveAndScaleLabel!.backgroundColor = UIColor.clearColor()
            moveAndScaleLabel!.text = "Move and Scale"
            moveAndScaleLabel!.textColor = UIColor.whiteColor()
            moveAndScaleLabel!.opaque = false
        }
        
        if (cancelButton == nil) {
            cancelButton = UIButton();
            cancelButton!.setTranslatesAutoresizingMaskIntoConstraints(false)
            cancelButton!.setTitle("Cancel" ,forState:UIControlState.Normal)
            cancelButton!.addTarget(self, action: "onCancelButtonTouch:", forControlEvents:UIControlEvents.TouchUpInside)
            cancelButton!.opaque = false;
        }

        if (chooseButton == nil) {
            chooseButton = UIButton();
            chooseButton!.setTranslatesAutoresizingMaskIntoConstraints(false)
            chooseButton!.setTitle("Choose" ,forState:UIControlState.Normal)
            chooseButton!.addTarget(self, action: "onChooseButtonTouch:", forControlEvents:UIControlEvents.TouchUpInside)
            chooseButton!.opaque = false;
        }
        
        if (doubleTapGestureRecognizer == nil) {
            doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDoubleTap:");
            doubleTapGestureRecognizer!.delaysTouchesEnded = false;
            doubleTapGestureRecognizer!.numberOfTapsRequired = 2;
            doubleTapGestureRecognizer!.delegate = self;
        }

        if (rotationGestureRecognizer == nil) {
            rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "handleRotation:");
            rotationGestureRecognizer!.delaysTouchesEnded = false;
            rotationGestureRecognizer!.delegate = self;
            
        }




        
    }
    // #pragma mark - Action handling
    func onCancelButtonTouch(sender:UIBarButtonItem){
        
                cancelCrop()
    }
    func onChooseButtonTouch(sender:UIBarButtonItem){
        
                cropImage()
    }
    func handleDoubleTap(gestureRecognizer:UITapGestureRecognizer){
        
        reset(true)
    }
    func handleRotation(var gestureRecognizer:UIRotationGestureRecognizer){
        
        setNewRotationAngle(self.rotationAngle + gestureRecognizer.rotation)
        gestureRecognizer.rotation = 0
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            
            UIView.animateWithDuration(NSTimeInterval(kLayoutImageScrollViewAnimationDuration), delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.layoutImageScrollView()
                }, completion: nil)
        }
        
        
    }
    func reset(animated:Bool){
        
        if animated{
            UIView.beginAnimations("reset", context: nil)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.setAnimationDuration(NSTimeInterval(kResetAnimationDuration))
            UIView.setAnimationBeginsFromCurrentState(true)
            
            
        }
        
        resetRotation()
        resetFrame()
        resetZoomScale()
        resetContentOffset()
        
        if animated {
            UIView.commitAnimations()
        }
        
        
    }
    
    func resetContentOffset(){
        
        var boundsSize:CGSize = self.imageScrollView!.bounds.size
        var frameToCenter:CGRect = self.imageScrollView!.zoomView!.frame
        
        var contentOffset:CGPoint = CGPointZero
        
        if (CGRectGetWidth(frameToCenter) > boundsSize.width) {
            contentOffset.x = (CGRectGetWidth(frameToCenter) - boundsSize.width) * 0.5
        } else {
            contentOffset.x = 0
        }
        if (CGRectGetHeight(frameToCenter) > boundsSize.height) {
            contentOffset.y = (CGRectGetHeight(frameToCenter) - boundsSize.height) * 0.5
        } else {
            contentOffset.y = 0
        }
        
        self.imageScrollView!.contentOffset = contentOffset;
        
    }
    func resetFrame(){
        layoutImageScrollView()
    }
    func resetRotation(){
        
        self.setNewRotationAngle(0.0)
    }
    func resetZoomScale(){
        
        var zoomScale:CGFloat
        
        if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
            zoomScale = CGRectGetHeight(self.view.bounds) / _originalImage!.size.height;
        } else {
            zoomScale = CGRectGetWidth(self.view.bounds) / _originalImage!.size.width;
        }
        self.imageScrollView!.zoomScale = zoomScale;
        
    }
    
    func intersectionPointsOfLineSegment(lineSegment:SMULineSegment , rect:CGRect) -> Array<CGPoint>{
        
        
        var top:SMULineSegment = SMUImageCropper.sharedInstance.SMULineSegmentMake(CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)),
            end1: CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)))
        
        var right:SMULineSegment = SMUImageCropper.sharedInstance.SMULineSegmentMake(CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect)),
            end1: CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)))
        
        var bottom:SMULineSegment = SMUImageCropper.sharedInstance.SMULineSegmentMake(CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)),
            end1: CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect)))
        
        var left:SMULineSegment = SMUImageCropper.sharedInstance.SMULineSegmentMake(CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)),
            end1: CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)))
        
        let p0:CGPoint = SMUImageCropper.sharedInstance.SMULineSegmentIntersection(top, ls2: lineSegment)
        let p1:CGPoint = SMUImageCropper.sharedInstance.SMULineSegmentIntersection(right, ls2: lineSegment)
        let p2:CGPoint = SMUImageCropper.sharedInstance.SMULineSegmentIntersection(bottom, ls2: lineSegment)
        let p3:CGPoint = SMUImageCropper.sharedInstance.SMULineSegmentIntersection(left, ls2: lineSegment)
        
        var intersectionPoints : Array<CGPoint>?
        
        if !SMUImageCropper.sharedInstance.SMUPointIsNull(p0){
            
            intersectionPoints?.append(p0)
        }
        if !SMUImageCropper.sharedInstance.SMUPointIsNull(p1){
            
            intersectionPoints?.append(p1)
        }
        
        if !SMUImageCropper.sharedInstance.SMUPointIsNull(p2){
            
            intersectionPoints?.append(p2)
        }
        
        if !SMUImageCropper.sharedInstance.SMUPointIsNull(p3){
            
            intersectionPoints?.append(p3)
        }
        
        return intersectionPoints!
        
    }
    
    func displayImage(){
        
        if _originalImage != nil{
            
            imageScrollView?.displayImage(_originalImage!)
            reset(false)
        }
    }
    
    func layoutImageScrollView(){
        
        var frame:CGRect = CGRectZero
        // The bounds of the image scroll view should always fill the mask area.
        switch (_cropMode) {
            
        case SMUImageCropMode.Circle:
            
            frame = maskRect!
            break
            
            
        case SMUImageCropMode.Square:
            
            if (self.rotationAngle == 0.0) {
                frame = self.maskRect!
            } else {
                // Step 1: Rotate the left edge of the initial rect of the image scroll view clockwise around the center by `rotationAngle`.
                var initialRect:CGRect = self.maskRect!
                
                var leftTopPoint:CGPoint = CGPointMake(initialRect.origin.x, initialRect.origin.y);
                var leftBottomPoint:CGPoint = CGPointMake(initialRect.origin.x, initialRect.origin.y + initialRect.size.height);
                let leftLineSegment:SMULineSegment = SMUImageCropper.sharedInstance.SMULineSegmentMake(leftTopPoint, end1: leftBottomPoint);
                
                var pivot:CGPoint = SMUImageCropper.sharedInstance.SMURectCenterPoint(initialRect);
                
                var alpha:CGFloat = fabs(rotationAngle);
                let rotatedLeftLineSegment:SMULineSegment = SMUImageCropper.sharedInstance.SMULineSegmentRotateAroundPoint(leftLineSegment, pivot: pivot, angle: alpha)
                
                // Step 2: Find the points of intersection of the rotated edge with the initial rect.
                var points:Array<CGPoint> = intersectionPointsOfLineSegment(rotatedLeftLineSegment, rect: initialRect)
                
                // Step 3: If the number of intersection points more than one
                // then the bounds of the rotated image scroll view does not completely fill the mask area.
                // Therefore, we need to update the frame of the image scroll view.
                // Otherwise, we can use the initial rect.
                
                if (points.count > 1) {
                    // We have a right triangle.
                    
                    // Step 4: Calculate the altitude of the right triangle.
                    if ((alpha > CGFloat(M_PI_2)) && (alpha < CGFloat( M_PI))) {
                        alpha = alpha - CGFloat(M_PI_2)
                    } else if ((alpha > CGFloat(M_PI + M_PI_2)) && (alpha < CGFloat(M_PI + M_PI))) {
                        alpha = alpha - CGFloat(M_PI + M_PI_2)
                    }
                    let sinAlpha:CGFloat = sin(alpha)
                    let cosAlpha:CGFloat = cos(alpha);
                    let hypotenuse:CGFloat = SMUImageCropper.sharedInstance.SMUPointDistance(points[0], p2: points[1])
                    let altitude:CGFloat = hypotenuse * sinAlpha * cosAlpha;
                    
                    // Step 5: Calculate the target width.
                    let initialWidth:CGFloat = CGRectGetWidth(initialRect);
                    let targetWidth:CGFloat = initialWidth + altitude * 2;
                    
                    // Step 6: Calculate the target frame.
                    let scale:CGFloat = targetWidth / initialWidth;
                    let center:CGPoint = SMUImageCropper.sharedInstance.SMURectCenterPoint(initialRect)
                    frame = SMUImageCropper.sharedInstance.SMURectScaleAroundPoint(initialRect, point: center, sx: scale, sy: scale)
                    
                    // Step 7: Avoid floats.
                    frame.origin.x = round(CGRectGetMinX(frame));
                    frame.origin.y = round(CGRectGetMinY(frame));
                    frame = CGRectIntegral(frame);
                } else {
                    // Step 4: Use the initial rect.
                    frame = initialRect;
                }
            }
            
            break
            
            
            
        }
        
        let transform:CGAffineTransform = self.imageScrollView!.transform
        self.imageScrollView!.transform = CGAffineTransformIdentity
        self.imageScrollView!.frame = frame
        self.imageScrollView!.transform = transform

    }
    
    func layoutOverlayView(){
        
        let frame:CGRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2);
        self.overlayView!.frame = frame;

    }
    
    func updateMaskRect(){
        
        switch (_cropMode) {
            
        case SMUImageCropMode.Circle:
            
            var viewWidth:CGFloat = CGRectGetWidth(self.view.bounds);
            var viewHeight:CGFloat = CGRectGetHeight(self.view.bounds);
            
            let diameter:CGFloat = min(viewWidth, viewHeight) - kPortraitCircleMaskRectInnerEdgeInset * 2;
            let maskSize:CGSize = CGSizeMake(diameter, diameter);
            
            self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5,
                (viewHeight - maskSize.height) * 0.5,
                maskSize.width,
                maskSize.height);
            break
            
        case SMUImageCropMode.Square:
            var viewWidth:CGFloat = CGRectGetWidth(self.view.bounds);
            var viewHeight:CGFloat = CGRectGetHeight(self.view.bounds);
            
            let length:CGFloat = min(viewWidth, viewHeight) - kPortraitSquareMaskRectInnerEdgeInset * 2;
            
            var maskSize:CGSize = CGSizeMake(length, length);
            
            self.maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5,
                (viewHeight - maskSize.height) * 0.5,
                maskSize.width,
                maskSize.height);
            break
            
        default:
            break
            
        }
        
    }
    func updateMaskPath(){
        
        switch (_cropMode) {
        case SMUImageCropMode.Circle:
            self.maskPath = UIBezierPath(ovalInRect: maskRect!)
            break;
            
        case SMUImageCropMode.Square:
            self.maskPath = UIBezierPath(rect: maskRect!)
            break;
            
        }

        
    }
    
    func croppedImage (image: UIImage , cropMode:SMUImageCropMode,  cropRect:CGRect, rotationAngle:CGFloat, zoomScale:CGFloat,maskPathForImage:UIBezierPath,applyMaskToCroppedImage:Bool )-> UIImage{
        
        // Step 1: check and correct the crop rect.
        
        var cropRectForImage = cropRect
        let imageSize:CGSize = image.size;
        var x:CGFloat = CGRectGetMinX(cropRect);
        var y:CGFloat = CGRectGetMinY(cropRect);
        var width:CGFloat = CGRectGetWidth(cropRect);
        var height:CGFloat = CGRectGetHeight(cropRect);
        
        var imageOrientation:UIImageOrientation = image.imageOrientation
        
        if (imageOrientation == UIImageOrientation.Right || imageOrientation == UIImageOrientation.RightMirrored) {
            cropRectForImage.origin.x = y;
            cropRectForImage.origin.y = round(imageSize.width - CGRectGetWidth(cropRect) - x);
            cropRectForImage.size.width = height;
            cropRectForImage.size.height = width;
        } else if (imageOrientation == UIImageOrientation.Left || imageOrientation == UIImageOrientation.LeftMirrored) {
            cropRectForImage.origin.x = round(imageSize.height - CGRectGetHeight(cropRect) - y);
            cropRectForImage.origin.y = x;
            cropRectForImage.size.width = height;
            cropRectForImage.size.height = width;
        } else if (imageOrientation == UIImageOrientation.Down || imageOrientation == UIImageOrientation.DownMirrored) {
            cropRectForImage.origin.x = round(imageSize.width - CGRectGetWidth(cropRect) - x);
            cropRectForImage.origin.y = round(imageSize.height - CGRectGetHeight(cropRect) - y);
        }
        
        let imageScale:CGFloat = image.scale;
        cropRectForImage = CGRectApplyAffineTransform(cropRect, CGAffineTransformMakeScale(imageScale, imageScale));
        
        // Step 2: create an image using the data contained within the specified rect.
        let croppedCGImage:CGImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
        var croppedImage:UIImage = UIImage(CGImage: croppedCGImage, scale: imageScale, orientation: imageOrientation)!
        
        // Step 3: fix orientation of the cropped image.
        croppedImage = croppedImage.fixOrientation();
        imageOrientation = croppedImage.imageOrientation;
        
        if ((cropMode == SMUImageCropMode.Square || !applyMaskToCroppedImage) && rotationAngle == 0.0) {
            // Step 5: return the cropped image immediately.
            return croppedImage;
        } else {
            // Step 5: create a new context.
            var maskSize:CGSize = CGRectIntegral(maskPathForImage.bounds).size;
            let contextSize:CGSize = CGSizeMake(ceil(maskSize.width / zoomScale),
                ceil(maskSize.height / zoomScale));
            UIGraphicsBeginImageContextWithOptions(contextSize, false, imageScale);
            
            // Step 6: apply the mask if needed.
            if (applyMaskToCroppedImage) {
                // 6a: scale the mask to the size of the crop rect.
                var maskPathCopy:UIBezierPath = maskPathForImage.copy() as! UIBezierPath
                let scale:CGFloat = 1 / zoomScale;
                maskPathCopy.applyTransform(CGAffineTransformMakeScale(scale, scale))
                
                // 6b: move the mask to the top-left.
                var translation:CGPoint = CGPointMake(-CGRectGetMinX(maskPathCopy.bounds),
                    -CGRectGetMinY(maskPathCopy.bounds));
                maskPathCopy.applyTransform(CGAffineTransformMakeTranslation(translation.x, translation.y))
                
                // 6c: apply the mask.
                maskPathCopy.addClip()
            }
            
            // Step 7: rotate the cropped image if needed.
            if (rotationAngle != 0) {
                croppedImage = croppedImage.rotateByAngle(rotationAngle)
            }
            
            // Step 8: draw the cropped image.
            let point:CGPoint = CGPointMake(round((contextSize.width - croppedImage.size.width) * 0.5),
                round((contextSize.height - croppedImage.size.height) * 0.5))
            croppedImage.drawAtPoint(point)
            
            // Step 9: get the cropped image affter processing from the context.
            croppedImage = UIGraphicsGetImageFromCurrentImageContext();
            
            // Step 10: remove the context.
            UIGraphicsEndImageContext();
            
            croppedImage = UIImage(CGImage: croppedImage.CGImage, scale: imageScale, orientation: imageOrientation)!
            
            // Step 11: return the cropped image affter processing.
            return croppedImage;
        }

        
    }
    func cropImage(){
        
        getCropRect()

        print("zoomScale: \(self.imageScrollView!.zoomScale)");

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let cropRect:CGRect = self.cropRect!
            let rotationAngle:CGFloat = self.rotationAngle
            
            var croppedImage1:UIImage = self.croppedImage(self._originalImage!, cropMode: self._cropMode, cropRect: cropRect, rotationAngle: rotationAngle, zoomScale: self.imageScrollView!.zoomScale, maskPathForImage: self.maskPath!, applyMaskToCroppedImage: self.applyMaskToCroppedImage!)
            
            dispatch_async(dispatch_get_main_queue(), {

                var imageDictionary = Dictionary<String,UIImage>()
                imageDictionary["image"] = croppedImage1
                NSNotificationCenter.defaultCenter().postNotificationName("photoRecieved", object: nil, userInfo: imageDictionary)

            });
        });

    }
    func cancelCrop(){
        
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func ifRotationEnabled(){
        self.rotationGestureRecognizer!.enabled = rotationEnabled!;
    }
    
    
    func ifAvoidEmptySpaceAroundImage(){
        self.imageScrollView!.aspectFill = avoidEmptySpaceAroundImage;
    }
    
    func getZoomScale(){
        
        zoomScale =  self.imageScrollView!.zoomScale;
    }
    func getRotatingAngle(){
        var transform:CGAffineTransform = self.imageScrollView!.transform;
        rotationAngle = atan2(transform.b, transform.a);
    }
    func getCropRect(){
        
        
        var cropRectAfterZoom:CGRect = CGRectZero;
        
        var zoomScale:CGFloat = 1.0 / imageScrollView!.zoomScale
        cropRectAfterZoom.origin.x = round(self.imageScrollView!.contentOffset.x * zoomScale);
        cropRectAfterZoom.origin.y = round(self.imageScrollView!.contentOffset.y * zoomScale);
        cropRectAfterZoom.size.width = CGRectGetWidth(self.imageScrollView!.bounds) * zoomScale;
        cropRectAfterZoom.size.height = CGRectGetHeight(self.imageScrollView!.bounds) * zoomScale;
        cropRectAfterZoom = CGRectIntegral(cropRectAfterZoom);
        cropRect = cropRectAfterZoom;
    }
    
    
    func getOriginalImage(){
        
        if isViewLoaded() && self.view.window != nil {
            displayImage()
        }

    }
    
    func getMaskLayer() -> CAShapeLayer{
        
        if (maskLayer == nil){
            maskLayer = CAShapeLayer();
            maskLayer!.fillRule = kCAFillRuleEvenOdd;
            maskLayer!.fillColor = getMaskLayerColor().CGColor;
        }
        return maskLayer!;
        
        
    }
    
    func getMaskLayerColor()->UIColor{
        
        if (maskLayerColor == nil) {
            
            maskLayerColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
            
        }
        return maskLayerColor!
    }

    
    func getMaskPath()
    {
        
        var clipPath:UIBezierPath = UIBezierPath(rect: overlayView!.frame)
        clipPath.appendPath(self.maskPath!)
        clipPath.usesEvenOddFillRule = true;
        
        var pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.duration = CATransaction.animationDuration()
        pathAnimation.timingFunction = CATransaction.animationTimingFunction();
        maskLayer!.addAnimation(pathAnimation, forKey: "path")
        self.maskLayer!.path = clipPath.CGPath;
        
    }
    
    
    func setNewRotationAngle(rotationAngle:CGFloat)
    {
        if (self.rotationAngle != rotationAngle) {
            var rotation:CGFloat = (rotationAngle - self.rotationAngle);
            var transform:CGAffineTransform = CGAffineTransformRotate(self.imageScrollView!.transform, rotation);
            self.imageScrollView!.transform = transform;
        }
    }
    
    
}