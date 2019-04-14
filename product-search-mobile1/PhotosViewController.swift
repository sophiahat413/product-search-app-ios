//
//  PhotosViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner

class PhotosViewController: UIViewController {

    @IBOutlet weak var photos: UIScrollView!
    @IBOutlet weak var editList: UIBarButtonItem!
    var info:[[String:Any]] = []
    var itemInfo:[String:Any] = [:]
    var display:[Data] = []
    var frame = CGRect(x:0, y:0, width:0, height:0)
    var price:String = ""
    var name:String = ""
    var storeUrl:String = ""
    var id:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Google Images...")
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
        }
        //print("get imahes: ")
        //print(info)
        for i in 0..<info.count {
            let imgUrl = URL(string: info[i]["link"] as! String)
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: imgUrl!){
                (data, response, error) in
                if let e = error {
                    print("Error downloading cat picture: \(e)")
                } else {
                    if let res = response as?
                      HTTPURLResponse {
                        print("Downloaded cat picture with response code \(res.statusCode)")
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.frame.origin.y = self.photos.frame.size.height * CGFloat(i)
                                self.frame.size = self.photos.frame.size
                                let imgView = UIImageView(frame: self.frame)
                                imgView.image =
                                    UIImage(data:imageData)
                                self.photos.addSubview(imgView)
                            }
                         } else {
                                print("Couldn't get image: Image is nil")
                            }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
             downloadPicTask.resume()
        }
        photos.contentSize = CGSize(width: photos.frame.size.width, height: (photos.frame.size.height * CGFloat(info.count)))
        photos.delegate = self as? UIScrollViewDelegate
         Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideSpinner), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
        }
    }
    @objc func hideSpinner(){
        
        SwiftSpinner.hide()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.contentOffset.x = 0.0
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
