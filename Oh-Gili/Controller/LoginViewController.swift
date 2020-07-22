//
//  LoginViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/19.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

   
    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //グラデーションの開始色
        let topColor = UIColor(red:2.00, green:0.80, blue:0.00, alpha:2)
        //グラデーションの開始色
        let bottomColor = UIColor(red:0.54, green:0.74, blue:0.90, alpha:1)

        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]

        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()

        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.view.bounds

        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    //ロゴのアニメーション
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false

        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 2.0
        animation1.toValue = 1.0

        let animation2 = CABasicAnimation(keyPath: "cornerRadius")
        animation2.fromValue = 0.0
        animation2.toValue = 20.0

        let animation3 = CABasicAnimation(keyPath: "transform.rotation")
        animation3.fromValue = 0.0
        animation3.toValue = M_PI * 2.0
        animation3.speed = 2.0

        animationGroup.animations = [animation1, animation2, animation3]
        logoView.layer.add(animationGroup, forKey: nil)
    }

}
