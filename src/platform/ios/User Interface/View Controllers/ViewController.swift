//
//  ViewController.swift
//  airhockey
//
//  Created by Sprite on 2018/12/9.
//  Copyright © 2018年 Learn OpenGL ES. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        let frame = UIScreen.main.bounds
        let _glView = GLCubeView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        
        self.view.addSubview(_glView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
