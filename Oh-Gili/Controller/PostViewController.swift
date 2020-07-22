//
//  PostViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/19.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD
import Kingfisher

class PostViewController: UIViewController {
    var image: UIImage!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // 受け取った画像をImageViewに設定する
        imageView.image = image
        
    }
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 表示名とを取得してnameLabelに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            nameLabel.text = user.displayName
        }
        //プロフィール画像を表示する
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
                self.profileImageView.kf.setImage(with: url)
              }

            }
        
    }

    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        
        // ImageViewから画像を取得する
        let profileImageData = profileImageView.image!.jpegData(compressionQuality: 0.5)
        let profileImageString = profileImageData!.base64EncodedString(options: .lineLength64Characters)
        //もし、プロフィールイメージが空なら、デフォルト画像を表示しておく。
        if profileImageView.image == nil {
            let image1 = UIImage(named: "defaultProfileImage")
            profileImageView.image = image1
        }

        // ImageViewから画像を取得する
        let imageData = imageView.image!.jpegData(compressionQuality: 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)

       // postDataに必要な情報を取得しておく
        let uid = Auth.auth().currentUser?.uid
        let postRef = Database.database().reference().child(Const.PostPath)
        let time = Date.timeIntervalSinceReferenceDate
        let name = Auth.auth().currentUser?.displayName

        // 辞書を作成してFirebaseに保存する
        let postDic = ["uid":uid!,"profileImage": profileImageString,"caption": textField.text!, "image": imageString, "time": String(time), "name": name!]
        postRef.childByAutoId().setValue(postDic)

        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")

        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    // キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        dismiss(animated: true, completion: nil)
    }



}

