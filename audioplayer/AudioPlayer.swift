//
//  AudioPlayer.swift
//  audioplayer
//
//  Created by Johan Hosk on 26/11/14.
//  Copyright (c) 2014 Johan Hosk. All rights reserved.
//

/* 

KVO buffering
http://stackoverflow.com/questions/3999228/how-to-get-file-size-and-current-file-size-from-nsurl-for-avplayer-ios4-0

KVO swift
https://developer.apple.com/library/mac/documentation/Swift/Conceptual/BuildingCocoaApps/AdoptingCocoaDesignPatterns.html#//apple_ref/doc/uid/TP40014216-CH7-XID_8


audio player swift
http://stackoverflow.com/questions/24357468/converting-avplayer-code-to-swift


mp3 http://metafiles.gl-systemhaus.de/hr/hr1_2.m3u

*/

import Foundation
import AVFoundation
import CoreMedia


private var AVPlayerStatusObservationContext = 0
private var AVPlayerCurrentItemObservationContext = 1
private var AVPlayerRateObservationContext = 2


class AudioPlayer : NSObject {
  
  var isSeeking : Bool = false
  
  var seekToZeroBeforePlay = false
  
  let restoreAfterScrubbingRate : CGFloat = 1.0
  
  var timeObserver : AnyObject?
  
  var isPlaying : Bool {
    return restoreAfterScrubbingRate != 0.0 || self.player!.rate != 0.0
  }
  
  var audioPlayerControls : AudioPlayerControls? {
    didSet {
      self.audioPlayerControls!.audioPlayer = self
    }
  }
  dynamic var player : AVPlayer?
  var progressUpdateTimer : NSTimer?
  
  dynamic var playerItem : AVPlayerItem?
  
  var url : String? {
    didSet {
      
      if (self.audioPlayerControls == nil) {return}
      let asset : AVURLAsset? = AVURLAsset(URL: NSURL(string: url!), options: nil)
      let keys = ["playable"]
      
      asset!.loadValuesAsynchronouslyForKeys(keys, completionHandler: {
        
        dispatch_async(dispatch_get_main_queue(), {
          
            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
          self.loadAsset(asset, keys: keys)
          self.setSessionPlayer()
        })
      })
    }
  }

  override init() {
    super.init()
    
    self.player = AVPlayer()
    
    initScrubberTimer()
    syncPlayPauseButtons()
    //syncScrubber()
  
  }
  
  deinit {
    //TODO: remove observers
    
    //NSNotificationCenter.defaultCenter().removeObserver(<#observer: NSObject#>, forKeyPath: <#String#>)
    self.player!.removeObserver(self, forKeyPath:"rate")
    self.player!.currentItem?.removeObserver(self, forKeyPath: "status")
    NSNotificationCenter.defaultCenter().removeObserver(self) //addObserver(self, selector: "playerReachedEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
  }
  

  
  /**
  Invoked at the completion of the loading of the values for all keys on the asset that we require.
  Checks whether loading was successfull and whether the asset is playable.
  If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
  */
  func loadAsset(asset : AVURLAsset?, keys : Array<String>?) {
    
    if (asset == nil || keys == nil) {return}
    
    for key in keys!  {
      var error : NSError?
      let keyStatus = asset!.statusOfValueForKey(key, error: &error)
      if keyStatus == AVKeyValueStatus.Failed {
        println("Loading failed")
        //Disable
        loadingFailed()
      }
    }
    
    if !(asset!.playable) {
      loadingFailed()
      return
    }
    
    if (self.playerItem != nil) {
      //self.playerItem!.removeObserver(self, forKeyPath: "status")
      
  
      NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
      
      self.playerItem!.removeObserver(self, forKeyPath: "status", context: &AVPlayerStatusObservationContext)
    }
    
    self.playerItem = AVPlayerItem(asset: asset!)
    self.playerItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &AVPlayerStatusObservationContext)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemReachedEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
    
    if self.player == nil {
      self.player = AVPlayer(playerItem: self.playerItem!)
      
      self.player!.addObserver(self, forKeyPath: "currentItem", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: &AVPlayerCurrentItemObservationContext)
      self.player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.Initial | NSKeyValueObservingOptions.New, context: &AVPlayerRateObservationContext)
      
      
    }
    
    if self.player!.currentItem != self.playerItem {
      self.player!.replaceCurrentItemWithPlayerItem(self.playerItem)
      
      syncPlayPauseButtons()
    
    }
    
  //TODO: Set scrubber to 0.0
  }
  
  func loadingFailed() {
    
    removePlayerTimerObserver()
    syncScrubber()
    self.audioPlayerControls!.enableScrubber(false)
    self.audioPlayerControls!.enablePlayerButtons(false)
  }
  
  func initScrubberTimer() {
    var interval : Double = 0.1
    
    let playerDuration : CMTime = playerItemDuration()
    if !playerDuration.isValid { return }
    
    let duration : Double = CMTimeGetSeconds(playerDuration)
    if duration.isFinite {
      let width : CGFloat = CGRectGetWidth(self.audioPlayerControls!.audioSlider.bounds)
      interval = 0.5 * duration / Double(width)
      
      //CMTimeMakeWithSeconds(<#seconds: Float64#>, <#preferredTimeScale: Int32#>)
      
      self.timeObserver = self.player!.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(Float64(interval), Int32( NSEC_PER_MSEC)), queue: dispatch_get_main_queue(), usingBlock: { (CMTime) -> Void in
        self.syncScrubber()
      })
      
    
    }
  }
  
  func syncScrubber() {
    
    //if self.player!.currentTime() =
    var timeNow = Int(CMTimeGetSeconds(self.player!.currentTime()))
    let playerDurationTime : CMTime = playerItemDuration()
    
    if !playerDurationTime.isValid {return}
    
    let playerDuration = Int(CMTimeGetSeconds(playerDurationTime))
    
    var currentMins = timeNow / 60
    var currentSec = timeNow % 60

    var currentTimeString: NSString = "\(currentMins):\(currentSec)"
    
    //TODO: set scrubber value
    /*
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
    float minValue = [self.mScrubber minimumValue];
    float maxValue = [self.mScrubber maximumValue];
    double time = CMTimeGetSeconds([self.mPlayer currentTime]);
    
    [self.mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
    }
    
    */
  }
  func didBeginScrubbing() {
    self.player!.rate = 0.0
    removePlayerTimerObserver()
  }
  
  func scrubToValue(scrubberValue : CGFloat) {
    
    isSeeking = true
    var playerDurationTime : CMTime = playerItemDuration()
    if !playerDurationTime.isValid {return}
    
    var duration : Double = CMTimeGetSeconds(playerDurationTime)
    
    if duration.isFinite {
      let width : CGFloat = CGRectGetWidth(self.audioPlayerControls!.audioSlider.bounds)
      //interval = 0.5 * duration / Double(width)
      
      var sliderMaxValue : Double = self.audioPlayerControls!.audioSlider.maximumValue
      var sliderMinValue : Double = self.audioPlayerControls!.audioSlider.minimumValue
      
      var time : Double = duration * (Double(scrubberValue) - sliderMinValue) / (sliderMaxValue - sliderMinValue)
      
      self.player!.seekToTime(CMTimeMakeWithSeconds(Float64(time), Int32(NSEC_PER_SEC)), completionHandler: { (finished : Bool) -> Void in
        dispatch_async(dispatch_get_main_queue(), {
          self.isSeeking = false
        })
      })
      
    }
    

    
    
  }
  
  func didEndScrubbing() {
    
  }
  

  
  func removePlayerTimerObserver() {
  
    /*
    if (mTimeObserver)
    {
    [self.mPlayer removeTimeObserver:mTimeObserver];
    mTimeObserver = nil;
    }
    
    */
  }
  

  func seekTo() {
    
  }
  
  func syncPlayPauseButtons() {
    
    if isPlaying {
      //TODO: show pause button
    }else {
      //TODO: show play button
    }
  
  }
  
   

  
  func play() {
    
    
    if seekToZeroBeforePlay {
      self.player!.seekToTime(kCMTimeZero)
      seekToZeroBeforePlay = false
    }
    self.player!.play()
    
    /*

    /* If we are at the end of the movie, we must seek to the beginning first
    before starting playback. */
    if (YES == seekToZeroBeforePlay)
    {
    seekToZeroBeforePlay = NO;
    [self.mPlayer seekToTime:kCMTimeZero];
    }
    
    [self.mPlayer play];
    
    [self showStopButton];

    */
  }
  
  func pause() {
    self.player!.pause()
    
    //TODO: show playbutton
  }
 


  func playerItemDuration() -> CMTime {
    if let playerItem = self.player?.currentItem? {
      if playerItem.status == AVPlayerItemStatus.ReadyToPlay {
        return playerItem.duration
      }
    }
    return kCMTimeInvalid
  }
  
  func setSessionPlayer() {
    let session:AVAudioSession = AVAudioSession.sharedInstance()
    var error: NSError?
    if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
      println("could not set session category")
      if let e = error {
        println(e.localizedDescription)
      }
    }
    if !session.setActive(true, error: &error) {
      println("could not make session active")
      if let e = error {
        println(e.localizedDescription)
      }
    }else {
      println("Audio session ready")
    }
  }

  func playerItemReachedEnd(notification: NSNotification){
    //Action take on Notification
    
    seekToZeroBeforePlay = true
  }
  
  /*
  func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
    if keyPath == "currentItem" {
      //self.changed()
    }
  }
  */
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    let changeDict : NSDictionary = change as NSDictionary!
    
    /* AVPlayerItem "status" property value observer. */
    if context == &AVPlayerStatusObservationContext {
      syncPlayPauseButtons()
      
      if let status = changeDict.objectForKey(NSKeyValueChangeNewKey) as? Int {
        if let playerStatus : AVPlayerItemStatus = AVPlayerItemStatus(rawValue: status) {
          
          switch playerStatus {
          case AVPlayerItemStatus.Unknown:
            
            removePlayerTimerObserver()
            syncScrubber()
            
            disableScrubber()
            disablePlayerButtons()
            println("Player item status unknown")

          case AVPlayerItemStatus.ReadyToPlay:
            
            initScrubberTimer()
            
            enableScrubber()
            enablePlayerButtons()
            println("Player item status ready to play")
            play()
            

          case AVPlayerItemStatus.Failed:
            let playerItem : AVPlayerItem? = object as? AVPlayerItem
            
              loadingFailed()
              println("Player item status failed to load")
          }
        }
      }
    }
    /* AVPlayer "rate" property value observer. */
    else if context == &AVPlayerRateObservationContext {
      
      syncPlayPauseButtons()
      
    }
      /* AVPlayer "currentItem" property observer. Called when the AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did occur. */
    else if context == &AVPlayerCurrentItemObservationContext {
      if let newPlayerItem : AVPlayerItem = changeDict.objectForKey(NSKeyValueChangeNewKey) as? AVPlayerItem {
        syncScrubber()
      }else {
        disableScrubber()
        disablePlayerButtons()
        
      }
    }else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)

    }
    
  }
}

extension CMTime {
  var isValid:Bool {
    return (flags & .Valid) != nil
  }
}

extension AVPlayer {
  var playing : Bool {
    return self.rate > 0.1
  }
  
  func doPlay() {
    self.play()
  }
}








