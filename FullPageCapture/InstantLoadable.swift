//
//  InstantLoadable.swift
//  FullPageCapture
//
//  Created by Imairi, Yosuke on 5/5/16.
//  Copyright © 2016 imairi. All rights reserved.
//

import UIKit

protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable {
    static var nibName: String { return String(self) }
}

extension UINib {
    static func instantiateView<T:UIView where T:NibLoadable>() -> T {
        guard let view = UINib(nibName: T.nibName, bundle: nil).instantiateWithOwner(self, options: nil)[0] as? T else {
            fatalError("cannot load nib")
        }
        
        return view
    }
}

protocol StoryboardLoadable {
    static var storyboardIdentifier:String { get }
    static var storyboardName:String { get }
}

extension StoryboardLoadable {
    static var storyboardIdentifier:String {return String(self)}
}

extension UIStoryboard {
    static func instantiateViewController<T:UIViewController where T:StoryboardLoadable>() -> T {
        guard let viewController = UIStoryboard(name: T.storyboardName, bundle: nil).instantiateViewControllerWithIdentifier(T.storyboardIdentifier) as? T else {
            fatalError("cannot load storyboard")
        }
        
        return viewController
    }
}
