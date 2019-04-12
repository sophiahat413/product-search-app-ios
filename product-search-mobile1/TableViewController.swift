//
//  TableViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/8.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner
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

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemShipCost: UILabel!
    @IBOutlet weak var itemZip: UILabel!
    @IBOutlet weak var itemStatus: UILabel!
    @IBOutlet weak var editWish: UIButton!
    @IBOutlet weak var itemCondition: UILabel!
    var info:[String:Any] = [:]
    var id:String = ""
    @IBAction func editList(_ sender: UIButton) {
            if(UserDefaults.standard.object(forKey: id) == nil){
                UserDefaults.standard.set(info, forKey: id)
                sender.setImage(UIImage(named:"wishListFilled"), for:.normal)
            }
            else{
                UserDefaults.standard.removeObject(forKey: id)
                sender.setImage(UIImage(named:"wishListEmpty"), for:.normal)
            }
    }
}

class TableViewController: UITableViewController {
    var results:[[String:Any]] = Array()
    var text:String = ""
    var items:[itemInfo] = []
    var currentTitle:String = ""
    var currentId:String = ""
    var currentPrice:String = ""
    var currentShip:[String:Any] = [:]
    var currentSpecifics:[String:Any] = [:]
    var currentImg:[String] = []
    var currentSeller:[String:Any] = [:]
    var currentPolicy:[String:Any] = [:]
    var currentItemInfo:[String:Any] = [:]
    var infoOldUrl = ""
    var currentSimilar:[[String:Any]] = []
    var currentPictures:[[String:Any]] = []
    
    @IBOutlet var itemTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Searching...")
        print("getting results")
        print(text)
        
        itemTableView.delegate = self
        itemTableView.dataSource = self
        let tmpUrl:String = text.replacingOccurrences(of: " ", with: "%20")
        let reqUrl = URL(string: tmpUrl)
        
        //print(reqUrl)
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
        SwiftSpinner.hide()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! ItemTableViewCell
        //print("get into view!!")
        //print(items)
        let item = items[indexPath.row]
        let id = results[indexPath.row]["id"] as! String
        cell.itemTitle?.text = item.short_title
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("select one item!!")
        //print(items[indexPath.row])
        currentId = items[indexPath.row].id
        currentShip = items[indexPath.row].shipInfo
        currentTitle = items[indexPath.row].title
        currentPrice = items[indexPath.row].price
        //performSegue(withIdentifier: "getDetails", sender: nil)
        infoOldUrl = "https://product-search-backend.appspot.com/getSingle?itemId=" + currentId
        getInfo(id: currentId, userCompletionHandler: { user, error in
            if let user = user{
                self.currentSpecifics = user["specifics"] as! [String : Any]
                self.currentImg = user["image"] as! [String]
                self.currentItemInfo = user
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "getDetails", sender: nil)
                }
            }
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailTabController
        vc.id = currentId
        vc.shipInfo = currentShip
        vc.specifics = currentSpecifics
        vc.imgs = currentImg
        vc.name = currentTitle
        vc.price = currentPrice
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
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
