//
//  ImageViewController.swift
//  ClosureAndGCDApp
//
//  Created by Sergio Cabrera Hernández on 5/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

typealias nothingToNothing = () -> Void

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let operationQueue = OperationQueue()
    let mainOpQueue = OperationQueue.main
    
    
    var img1:UIImage?
    var img2:UIImage?
    var img3:UIImage?
    var img4:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func downloadImage(_ sender: Any) {
        let button = sender as! UIButton
        
        activityIndicator.startAnimating()
        button.isEnabled = false
        
        /* Usando GCD
         // Está creada en el hilo principal con lo que la closure asociada se ejecutará en main thread
         DispatchQueue.global(qos: .utility).async {
         self.downloadClosure(button: button)
         }
         // es lo mismo que: queue.async(execute: downloadClosure)
         */
        
        let viewOperation1 = BlockOperation {
            self.imageView1.image = self.img1
        }
        let downloadOperation1 = self.giveMeDownloadOperationFor(index: 1)
        viewOperation1.addDependency(downloadOperation1)
        
        let viewOperation2 = BlockOperation {
            self.imageView2.image = self.img2
        }
        let downloadOperation2 = self.giveMeDownloadOperationFor(index: 2)
        viewOperation2.addDependency(downloadOperation2)
        viewOperation2.addDependency(viewOperation1)
        
        let viewOperation3 = BlockOperation {
            self.imageView3.image = self.img3
        }
        let downloadOperation3 = self.giveMeDownloadOperationFor(index: 3)
        viewOperation3.addDependency(downloadOperation3)
        viewOperation3.addDependency(viewOperation2)
        
        let viewOperation4 = BlockOperation {
            self.imageView4.image = self.img4
        }
        let downloadOperation4 = self.giveMeDownloadOperationFor(index: 4)
        viewOperation4.addDependency(downloadOperation4)
        viewOperation4.addDependency(viewOperation3)
        
        // Se añade de forma aleatoria para comprobar que se muestran en orden 1, 2, 3, 4
        mainOpQueue.addOperation(viewOperation4)
        mainOpQueue.addOperation(viewOperation3)
        mainOpQueue.addOperation(viewOperation2)
        mainOpQueue.addOperation(viewOperation1)
        
        let userViewOperation = BlockOperation {
            self.activityIndicator.stopAnimating()
            button.isEnabled = true
        }
        
        userViewOperation.addDependency(viewOperation4)
        mainOpQueue.addOperation(userViewOperation)
        
        // operationQueue.maxConcurrentOperationCount = 1
        operationQueue.addOperations(
            [downloadOperation1,downloadOperation2,downloadOperation3,downloadOperation4],
            waitUntilFinished: false)
    }
    
    
    func giveMeDownloadOperationFor(index:Int) -> DownloadImgOperation
    {
        var urlString = ""
        
        switch index {
        case 1:
            urlString = "http://c8.alamy.com/comp/KA3NBR/expo92-district-in-seville-sevilla-spain-white-bioclimatic-sphere-KA3NBR.jpg"
        case 2:
            urlString = "https://www.ecestaticos.com/image/clipping/939/56c9f8853cafb0265da40eb3478269a4/expo.jpg"
        case 3:
            urlString = "http://www.hanedanrpg.com/photos/hanedanrpg/12/55932.jpg"
        default:
            urlString = "http://www.alpha-exposiciones.com/wp-content/uploads/2018/03/marathonweek_expo15_mm-106_r1.jpg"
        }
        
        let downloadOperation = DownloadImgOperation(urlString: urlString)
        
        downloadOperation.imageClosure = { (succes:Bool, image:UIImage?, error:Error?) in
            if succes {
                switch index {
                case 1:
                    self.img1 = image
                    
                case 2:
                    self.img2 = image
                    
                case 3:
                    self.img3 = image
                    
                default:
                    self.img4 = image
                }
                
            } else {
                print(error!)
            }
        }
        
        return downloadOperation
    }
    /* Usando GCD
    func downloadClosure(button: UIButton) {
        // Background thread
        let stringURL = "http://www.hanedanrpg.com/photos/hanedanrpg/12/55931.jpg"
        let url = URL(string: stringURL)
        
        do {
            let imgData = try Data.init(contentsOf: url!) // Heavy task
            
            // la actualización del UI siempre se debe hacer en la cola main
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imgData)
                self.activityIndicator.stopAnimating()
                button.isEnabled = true
            }
            
        } catch {
            print(error)
        }
    }
     */
}
