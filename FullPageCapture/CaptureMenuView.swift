//
//  CaptureMenuView.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke on 5/5/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit

enum CaptureType {
    case Full, Current, Selection
}

protocol CaptureMenuViewDelegate {
    func tapCaptureButton(type:CaptureType)
    func decideSelectedArea()
}

class CaptureMenuView: UIView, NibLoadable {

    var delegate: CaptureMenuViewDelegate? = nil
    var isSelectedSelectionCaptureButton = false
    
    @IBAction func tapFullCaptureButton(sender: AnyObject) {
        if let delegate = delegate {
            delegate.tapCaptureButton(.Full)
        }
    }
    @IBAction func tapCurrentCaptureButton(sender: AnyObject) {
        if let delegate = delegate {
            delegate.tapCaptureButton(.Current)
        }
    }
    @IBAction func tapSelectionCaptureButton(sender: AnyObject) {
        
        guard let delegate = delegate else {
            return
        }
        
        if isSelectedSelectionCaptureButton {
            delegate.decideSelectedArea()
            return
        }

        delegate.tapCaptureButton(.Selection)
        isSelectedSelectionCaptureButton = true
    }
    
    @IBAction func tapCaptureButton(sender: AnyObject) {
        
    }
}
