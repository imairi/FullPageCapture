//
//  ProgressView.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke on 5/3/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit

class ProgressView: UIView {
    
    var progress = 0.0

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect))
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMidX(rect), CGRectGetMinY(rect), 0)
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect) * CGFloat(progress), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMidY(rect), 0)
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect) * CGFloat(progress), CGRectGetMaxY(rect), CGRectGetMidX(rect), CGRectGetMaxY(rect), 0)
        CGContextAddArcToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMidY(rect), 0)
        CGContextClosePath(context);
        CGContextFillPath(context);
    }

}
