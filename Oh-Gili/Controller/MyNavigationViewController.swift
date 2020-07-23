//
//  MyNavigationViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/23.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit

class MyUINavigationController: UINavigationController {

    // MyUINavigationController.class
    override func viewDidLoad() {
            super.viewDidLoad()
        
            //　ナビゲーションバーの背景色
            navigationBar.barTintColor = UIColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0)
            // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
            navigationBar.tintColor = .black
            // ナビゲーションバーのテキストを変更する
            navigationBar.titleTextAttributes = [
                // 文字の色
                .foregroundColor: UIColor.black
            ]
            // Do any additional setup after loading the view.
        }

}

