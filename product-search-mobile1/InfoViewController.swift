//
//  InfoViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner

class InfoTableViewCell : UITableViewCell {
  
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var content: UILabel!
    //  @IBOutlet weak var label: UILabel!
   // @IBOutlet weak var content: UILabel!
}

class InfoViewController: UIViewController, UIScrollViewDelegate,  UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var facebook: UIBarButtonItem!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var editList: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var infoScrollView: UIScrollView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var noSpecific: UILabel!
    @IBOutlet weak var InfoTable: UITableView!
    //@IBOutlet weak var InfoTable: UITableView!
    
    //@IBOutlet weak var tableHeight: NSLayoutConstraint!
    //@IBOutlet weak var tableWidth: NSLayoutConstraint!
    var id:String = ""
    var info:[String:Any] = [:]
    var itemInfo:[String:Any] = [:]
    var keys:[String] = []
    var name:String = ""
    var price:String = ""
    var storeUrl :String = ""
    var imgs:[String] = []
    var display:[Data] = []
    var frame = CGRect(x:0, y:0, width:0, height:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Product Details...")
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
            
        }
        //print("get title from tab info!")
        //print(name)
        //print(imgs)
    //navigationController?.isNavigationBarHidden = true
        keys = Array(info.keys)
        InfoTable.isScrollEnabled = true
        
        if(keys.count == 0){
            noSpecific.isHidden = false
            InfoTable.isHidden = true
        }
        else{
            noSpecific.isHidden = true
            InfoTable.isHidden = false
        }
        itemName.text = name
        itemPrice.text = price
        infoTitle.text = "Description"
        infoIcon.image = UIImage(named: "description")
        InfoTable.delegate = self
        InfoTable.dataSource = self
        InfoTable.reloadData()
        InfoTable.frame = CGRect(x: InfoTable.frame.origin.x, y:  InfoTable.frame.origin.y, width: InfoTable.frame.size.width, height: InfoTable.contentSize.height)
      
        InfoTable.tableFooterView = UIView(frame: .zero)
        pageControl.numberOfPages = imgs.count
        for i in 0..<imgs.count {
            //let tmpImg = "https" + pic.dropFirst(4)
            //print(tmpImg)
            let imgUrl = URL(string: imgs[i])
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: imgUrl!) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading cat picture: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if let res = response as? HTTPURLResponse {
                        //print("Downloaded cat picture with response code \(res.statusCode)")
                        if let imageData = data {
                            // Finally convert that Data into an image and do what you wish with it.
                            DispatchQueue.main.async {
                                //self.display.append(imageData)
                                self.frame.origin.x = self.scrollView.frame.size.width * CGFloat(i)
                                self.frame.size = self.scrollView.frame.size
                                let imgView = UIImageView(frame: self.frame)
                                //imgView.frame.size = CGSize(width: self.scrollView.frame.size.width, height:self.scrollView.frame.size.height)
                                imgView.image =
                                    UIImage(data:imageData)
                                self.scrollView.addSubview(imgView)
                                //self.testImg.image = //UIImage(data:imageData)
                            }
                            // Do something with your image.
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            downloadPicTask.resume()
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideSpinner), userInfo: nil, repeats: false)
            
        }
        scrollView.contentSize = CGSize(width:(scrollView.frame.size.width * CGFloat(imgs.count)), height: scrollView.frame.size.height)
        scrollView.delegate = self
        //print("get display image:")
        //print(display)
        //testImg.image = UIImage(data:display[0])
        /*let tmpImg = "https" + item.img.dropFirst(4)
        let imgUrl = URL(string: tmpImg)
        */
        // Do any additional setup after loading the view.
    }
    //ScrollView Method
    //----------------------------------
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
            print("in info: product is not in wish list")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
            print("in info: product is in wish list")
        }
    }
    @objc func hideSpinner(){
        SwiftSpinner.hide()
    }
    
    @IBAction func editWish(_ sender: UIBarButtonItem) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            UserDefaults.standard.set(itemInfo, forKey: id)
            editList.image = UIImage(named:"wishListFilled")
        }
        else{
            UserDefaults.standard.removeObject(forKey: id)
            editList.image = UIImage(named:"wishListEmpty")
            
        }
    }
   
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareToFacebook(_ sender: Any) {
        let content = "Buy " + name + " for " + price + " from EBay!"
        let newContent = content.encodeURIComponent()
        let link = "https://www.facebook.com/sharer/sharer.php?u=" + storeUrl + "&quote=" + newContent!
        let url = URL(string: link)
        UIApplication.shared.open(url!, options: [:])
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
            let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
            pageControl.currentPage = Int(pageNumber)
    
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.contentOffset.y = 0.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tableHeight.constant = InfoTable.contentSize.height
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
        let key = keys[indexPath.row]
        cell.label?.text = key
        cell.content?.text = info[key] as? String
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
