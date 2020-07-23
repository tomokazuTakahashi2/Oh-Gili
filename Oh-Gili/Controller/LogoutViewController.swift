//
//  LogoutViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/23.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase

class LogoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //MARK: - ログアウトボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()

        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        loginViewController?.modalPresentationStyle = .fullScreen
        self.present(loginViewController!, animated: true, completion: nil)

        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        let tabBarController = parent as! ESTabBarController
        tabBarController.setSelectedIndex(0, animated: false)
    }
    

}
