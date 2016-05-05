//
//  UIView+Screenshot.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke on 5/5/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit

extension UIView {
    func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}