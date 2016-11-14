//
//  ViewController.swift
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/17/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        var rtspPlayer:RTSPPlayer =
        
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        openRTSPPanel()
    }
    
    @IBAction func button2Pressed(_ sender: UIButton) {
        openRTSPSceneKit()
    }
    
    
}

extension ViewController{
    
    func openRTSPPanel(){
        let storyboard: UIStoryboard = UIStoryboard(name: "RTSPPanel", bundle: nil)
        
        let rtspPenal:RTSPPanel = storyboard.instantiateViewController(withIdentifier: "RTSPPanel") as! RTSPPanel
        
        present(rtspPenal, animated: true, completion: nil)
    }
    
    func openRTSPOpenGL(){
        let storyboard: UIStoryboard = UIStoryboard(name: "RTSPOpenGL", bundle: nil)
        let rtspOpenGL:RTSPOpenGL = storyboard.instantiateViewController(withIdentifier: "RTSPOpenGL") as! RTSPOpenGL
        present(rtspOpenGL, animated: true, completion: nil)
    }
    
    func openRTSPSceneKit(){
        let storyboard: UIStoryboard = UIStoryboard(name: "RTSPSceneKit", bundle: nil)
        let rtspSceneKit:RTSPSceneKit = storyboard.instantiateViewController(withIdentifier: "RTSPSceneKit") as! RTSPSceneKit
        present(rtspSceneKit, animated: true, completion: nil)
    }

    
}
