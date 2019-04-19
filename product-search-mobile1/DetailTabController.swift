//
//  DetailTabController.swift
//  product-search-mobile1
//
//  Created by 王馨嫻 on 2019/4/9.
//  Copyright © 2019年 王馨嫻. All rights reserved.
//

import UIKit

extension String {
    func encodeURIComponent() -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        return self.addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

class DetailTabController: UITabBarController {
    var id:String = ""
    var name:String = ""
    var price:String = ""
    var shipCost:String = ""
    var shipInfo:[String:Any] = [:]
    var infoOldUrl = "", similarOldUrl = ""
    var itemInfo:[String:Any] = [:]
    var specifics:[String:Any] = [:]
    var imgs:[String] = []
    var similarItems:[[String: Any]] = []
    var returnPolicy:[String:Any] = [:]
    var seller:[String:Any] = [:]
    var pictures:[[String:Any]] = []
    var getData = false
    var storeUrl:String = ""
    override func viewDidLoad() {
        print("shipcost in ttab")
        print(shipCost)
        super.viewDidLoad()
        let tmpName:String = name.encodeURIComponent()!
        //let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Selector(("addTapped")))
        //let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: Selector(("buttonMethod")))
        //let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: Selector(("buttonMethod")))
       // addButton.setImage(UIImage(named: "facebook"))
        self.navigationController?.navigationBar.topItem!.title = ""
        //print("encode name: ")
        //print(tmpName as Any)
        infoOldUrl = "https://product-search-advance.appspot.com/getSingle?itemId=" + id + "&title=" + tmpName
        //print("get details from back url")
        print(infoOldUrl)
        getInfo(id: id, userCompletionHandler: { user, error in
            if let user = user{
                self.similarItems = user["similarItem"] as! [[String : Any]]
                self.seller = user["seller"] as! [String : Any]
                self.returnPolicy = user["policy"] as! [String : Any]
                self.pictures = user["pictures"] as! [[String : Any]]
                self.shipInfo = user["shipping"] as! [String : Any]
                self.storeUrl = user["link"] as! String
                
                DispatchQueue.main.async {
                    guard let viewControllers = self.viewControllers else{
                        return
                    }
                    for viewController in viewControllers{
                        if let photosNavigationController = viewController as? PhotosNavigationController {
                            if let photosViewController = photosNavigationController.viewControllers.first as? PhotosViewController {
                                photosViewController.info = self.pictures
                                photosViewController.name = self.name
                                photosViewController.price = self.price
                                photosViewController.id = self.id
                                photosViewController.itemInfo = self.itemInfo
                                photosViewController.storeUrl = self.storeUrl
                            }
                        }
                        if let shippingNavigationController = viewController as? ShippingNavigationController {
                            if let shippingViewController = shippingNavigationController.viewControllers.first as? ShippingViewController {
                                shippingViewController.seller = self.seller
                                shippingViewController.shipping = self.shipInfo
                                shippingViewController.shipCost = self.shipCost
                                shippingViewController.policy = self.returnPolicy
                                shippingViewController.name = self.name
                                shippingViewController.price = self.price
                                shippingViewController.id = self.id
                                shippingViewController.itemInfo = self.itemInfo
                                shippingViewController.storeUrl = self.storeUrl
                            }
                        }
                        if let similarNavigationController = viewController as? SimilarNavigationController {
                            if let similarViewController = similarNavigationController.viewControllers.first as? SimilarViewController {
                                similarViewController.info = self.similarItems
                                similarViewController.price = self.price
                                similarViewController.name = self.name
                                similarViewController.id = self.id
                                similarViewController.itemInfo = self.itemInfo
                                similarViewController.storeUrl = self.storeUrl
                            }
                        }
                    }
                }
            }
        })
        guard let viewControllers = self.viewControllers else{
            return
        }
        for viewController in viewControllers{
            if let infoNavigationController = viewController as? InfoNavigationController {
                if let infoViewController = infoNavigationController.viewControllers.first as? InfoViewController {
                    infoViewController.info = self.specifics
                    infoViewController.imgs = self.imgs
                    infoViewController.name = self.name
                    infoViewController.price = self.price
                    infoViewController.id = self.id
                    infoViewController.itemInfo = self.itemInfo
                    infoViewController.storeUrl = self.storeUrl
                }
            }
        }
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)], for: .selected)
    UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor:UIColor(red:0.83, green:0.80, blue:0.80, alpha:1.0)], for: .normal)
        
        var selectedImg1 = UIImage(named: "icons8-info-80")
        selectedImg1 = selectedImg1?.tinted(with: UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0))
        var deSelectedImg1 = UIImage(named: "icons8-info-80")
        deSelectedImg1 = deSelectedImg1?.tinted(with: UIColor(red:0.83, green:0.80, blue:0.80, alpha:1.0))
        tabBarItem = self.tabBar.items![0]
        tabBarItem.image = deSelectedImg1
        tabBarItem.selectedImage = selectedImg1
        
        var selectedImg2 = UIImage(named: "icons8-in-transit-80")
        selectedImg2 = selectedImg2?.tinted(with: UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0))
        var deSelectedImg2 = UIImage(named: "icons8-in-transit-80")
        deSelectedImg2 = deSelectedImg2?.tinted(with: UIColor(red:0.83, green:0.80, blue:0.80, alpha:1.0))
        tabBarItem = self.tabBar.items![1]
        tabBarItem.image = deSelectedImg2
        tabBarItem.selectedImage = selectedImg2
        
        var selectedImg3 = UIImage(named: "icons8-google-96")
        selectedImg3 = selectedImg3?.tinted(with: UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0))
        var deSelectedImg3 = UIImage(named: "icons8-google-96")
        deSelectedImg3 = deSelectedImg3?.tinted(with: UIColor(red:0.83, green:0.80, blue:0.80, alpha:1.0))
        tabBarItem = self.tabBar.items![2]
        tabBarItem.image = deSelectedImg3
        tabBarItem.selectedImage = selectedImg3
        
        var selectedImg4 = UIImage(named: "icons8-similar-items-80")
        selectedImg4 = selectedImg4?.tinted(with: UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0))
        var deSelectedImg4 = UIImage(named: "icons8-similar-items-80")
        deSelectedImg4 = deSelectedImg4?.tinted(with: UIColor(red:0.83, green:0.80, blue:0.80, alpha:1.0))
        tabBarItem = self.tabBar.items![3]
        tabBarItem.image = deSelectedImg4
        tabBarItem.selectedImage = selectedImg4
        
    }
    @objc func testing(){
        print("testing!!")
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation*/
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
    

}
