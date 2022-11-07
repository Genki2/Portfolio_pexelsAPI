//
//  ViewController.swift
//  pexelsAPI
//
//  Created by GENKIFUJIMOTO on 2022/11/07.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    var tappedPhotoLargeUrl = String()
    
    @IBOutlet weak var imageview: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SDWebImag画像表示
        imageview.sd_setImage(with:  URL(string:tappedPhotoLargeUrl),placeholderImage: nil,
                              options: .continueInBackground, completed: nil)
    }
}
