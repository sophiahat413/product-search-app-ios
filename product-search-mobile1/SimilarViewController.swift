//
//  SimilarViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner

struct itemType{
    var title:String
    var url:String
    var img:String
    var shipping: Double
    var shippingS:String
    var days:Int
    var daysS:String
    var price:Double
    var priceS:String
}
extension itemType: Comparable {
    static func ==(lhs: itemType, rhs: itemType) -> Bool {
        return lhs.title == rhs.title
    }
    
    static func <(lhs: itemType, rhs: itemType) -> Bool {
        return lhs.title < rhs.title
    }
}

class SimilarViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var itemDays: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
}
class SimilarViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var noSimilar: UILabel!
    @IBOutlet weak var sortBy: UILabel!
    @IBOutlet weak var orderBy: UILabel!
    @IBOutlet weak var similarTable: UICollectionView!
    @IBOutlet weak var editList: UIBarButtonItem!
    @IBOutlet weak var editMsg: UILabel!
    @IBOutlet weak var sortLabel: UISegmentedControl!
    @IBOutlet weak var sortingOrder: UISegmentedControl!
    
    var info:[[String:Any]] = []
    var itemInfo:[String:Any] = [:]
    var items:[itemType] = []
    var originalItems:[itemType] = []
    var sortFactor = "", sortOrder = "asc"
    var price:String = ""
    var name:String = ""
    var storeUrl:String = ""
    var id:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Similar Items...")
        similarTable.isHidden = true
        noSimilar.isHidden = true
        editMsg.isHidden = true
        sortLabel.isHidden = true
        sortingOrder.isHidden = true
        sortBy.isHidden = true
        orderBy.isHidden = true
        editMsg.layer.zPosition = 1;
        editMsg.layer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
        editMsg.layer.cornerRadius = 5.0
        editMsg.layer.masksToBounds = true
        sortingOrder.isUserInteractionEnabled = false
        sortingOrder.alpha = 0.6
        //print("tab in similar: ")
        //print(info)
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
            
        }
        for i in info {
            var item = itemType(title:"", url:"", img:"", shipping:0.0, shippingS:"", days:0, daysS:"", price:0, priceS:"")
            let json = i["title"] as? [String:Any]
            item.title = (json!["title"] as? String)!
            item.url = (json!["url"] as? String)!
            item.img =  (i["img"] as? String)!
            item.shipping =  (i["shipping"] as? Double)!
            item.shippingS = (i["shippings"] as? String)!
            item.days =  (i["days"] as? Int)!
            item.daysS = (i["dayss"] as? String)!
            item.price =  (i["price"] as? Double)!
            item.priceS = (i["prices"] as? String)!
            items.append(item)
        }
        similarTable.dataSource = self
        similarTable.delegate = self
        originalItems = items
        similarTable.reloadData()
        if(items.count == 0){
            similarTable.isHidden = true
            noSimilar.isHidden = false
            sortLabel.isHidden = true
            sortingOrder.isHidden = true
            sortBy.isHidden = true
            orderBy.isHidden = true
        }
        else{
            similarTable.isHidden = false
            noSimilar.isHidden = true
            sortLabel.isHidden = false
            sortingOrder.isHidden = false
            sortBy.isHidden = false
            orderBy.isHidden = false
        }
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideSpinner), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
            print("in similar: product is not in wish list")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
            print("in similar: product is  in wish list")
        }
    }
    @objc func hideSpinner(){
        SwiftSpinner.hide()
    }
    @IBAction func sort(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                sortFactor = "default"
                sortingOrder.isUserInteractionEnabled = false
                sortingOrder.alpha = 0.6
            case 1:
                sortFactor = "title"
                sortingOrder.isUserInteractionEnabled = true
                sortingOrder.alpha = 1
            case 2:
                sortFactor = "price"
                sortingOrder.isUserInteractionEnabled = true
                sortingOrder.alpha = 1
            case 3:
                sortFactor = "days"
                sortingOrder.isUserInteractionEnabled = true
                sortingOrder.alpha = 1
            case 4:
                sortFactor = "shipping"
                sortingOrder.isUserInteractionEnabled = true
                sortingOrder.alpha = 1
            default: break
        }
        changeOrder()
    }
    @IBAction func order(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                sortOrder = "asc"
            case 1:
                sortOrder = "desc"
            default: break
        }
        changeOrder()
    }
    func changeOrder(){
        if(sortFactor == "default"){
            items = originalItems
        }
        else{
            if(sortOrder == "desc"){
                if(sortFactor == "title"){
                    items = items.sorted{$0.title > $1.title}
                }
                else if(sortFactor == "price"){
                     items = items.sorted{$0.price > $1.price}
                }
                else if(sortFactor == "days"){
                    items = items.sorted{$0.days > $1.days}
                }
                else if(sortFactor == "shipping"){
                     items = items.sorted{$0.shipping > $1.shipping}
                }
            }
            else if (sortOrder == "asc"){
                if(sortFactor == "title"){
                    items = items.sorted{$0.title < $1.title}
                }
                else if(sortFactor == "price"){
                     items = items.sorted{$0.price < $1.price}
                }
                else if(sortFactor == "days"){
                    items = items.sorted{$0.days < $1.days}
                }
                else if(sortFactor == "shipping"){
                     items = items.sorted{$0.shipping < $1.shipping}
                }
            }
        }
        similarTable.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("enter collection cnt: ")
        print(items.count)
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SimilarViewCell
        cell.layer.borderWidth = 2.0
        cell.layer.cornerRadius = 10.0
        cell.layer.borderColor = UIColor(red:0.69, green:0.69, blue:0.69, alpha:1.0).cgColor
        cell.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        cell.itemTitle.text = items[indexPath.row].title
        cell.itemCost.text = items[indexPath.row].shippingS
        cell.itemDays.text = items[indexPath.row].daysS
        cell.itemPrice.text = items[indexPath.row].priceS
        if items[indexPath.row].img == "N/A" || items[indexPath.row].img.isEmptyOrWhitespace() {
            cell.itemImg.image = UIImage(named: "brokenImage")
        }
        else{
            let oriUrl = items[indexPath.row].img
            var newUrl1 = ""
            if oriUrl.prefix(5) == "https" {
                newUrl1 = oriUrl
            }
            else {
                newUrl1 = "https" + oriUrl.dropFirst(4)
            }
            let newUrl = newUrl1.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let imgUrl = URL(string: newUrl!)
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: imgUrl!) {
                (data, response, error) in
                if let e = error{
                     print("Error downloading cat picture: \(e)")
                }
                else{
                    if let res = response as? HTTPURLResponse{
                        if let imageData = data {
                            DispatchQueue.main.async {
                                cell.itemImg.image = UIImage(data: imageData)
                            }
                        }
                        else{
                            print("Couldn't get image: Image is nil")
                        }
                    }
                    else{
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            downloadPicTask.resume()
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = URL(string: items[indexPath.row].url)
        UIApplication.shared.open(url!, options: [:])
    }
    @IBAction func editWish(_ sender: UIBarButtonItem) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            UserDefaults.standard.set(itemInfo, forKey: id)
            editList.image = UIImage(named:"wishListFilled")
            editMsg.text = name + " was added to the wishList"
        }
        else{
            UserDefaults.standard.removeObject(forKey: id)
            editList.image = UIImage(named:"wishListEmpty")
            editMsg.text = name + " was removed from the wishList"
        }
        editMsg.frame.size.height = editMsg.retrieveTextHeight()
        editMsg.isHidden = false
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            self.editMsg.isHidden = true
        }
    }
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareToFacebook(_ sender: Any) {
        let content = "Buy " + name + " for " + price + " from EBay!"
        let newContent = content.encodeURIComponent()
        let link = "https://www.facebook.com/sharer/sharer.php?u=" + storeUrl + "&quote=" + newContent! + "&hashtag=%23CSCI571Spring2019Ebay"
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
