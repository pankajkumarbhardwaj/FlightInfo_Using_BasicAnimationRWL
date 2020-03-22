//
//  ViewController.swift
//  Flight Info
//
//  Created by Pankaj Kumar on 19/03/20.
//  Copyright © 2020 Razeware LLC. All rights reserved.
//

import UIKit
import QuartzCore



class ViewController: UIViewController {
  
//MARK: ................Outlet....................
  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summaryIcon: UIImageView!
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!

    //MARK://MARK: ................View Life Cycle....................
    override func viewDidLoad() {
      super.viewDidLoad()
      
      //add the snow effect layer
      snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
      let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50))
      snowClipView.clipsToBounds = true
      snowClipView.addSubview(snowView)
      view.addSubview(snowClipView)
      
      //start rotating the flights
      changeFlight(to: londonToParis, animated: false)
    }
    
    func changeFlight(to data: FlightData, animated: Bool = false) {
        // populate the UI with the next flight's data
        flightNr.text = data.flightNr
        gateNr.text = data.gateNr
        
        if animated {
            fade(toImage: UIImage(named: data.weatherImageName)!, showEffects: data.showWeatherEffects)
          
            let offsetDeparting = CGPoint(x: -80, y: 0.0)
            let offsetArriving = CGPoint(x: 80, y: 0.0)
            moveLabel(label: departingFrom, text: data.departingFrom, offset: offsetDeparting)
            moveLabel(label: arrivingTo, text: data.arrivingTo, offset: offsetArriving)
        
            cubeTransition(label: flightStatus, text: data.flightStatus)
            
            planeDepart()
            
            changeSummary(to: data.summary)
      } else {
            bgImageView.image = UIImage(named: data.weatherImageName)
          
            departingFrom.text = data.departingFrom
            arrivingTo.text = data.arrivingTo
        
            flightStatus.text = data.flightStatus
            
            summary.text = data.summary
        }
      
      // schedule next flight
      delay(seconds: 3.0) {
        self.changeFlight(to: data.isTakingOff ? parisToRome : londonToParis, animated: true)
      }
    }
    
  
  
  func fade(toImage: UIImage, showEffects: Bool) {
    let tempView = UIImageView(frame: bgImageView.frame)
    tempView.image = toImage
    tempView.alpha = 0.0
    bgImageView.superview?.insertSubview(tempView, aboveSubview: bgImageView)
    
    //Fade Temp view
    UIView.animate(withDuration: 0.5,
                   animations: {
                    tempView.alpha = 1.0
    }) { _ in
        self.bgImageView.image = toImage
        tempView.removeFromSuperview()
    }
    
    //Create a fade animation for snowView
    UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
        self.snowView.alpha = showEffects ? 1.0 : 0.0
    }, completion: nil)
  }
  
    func moveLabel(label:UILabel,text:String,offset:CGPoint) {
        //Create and set up temp label
        let tempLabel = duplicateLabel(label: label)
        tempLabel.text = text
        tempLabel.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
        tempLabel.alpha = 0.0
        view.addSubview(tempLabel)
        
        //Fade out and translate real label
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            label.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
            label.alpha = 0.0
        }, completion: nil)
    
        //Fade in and translate temp label
        UIView.animate(withDuration: 0.25, delay: 0.2, options: .curveEaseIn, animations: {
            //tempLabel.transform = CGAffineTransform(translationX: -offset.x, y: -offset.y)
            tempLabel.transform = .identity
            tempLabel.alpha = 1.0
        }) { _ in
            label.text = text
            label.alpha = 1.0
            label.transform = .identity
            tempLabel.removeFromSuperview()
        }
    
        // Update real label and remove temp label
  }
  
    func cubeTransition(label:UILabel, text:String) {
		//Create and setup temp label
        let templabel = duplicateLabel(label: label)
        templabel.text = text
        let templateOffset = label.frame.size.height / 2.0
        let scale = CGAffineTransform(scaleX: 1.0, y: 0.1)
        let translate = CGAffineTransform(translationX: 0.0, y: templateOffset)
        templabel.transform = scale.concatenating(translate)
//        templabel.transform = translate.concatenating(scale)
        label.superview?.addSubview(templabel)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            //Scale temp label down and translate up
            templabel.transform = .identity
            //Scale real label dodn and translate up
            label.transform = scale.concatenating(translate.inverted())
//            label.transform = translate.concatenating(scale.inverted())
        }) { _ in
            //update the real label,s text and reset its transform
            label.text = templabel.text
            label.transform = .identity
            //Remove the temp label
            templabel.removeFromSuperview()
        }
  }

  
  func planeDepart() {
    //Store the plane center value
    let origionalCenter = planeImage.center
    //Create new keframe animation
    UIView.animateKeyframes(withDuration: 1.5,
                            delay: 0.0,
                            animations: {
                                //Create keyframes
                                //Move plane right & up
                                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                                    self.planeImage.center.x += 80.0
                                    self.planeImage.center.y -= 10.0
                                }
                                //Rotate plane
                                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4) {
                                    self.planeImage.transform = CGAffineTransform.init(rotationAngle: -.pi / 8)
                                }
                                //Move plane right and up off screen, while fading out
                                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                                    self.planeImage.center.x += 100.0
                                    self.planeImage.center.y -= 50.0
                                    self.planeImage.alpha = 0.0
                                }
                                //Move plane just off left side, Reset transform and height
                                UIView.addKeyframe(withRelativeStartTime: 0.51, relativeDuration: 0.01) {
                                    self.planeImage.transform = .identity
                                    self.planeImage.center = CGPoint(x: 0.0, y: origionalCenter.y)
                                }
                                //move plane back to orizonal position & fade in
                                UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45) {
                                    self.planeImage.alpha = 1.0
                                    self.planeImage.center = origionalCenter
                                }
    },
    completion: nil)
  }
  
  func changeSummary(to summaryText: String) {
    UIView.animateKeyframes(withDuration: 1.0, delay: 0.0,  animations: {
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.45) {
            self.summary.center.y -= 100.0
            
        }
        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.45) {
            self.summary.center.y += 100.0
        }
    }, completion: nil)
		
    delay(seconds: 0.5) {
      self.summary.text = summaryText
    }
  }

 
  
  //MARK:- utility methods
  func delay(seconds: Double, completion: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
  }
  
  func duplicateLabel(label: UILabel) -> UILabel {
    let newLabel = UILabel(frame: label.frame)
    newLabel.font = label.font
    newLabel.textAlignment = label.textAlignment
    newLabel.textColor = label.textColor
    newLabel.backgroundColor = label.backgroundColor
    return newLabel
  }
}
