//
//  ViewController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/6.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit
import SwiftSpinner
extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
class ViewTableCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var ship: UILabel!
    @IBOutlet weak var zipcode: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var img: UIImageView!
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let myPickerData = [String](arrayLiteral: "All", "Art", "Baby", "Books", "Clothing, Shoes & Accessories", "Computers/Tablets & Networking", "Health & Beauty", "Music", "Video Games & Consoles")
    var key = "", cat = "", dis = "", loc = "", text = "", invalid = true, valid = false, requestURL = ""
    var New = false, Used = false, Unspecified = false, Pickup = false, FreeShip = false
    var zipcodes:[String] = Array()
    var userLocation:String = ""
    let url = URL(string: "https://ipapi.co/json/")
    var results:[String] = Array()
    var wishList:[[String:Any]] = []
    var cnt = 0, totalPrice = 0.0
    var currentId:String = ""
    var currentTitle:String = ""
    var currentPrice:String = ""
    var currentShipCost:String = ""
    var currentItemLink:String = ""
    var infoOldUrl:String = ""
    var currentSpecifics:[String:Any] = [:]
    var currentImg:[String] = []
    var currentItemInfo:[String:Any] = [:]
    
    @IBOutlet weak var totalItemPrice: UILabel!
    @IBOutlet weak var totalItems: UILabel!
    @IBOutlet weak var noItems: UILabel!
    
    @IBOutlet weak var WishList: UITableView!
    @IBOutlet weak var form: UIScrollView!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var new: UIButton!
    @IBOutlet weak var used: UIButton!
    @IBOutlet weak var unspecified: UIButton!
    @IBOutlet weak var pickup: UIButton!
    @IBOutlet weak var freeship: UIButton!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var searchTop: NSLayoutConstraint!
    @IBOutlet weak var clearTop: NSLayoutConstraint!
    @IBOutlet weak var zipSwitch: UISwitch!
    @IBOutlet weak var keywordError: UILabel!
    @IBOutlet weak var autoComplete: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Product Search"
        navigationController?.navigationItem.title = "Product Search"
        let thePicker = UIPickerView()
        thePicker.backgroundColor = UIColor.white
        category.inputView = thePicker
        thePicker.delegate = self
        keywordError.isHidden = true
        totalItemPrice.isHidden = true
        totalItems.isHidden = true
        WishList.isHidden = true
        zipSwitch.isOn = false
        zipcode.isHidden = true
        noItems.isHidden = true
        keyword.delegate = self
        category.delegate = self
        distance.delegate = self
        zipcode.delegate = self
        clearTop.constant = -10
        searchTop.constant = -10
        zipcode.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        autoComplete.delegate = self
        autoComplete.dataSource = self
        autoComplete.isHidden = true
        autoComplete.layer.borderColor = UIColor.darkGray.cgColor
        autoComplete.layer.borderWidth = 2.0
        autoComplete.layer.cornerRadius = 8.0
        autoComplete.register(UITableViewCell.self, forCellReuseIdentifier: "zips")
        //autoComplete.register(UITableViewCell.self, f: "zips")
        let Tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(Tap)
        Tap.cancelsTouchesInView = false
        WishList.isHidden = true
        WishList.tableFooterView = UIView(frame: .zero)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.doneClick))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor :UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)] ,for: UIControl.State.normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.cancelClick))
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor :UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)] ,for: UIControl.State.normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        category.inputAccessoryView = toolBar
        
        let session = URLSession.shared.dataTask(with: url!){
            (data, response, error) in
            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    //print(jsonObject)
                    guard let json = jsonObject as? [String: Any] else {
                        return
                    }
                    print("print postal: ")
                    DispatchQueue.main.async{
                        self.userLocation = json["postal"] as! String
                        print(self.userLocation)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
        session.resume()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationItem.title = "Product Search"
        navigationItem.title = "Product Search"
        getWishList();
    }
    func getWishList(){
        print("wish list")
        wishList = []
        cnt = 0
        totalPrice = 0.0
        let regex = try! NSRegularExpression(pattern: ".*[A-Za-z].*")
        for key in UserDefaults.standard.dictionaryRepresentation().keys{
            let range = NSRange(location: 0, length: key.count)
            if regex.firstMatch(in: key, options: [], range: range) == nil && key.count > 0 {
                let dictionary = UserDefaults.standard.object(forKey: key) as? [String: Any]
                if(!(dictionary?.isEmpty)!){
                    cnt += 1
                    totalPrice += dictionary?["priceN"] as! Double
                    wishList.append(dictionary!)
                }
            }
        }
        WishList.reloadData()
        if(cnt > 0){
            if(cnt > 1){
                totalItems.text = "WishList Total(" + String(cnt) + " items):"
            }
            else {
                totalItems.text = "WishList Total(" + String(cnt) + " item):"
            }
            totalItemPrice.text = "$" + String(totalPrice)
        }
        if(form.isHidden == true){
            if cnt == 0 {
                noItems.isHidden = false
                totalItems.isHidden = true
                totalItemPrice.isHidden = true
                WishList.isHidden = true
            }
            else{
                noItems.isHidden = true
                totalItems.isHidden = false
                totalItemPrice.isHidden = false
                WishList.isHidden = false
            }
        }
    }
   
    @IBAction func showControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                 form.isHidden = false
                 WishList.isHidden = true
                 totalItemPrice.isHidden = true
                 totalItems.isHidden = true
                 noItems.isHidden = true
            case 1:
                 form.isHidden = true
                 getWishList()
                 if cnt == 0 {
                    noItems.isHidden = false
                    totalItems.isHidden = true
                    totalItemPrice.isHidden = true
                    WishList.isHidden = true
                 }
                 else{
                    noItems.isHidden = true
                    totalItems.isHidden = false
                    totalItemPrice.isHidden = false
                    WishList.isHidden = false
                 }
            default:
                break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category.text = myPickerData[row]
    }
    @objc func doneClick() {
        category.resignFirstResponder()
    }
    @objc func cancelClick() {
        category.resignFirstResponder()
    }
    
    @objc func searchRecords(_ textField: UITextField){
        self.zipcodes.removeAll()
        autoComplete.isHidden = false
        var resZips:[String] = Array()
        if zipcode.text?.count != 0 {
            let userzip = zipcode.text!
            let range = NSRange(location: 0, length: userzip.count)
            let regex = try! NSRegularExpression(pattern: "[^0-9]")
            if regex.firstMatch(in: userzip, options: [], range: range) != nil || userzip.count > 5 {
                autoComplete.isHidden = true
                return
            }
            let tmpUrl = "https://product-search-advance.appspot.com/getZips?zip=" + userzip
            let reqUrl = URL(string: tmpUrl)
            
            let auto = URLSession.shared.dataTask(with: reqUrl!){
                (data, response, error) in
                if let data = data {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        guard let json = jsonObject as? [String] else {
                            return
                        }
                        resZips = json
                        DispatchQueue.main.async {
                            self.zipcodes = resZips
                            //self.changeZipcodes(resZips)
                            self.autoComplete.reloadData()
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
            print("get zipcodes when type!!")
            print(zipcodes)
        }
        else{
            autoComplete.isHidden = true
        }
    }
    func changeZipcodes (_ resZips:[String]) {
        zipcodes = resZips
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == autoComplete){
            let cell = tableView.dequeueReusableCell(withIdentifier: "zips")
            if(cell == nil){
                print("nulllllllll")
            }
            return zipcodes.count
        }
        else{
            print("wish list count")
            print(wishList.count)
            return wishList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == autoComplete){
            let cell = tableView.dequeueReusableCell(withIdentifier: "zips")
            if(cell == nil){
                print("cell is empty")
            }
            cell?.textLabel?.text = zipcodes[indexPath.row]
            return cell!
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! ViewTableCell
            cell.name.text = wishList[indexPath.row]["title"] as? String
            cell.price.text = wishList[indexPath.row]["price"] as? String
            cell.ship.text = wishList[indexPath.row]["shipping"] as? String
            cell.status.text = wishList[indexPath.row]["condition"] as? String
            cell.zipcode.text = wishList[indexPath.row]["zip"] as? String
            let imgF = wishList[indexPath.row]["image"] as? String
            if imgF != nil {
                let tmpImg = "https" + imgF!.dropFirst(4)
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
                                    cell.img.image = UIImage(data: imageData)
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
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == autoComplete){
            print("select one item!!")
            print("enter table view get zoipcodes")
            print(zipcodes)
            print(zipcodes[indexPath.row])
            zipcode.text = zipcodes[indexPath.row]
            tableView.isHidden = true
        }
        else{
            currentId = (wishList[indexPath.row]["id"] as? String)!
            currentTitle = (wishList[indexPath.row]["title"] as? String)!
            currentPrice = (wishList[indexPath.row]["price"] as? String)!
            currentShipCost = (wishList[indexPath.row]["shipping"] as? String)!
            //performSegue(withIdentifier: "getDetails", sender: nil)
            infoOldUrl = "https://product-search-backend.appspot.com/getSingle?itemId=" + currentId
            getInfo(id: currentId, userCompletionHandler: { user, error in
                if let user = user{
                    self.currentSpecifics
                        = user["specifics"] as! [String : Any]
                    self.currentImg = user["image"] as! [String]
                    self.currentItemInfo = user
                    self.currentItemLink = user["link"] as! String
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "getDetailFromMain", sender: nil)
                    }
                }
            })
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(tableView == WishList){
            if editingStyle == UITableViewCell.EditingStyle.delete{
                let id = wishList[indexPath.row]["id"] as? String
                UserDefaults.standard.removeObject(forKey: id!)
                cnt -= 1
                totalPrice -= (wishList[indexPath.row]["priceN"] as? Double)!
                if(cnt == 0){
                    noItems.isHidden = false
                    totalItems.isHidden = true
                    totalItemPrice.isHidden = true
                    WishList.isHidden = true
                }
                else{
                    if(cnt > 1){
                        totalItems.text = "WishList Total(" + String(cnt) + " items):"
                    }
                    else{
                        totalItems.text = "WishList Total(" + String(cnt) + " item):"
                    }
                    totalItemPrice.text = "$" + String(totalPrice)
                    wishList.remove(at: indexPath.row)
                    noItems.isHidden = true
                    totalItems.isHidden = false
                    totalItemPrice.isHidden = false
                    WishList.isHidden = false
                }
                WishList.reloadData()
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "getItemList"){
            let vc = segue.destination as! ItemViewController
            vc.text = requestURL
        }
        else{
            let vc = segue.destination as! DetailTabController
            vc.id = currentId
            vc.specifics = currentSpecifics
            vc.shipCost = currentShipCost
            vc.imgs = currentImg
            vc.name = currentTitle
            vc.price = currentPrice
            vc.storeUrl = currentItemLink
        }
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
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    @objc func DismissView(){
        autoComplete.isHidden = true
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton){
        if sender.isSelected{
            sender.isSelected = false
        } else{
            sender.isSelected = true
        }
    }
    
    @IBAction func locationSwitch(_ sender: UISwitch) {
        if(sender.isOn == true){
            zipcode.isHidden = false
            clearTop.constant = 20
            searchTop.constant = 20
        }
        else{
            zipcode.isHidden = true
            zipcode.text = ""
            clearTop.constant = -10
            searchTop.constant = -10
        }
    }
    @IBAction func pressNew(_ sender: UIButton) {
        if(sender.isSelected == true){
            New = true
        }
        else{
            New = false
        }
    }
    @IBAction func pressUsed(_ sender: UIButton) {
        if(sender.isSelected == true){
            Used = true
        }
        else{
            Used = false
        }
    }
    @IBAction func pressUnspecified(_ sender: UIButton) {
        if(sender.isSelected == true){
            Unspecified = true
        }
        else{
            Unspecified = false
        }
    }
    @IBAction func pressPickup(_ sender: UIButton) {
        if(sender.isSelected == true){
            Pickup = true
        }
        else{
            Pickup = false
        }
    }
    @IBAction func pressFreeShip(_ sender: UIButton) {
        if(sender.isSelected == true){
            FreeShip = true
        }
        else{
            FreeShip = false
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if(keyword.text?.isEmpty ?? true){
            print("keyword is empty!")
            keywordError.text = "Keyword Is Mandatory"
            keywordError.isHidden = false
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideKeywordError), userInfo: nil, repeats: false)
            return
        }
        if(zipSwitch.isOn == true){
            if(zipcode.text?.isEmpty ?? true){
                keywordError.isHidden = false
                keywordError.text = "Zipcode Is Mandatory"
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideKeywordError), userInfo: nil, repeats: false)
                return
            }
            if(zipcode.text?.count != 5){
                print("zipcode length is wrong")
                keywordError.text = "Zipcode Is Invalid"
                keywordError.isHidden = false
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideKeywordError), userInfo: nil, repeats: false)
                return
            }
            let userzip = zipcode.text!
            let range = NSRange(location: 0, length: userzip.count)
            let regex = try! NSRegularExpression(pattern: "[^0-9]")
            if regex.firstMatch(in: userzip, options: [], range: range) != nil {
                print("zipcode is invalid")
                keywordError.text = "Zipcode Is Invalid"
                keywordError.isHidden = false
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(hideKeywordError), userInfo: nil, repeats: false)
                return
            }
        }
        invalid = false
        requestURL = "https://product-search-advance.appspot.com/listGet?keyword=";
        //equestURL = "http://localhost:8080/listGet?keyword=";
        key = keyword.text!
        requestURL += key
        cat = category.text!
        dis = distance.text!
        if zipcode.text != ""{
            loc = zipcode.text!
        }
        else{
            loc = userLocation
        }
        if(dis == ""){
            dis = "10"
        }
        text += "Keyword : \(key)\nCategory: \(cat)\nDistance: \(dis)\nCustom Location: \(loc)\nCondition: New \(New) Used \(Used) Unspecified \(Unspecified) \n Shipping: Pickup \(Pickup) FreeShipping \(FreeShip)\n"
        print("text in form")
        print(text)
            if(cat == "All"){
                cat = "all"
            }
            if(cat == "Art"){
                cat = "550"
            }
            if(cat == "Baby"){
                cat = "2987"
            }
            else if(cat == "Books"){
                cat = "267"
            }
            else if(cat == "Clothing, Shoes & Accessories"){
                cat = "11450"
            }
            else if(cat == "Computers/Tablets & Networking"){
                cat = "58058"
            }
            else if(cat == "Health & Beauty"){
                cat = "26395"
            }
            else if(cat == "Music"){
                cat = "11233"
            }
            else if(cat == "Video Games & Consoles"){
                cat = "1249"
            }
            requestURL = requestURL + "&category=" + cat
        
        if(Used){
            requestURL += "&condition1=1";
        }
        else{
             requestURL += "&condition1=0";
        }
        if(New){
            requestURL += "&condition2=1";
        }
        else{
            requestURL += "&condition2=0";
        }
        if(Unspecified){
            requestURL += "&condition3=1";
        }
        else{
            requestURL += "&condition3=0";
        }
        if(Pickup){
            requestURL += "&shipping1=1";
        }
        else{
            requestURL += "&shipping1=0";
        }
        if(FreeShip){
            requestURL += "&shipping2=1";
        }
        else{
            requestURL += "&shipping2=0";
        }
        requestURL = requestURL + "&distance=" + dis;
        requestURL = requestURL + "&zipcode=" + loc;
        print("first request url: ")
        print(requestURL)
        performSegue(withIdentifier: "getItemList", sender: self)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if invalid {
            return false
        }
        return true
    }
    
    @IBAction func reset(_ sender: UIButton) {
        keyword.text = ""
        category.text = "All"
        new.isSelected = false
        used.isSelected = false
        unspecified.isSelected = false
        pickup.isSelected = false
        freeship.isSelected = false
        distance.text = ""
        zipcode.text = ""
        zipSwitch.isOn = false
        zipcode.isHidden = true
        clearTop.constant = -10
        searchTop.constant = -10
    }
    
    @objc func hideKeywordError() {
        //print("hide keyword error")
        keywordError.isHidden = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

