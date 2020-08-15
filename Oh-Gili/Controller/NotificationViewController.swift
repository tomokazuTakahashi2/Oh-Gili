//
//  NotificationViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/24.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notificationArray: [PostData] = []

    //  userDefaultsの定義
    var userDefaults = UserDefaults.standard
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false

    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        
        let nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        notificationTableView.register(nib, forCellReuseIdentifier: "NotificationCell")

        // テーブル行の高さをAutoLayoutで自動調整する
        notificationTableView.rowHeight = UITableView.automaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        notificationTableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    //MARK:-viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")


        if Auth.auth().currentUser != nil {
            if self.observing == false {
                
                let postsRef = Database.database().reference().child("notification")
                // 要素が追加されたらnotificationArrayに追加してTableViewを再表示する
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let displayName = Auth.auth().currentUser?.displayName
                        
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        self.notificationArray.insert(postData, at: 0)
                        
                        //notificationArrayのnotificationName2（名前B）とdisplayNameが同じものを残す
                        let filtering = self.notificationArray.filter({$0.notificationName2 == displayName})
                        //フィルタリングしたものをnotificationArrayにすり替える。
                        self.notificationArray = filtering

                        // TableViewを再表示する
                        self.notificationTableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")

                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)

                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.notificationArray {
                            if post.id == postData.id {
                                index = self.notificationArray.firstIndex(of: post)!
                                break
                            }
                        }

                        // 差し替えるため一度削除する
                        self.notificationArray.remove(at: index)

                        // 削除したところに更新済みのデータを追加する
                        self.notificationArray.insert(postData, at: index)

                        // TableViewを再表示する
                        self.notificationTableView.reloadData()
                    }
                })

                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                notificationArray = []
                notificationTableView.reloadData()
                // オブザーバーを削除する
                let postsRef = Database.database().reference().child("notification")
                postsRef.removeAllObservers()

                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
//MARK:-テーブルビュー
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
        
    }
    //セルを構築
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        cell.setPostData(notificationArray[indexPath.row])
        
        return cell
    }
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    
    }
}
