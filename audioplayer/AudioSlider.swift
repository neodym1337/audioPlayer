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

class RangeSlider: UIControl {
  
  var minimumValue = 0.0
  var maximumValue = 1.0
  var sliderValue = 0.2
  
  let trackLayer = CALayer()
  let scrubberLayer = CALayer()
  
  
  required init(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override var frame: CGRect {
    didSet {
      updateLayerFrames()
    }
  }
  
  var scrubberWidth: CGFloat {
    return CGFloat(10.0)
  }
  
  var scrubberHeight: CGFloat {
    return CGFloat(bounds.height)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    trackLayer.backgroundColor = UIColor.blueColor().CGColor
    layer.addSublayer(trackLayer)
    
    scrubberLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    layer.addSublayer(scrubberLayer)
    
    //setNeedsDisplay()
  }
  
  func updateLayerFrames() {
    trackLayer.frame = bounds.rectByInsetting(dx: 0.0, dy: bounds.height / 4)
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
  
  
  
}