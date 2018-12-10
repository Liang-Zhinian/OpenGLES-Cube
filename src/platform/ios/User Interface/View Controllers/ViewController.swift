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
        
        let scalar = UIScreen.main.scale
        let bounds = UIScreen.main.bounds
        let _glView = GLCubeView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
//        _glView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)

        self.view.addSubview(_glView)
        
//        let cubeViewController:CubeViewController = CubeViewController(nibName: nil, bundle: nil);
//
//        self.view.addSubview(cubeViewController.view);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
