//
//  AudioSlider.swift
//  audioplayer
//
//  Created by Johan Hosk on 25/11/14.
//  Copyright (c) 2014 Johan Hosk. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

// MARK: - AudioSlider
class AudioSlider: UIControl {
  
  var audioPlayerControls : AudioPlayerControls?
  
  var scrubberEnabled : Bool = false
  
  var minimumValue : Double = 0.0
  var maximumValue : Double = 1.0
  var sliderValue : Double = 0.0
  
  let trackLayer = CALayer()
  let bufferLayer = CALayer()
  
  let scrubberLayer = ScrubberLayer()
  
  var previousLocation = CGPoint()
  
  /*
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
  */
  
  override var frame: CGRect {
    didSet {
      updateLayerFrames()
    }
  }
  
  var trackMargin: CGFloat {
    return CGFloat(10.0)
  }
  var trackHeight: CGFloat {
    return CGFloat(5.0)
  }
  
  var scrubberWidth: CGFloat {
    return CGFloat(5.0)
  }
  
  var scrubberHeight: CGFloat {
    return CGFloat(bounds.height)
  }
  
  var hitBoxHeight: CGFloat {
    return CGFloat(bounds.height)
  }
  
  var hitBoxWidth: CGFloat {
    return CGFloat((scrubberWidth * 4))
  }
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
 
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clearColor()
    
    trackLayer.backgroundColor = UIColor.blueColor().CGColor
    layer.addSublayer(trackLayer)
    
    bufferLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    layer.addSublayer(bufferLayer)
    
    scrubberLayer.backgroundColor = UIColor.redColor().CGColor
    layer.addSublayer(scrubberLayer)
    
    scrubberLayer.audioSlider = self
    
    updateLayerFrames()
  }

  
  func updateLayerFrames() {
    trackLayer.frame = CGRectMake(0, (scrubberHeight / 2) - (trackHeight / 2), self.frame.size.width , trackHeight)//self.bounds.rectByInsetting(dx: 0.0, dy: bounds.height / 4)
    trackLayer.setNeedsDisplay()
    
    bufferLayer.frame = CGRectMake(0, (scrubberHeight / 2) - (trackHeight / 2), self.frame.size.width, trackHeight) //bounds.rectByInsetting(dx: 0.0, dy: bounds.height / 4)
    trackLayer.setNeedsDisplay()
    
    let scrubberCenter = CGFloat(positionForValue(self.sliderValue))
    self.scrubberLayer.frame = CGRect(x: scrubberCenter - (scrubberWidth / 2.0), y: 0.0, width: scrubberWidth, height: scrubberHeight)
    self.scrubberLayer.setNeedsDisplay()
  }
  
  func positionForValue(value: Double) -> Double {
    let widthDouble = Double(self.scrubberWidth)
    return Double(bounds.width - self.scrubberWidth) * (value - minimumValue) /
      (maximumValue - minimumValue) + Double(self.scrubberWidth / 2.0)
  }
  
  override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
  
    
    previousLocation = touch.locationInView(self)
    
    // Hit test the scrubber with exanded frame for easier hit
    let hitBox = CGRectMake(scrubberLayer.frame.origin.x + (scrubberWidth / 2) - (hitBoxWidth / 2), scrubberLayer.frame.origin.y, hitBoxWidth, hitBoxHeight)
    
    if hitBox.contains(previousLocation) {
      self.audioPlayerControls!.audioSliderBeginScrubbing()
      scrubberLayer.highlighted = true
      
    }
    return scrubberLayer.highlighted && scrubberEnabled
  }
  

  
  override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
    
    if !scrubberEnabled {
      return false
    }
    
    let location = touch.locationInView(self)
    
    // Determine by how much the user has dragged
    let deltaLocation = Double(location.x - previousLocation.x)
    let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double((bounds.width) - bounds.height)
    
    previousLocation = location
    
    // Update the values
    if scrubberLayer.highlighted {
      sliderValue += deltaValue
      sliderValue = boundValue(sliderValue, toLowerValue: minimumValue, upperValue: maximumValue)
      
      
    }
    
    // Update the UI
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    
    updateLayerFrames()
    
    CATransaction.commit()
    
    sendActionsForControlEvents(.ValueChanged)
    
    return true
  }
  
  override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    scrubberLayer.highlighted = false
    self.audioPlayerControls!.audioSliderEndedScrubbing()
  }
  
  func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
    return min(max(value, lowerValue), upperValue)
  }
  
  
}

//MARK: - ScrubberLayer
class ScrubberLayer : CALayer {
  
  weak var audioSlider : AudioSlider?
  var highlighted = false
  
  

}





