//
//  ShippingViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit

class ShippingTableCell: UITableViewCell{
   
    @IBOutlet weak var sellerL: UILabel!
    @IBOutlet weak var sellerC: UILabel!
    @IBOutlet weak var sellerD: UILabel!
    @IBOutlet weak var storeL: UILabel!
    @IBOutlet weak var storeC: UIButton!
    @IBOutlet weak var sellerImg: UIImageView!
    @IBOutlet weak var shippingL: UILabel!
    @IBOutlet weak var shippingC: UILabel!
    @IBOutlet weak var shippingD: UILabel!
    @IBOutlet weak var shippingImg: UIImageView!
    @IBOutlet weak var returnL: UILabel!
    @IBOutlet weak var returnC: UILabel!
    @IBOutlet weak var returnD: UILabel!
    @IBOutlet weak var returnImg: UIImageView!
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

class ShippingViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {
   

    @IBOutlet weak var SellerTable: UITableView!
    @IBOutlet weak var ShippingTable: UITableView!
    @IBOutlet weak var ReturnTable: UITableView!
    
    @IBOutlet weak var noDetails: UILabel!
    
    var seller:[String:Any] = [:]
    var shipping:[String:Any] = [:]
    var shipCost:String = ""
    var policy:[String:Any] = [:]
    var sellerKeys:[String] = []
    var shipKeys:[String] = []
    var returnKeys:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("tab in shipping info: ")
        print(shipping)
        print("tab in spolicy info: ")
        print(policy)
        print("tab in seller info: ")
        print(seller)
        SellerTable.delegate = self
        SellerTable.dataSource = self
        SellerTable.isScrollEnabled = false
        ShippingTable.delegate = self
        ShippingTable.dataSource = self
        ShippingTable.isScrollEnabled = false
        ReturnTable.delegate = self
        ReturnTable.dataSource = self
        ReturnTable.isScrollEnabled = false
        sellerKeys = Array(seller.keys)
        sellerKeys.insert("Default", at: 0)
        sellerKeys.append("")
        shipKeys.append("Shipping Cost")
        shipKeys = Array(shipping.keys)
        shipKeys.insert("Shipping Cost", at: 0)
        shipKeys.insert("Default", at: 0)
        returnKeys = Array(policy.keys)
        returnKeys.insert("Default", at: 0)
        SellerTable.reloadData()
        ShippingTable.reloadData()
        ReturnTable.reloadData()
        SellerTable.tableFooterView = UIView(frame: .zero)
        ShippingTable.tableFooterView = UIView(frame: .zero)
        ReturnTable.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == SellerTable){
            //print("in seller table!")
            //print(SellerTable.contentSize.height)
            //sellerHeight.constant = SellerTable.contentSize.height
            return sellerKeys.count
        }
        else if(tableView == ShippingTable){
            //print("in shipping table!")
            //print(ShippingTable.contentSize.height)
            //shippingHeight.constant = ShippingTable.contentSize.height
            return shipKeys.count
        }
        else{
            //returnHeight.constant = ReturnTable.contentSize.height
            return returnKeys.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == SellerTable){
            let key = sellerKeys[indexPath.row]
            if(key == "Default"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell1", for: indexPath) as! ShippingTableCell
                cell.sellerD.text = "Seller"
                cell.sellerImg.image = UIImage(named: "Seller")
                return cell
            }
            else if(key == "Store Name"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell3", for: indexPath) as! ShippingTableCell
                 let json = seller[key] as? [String:Any]
                cell.storeL.text = key
                let storeName = (json!["name"] as? String)!
                let attributedString = NSMutableAttributedString(string: storeName)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: storeName.count))
                cell.storeC.setAttributedTitle(attributedString, for: .normal)
                cell.url = (json!["url"] as? String)!
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell2", for: indexPath) as! ShippingTableCell
                cell.sellerL.text = key
                cell.sellerC.text = seller[key] as? String
                //cell.separatorInset = .zero
                if(indexPath.row != sellerKeys.count - 1){
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                }
                return cell
            }
        }
        else if(tableView == ShippingTable){
            let key = shipKeys[indexPath.row]
            if(key == "Default"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "shippingCell1", for: indexPath) as! ShippingTableCell
                cell.shippingD.text = "Shipping Info"
                cell.shippingImg.image = UIImage(named: "Shipping Info")
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "shippingCell2", for: indexPath) as! ShippingTableCell
                cell.shippingL.text = key
                if(key == "Shipping Cost"){
                    cell.shippingC.text = shipCost
                }
                else{
                    cell.shippingC.text = shipping[key] as? String
                }
                //cell.separatorInset = .zero
                if(indexPath.row != shipKeys.count - 1){
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                }
                return cell
            }
        }
        else{
            let key = returnKeys[indexPath.row]
            if(key == "Default"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "returnCell1", for: indexPath) as! ShippingTableCell
                cell.returnD.text = "Return Policy"
                cell.returnImg.image = UIImage(named: "Return Policy")
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "returnCell2", for: indexPath) as! ShippingTableCell
                cell.returnL.text = key
                cell.returnC.text = policy[key] as? String
                //cell.separatorInset = .zero
                if(indexPath.row != returnKeys.count - 1){
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                }
                return cell
            }
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


