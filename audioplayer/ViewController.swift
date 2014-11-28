//
//  ViewController.swift
//  audioplayer
//
//  Created by Johan Hosk on 25/11/14.
//  Copyright (c) 2014 Johan Hosk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var audioPlayerControls : AudioPlayerControls?
  
  var audioPlayer : AudioPlayer?
  
  

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.audioPlayer = AudioPlayer()
    
    
    self.audioPlayerControls = AudioPlayerControls.loadFromNibNamed(AudioPlayerControls.nibName(), bundle: nil)
    self.audioPlayer!.audioPlayerControls = self.audioPlayerControls
    
    self.audioPlayerControls!.center = self.view.center
    self.view.addSubview(self.audioPlayerControls!)
    
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

