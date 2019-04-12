//
//  PhotosViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    @IBOutlet weak var photos: UIScrollView!
    var info:[[String:Any]] = []
    var display:[Data] = []
    var frame = CGRect(x:0, y:0, width:0, height:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Do any additional setup after loading the view.
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.contentOffset.x = 0.0
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
