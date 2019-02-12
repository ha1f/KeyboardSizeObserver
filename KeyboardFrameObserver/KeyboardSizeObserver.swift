//
//  KeyboardSizeObserver.swift
//  KeyboardFrameObserver
//
//  Created by ha1f on 2019/02/08.
//  Copyright © 2019年 ha1f. All rights reserved.
//

import UIKit

public protocol KeyboardSizeObserverDelegate: AnyObject {
    func keyboardSizeObserver(_ observer: KeyboardSizeObserver, sizeDidChangeTo size: CGSize)
}

public extension KeyboardSizeObserverDelegate {
    func keyboardSizeObserver(_ observer: KeyboardSizeObserver, sizeDidChangeTo size: CGSize) {
        // implementation is optional
    }
}

/// This class have to be instantiated before keyboard shown to track keyboard correctly. (You can use singleton if needed.)
/// userInfo returns frame, but doc recommends us not to use origin, and just use size.
/// Ref: https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
public final class KeyboardSizeObserver: NSObject {
    /// Note that we have to set this property using _dispatchQueue
    public private(set) var keyboardSize: CGSize = KeyboardSizeObserver._defaultSize {
        didSet {
            delegate?.keyboardSizeObserver(self, sizeDidChangeTo: keyboardSize)
        }
    }
    
    public weak var delegate: KeyboardSizeObserverDelegate? {
        didSet {
            _dispatchQueue.async { [self, delegate, keyboardSize] in
                // notify initial value
                delegate?.keyboardSizeObserver(self, sizeDidChangeTo: keyboardSize)
            }
        }
    }
    
    /// For thread safety, we have to use at least serial queue
    private let _dispatchQueue: DispatchQueue = DispatchQueue.main
    
    private var _keyboardFrameEndKey: String {
        #if swift(>=4.2)
        return UIResponder.keyboardFrameEndUserInfoKey
        #else
        return UIKeyboardFrameEndUserInfoKey
        #endif
    }
    
    private static let _defaultSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: 0
    )
    
    public override init() {
        super.init()
        
        // Though we have more notifications, since [RxKeyboard](https://github.com/RxSwiftCommunity/RxKeyboard/blob/master/Sources/RxKeyboard/RxKeyboard.swift) uses
        // only this two, I guess this is enough
        #if swift(>=4.2)
        let keyboardWillChangeFrame = UIResponder.keyboardWillChangeFrameNotification
        let keyboardWillHide = UIResponder.keyboardWillHideNotification
        #else
        let keyboardWillChangeFrame = NSNotification.Name.UIKeyboardWillChangeFrame
        let keyboardWillHide = NSNotification.Name.UIKeyboardWillHide
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedKeyboardWillHideNotification(_:)), name: keyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedKeyboardWillChangeFrameNotification(_:)), name: keyboardWillChangeFrame, object: nil)
    }
    
    private func _handleNotification(_ notification: Notification) {
        let newSize = (notification.userInfo?[_keyboardFrameEndKey] as? NSValue)?.cgRectValue.size
            ?? KeyboardSizeObserver._defaultSize
        
        _dispatchQueue.async { [weak self] in
            self?.keyboardSize = newSize
        }
    }
    
    @objc
    private func didReceivedKeyboardWillChangeFrameNotification(_ notification: Notification) {
        _handleNotification(notification)
    }
    
    @objc
    private func didReceivedKeyboardWillHideNotification(_ notification: Notification) {
        _handleNotification(notification)
    }
}
