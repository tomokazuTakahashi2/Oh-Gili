//
//  SettingViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/19.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseStorage
import SVProgressHUD
import Kingfisher
import CLImageEditor

class SettingViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLImageEditorDelegate {
    
    var imageURL:URL?
    var imageData:Data = Data()
    //  userDefaultsの定義
    var userDefaults = UserDefaults.standard
    
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blockListView: UITextView!
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                self.imageView.kf.setImage(with: url)
              }
            }
            

        // 表示名とを取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameLabel.text = user.displayName
        }
        
        //userDefaultから呼び出す
        if let getBlockUserArray = self.userDefaults.array(forKey: "blockUser") as! [String]?{
        print("【getBlockUserArray】:\(getBlockUserArray)")
            for blockUserId in getBlockUserArray{
                self.blockListView.text = blockUserId
                print("【blockUserIdy】:\(blockUserId)")
            }
            
        }
        
    }
//MARK: - 画面をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
//MARK: - 表示名変更ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleChangeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text {

            // 表示名が入力されていない時はHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                return
            }

            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")

                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
            }
        }
        displayNameLabel.text = displayNameTextField.text
        // キーボードを閉じる
        self.view.endEditing(true)
        //textfieldをからにする
        displayNameTextField.text = ""
    }

//MARK: - プロフィール画像を選ぶボタン
    @IBAction func imageChoiceButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    //カメラロールから写真を取得
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage

            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            picker.pushViewController(editor, animated: true)
        }
    }
    //ピッカーを閉じる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }

    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        
        // 画面を閉じるコマンド
        editor.dismiss(animated: true, completion: nil)
        //イメージビューに反映する
        self.imageView.image = image!
        
         print("DEBUG_PRINT: 画像を編集して選択しました。")
    //プロフィール画像をStorageに保存
        let storage = Storage.storage().reference()
        //プロフィール画像の変更
        let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
        //画像を圧縮
        let data = imageView.image!.jpegData(compressionQuality: 0.01)!
        //uidの場所
        let user = Auth.auth().currentUser!
        
        let photoRef = storage.child("users/\(user.uid)/profile-picture.jpg")
        
        //storageに画像を送信
        //成功すればmetaDataへ、失敗すればerrorに値が入る
        photoRef.putData(data, metadata: nil) { (metadata, error) in
            //エラーの場合
            if let error = error {
                print(error)
                return
            }
            //成功すればurlへ、失敗すればerrorに値が入る
            photoRef.downloadURL { (url, error) in
                //エラーの場合
                if let error = error {
                    print(error)
                }
                //もしurlがnillだったら進まない(return)、nillじゃなかったら、次に進む
                guard let downloadURL = url else {
                    return
                }
                                
                //nilじゃなかったら、画像を変更する
                changeRequest.photoURL = downloadURL
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        print(error)
                    }
                }
            }
             print("DEBUG_PRINT: 画像がstorageに保存されました。")
        }
    
    }

}
