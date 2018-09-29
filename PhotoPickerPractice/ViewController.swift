//
//  ViewController.swift
//  PhotoPickerPractice
//
//  Created by 坂本貴宏 on 2018/09/29.
//  Copyright © 2018年 坂本貴宏. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import TLPhotoPicker

class ViewController: UIViewController {
    var animalArray = ["Mikeneko", "Pug", "Chihuahua", "American Shorthair", "persian"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView1 = makeImageView(x: 16, y: 133)
        self.view.addSubview(imageView1)
        
        let button = makebutton()
        self.view.addSubview(button)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func makeImageView(x: Int, y:Int) -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: x, y: y, width: 80, height: 80)
        imageView.image = UIImage(named: "\(animalArray[0]).png")
        return imageView
        
    }
    func makebutton() -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 98, y: 480, width: 180, height: 80)
        button.setTitle("select", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "HirakakuPorN-W6", size: 15)
        button.addTarget(self, action: #selector(selectImage(_:)) , for: .touchUpInside)
        return button
    }
    
    
    @objc func selectImage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Segue", sender: nil)
        print("ボタンが押されました")
        
    }
}

