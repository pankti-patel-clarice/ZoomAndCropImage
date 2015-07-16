//
//  SMUImageScrollView.swift
//  ZoomAndCropImage
//
//  Created by Pankti Patel on 15/07/15.
//  Copyright (c) 2015 Pankti Patel. All rights reserved.
//

import Foundation
import UIKit

class SMUImageScrollView : UIScrollView,UIScrollViewDelegate{
    

    var _imageSize : CGSize?
    var pointToCenterAfterResize : CGPoint?
    var scaleToRestoreAfterResize : CGFloat = 0

    internal var zoomView:UIImageView?
    internal var aspectFill:Bool?
    
    
     override init(frame: CGRect) {
        
        super.init(frame: frame)
        aspectFill = false;
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.bouncesZoom = true;
        self.scrollsToTop = false;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;

    }

     required init(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    override func didAddSubview(subview: UIView) {
        super.didAddSubview(subview)
        
    }
    
    
   //  MARK - UIScrollViewDelegate
     func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return zoomView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        centerZoomView()
    }
    
    func centerZoomView(){

        // center zoomView as it becomes smaller than the size of the screen
        // we need to use contentInset instead of contentOffset for better positioning when zoomView fills the screen
        
        if aspectFill != nil{
            
            var top : CGFloat = 0
            var left : CGFloat = 0
            
            // center vertically
            if contentSize.height < CGRectGetHeight(bounds){
                top = CGRectGetHeight(bounds) - contentSize.height * 0.5
            }
            
            // center horizontally
            if contentSize.width < CGRectGetWidth(bounds){
                left = CGRectGetWidth(bounds) - contentSize.width * 0.5
            }
            
            contentInset = UIEdgeInsetsMake(top, left, top, left)

        }
        else{
            
            var frameToCenter : CGRect = zoomView!.frame
            
            // center horizontally

            if CGRectGetWidth(frameToCenter) < CGRectGetWidth(bounds){
                frameToCenter.origin.x = CGRectGetWidth(bounds) - CGRectGetWidth(frameToCenter) * 0.5
            }
            else{
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if CGRectGetHeight(frameToCenter) < CGRectGetHeight(bounds){
                frameToCenter.origin.y = CGRectGetHeight(bounds) - CGRectGetHeight(frameToCenter) * 0.5
            }
            else{
                frameToCenter.origin.x = 0
            }
            
            zoomView?.frame = frameToCenter

        }
        
    }
    
    //#pragma mark - Configure scrollView to display new image
    func displayImage (image:UIImage){
        
        // clear view for the previous image

        zoomView?.removeFromSuperview()
        zoomView = nil
        
        // reset our zoomScale to 1.0 before doing any further calculations

        zoomScale = 1.0
        
        // make views to display the new image

        zoomView = UIImageView(image: image)
        self.addSubview(zoomView!)
        
        configureForImageSize(image.size)
        
    }
    
    func configureForImageSize (imageSize : CGSize){
  
        _imageSize = imageSize
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        setInitialZoomScale()
        setInitialContentOffset()
        contentInset = UIEdgeInsetsZero
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
    
        var boundsSize : CGSize = bounds.size
        var xScale : CGFloat = boundsSize.width  / _imageSize!.width;    // the scale needed to perfectly fit the image width-wise
        var yScale : CGFloat = boundsSize.height / _imageSize!.height;   // the scale needed to perfectly fit the image height-wise
        
        var minScale : CGFloat = 0
        if aspectFill != nil{
            
            minScale = max(xScale,yScale) // use maximum of these to allow the image to fill the screen

        }
        else{
            minScale = min(xScale, yScale); // use minimum of these to allow the image to become fully visible

        }
        
        var maxScale:CGFloat = max(xScale,yScale)
        // Image must fit/fill the screen, even if its size is smaller.

        var xImageScale:CGFloat = maxScale * _imageSize!.width / boundsSize.width
        var yImageScale:CGFloat = maxScale * _imageSize!.height / boundsSize.width
        var maxImageScale:CGFloat = max(xImageScale,yImageScale)
        
        maxImageScale = max(minScale,maxImageScale)
        maxScale = max(maxScale,maxImageScale)
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale{
            minScale = maxScale
        }
        maximumZoomScale = maxScale
        minimumZoomScale = minScale
        
       
    
    }
    
    func setInitialZoomScale(){
        
        var boundsSize:CGSize = bounds.size
        var xScale:CGFloat = boundsSize.width / _imageSize!.width // the scale needed to perfectly fit the image width-wise
        var yscale:CGFloat = boundsSize.height / _imageSize!.height // the scale needed to perfectly fit the image height-wise
        var scale:CGFloat = max(xScale,yscale)
        zoomScale = scale
        
    }
    
    func setInitialContentOffset(){
        
        var boundsSize:CGSize = bounds.size
        var frameToCenter : CGRect = zoomView!.frame
        
        var contentOffset:CGPoint = CGPointZero
        if CGRectGetWidth(frameToCenter) > boundsSize.width{
            contentOffset.x  = CGRectGetWidth(frameToCenter) - boundsSize.width * 0.5
        }
        else{
            contentOffset.x = 0
        }
        if (CGRectGetHeight(frameToCenter) > boundsSize.height) {
            contentOffset.y = (CGRectGetHeight(frameToCenter) - boundsSize.height) * 0.5;
        } else {
            contentOffset.y = 0;
        }
        
        setContentOffset(contentOffset, animated: false)
        
    }
    
    /*
    
    #pragma mark -
    #pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image
    
    #pragma mark - Rotation support

    */
    func prepareToResize(){
        
        var boundsCenter:CGPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        pointToCenterAfterResize = convertPoint(boundsCenter, toView: zoomView!)
        scaleToRestoreAfterResize = zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.

        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(FLT_EPSILON){
        
            scaleToRestoreAfterResize = 0
        }
        
    }
    
    func recoverFromResizing(){
        
        
        setMaxMinZoomScalesForCurrentBounds()
        // Step 1: restore zoom scale, first making sure it is within the allowable range.
        var maxZoomScale:CGFloat = max(minimumZoomScale,scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale,maxZoomScale)
        
        // Step 2: restore center point, first making sure it is within the allowable range.
        // 2a: convert our desired center point back to our own coordinate space
        var boundsCenter:CGPoint = convertPoint(pointToCenterAfterResize!, toView: zoomView)
        
        // 2b: calculate the content offset that would yield that center point
        var offset:CGPoint = CGPointMake(boundsCenter.x - bounds.size.width/2.0, boundsCenter.y - bounds.size.height/2.0)
        
        // 2c: restore offset, adjusted to be within the allowable range
        var maxOffset:CGPoint = maximumContentOffset()
        var minOffset:CGPoint = minimumContentOffset()
        
        var realMaxOffset:CGFloat = min(maxOffset.x,offset.x)
        offset.x = max(minOffset.x,realMaxOffset)
        
        realMaxOffset = min(maxOffset.y,offset.y)
        offset.y = max(minOffset.y,realMaxOffset)
        
        contentOffset = offset
    }
    
    func maximumContentOffset() -> CGPoint{
        
        var pointX:CGFloat = contentSize.width - bounds.width
        var pointy:CGFloat = contentSize.height - bounds.height
        
        return CGPointMake(pointX,pointy)
       
    }
    
    func minimumContentOffset() -> CGPoint{
        return CGPointZero
    }
    
}