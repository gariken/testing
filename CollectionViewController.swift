//
//  CollectionViewController.swift
//  IP
//
//  Created by Александр on 15.03.16.
//  Copyright © 2016 Александр. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import M13PDFKit

private let reuseIdentifier = "Cell"
private let ident = "showPDF"  //открыть через фреймворк
private let showSetting = "settingVC"
private let shoWebView = "WebViewPdf" //открыть через webView


var names = ["Февраль 2016", "Декабрь 2015", "Ноябрь 2015", "октябрь 2015", "Сентябрь 2015", "Август 2015", "Июль 2015"] //имена журналов в локальной директории

class CollectionViewController: UICollectionViewController {
    @IBOutlet var theCollectionView: UICollectionView!
    var datas : [JSON] = []   //JSON
    var labels = [String!]()  //Нанзвания журналов
    var images = [String!]()  //Картинка
    var urls = [String!]()    //URL журнала
    

 
    
    override func viewDidLoad() {
        super.viewDidLoad()
            requestServer()
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func settingView(sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(showSetting) as! settingViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
 
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count //вернуть количество объетов
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.textView.textColor = UIColorFromRGB("CA3B65")
        cell.progressView.hidden = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let imageString = self.images[indexPath.row]
            let imageUrl = NSURL(string: imageString)
            let data = NSData(contentsOfURL: imageUrl!)
        
            
                dispatch_async(dispatch_get_main_queue(), {
                    
                    cell.textView.text = (named: self.labels[indexPath.row])
                    cell.imageView.image = UIImage(data: data!)
                    
               })
            
        })
    
        return cell
    }
 
  
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let indexPath = self.collectionView?.indexPathForCell((sender as! UICollectionViewCell)){
            if (segue.identifier == ident) {
                let viewers : PDFKBasicPDFViewer = segue.destinationViewController as! PDFKBasicPDFViewer
                let targetUrl  = NSBundle.mainBundle().pathForResource(names[(indexPath.row)], ofType: "pdf", inDirectory: "supporting files/other")
                let document : PDFKDocument = PDFKDocument(contentsOfFile: targetUrl, password: nil)
                viewers.loadDocument(document)
           }
        }
    }


    func requestServer(){
        Alamofire.request(.GET, "http://apps.iskusstvo-potreblenija.ru/appiis.json")
            .responseJSON{ response in
                let value = response.result.value
                let json = JSON(value!)
                if json != nil{
                    if let data = json["Data"].arrayValue as [JSON]?{
                        self.datas = data
                        self.theCollectionView.reloadData()
                    }
                    let ct = self.datas.count
                    for index in 0...ct-1{
                        if let dan = (json["Data", index, "name"].string){
                            self.labels.append(dan)
                        }
                        if let img = (json["Data", index, "image"].string){
                            self.images.append(img)
                        }
                        if let url = (json["Data", index, "url"].string){
                            self.urls.append(url)
                        }
                    }
                }
        }
    }
    
    

    //RGB
    func UIColorFromRGB(colorCode: String, alpha: Float = 1.0) -> UIColor {
        let scanner = NSScanner(string:colorCode)
        var color:UInt32 = 0
        scanner.scanHexInt(&color)
        
        let mask = 0x000000FF
        let r = CGFloat(Float(Int(color >> 16) & mask)/255.0)
        let g = CGFloat(Float(Int(color >> 8) & mask)/255.0)
        let b = CGFloat(Float(Int(color) & mask)/255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }

  

}
