//
//  MaskView.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke on 5/5/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit

class MaskView: UIView {

    var leftTop = CGPointMake(100 - 10, 100 - 10)
    var rightBottom = CGPointMake(200 - 10, 200 - 10)
    let radius = CGFloat(10)
    var canMoveLeftTop = false
    var canMoveRightBottom = false
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        // black mask background
        CGContextSetFillColorWithColor(context, UIColor(white: 0.0, alpha: 0.5).CGColor)
        CGContextFillRect(context, rect)
        
        // transparent background
        CGContextClearRect(context, CGRectMake(leftTop.x + radius, leftTop.y + radius, rightBottom.x - leftTop.x, rightBottom.y - leftTop.y))
        
        // draw rect line
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextMoveToPoint(context, leftTop.x + radius, leftTop.y + radius)
        CGContextAddLineToPoint(context, rightBottom.x + radius, leftTop.y + radius)
        CGContextAddLineToPoint(context, rightBottom.x + radius, rightBottom.y + radius)
        CGContextAddLineToPoint(context, leftTop.x + radius, rightBottom.y + radius)
        CGContextClosePath(context);
        CGContextStrokePath(context);
        
        // draw left top circle
        let leftTopRectEllipse = CGRectMake(leftTop.x, leftTop.y, radius*2, radius*2);
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillEllipseInRect(context, leftTopRectEllipse);
        
        // draw right bottom circle
        let rightBottomRectEllipse = CGRectMake(rightBottom.x, rightBottom.y, radius*2, radius*2);
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillEllipseInRect(context, rightBottomRectEllipse);
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        canMoveLeftTop = false
        canMoveRightBottom = false
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let touchPosition = touch.locationInView(self)
            
            if leftTop.x < touchPosition.x && touchPosition.x < leftTop.x + radius * 2
                && leftTop.y < touchPosition.y && touchPosition.y < leftTop.y + radius * 2 {
                canMoveLeftTop = true
            }
            
            if rightBottom.x < touchPosition.x && touchPosition.x < rightBottom.x + radius * 2
                && rightBottom.y < touchPosition.y && touchPosition.y < rightBottom.y + radius * 2 {
                canMoveRightBottom = true
            }
            
            if canMoveLeftTop && touchPosition.x < rightBottom.x && touchPosition.y < rightBottom.y{
                leftTop = CGPointMake(touchPosition.x - radius, touchPosition.y - radius)
            }
            
            if canMoveRightBottom && leftTop.x + radius * 2 < touchPosition.x && leftTop.y + radius * 2 < touchPosition.y {
                rightBottom = CGPointMake(touchPosition.x - radius, touchPosition.y - radius)
            }
            
            setNeedsDisplay()
        }
    }
    
    // MARK: - Public Methods
    func capturedRect() -> CGRect {
        return CGRectMake(leftTop.x, leftTop.y, rightBottom.x - leftTop.x, rightBottom.y - leftTop.y)
    }
}
