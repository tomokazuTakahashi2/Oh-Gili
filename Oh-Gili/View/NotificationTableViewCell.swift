//
//  NotificationTableViewCell.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/08/11.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var natificationImageView: UIImageView!
    @IBOutlet weak var notificationDateLabel: UILabel!
    @IBOutlet weak var notificationTextLabel: UILabel!
    
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
        if postData.notificationProfileImage != nil{
            self.natificationImageView.image = postData.notificationProfileImage
        }
        //名前とテキストの表示
        if postData.notificationName1 != nil{
            self.notificationTextLabel.text = "\(postData.notificationName1!)さんが\(postData.notificationName2!)さんの投稿にコメントしました。"
        }

        //投稿日時
        if postData.notificationDate != nil{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: postData.notificationDate!)
            self.notificationDateLabel.text = dateString
        }
    }
    
}
