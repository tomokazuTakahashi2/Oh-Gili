//
//  PostData.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/19.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var uid: String?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var zabutons: [String] = []
    var isZabuton: Bool = false
    var profileImageString: String?
    var profileImage: UIImage?
    
    var commentName: String?
    var commentUid: String?
    var commentProfileImageString: String?
    var commentProfileImage: UIImage?
    var comment: String?
    var commentDate: Date?
    var commentZabutonArray: [String] = []
    var zabutonAlready: Bool = false
    
    var blockUserId: String? = nil
    
    
    var notificationProfileImage: UIImage?
    var notificationDate: Date?
    var notificationName1: String?
    var notificationName2: String?
    
    

    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key

        let valueDictionary = snapshot.value as! [String: Any]
        
        self.uid = valueDictionary["uid"]as? String
        
        self.blockUserId = valueDictionary["blockUserId"]as? String
        
        //イメージ画像
        if let imageString = valueDictionary["image"] as? String{
        image = UIImage(data: Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!)
        }
        
        //表示名
        self.name = valueDictionary["name"] as? String
        
        //キャプション
        self.caption = valueDictionary["caption"] as? String
        
        //日時
        if let time = valueDictionary["time"] as? String{
            self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time)!)
        }
        
        //プロフィール画像
        if let profileImageString = valueDictionary["profileImage"] as? String{
            profileImage = UIImage(data: Data(base64Encoded: profileImageString, options: .ignoreUnknownCharacters)!)
        }
        
        //ハートカウント
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        //ハートカウント済み
        for likeId in self.likes {
            if likeId == myId {
                self.isLiked = true
                break
            }
        }
        //座布団カウント
        if let zabutons = valueDictionary["zabutons"] as? [String] {
            self.zabutons = zabutons
        }
        //座布団カウント済み
        for zabutonId in self.zabutons {
            if zabutonId == myId {
                self.isZabuton = true
                break
            }
        }
        //コメント uid
        self.commentUid = valueDictionary["commentUid"]as? String
    
        //コメント欄の名前
        self.commentName = valueDictionary["commentName"] as? String
        
        //コメント文
        if let comment = valueDictionary["comment"] as? String {
            self.comment = comment
        }
        
        //コメント日時
        if let commentTime = valueDictionary["commentDate"] as? String{
            self.commentDate = Date(timeIntervalSinceReferenceDate: TimeInterval(commentTime)!)
        }
        //座布団カウント
        //commentZabutonArray配列にはuidが格納されている
        if let commentLikes = valueDictionary["commentLikes"] as? [String] {
            self.commentZabutonArray = commentLikes
        }
        //座布団ボタンを押したかどうか
        //commentZabutonArray配列から一つずつ取り出したものをlikeIdとする
        for likeId in self.commentZabutonArray {
            //もし自分のIDがlikeIDと同じならば、
            if likeId == myId {
                //zabutonAlreadyをtrue（=イイね済）とする
                self.zabutonAlready = true
                //ループを抜ける
                break
            }
        }
        //コメント欄のプロフィール画像
        if let commentProfileImageString = valueDictionary["commentProfileImage"] as? String{
        commentProfileImage = UIImage(data: Data(base64Encoded: commentProfileImageString, options: .ignoreUnknownCharacters)!)
        }
        
        
        //通知欄のプロフィール画像
        if let notificationProfileImageString = valueDictionary["通知画像"] as? String{
        notificationProfileImage = UIImage(data: Data(base64Encoded: notificationProfileImageString, options: .ignoreUnknownCharacters)!)
        }
        //通知欄の名前A
        self.notificationName1 = valueDictionary["名前A"] as? String
        //通知欄の名前B
        self.notificationName2 = valueDictionary["名前B"] as? String
        
        //コメント日時
        if let notificationTime = valueDictionary["日時"] as? String{
            self.notificationDate = Date(timeIntervalSinceReferenceDate: TimeInterval(notificationTime)!)
        }
    }
}
