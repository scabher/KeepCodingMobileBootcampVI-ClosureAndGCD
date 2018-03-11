//
//  ViewController.swift
//  ClosureAndGCDApp
//
//  Created by Sergio Cabrera Hernández on 5/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit

// Clase abstracta donde tendremos que sobreescribir la función main
// que es lo que se ejecutará en background
class DownloadImgOperation: Operation {
    
    let urlString:String
    var imageClosure:((Bool ,UIImage?, Error?)->Void)?
    var end = false
    override var isFinished: Bool {
        return end
    }
    
    init(urlString:String) {
        self.urlString = urlString
        super.init()
    }
    
    override func main() {
        if let endClosure = imageClosure {
            let url = URL(string: urlString)
            
            let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: { (data, urlResponse, error) in
                if let realData = data {
                    endClosure(true, UIImage(data: realData), nil)
                } else {
                    endClosure(false, nil, error!)
                }
                
                // Si sobreescribimos una propiedad, somos nosotros quien tiene que avisar de sus cambios
                self.willChangeValue(forKey: "isFinished") // KVO.
                self.end = true
                _ = self.isFinished
                self.didChangeValue(forKey: "isFinished")   // KVO
                
            })
            dataTask.resume()
        }
    }
}
