//
//  HomeViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/19.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var postArray: [PostData] = []
    
    //ブロックされたユーザーID
    var blockUserIdArray =  [String]()

    // DatabaseのobserveEventの登録状態を表す
    var observing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG_PRINT: viewDidLoad")

        tableView.delegate = self
        tableView.dataSource = self

        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        // テーブル行の高さの概算値を設定しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")

                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)

                        // TableViewを再表示する
                        self.tableView.reloadData()
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
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.firstIndex(of: post)!
                                break
                            }
                        }

                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)

                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)

                        // TableViewを再表示する
                        self.tableView.reloadData()
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
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.removeAllObservers()

                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])

        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.zabutonButton.addTarget(self, action:#selector(handleZabutonButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    //セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    
    }
    //セルをタップしたら画面遷移
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        //次ページにデータを送信するもの
        let postData = postArray[indexPath.row]
        postDataToSend = postData
        
        //画面遷移
        performSegue(withIdentifier: "cellSegue",sender: nil)
        
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)

    }

        var postDataToSend: PostData?

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "cellSegue" {
                let commentViewController = segue.destination as! CommentViewController
                if let postData = postDataToSend {
                    commentViewController.setPostData(postData)
                }
            }
        }
    
    //自分以外＝>報告・ブロックする
    internal func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let postData = postArray[indexPath.row]
        let postRef = Database.database().reference().child(Const.PostPath)
        let posts = postRef.child(postData.id!)

        //もし、投稿ユーザーIDが自分のIDじゃなかったら、
        if postData.uid != Auth.auth().currentUser?.uid{
            //💡スワイプアクション報告ボタン
            let reportButton: UIContextualAction = UIContextualAction(style: .normal, title: "報告",handler:  { (action: UIContextualAction, view: UIView, success :(Bool) -> Void )in
                
                //アラートコントローラー（報告）
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                //報告アクション
                let reportAction = UIAlertAction(title: "報告する", style: .destructive ){ (action) in
                    //表示
                    SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
                    
                    let postDataId = postData.id
                    let reportUserId = postData.uid
                    //辞書
                    let blockUserIdDic = ["reportID": postDataId!,"reportUser": reportUserId!] as [String : Any]
                    //保存
                    posts.child("report").setValue(blockUserIdDic)
                    print("DEBUG_PRINT: 報告を保存しました。")
                    print(blockUserIdDic)

                }
                //アラートアクション（報告）のキャンセルボタン
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                //UIAlertControllerに報告Actionを追加
                alertController.addAction(reportAction)
                //UIAlertControllerにキャンセルActionを追加
                alertController.addAction(cancelAction)
                //アラートを表示
                self.present(alertController, animated: true, completion: nil)
                tableView.isEditing = false

            })
            //報告ボタンの色(赤)
            reportButton.backgroundColor = UIColor.red
            
            //💡スワイプアクションブロックボタン
            let blockButton: UIContextualAction = UIContextualAction(style: .normal, title: "ブロック",handler:  { (action: UIContextualAction, view: UIView, success :(Bool) -> Void )in
            
                //アラートアクション（ブロック）
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
                    SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
                    
                //blockUserIdArrayに対象投稿のuidを追加
                self.blockUserIdArray.append(postData.uid!)
                    print("【blockUserIdArray】\(self.blockUserIdArray)")
                    
                //postArrayをフィルタリング（postArray.uidとpostData.uidが異なるもの(=ブロックIDじゃないもの)を残す）したもの
                let filteringArray = self.postArray.filter{$0.uid != postData.uid}
                    print("【filteringArray】:\(filteringArray)")
                    
                let sendNsData: NSData = try! NSKeyedArchiver.archivedData(withRootObject: postData, requiringSecureCoding: true) as NSData
                
                //UserDefaultsに保存
                UserDefaults.standard.set(sendNsData, forKey: "filteringArray")

                //postArrayの中身をfilteringArrayの中身にすり替える
                self.postArray = filteringArray

                // TableViewを再表示する
                self.tableView.reloadData()

                }
                //アラートアクションのキャンセルボタン
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                //UIAlertControllerにブロックActionを追加
                alertController.addAction(blockAction)
                //UIAlertControllerにキャンセルActionを追加
                alertController.addAction(cancelAction)
                //アラートを表示
                self.present(alertController, animated: true, completion: nil)
                //テーブルビューの編集→切
                tableView.isEditing = false
            })
            //ブロックボタンの色(青)
            blockButton.backgroundColor = UIColor.blue
            
            return UISwipeActionsConfiguration(actions: [blockButton,reportButton])
    
    //投稿ユーザーが自分だったら、
         } else {
             //💡スワイプアクション削除ボタン
             let deleteButton = UIContextualAction(style: .normal, title: "削除",handler:  { (action: UIContextualAction, view: UIView, success :(Bool) -> Void )in
    
                 //非同期的：タスクをディスパッチキューに追加したら、そのタスクの処理完了を待たずに次の行に移行する。
                 DispatchQueue.main.async {
                     let alertController = UIAlertController(title: "投稿を削除しますか？", message: nil, preferredStyle: .alert)
                     //削除のキャンセル
                     let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                         alertController.dismiss(animated: true, completion: nil)
                     }
                     //削除をする
                     let deleteAction = UIAlertAction(title: "OK", style: .default) { (action) in
                         //firebaseのオブジェクトの削除
                         posts.removeValue()
                         print("削除しました")
                         // 差し替えるため一度削除する
                        var index: Int = 0
                        //postArrayから一つずつ取り出す
                        for post in self.postArray {
                            //取り出したID(post.id)とポストデータのID（postData.id）が同じとき、
                            if post.id == postData.id {
                                //（一致したIDのうちの）最初のインデックスをindexとする
                                index = self.postArray.firstIndex(of: post)!
                                break
                            }
                        }
                         //差し替えるため一度削除する
                         self.postArray.remove(at: index)
                         // TableViewを再表示する
                         self.tableView.reloadData()
                         
                     }
                     //UIAlertControllerにキャンセルアクションを追加
                     alertController.addAction(cancelAction)
                     //UIAlertControllerに削除アクションを追加
                     alertController.addAction(deleteAction)
                     //アラートを表示
                     self.present(alertController,animated: true,completion: nil)
         
                     //テーブルビューの編集→切
                     tableView.isEditing = false
                 }
     
             })
             //削除ボタンの色(赤)
             deleteButton.backgroundColor = UIColor.red //色変更
             
             return UISwipeActionsConfiguration(actions:[deleteButton])
             
         }
        

     }

    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.firstIndex(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }

            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleZabutonButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isZabuton {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for zabutonId in postData.zabutons {
                    if zabutonId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.zabutons.firstIndex(of: zabutonId)!
                        break
                    }
                }
                postData.zabutons.remove(at: index)
            } else {
                postData.zabutons.append(uid)
            }

            // 増えたzabutonsをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let zabutons = ["zabutons": postData.zabutons]
            postRef.updateChildValues(zabutons)
        }
    }

}
