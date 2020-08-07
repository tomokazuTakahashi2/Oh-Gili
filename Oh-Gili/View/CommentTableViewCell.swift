//
//  CommentTableViewCell.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/24.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var zabutonButton: UIButton!
    @IBOutlet weak var zabutonCount: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setPostData(_ postData: PostData) {
        
        //プロフィール画像
        if postData.commentProfileImage != nil{
            self.profileImage.image = postData.commentProfileImage
        }
        //名前の表示
        if postData.commentName != nil{
            self.nameLabel.text = "\(postData.commentName!)"
        }
        
        //投稿日時
        if postData.commentDate != nil{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: postData.commentDate!)
            self.dateLabel.text = dateString
        }
        //座布団カウント
        if postData.commentZabutonArray.count != 0{
            let likeNumber = postData.commentZabutonArray.count
            zabutonCount.text = "\(likeNumber)"
        }else{
            zabutonCount.text = "\(0)"
        }
        //座布団ボタン
        if postData.zabutonAlready {
            let buttonImage = UIImage(named: "座布団")
            self.zabutonButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "座布団（白黒）")
            self.zabutonButton.setImage(buttonImage, for: .normal)
        }
        
        //コメント
        if postData.comment != nil{
        self.textView.text = postData.comment!
        }
    }
    
}
