//
//  CommentViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/24.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Kingfisher
import SVProgressHUD

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate{
    
    //var postArray: [PostData] = []
    var commentPostArray: [PostData] = []
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    //前画面からデータを受け取るための変数
    var postDataReceived: PostData?
    //(かぶらないようにの為)
    @IBOutlet weak var scrollView: UIScrollView!
    // 現在選択されているTextField(かぶらないようにの為)
    var selectedTextField:UITextField?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var zabutonButton: UIButton!
    @IBOutlet weak var zabutonLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentProfileImage: UIImageView!
    
    
    //MARK:-viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        commentTableView.allowsSelection = false

        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        commentTableView.register(nib, forCellReuseIdentifier: "CommentCell")

        // テーブル行の高さをAutoLayoutで自動調整する
        commentTableView.rowHeight = UITableView.automaticDimension
        
    }
    //MARK:-viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //自分のプロフィール画像を表示する
            //ダウンロード URL
                let storageRef = Storage.storage().reference(forURL: "gs://oh-gili-dde20.appspot.com")
                // Create a reference to the file you want to download
                let starsRef = storageRef.child("users/\(Auth.auth().currentUser!.uid)/profile-picture.jpg")

                // Fetch the download URL
                starsRef.downloadURL { url, error in
                  if let error = error {
                    // Handle any errors
                    print(error)
                    return
                  } else {
                    // Get the download URL for 'images/stars.jpg'
                    print("Image URL: \((url?.absoluteString)!)")
                    //Kingfisher
                    let url = URL(string: (url?.absoluteString)!)
                    self.commentProfileImage.kf.setImage(with: url)
                  }

                }
        
        //タップされたセルのポストデータ
        guard let postData = postDataReceived else {
          return
        }
        //プロフィール画像
        self.profileImage.image = postData.profileImage
        //名前
        self.nameLabel.text = postData.name
        //日時
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if postData.date != nil{
            let dateString = formatter.string(from: postData.date!)
            self.dateLabel.text = dateString
        }
        //タイトル
        self.titleLabel.text = "\(postData.caption!)"
        //イメージ
        if postData.image != nil{
            self.imageView.image = postData.image
        }
        //座布団
        if postData.isZabuton {
          let buttonImage = UIImage(named: "座布団")
          self.zabutonButton.setImage(buttonImage, for: .normal)
        } else {
          let buttonImage = UIImage(named: "座布団（白黒）")
          self.zabutonButton.setImage(buttonImage, for: .normal)
        }
        let zabutonNumber = postData.zabutons.count
        self.zabutonLabel.text = "\(zabutonNumber)"
        //ハート
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        let likeNumber = postData.likes.count
        self.likeCount.text = "\(likeNumber)"
        
        self.commentCount.text = postData.comment


        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath).child(postData.id!).child("comment")
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")

                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.commentPostArray.insert(postData, at: 0)

                        // TableViewを再表示する
                        self.commentTableView.reloadData()
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
                        for post in self.commentPostArray {
                            if post.id == postData.id {
                                index = self.commentPostArray.firstIndex(of: post)!
                                break
                            }
                        }

                        // 差し替えるため一度削除する
                        self.commentPostArray.remove(at: index)

                        // 削除したところに更新済みのデータを追加する
                        self.commentPostArray.insert(postData, at: index)

                        // TableViewを再表示する
                        self.commentTableView.reloadData()
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
                commentPostArray = []
                commentTableView.reloadData()
                // オブザーバーを削除する
                let postsRef = Database.database().reference().child(Const.PostPath).child(postData.id!).child("comment")
                postsRef.removeAllObservers()

                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }

        
    }
    //前の画面からデータを継承
    func setPostData(_ postData: PostData) {
        postDataReceived = postData
    }
    
//MARK:-コメントテーブルビュー
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentPostArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell

        // セルを取得してデータを設定する
        cell.setPostData(commentPostArray[indexPath.row])
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(heartButton(_:forEvent:)), for: .touchUpInside)
        
        
        return cell
        
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 300
//
//    }
    
    //MARK:-コメントテーブルビューのイイねボタン
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func heartButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        guard let postData = postDataReceived else {return}

        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.commentTableView)
        let indexPath = commentTableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let indexData = commentPostArray[indexPath!.row]

        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if indexData.commentLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in indexData.commentLikes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = indexData.commentLikes.firstIndex(of: likeId)!
                        break
                    }
                }
                indexData.commentLikes.remove(at: index)
            } else {
                indexData.commentLikes.append(uid)
            }

            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!).child("comment").child(indexData.id!)
            let likes = ["commentLikes": indexData.commentLikes]
            postRef.updateChildValues(likes)

        }
    }
    //キーボードを閉じる（タップしたら）
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //MARK:-決定を押したら
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // postDataに必要な情報を取得しておく
            let uid = Auth.auth().currentUser?.uid
            let postRef = Database.database().reference().child(Const.PostPath)
            let commentTime = Date.timeIntervalSinceReferenceDate
            let name = Auth.auth().currentUser?.displayName
            // ImageViewから画像を取得する
            let profileImageData = commentProfileImage.image!.jpegData(compressionQuality: 0.5)
            let profileImageString = profileImageData!.base64EncodedString(options: .lineLength64Characters)
            //もし、プロフィールイメージが空なら、デフォルト画像を表示しておく。
            if commentProfileImage.image == nil {
                let image1 = UIImage(named: "defaultProfileImage")
                commentProfileImage.image = image1
            }
            
            guard let postData = postDataReceived else {return true}
        
        //cell.textField.textが空欄じゃなかったら、
        if self.commentTextField.text != ""  {
            
            // 辞書を作成してFirebaseに保存する
            let postDic = ["uid":uid!,"commentProfileImage": profileImageString,"comment": textField.text!,"commentDate": String(commentTime), "commentName": name!]
        postRef.child(postData.id!).child("comment").childByAutoId().updateChildValues(postDic)

            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
             //キーボードを閉じる
             textField.resignFirstResponder()

            //textfieldをからにする
            commentTextField.text = ""
            
        //空欄だったら、
        }else{
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "空欄です")
        }

       
        return true
    }
}
