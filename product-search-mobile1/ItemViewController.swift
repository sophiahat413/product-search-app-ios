//
//  ItemViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/13.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner
extension UILabel {
    
    func retrieveTextHeight () -> CGFloat {
        let attributedText = NSAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font:self.font])
        
        let rect = attributedText.boundingRect(with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(rect.size.height)
    }
    
}
struct itemInfo {
    var id: String
    var title: String
    var short_title: String
    var price: String
    var shipCost: String
    var zip: String
    var img: String
    var wish: Bool
    var condition: String
    var shipInfo: [String:Any]
}
protocol SwiftyTableViewCellDelegate : class {
    func showEditList(_ sender: ItemViewCell, title: String, message: String)
}

class ItemViewCell: UITableViewCell{
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemShipCost: UILabel!
    @IBOutlet weak var itemZip: UILabel!
    
    @IBOutlet weak var editWish: UIButton!
    @IBOutlet weak var itemCondition: UILabel!
    var info:[String:Any] = [:]
    var id:String = "", msg = ""
    weak var delegate: SwiftyTableViewCellDelegate?
    
    @IBAction func editList(_ sender: UIButton) {
        if(UserDefaults.standard.object(forKey: id) == nil){
            UserDefaults.standard.set(info, forKey: id)
            sender.setImage(UIImage(named:"wishListFilled"), for:.normal)
            msg = itemTitle.text! + " was added to the wishList"
        }
        else{
            UserDefaults.standard.removeObject(forKey: id)
            sender.setImage(UIImage(named:"wishListEmpty"), for:.normal)
            msg = itemTitle.text! + " was removed from the wishList"
        }
        delegate?.showEditList(self, title:"", message: msg)
    }
}

class ItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwiftyTableViewCellDelegate {
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var editMsg: UILabel!
    var results:[[String:Any]] = Array()
    var text:String = ""
    var items:[itemInfo] = []
    var currentTitle:String = ""
    var currentId:String = ""
    var currentPrice:String = ""
    var currentShipCost:String = ""
    var currentShip:[String:Any] = [:]
    var currentSpecifics:[String:Any] = [:]
    var currentImg:[String] = []
    var currentSeller:[String:Any] = [:]
    var currentPolicy:[String:Any] = [:]
    var currentItemInfo:[String:Any] = [:]
    var infoOldUrl = ""
    var currentSimilar:[[String:Any]] = []
    var currentPictures:[[String:Any]] = []
    var currentInfo:[String:Any] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem?.title = ""
        editMsg.isHidden = true
        editMsg.layer.zPosition = 1;
        editMsg.layer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
        editMsg.layer.cornerRadius = 8.0
        SwiftSpinner.show("Searching...")
        print("getting results")
        print(text)
        self.navigationController?.navigationBar.topItem!.title = ""
        itemTableView.delegate = self
        itemTableView.dataSource = self
        let tmpUrl:String = text.replacingOccurrences(of: " ", with: "%20")
        let reqUrl = URL(string: tmpUrl)
        let auto = URLSession.shared.dataTask(with: reqUrl!){
            (data, response, error) in
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let json = jsonObject as? [[String:Any]] else {
                        return
                    }
                    self.results = json
                    //print(self.results)
                    for data in self.results {
                        var item = itemInfo(id:"", title:"", short_title:"", price:"", shipCost:"", zip:"", img:"", wish:false, condition:"", shipInfo:[:])
                        item.id = data["id"] as! String
                        item.title = data["title"] as! String
                        item.short_title = data["short_title"] as! String
                        item.price = data["price"] as! String
                        item.shipCost = data["shipping"] as! String
                        item.zip = data["zip"] as! String
                        item.img = data["image"] as! String
                        item.shipInfo = data["shipInfo"] as![String:Any]
                        //print(item.shipInfo)
                        item.condition = data["condition"] as! String
                        item.wish = data["wish"] as! Bool
                        self.items.append(item)
                    }
                    DispatchQueue.main.async {
                        self.itemTableView.reloadData()
                        if self.items.count == 0{
                            self.createAlert(title: "No Results!", message: "Failed to fetch search results")
                        }
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
        auto.resume()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideSpinner), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        itemTableView.reloadData()
    }
    @objc func hideSpinner() {
        //print("hide keyword error")
        SwiftSpinner.hide()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemViewCell
        //print("get into view!!")
        //print(items)
        let item = items[indexPath.row]
        let id = results[indexPath.row]["id"] as! String
        cell.delegate = self
        cell.itemTitle?.text = item.title
        cell.itemPrice?.text = item.price
        cell.itemCondition?.text = item.condition
        if(UserDefaults.standard.object(forKey: id) == nil){
            cell.editWish.setImage(UIImage(named:"wishListEmpty"), for:.normal)
        }
        else{
            UserDefaults.standard.removeObject(forKey: id)
            cell.editWish.setImage(UIImage(named:"wishListFilled"), for:.normal)
        }
        
        let tmpImg = "https" + item.img.dropFirst(4)
        let imgUrl = URL(string: tmpImg)
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
                            cell.itemImg.image = UIImage(data: imageData)
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
        cell.itemShipCost?.text = item.shipCost
        cell.itemZip?.text = item.zip
        cell.info = results[indexPath.row]
        
        //cell.info["image"] = cell.itemImg.image
        cell.id = id
        //cell.itemStatus?.text = item.wish
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("select one item!!")
        //print(items[indexPath.row])
        currentId = items[indexPath.row].id
        currentShip = items[indexPath.row].shipInfo
        currentTitle = items[indexPath.row].title
        currentPrice = items[indexPath.row].price
        currentShipCost = items[indexPath.row].shipCost
        currentInfo = results[indexPath.row]
        //performSegue(withIdentifier: "getDetails", sender: nil)
        infoOldUrl = "https://product-search-backend.appspot.com/getSingle?itemId=" + currentId
        getInfo(id: currentId, userCompletionHandler: { user, error in
            if let user = user{
                self.currentSpecifics = user["specifics"] as! [String : Any]
                self.currentImg = user["image"] as! [String]
                self.currentItemInfo = user
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "getItemInfo", sender: nil)
                }
            }
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailTabController
        vc.id = currentId
        vc.shipInfo = currentShip
        vc.specifics = currentSpecifics
        vc.shipCost = currentShipCost
        vc.imgs = currentImg
        vc.name = currentTitle
        vc.price = currentPrice
        vc.itemInfo = currentInfo
    }
    func getInfo(id: String, userCompletionHandler: @escaping([String:Any]?, Error?) -> Void){
        let infoUrl = URL(string: infoOldUrl)
        let task = URLSession.shared.dataTask(with: infoUrl!, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data else { return }
            do{
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = jsonObject as? [String:Any] else {
                    return
                }
                userCompletionHandler(json, nil)
            } catch let error  {
                print("Json parsing error", error )
                userCompletionHandler(nil, error)
            }
        })
        task.resume()
    }
    func createAlert(title:String, message: String){
        let alert = UIAlertController(title:title, message:message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler: { (action) in
            alert.dismiss(animated:true, completion:nil)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func showEditList(_ sender: ItemViewCell, title: String, message: String) {
        editMsg.text = message
        editMsg.frame.size.height = editMsg.retrieveTextHeight()
        editMsg.isHidden = false
        let when = DispatchTime.now() + 1
        print("get item!!!")
        print(message)
        DispatchQueue.main.asyncAfter(deadline: when){
            self.editMsg.isHidden = true
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

}
