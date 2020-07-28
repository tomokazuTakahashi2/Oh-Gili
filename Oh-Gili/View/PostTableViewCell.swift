//
//  PostTableViewCell.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/07/19.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var zabutonButton: UIButton!
    @IBOutlet weak var zabutonLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setPostData(_ postData: PostData) {
        
        self.profileImageView.image = postData.profileImage
        
        self.postImageView.image = postData.image

        if postData.caption != nil{
        self.captionLabel.text = "\(postData.caption!)"
        }
        
        if postData.name != nil{
        self.nameLabel.text = "\(postData.name!)"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if postData.date != nil{
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        }

        if postData.isZabuton {
            let buttonImage = UIImage(named: "座布団")
            self.zabutonButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "座布団（白黒）")
            self.zabutonButton.setImage(buttonImage, for: .normal)
        }
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        let zabutonNumber = postData.zabutons.count
        zabutonLabel.text = "\(zabutonNumber)"
    }
}

