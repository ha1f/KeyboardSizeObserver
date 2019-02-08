//
//  ViewController.swift
//  KeyboardFrameObserver
//
//  Created by ha1f on 2019/02/08.
//  Copyright © 2019年 ha1f. All rights reserved.
//

import UIKit

/// 大体の画面に対しておすすめの構造。
/// ScrollView > UIView > UIStackView > その他のViewたち
/// UIViewはScrollViewに対してLeading, Trailing, Top, Bottom EdgesをAlignして、
/// Equal Widthもつける。
/// UIStackViewはUIViewに対してLeading, Trailing, Top, Bottom EdgesをAlign
/// 要素はUIStackViewの小要素として配置。
///
/// UIStackViewはAlignmentをcenterにして、
/// 子要素は幅と高さだけconstraintすればOK。
/// SafeAreaからはみ出したくない場合は、SafeAreaのLeading, Trailing Edgesと高さでもよい。
/// 固有の背景をつけたい場合は一旦UIViewをおいて、それをUIStackViewとEqual Widthと高さをセットする。
class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    let keyboardSizeObserver = KeyboardSizeObserver()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentInsetAdjustmentBehavior = .never
        keyboardSizeObserver.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // dismissとかで閉じるときにこれがないとキーボードが残ってちょっとダサい
        textField.resignFirstResponder()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        _updateScrollViewContentInsets(keyboardSize: keyboardSizeObserver.keyboardSize)
    }
    
    private func _updateScrollViewContentInsets(keyboardSize: CGSize) {
        let newInsets = UIEdgeInsets(
            top: view.safeAreaInsets.top,
            left: 0,
            bottom: max(keyboardSize.height, view.safeAreaInsets.bottom),
            right: 0
        )
        scrollView.contentInset = newInsets
        // こっちも更新しないとindicatorが変になる
        scrollView.scrollIndicatorInsets = newInsets
    }
}

extension ViewController: KeyboardSizeObserverDelegate {
    func keyboardSizeObserver(_ observer: KeyboardSizeObserver, sizeDidChangeTo size: CGSize) {
        _updateScrollViewContentInsets(keyboardSize: size)
    }
}

