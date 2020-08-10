//
//  BlockUserListViewController.swift
//  Oh-Gili
//
//  Created by Raphael on 2020/08/09.
//  Copyright © 2020 takahashi. All rights reserved.
//

import UIKit
import SVProgressHUD

class BlockUserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //  userDefaultsの定義
    var userDefaults = UserDefaults.standard

    @IBOutlet weak var blockUserListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blockUserListTableView.delegate = self
        blockUserListTableView.dataSource = self
    }
    
//MARK:-テーブルビュー
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //もしuserDefaultがnilじゃなかったら、
        if self.userDefaults.array(forKey: "blockUser")as? [String] != nil{
            //userDefaultsから取り出す
            let getBlockUserArray:[String] = (self.userDefaults.array(forKey: "blockUser")as? [String])!
            //セルの数はgetBlockUserArrayの数
            return getBlockUserArray.count
        //userDefaultsがnilだったら、
        }else{
            return 0
        }
    }
    //セルを構築する際
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //userDefaultsから取り出す
        let getBlockUserArray:[String] = self.userDefaults.array(forKey: "blockUser")as! [String]
        print(getBlockUserArray)
        
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // セルに表示する値を設定する
        cell.textLabel!.text = getBlockUserArray[indexPath.row]
        
        return cell
    }
//    //スワイプボタン（ブロック解除ボタン）
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        //userDefaultsから取り出す
//        let getBlockUserArray:[String] = self.userDefaults.array(forKey: "blockUser")as! [String]
//        
//        // 解除のアクションを設定する
//        let action = UIContextualAction(style: .normal  , title: "解除") {
//            (ctxAction, view, completionHandler) in
//            
//            //getBlockUserArrayから一つずつ取り出したものをblockUserIdとし、
//            for blockUserId in getBlockUserArray{
//                //blockUserIdとタップしたblockUserIdが同じであれば、
//                if blockUserId == getBlockUserArray[indexPath.row]{
//                    print("\(blockUserId)を解除")
//                    //userDefaultから削除
//                    self.userDefaults.removeObject(forKey: "blockUser")
//                    //テーブルビューを更新
//                    self.blockUserListTableView.reloadData()
//                    
//                    // 全てのモーダルを閉じる
//                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
//                    SVProgressHUD.showSuccess(withStatus: "ブロックを解除しました。")
//     
//                    
//                }
//                
//            }
//            
//             print(getBlockUserArray)
//            completionHandler(true)
//        }
//        // シェアボタンの色を設定する（青）
//        action.backgroundColor = UIColor(red: 0/255, green: 125/255, blue: 255/255, alpha: 1)
//        
//        // スワイプでの削除を無効化して設定する
//         let swipeAction = UISwipeActionsConfiguration(actions:[action])
//         swipeAction.performsFirstActionWithFullSwipe = true
//        
//         
//        
//         return swipeAction
//        
//    }

}
