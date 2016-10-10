//
//  ViewController.swift
//  03_开源中国界面
//
//  Created by gaokunpeng on 16/9/23.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //数据源数组
    private lazy var dataArray = NSMutableArray()
    
    //表格
    private var tbView: UITableView?
    
    //当前页数
    private var curPage = 0
    
    //创建表格
    func createTableView() {
        
        automaticallyAdjustsScrollViewInsets = false
        tbView = UITableView(frame: CGRectMake(0, 64, 375, 667-64), style: .Plain)
        tbView?.delegate = self
        tbView?.dataSource = self
        view.addSubview(tbView!)
        
        
        //上拉加载更多
        tbView?.footerView = XWRefreshAutoNormalFooter(target: self, action: #selector(loadNextPage))
        
        //下拉刷新
        tbView?.headerView = XWRefreshNormalHeader(target: self, action: #selector(loadFirstPage))
    }
    
    //第一页
    func loadFirstPage() {
        
        curPage = 0
        
        downloadData()
    }
    
    
    //下一页
    func loadNextPage() {
        
        curPage += 1
        //下载
        downloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建表格
        createTableView()
        
        //下载数据
        downloadData()
        
    }
    
    //下载数据
    func downloadData() {
        
        let urlString = String(format: "http://www.oschina.net/action/api/tweet_list?uid=0&pageIndex=%d&pageSize=20", curPage)
        
        let url = NSURL(string: urlString)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            if let tmpError = error {
                print(tmpError)
                print("下载失败")
            }else {
                //XML解析
                self.parseXMLData(data!)
            }
        }
        
        task.resume()
    }
    
    //XML解析
    func parseXMLData(data: NSData) {
        
        //如果是下拉刷新，清空数组
        if curPage == 0 {
            dataArray.removeAllObjects()
        }
        
        let doc = try! GDataXMLDocument(data: data, options: 0)
        //获取tweet节点的数组
        let tweetArray = try! doc.nodesForXPath("/oschina/tweets/tweet") as! [GDataXMLElement]
        //遍历数组，转换成模型对象
        for ele in tweetArray {
            
            let model = TweetModel()
            
            model.id = ele.elementsForName("id").last?.stringValue()
            model.portrait = ele.elementsForName("portrait").last?.stringValue()
            model.author = ele.elementsForName("author").last?.stringValue()
            
            model.authorid = ele.elementsForName("authorid").last?.stringValue()
            model.body = ele.elementsForName("body").last?.stringValue()
            model.attach = ele.elementsForName("attach").last?.stringValue()
            
            model.appclient = ele.elementsForName("appclient").last?.stringValue()
            model.commentCount = ele.elementsForName("commentCount").last?.stringValue()
            model.pubDate = ele.elementsForName("pubDate").last?.stringValue()
            
            model.imgSmall = ele.elementsForName("imgSmall").last?.stringValue()
            model.imgBig = ele.elementsForName("imgBig").last?.stringValue()
            model.likeCount = ele.elementsForName("likeCount").last?.stringValue()
             
            model.isLike = ele.elementsForName("isLike").last?.stringValue()
 
            
            /*
            let attrArray = ["id","portrait","author","authorid","body","attach","appclient","commentCount","pubDate","imgSmall","imgBig","likeCount","isLike"]
            let model = parseModel(ele, nameArray: attrArray,className: "_3_开源中国界面.TweetModel")
            */

            dataArray.addObject(model)
        }
        
        //刷新表格
        dispatch_async(dispatch_get_main_queue()) {
            self.tbView?.reloadData()
            
            //结束刷新状态
            self.tbView?.footerView?.endRefreshing()
            
            self.tbView?.headerView?.endRefreshing()
        }
        
        
    }
    
    /*
     ele: 当前的节点
     nameArray:对象属性的数组
     className:对象所属的类型名
     */
    func parseModel(ele: GDataXMLElement, nameArray: [String], className: String) -> NSObject {
        
        //根据类名创建对象
        let cls = NSClassFromString(className) as! NSObject.Type
        
        let model = cls.init()
        
        for name in nameArray {
            let str = ele.elementsForName(name).last?.stringValue()
            
            let index = name.startIndex.successor()
            
            let setterName = String(format: "set%@%@:", name.substringToIndex(index).capitalizedString, name.substringFromIndex(index))
            print(setterName)
            
            //将字符串转换成方法
            let selector = NSSelectorFromString(setterName)
            
            //动态调用一个方法
            model.performSelector(selector, withObject: str)
        }
        
        return model
    }
    
    /*
    func parseModel(ele: GDataXMLElement, nameArray: [String]) -> TweetModel {
        
        let model = TweetModel()
        
        for name in nameArray {
            let str = ele.elementsForName(name).last?.stringValue()
            
            //isLike -> setIsLike(param: String)
            
            let index = name.startIndex.successor()

            let setterName = String(format: "set%@%@:", name.substringToIndex(index).capitalizedString, name.substringFromIndex(index))
            print(setterName)
            
            //将字符串转换成方法
            let selector = NSSelectorFromString(setterName)
            
            //动态调用一个方法
            model.performSelector(selector, withObject: str)
        }

        return model
    }
    */
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//MARK: UITableView代理
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let model = dataArray[indexPath.row] as! TweetModel
        return TweetCell.cellHeightForModel(model)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "tweetCellId"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? TweetCell
        if nil == cell {
            cell = NSBundle.mainBundle().loadNibNamed("TweetCell", owner: nil, options: nil).last  as? TweetCell
        }
        
        //显示数据
        let model = dataArray[indexPath.row] as! TweetModel
        cell?.configModel(model)
        return cell!
    }
    
}





