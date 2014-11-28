//
//  AudioControls.swift
//  audioplayer
//
//  Created by Johan Hosk on 26/11/14.
//  Copyright (c) 2014 Johan Hosk. All rights reserved.
//

import Foundation
import UIKit


class AudioPlayerControls : UIView {
  
  var audioPlayer : AudioPlayer?
  var audioSlider : AudioSlider = AudioSlider(frame: CGRectZero)
  
  
  
  var isSeeking = false

  @IBOutlet var playPauseButton: UIButton!
  
  @IBOutlet var timePassedLabel: UILabel!
  
  @IBOutlet var timeLeftLabel: UILabel!
  
  @IBOutlet var audioSliderView: UIView!
  
  
  class func nibName() -> String {
    return "AudioPlayerControls"
  }
  
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    //
    super.init(frame: frame)
  }
  
  class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> AudioPlayerControls? {
    return UINib(
      nibName: nibNamed,
      bundle: bundle
      ).instantiateWithOwner(nil, options: nil)[0] as? AudioPlayerControls
  }
  
  override func awakeFromNib() {
    self.audioSliderView.backgroundColor = UIColor.clearColor()
    self.audioSliderView.addSubview(self.audioSlider)
    self.audioSlider.frame = CGRectMake(0, 0, self.audioSliderView.frame.size.width, self.audioSliderView.frame.size.height)     //self.audioSlider.center = self.audioSlider.center
    self.audioSlider.audioPlayerControls = self
    
    
    self.audioSlider.addTarget(self, action: "audioSliderValueChanged:", forControlEvents: .ValueChanged)
    
  }
  
  func audioSliderBeginScrubbing() {
    println("audio slider began scrubbing")
    
    if self.audioPlayer!.player != nil {
      self.audioPlayer!.removePlayerTimerObserver()
      self.audioPlayer!.player!.rate = 0.0
    }

  
  }
  
  @IBAction func playPauseButtonPressed(sender: AnyObject) {
    
  }
  
  func audioSliderValueChanged(audioSlider: AudioSlider) {
    println("audio slider value changed: (\(audioSlider.sliderValue))")
    
    
  }
  
  func audioSliderEndedScrubbing() {
    println("audio slider ended scrubbing")
  }
  
  
  func setDurationLabel(durationString : String) {
  
  }
  
  func setTimeLeftLabel(timeLeftString : String) {
    
  }
  
  
  
  
  
  
  
}
