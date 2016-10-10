//
//  TweetCell.swift
//  03_开源中国界面
//
//  Created by gaokunpeng on 16/9/23.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import Kingfisher

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var bigImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    //文字的一行高度
    class var textH: CGFloat {
        return 20
    }
    
    //子视图纵向的间距
    class var marginY: CGFloat {
        return 10
    }
    
    //大图片的高度
    class var imageH: CGFloat {
        return 50
    }
    
    
    //显示数据
    func configModel(model: TweetModel) {
        
        //用户头像
        let url = NSURL(string: model.portrait!)
        userImageView.kf_setImageWithURL(url!)
        
        //用户名
        nameLabel.text = model.author
        
        //评论数
        commentLabel.text = model.commentCount
        
        //当前的y值
        var offsetY: CGFloat = TweetCell.textH + TweetCell.marginY*2
        
        //描述文字
        //计算文字的高度
        let bodyStr = NSString(string: model.body!)
        //bodyStr.sizeWithAttributes(<#T##attrs: [String : AnyObject]?##[String : AnyObject]?#>)
        /*
         第一个参数:文字允许显示的最大范围
         第二个参数:文字的显示规则
         第三个参数:字体的属性
         第四个参数:nil
         */
        
        let dict = [NSFontAttributeName: UIFont.systemFontOfSize(17)]
        let bodyH = bodyStr.boundingRectWithSize(CGSizeMake(255, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: dict, context: nil).size.height
        
        //设置文字
        bodyLabel.text = model.body
        //修改高度
        bodyLabel.frame.size.height = bodyH
        
        offsetY += (bodyH + TweetCell.marginY)
        
        
        //大图片
        if model.imgBig?.characters.count > 0 {
            //有图片
            bigImageView.hidden = false
            
            let bigUrl = NSURL(string: model.imgBig!)
            bigImageView.kf_setImageWithURL(bigUrl!)
            
            //修改位置
            bigImageView.frame.origin.y = offsetY
            
            offsetY += (TweetCell.imageH + TweetCell.marginY)

        }else{
            //没有图片
            bigImageView.hidden = true
        }
        
        
        //时间
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let pubDate = df.dateFromString(model.pubDate!)
        
        //计算时间差
        let time = NSDate().timeIntervalSinceDate(pubDate!)
        var timeStr = String()
        if time > 24*60*60 {
            timeStr = "一天前"
        }else if time > 60*60 {
            timeStr = String(format: "%d小时前", Int(time)/60/60)
        }else if time > 60 {
            timeStr = String(format: "%d分钟前", Int(time)/60)
        }else{
            timeStr = String(format: "%d秒前", Int(time))
        }
        
        if model.appclient == "1" {
            timeStr = timeStr + " 来自iPhone客户端"
        }else if model.appclient == "2" {
            timeStr = timeStr + " 来自Andriod客户端"
        }
        
        timeLabel.text = timeStr
        //修改位置
        timeLabel.frame.origin.y = offsetY
    }
    
    //计算cell的高度
    class func cellHeightForModel(model: TweetModel) -> CGFloat {
        
        //用户名
        var height = textH + marginY*2
        //body
        let bodyStr = NSString(string: model.body!)
        let bodyH = bodyStr.boundingRectWithSize(CGSizeMake(255, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17)], context: nil).size.height
        
        height += (bodyH+marginY)
        
        //图片
        if model.imgBig?.characters.count > 0 {
            height += (imageH+marginY)
        }
        
        //时间
        height += (textH + marginY)
        
        return height
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
