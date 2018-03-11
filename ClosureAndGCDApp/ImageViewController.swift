//
//  ImageViewController.swift
//  ClosureAndGCDApp
//
//  Created by Sergio Cabrera Hernández on 5/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func downloadImage(_ sender: Any) {
        let button = sender as! UIButton
        
        activityIndicator.startAnimating()
        button.isEnabled = false
        
        // Está creada en el hilo principal con lo que la closure asociada se ejecutará en main thread
        DispatchQueue.global(qos: .utility).async {
            self.downloadClosure(button: button)
        }
        // es lo mismo que: queue.async(execute: downloadClosure)
    }
    
    
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
}
