//
//  ShippingViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner
extension UILabel {
    func calculateMaxLines(actualWidth: CGFloat?) -> Int {
        var width = frame.size.width
        if let actualWidth = actualWidth {
            width = actualWidth
        }
        let maxSize = CGSize(width: width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

class ShippingTableCell: UITableViewCell{
   

    @IBOutlet weak var sellerL: UILabel!
    @IBOutlet weak var sellerC: UILabel!
    @IBOutlet weak var sellerD: UILabel!
    @IBOutlet weak var storeL: UILabel!
    @IBOutlet weak var storeC: UIButton!
    @IBOutlet weak var sellerImg: UIImageView!
    @IBOutlet weak var feedbackC: UIImageView!
    @IBOutlet weak var feedbackL: UILabel!
    var url:String = ""
    @IBAction func viewStore(_ sender: UIButton) {
        let storeUrl = URL(string: url)
        UIApplication.shared.open(storeUrl!, options: [:])
    }
}
extension UIButton {
    func underlineMyText() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
    attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
extension UIColor {
    static let silver = UIColor(red:204/255, green:204/255, blue:204/255, alpha:1.0)
    static let turquoise = UIColor(red:0/255, green:255/255, blue:255/255, alpha:1.0)
}

class ShippingViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var editList: UIBarButtonItem!
    @IBOutlet weak var SellerTable: UITableView!
    @IBOutlet weak var editMsg: UILabel!
    
    var seller:[String:Any] = [:]
    var shipping:[String:Any] = [:]
    var shipCost:String = ""
    var policy:[String:Any] = [:]
    var itemInfo:[String:Any] = [:]
    var sellerKeys:[String] = []
    var shipKeys:[String] = []
    var returnKeys:[String] = []
    var name:String = ""
    var price:String = ""
    var storeUrl = ""
    var id = ""
    var secCnt = 0
    var headers:[String] = []
    var headerImgs:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Shipping Data...")
        SellerTable.delegate = self
        SellerTable.dataSource = self
        SellerTable.isScrollEnabled = false
        SellerTable.estimatedRowHeight = 30
        SellerTable.rowHeight = UITableView.automaticDimension
        sellerKeys = Array(seller.keys)
        shipKeys = Array(shipping.keys)
        shipKeys.insert("Shipping Cost", at: 0)
        print("get shipcodt!!!!")
        print(shipCost)
        returnKeys = Array(policy.keys)
        editMsg.isHidden = true
        editMsg.layer.zPosition = 1;
        editMsg.layer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
        editMsg.layer.cornerRadius = 5.0
        editMsg.layer.masksToBounds = true
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
        }
        if sellerKeys.count != 0 {
            headers.append("Seller")
            headerImgs.append(UIImage(named:"Seller")!)
        }
        if shipKeys.count != 0 {
            headers.append("Shipping Info")
            headerImgs.append(UIImage(named:"Shipping Info")!)
        }
        if returnKeys.count != 0 {
            headers.append("Return Policy")
            headerImgs.append(UIImage(named:"Return Policy")!)
        }
        SellerTable.reloadData()
        SellerTable.tableFooterView = UIView(frame: .zero)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideSpinner), userInfo: nil, repeats: false)
    }
    @objc func hideSpinner(){
        SwiftSpinner.hide()
    }
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            editList.image = UIImage(named:"wishListEmpty")
            print("in shipping: product is not in wish list")
        }
        else{
            editList.image = UIImage(named:"wishListFilled")
            print("in shipping: product is in wish list")
        }
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
    
    @IBAction func shareToFacebook(_ sender: UIBarButtonItem) {
        let content = "Buy " + name + " for " + price + " from EBay!"
        let newContent = content.encodeURIComponent()
        let link = "https://www.facebook.com/sharer/sharer.php?u=" + storeUrl + "&quote=" + newContent! + "&hashtag=%23CSCI571Spring2019Ebay"
        let url = URL(string: link)
        UIApplication.shared.open(url!, options: [:])
    }
    @IBAction func goBack(_ sender: UIBarButtonItem) {
         self.dismiss(animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
       return headers.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view  = UIView()
        let TopseperatorView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        TopseperatorView.backgroundColor = UIColor(red:0.90, green:0.88, blue:0.88, alpha:1.0)
        let seperatorView = UIView(frame: CGRect(x: 0, y: 28, width: tableView.frame.width, height: 1))
         seperatorView.backgroundColor = UIColor(red:0.90, green:0.88, blue:0.88, alpha:1.0)
        let image = UIImageView(image: headerImgs[section])
        image.frame = CGRect(x: 10, y: 0, width:25, height: 25)
        let label = UILabel()
        label.text = headers[section]
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.frame = CGRect(x: 50, y: 0, width:200, height: 30)
        if section == 0 {
            view.addSubview(TopseperatorView)
        }
        view.addSubview(image)
        view.addSubview(label)
        view.addSubview(seperatorView)
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // UIView with darkGray background for section-separators as Section Footer
        let v = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 0.1))
        if(section == headers.count-1){
             v.backgroundColor = UIColor.white
        }
        else{
            v.backgroundColor = UIColor(red:0.90, green:0.88, blue:0.88, alpha:1.0)
        }
        return v
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(headers[indexPath.section] == "Return Policy"){
            let key = returnKeys[indexPath.row]
            if key == "Return Mode" {
                let content = policy[key] as? String
                if (content?.count)! <= 20{
                    return 30
                }
                else if (content?.count)! <= 40 {
                     return 45
                }
                else{
                    return 60
                }
            }
            else{
                return 30
            }
        }
        else{
            return 30
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(headers[section] == "Seller"){
             return sellerKeys.count
        }
        else if(headers[section] == "Shipping Info"){
            return shipKeys.count
        }
        else{
            return returnKeys.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(headers[indexPath.section] == "Seller"){
            let key = sellerKeys[indexPath.row]
            if(key == "Store Name"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell3", for: indexPath) as! ShippingTableCell
                 let json = seller[key] as? [String:Any]
                cell.storeL.text = "          " + key
                let storeName = (json!["name"] as? String)!
                let attributedString = NSMutableAttributedString(string: storeName)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: storeName.count))
                cell.storeC.setAttributedTitle(attributedString, for: .normal)
                cell.url = (json!["url"] as? String)!
                return cell
            }
            else if(key == "Feedback Star"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell4", for: indexPath) as! ShippingTableCell
                cell.feedbackL.text = key
                let score = Int((seller["Feedback Score"] as? String)!)
                let color = (seller[key] as? String)!
                if(score! < 10000){
                    cell.feedbackC.image = UIImage(named:"starBorder")
                }
                else{
                    cell.feedbackC.image = UIImage(named:"star")
                }
                cell.feedbackC.image = cell.feedbackC.image?.withRenderingMode(.alwaysTemplate)
                if color == "Red"{
                    cell.feedbackC.tintColor = UIColor.red
                }
                else if color == "Yellow" {
                    cell.feedbackC.tintColor = UIColor.yellow
                }
                else if color == "White" {
                    cell.feedbackC.tintColor = UIColor.white
                }
                else if color == "Purple" {
                    cell.feedbackC.tintColor = UIColor.purple
                }
                else if color == "Green" {
                    cell.feedbackC.tintColor = UIColor.green
                }
                else if color == "Silver" {
                    cell.feedbackC.tintColor = UIColor.silver
                }
                else if color == "Turquoise" {
                    cell.feedbackC.tintColor = UIColor.turquoise
                }
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell2", for: indexPath) as! ShippingTableCell
                cell.sellerL.text = key
                cell.sellerC.text = seller[key] as? String
                cell.sellerC.numberOfLines = 0
                return cell
            }
        }
        else if(headers[indexPath.section] == "Shipping Info"){
            let key = shipKeys[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell2", for: indexPath) as! ShippingTableCell
            cell.sellerL.text = key
            if(key == "Shipping Cost"){
                cell.sellerC.text = shipCost
            }
            else{
                cell.sellerC.text = shipping[key] as? String
                cell.sellerC.numberOfLines = 0
            }
            return cell
        }
        else{
            let key = returnKeys[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell2", for: indexPath) as! ShippingTableCell
            cell.sellerL.text = key
            cell.sellerC.text = policy[key] as? String
            cell.sellerC.numberOfLines = 0
            return cell
        }
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


