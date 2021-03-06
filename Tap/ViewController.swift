//
//  ViewController.swift
//  Tap
//
//  Created by AJ Priola on 7/10/15.
//  Copyright © 2015 AJ Priola. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    var circle:UIView!
    var blue:UIView!
    var thirdCircle:UIView!
    var center:UIView!
    var centerInside:UIView!
    var scoreLabel:UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreProgressView: UIProgressView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    var centerPoint:CGPoint!
    
    var rotateForward:CABasicAnimation!
    var rotateBackward:CABasicAnimation!
    var messages = ["Good start","Keep it up","You're doing great","Way to go","Keep going!","Epic!","Legendary!","Go play outside.","Put your phone down.","You're too good at this.","You should go pro."]
    var messages2 = ["Nice!","Great!","Awesome!","Super!","Fantastic!"]
    var playing = true
    var score = 0
    var timeMultiple = 1.0
    var blueTime = 4.5
    var redTime = 3.25
    var greenTime = 3.7
    var radius:CGFloat!
    var highscore = 0
    var replacedHighscore = false
    var interactionEnabled = true
    var overlayDisplayed = false
    var overlay:UIView!
    var blueTotalTimeLostResultingFromSpeedChange:Float = 0
    var currentChangeSpeedTime:CFTimeInterval = 0
    var WIDTH_CONSTANT:CGFloat!
    
    var overlayHighscores:[UILabel]!
    var overlayHighscore:UILabel!
    var overlayScore:UILabel!
    var slidelabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-large")!)
        
        if let readHighScore = self.getHighScore() {
            self.highscore = readHighScore
            self.highScoreLabel.text = "High Score: \(highscore)"
        }
        
        WIDTH_CONSTANT = self.view.frame.width * 0.17
        
        overlay = UIView(frame: self.view.frame)
        overlay.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.6)
        overlay.frame.origin.x += self.view.frame.width
        makeOverlayLabels()
        view.addSubview(overlay)
        
        centerPoint = CGPointMake(view.center.x, view.center.y * 1.4)
        scoreProgressView.progress = 0
        radius = (self.view.frame.width * 0.6)
        
        center = UIView(frame: CGRectMake(view.center.x, view.center.y, radius + WIDTH_CONSTANT, radius + WIDTH_CONSTANT))
        center.layer.cornerRadius = center.frame.width/2
        center.layer.borderColor = UIColor.blackColor().CGColor
        center.layer.borderWidth = 1
        center.backgroundColor = UIColor.cyanColor().colorWithAlphaComponent(0.5)
        center.clipsToBounds = true
        center.center = centerPoint
        view.addSubview(center)
        
        centerInside = UIView(frame: CGRectMake(view.center.x, view.center.y, radius - WIDTH_CONSTANT, radius - WIDTH_CONSTANT))
        centerInside.layer.cornerRadius = centerInside.frame.width/2
        centerInside.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        centerInside.layer.borderWidth = 1
        centerInside.clipsToBounds = true
        centerInside.center = centerPoint
        view.addSubview(centerInside)
        
        circle = UIView(frame: CGRectMake(WIDTH_CONSTANT, WIDTH_CONSTANT, WIDTH_CONSTANT, WIDTH_CONSTANT))
        circle.layer.cornerRadius = WIDTH_CONSTANT/2
        circle.clipsToBounds = true
        circle.backgroundColor = UIColor.whiteColor()
        circle.center = CGPointMake(0, centerPoint.y + radius)
        
        blue = UIView(frame: CGRectMake(WIDTH_CONSTANT, WIDTH_CONSTANT, WIDTH_CONSTANT, WIDTH_CONSTANT))
        blue.layer.cornerRadius = WIDTH_CONSTANT/2
        blue.clipsToBounds = true
        blue.backgroundColor = UIColor.blackColor()
        blue.center = CGPointMake(centerPoint.x, centerPoint.y - radius/2)
        
        thirdCircle = UIView(frame: CGRectMake(WIDTH_CONSTANT, WIDTH_CONSTANT, WIDTH_CONSTANT, WIDTH_CONSTANT))
        thirdCircle.layer.cornerRadius = WIDTH_CONSTANT/2
        thirdCircle.clipsToBounds = true
        thirdCircle.backgroundColor = UIColor.lightGrayColor()
        thirdCircle.center = CGPointMake(centerPoint.x, centerPoint.y - radius/2)
        thirdCircle.hidden = true
        
        scoreLabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
        scoreLabel.text = "\(score)"
        scoreLabel.center = centerPoint
        scoreLabel.textAlignment = .Center
        scoreLabel.font = messageLabel.font.fontWithSize(17)
        view.addSubview(scoreLabel)
        self.statusLabel.text = "Tap to begin"
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped")
        view.addGestureRecognizer(tapRecognizer)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "removeOverlay")
        swipeRight.direction = .Right
        overlay.addGestureRecognizer(swipeRight)
        
        blue.layer.speed = 1
        circle.layer.speed = 1
        
        self.view.addSubview(blue)
        self.view.addSubview(circle)
        self.view.addSubview(thirdCircle)
        animateForwards(blue, radius: radius, time: blueTime, speed:timeMultiple, key:"blue")
        animateBackwards(circle, radius: radius, time: redTime, speed:timeMultiple, key:"red")
        animateForwards(thirdCircle, radius: radius, time: greenTime, speed:timeMultiple, key:"green")
        
        //AI fun :)
        //NSTimer.scheduledTimerWithTimeInterval(0.000000001, target: self, selector: "ai", userInfo: nil, repeats: true)
    }
    
    func pauseAnimations() {
        let pausedTimeBlue = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        blue.layer.speed = 0.0
        blue.layer.timeOffset = pausedTimeBlue
        
        let pausedTimeRed = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        circle.layer.speed = 0.0
        circle.layer.timeOffset = pausedTimeRed
        
        let pausedTimeGreen = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        thirdCircle.layer.speed = 0.0
        thirdCircle.layer.timeOffset = pausedTimeGreen
    }
    
    func resumeAnimations() {
        let pausedTimeBlue = blue.layer.timeOffset
        blue.layer.speed = 1
        blue.layer.timeOffset = 0
        blue.layer.beginTime = 0
        let timeSincePauseBlue = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTimeBlue
        blue.layer.beginTime = timeSincePauseBlue
        
        let pausedTimeRed = circle.layer.timeOffset
        circle.layer.speed = 1
        circle.layer.timeOffset = 0
        circle.layer.beginTime = 0
        let timeSincePauseRed = circle.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTimeRed
        circle.layer.beginTime = timeSincePauseRed
        
        let pausedTimeGreen = thirdCircle.layer.timeOffset
        thirdCircle.layer.speed = 1
        thirdCircle.layer.timeOffset = 0
        thirdCircle.layer.beginTime = 0
        let timeSincePauseGreen = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTimeGreen
        thirdCircle.layer.beginTime = timeSincePauseGreen
    }
    
    func makeOverlayLabels() {
        let title = UILabel(frame: CGRectMake(self.view.frame.width, self.messageLabel.frame.origin.y, self.view.frame.width - 16, 40))
        title.textAlignment = .Center
        title.textColor = UIColor.whiteColor()
        title.font = self.messageLabel.font.fontWithSize(32)
        title.text = "Game Over"
        overlay.addSubview(title)
        
        let bar = UIView(frame: CGRectMake(self.view.frame.width, title.frame.origin.y + 48, self.view.frame.width - 16, 2))
        bar.backgroundColor = UIColor.whiteColor()
        overlay.addSubview(bar)
        
        let slideview = UIView(frame: CGRectMake(self.view.frame.width, title.frame.origin.y - 63, self.view.frame.width - 16, 55))
        
        
        let arrow = UIImageView(image: UIImage(named: "rightwhite"))
        arrow.frame.size = CGSizeMake(55, 55)
        arrow.frame.origin = CGPointMake(slideview.frame.width - 55, 0)
        slideview.addSubview(arrow)
        
        let arrow2 = UIImageView(image: UIImage(named: "rightwhite"))
        arrow2.frame.size = CGSizeMake(55, 55)
        arrow2.frame.origin = CGPointMake(slideview.frame.width - 65, 0)
        slideview.addSubview(arrow2)
        
        slidelabel = UILabel(frame: CGRectMake(0, 0, slideview.frame.width - 65, 55))
        slidelabel.font = title.font.fontWithSize(22)
        slidelabel.textColor = UIColor.whiteColor()
        slidelabel.text = "Slide to play again"
        slidelabel.textAlignment = .Center
        slidelabel.sizeToFit()
        slidelabel.frame.size.height = 55
        slidelabel.frame.origin.x = slideview.frame.width - slidelabel.frame.width*2
        
        overlayHighscore = UILabel(frame: CGRectMake(title.frame.origin.x, bar.frame.origin.y + 10, title.frame.width, 30))
        overlayHighscore.font = title.font.fontWithSize(26)
        overlayHighscore.textAlignment = .Center
        overlayHighscore.textColor = UIColor.whiteColor()
        overlayHighscore.text = "High Score: \(highscore)"
        overlay.addSubview(overlayHighscore)
        
        overlayScore = UILabel(frame: CGRectMake(overlayHighscore.frame.origin.x, overlayHighscore.frame.origin.y + 48, title.frame.width, 30))
        overlayScore.font = title.font.fontWithSize(26)
        overlayScore.textAlignment = .Center
        overlayScore.textColor = UIColor.whiteColor()
        overlayScore.text = "You scored: \(score)"
        overlay.addSubview(overlayScore)
        
        slideview.addSubview(slidelabel)
        overlay.addSubview(slideview)
    }
    
    func flashSlide() {
        UILabel.animateWithDuration(1.5) { () -> Void in
            self.slidelabel.alpha = 0
        }
        self.slidelabel.alpha = 1
    }
    
    func changeBackgroundGradient(bottom:UIColor, top:UIColor) {
        let vista : UIView = UIView(frame: self.view.frame)
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = vista.bounds
        let arrayColors = [top, bottom]
        
        gradient.colors = arrayColors
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func ai() {
        if CGRectIntersectsRect((blue.layer.presentationLayer()?.frame)!, (circle.layer.presentationLayer()?.frame)!) {
            tapped()
        }
    }
    
    func saveHighScore(score:Int) {
        /*
        var higher = false
        for n in getTopFive() {
            if score > n {
                higher = true
                break
            }
        }
        
        if higher {
            saveTopFive(score)
        }
        */
        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
    }
    
    func getHighScore() -> Int? {
        return NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    }
    
    func getTopFive() -> [Int] {
        return NSUserDefaults.standardUserDefaults().objectForKey("highscores") as! [Int]
    }
    
    func saveTopFive(score:Int) {
        let s = getTopFive()
        var sorted = s.sort()
        sorted.removeAtIndex(0)
        sorted.append(score)
        NSUserDefaults.standardUserDefaults().setObject(sorted.sort(), forKey: "highscores")
    }
    
    func animateForwards(forwardView:UIView, radius:CGFloat, time:Double, speed:Double, key:String) {
        let rotationPoint = centerPoint
        
        //let anchorPoint = CGPointMake((rotationPoint.x + radius/2)/(radius), (rotationPoint.y + radius/2)/(radius))
        //find center of blue
        
        let distanceUnit = radius/blue.frame.width
        //print(distanceUnit)
        let centerBlue = CGPointMake(distanceUnit * 0.494, distanceUnit * 0.494)
        //blue.layer.position = centerBlue
        //let anchorPoint = CGPointMake(0.5, 0.5)
        forwardView.layer.anchorPoint = centerBlue
        forwardView.layer.position = rotationPoint
        
        rotateForward = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateForward.toValue = (M_PI) * 2
        rotateForward.duration = time
        rotateForward.repeatCount = Float.infinity
        forwardView.layer.addAnimation(rotateForward, forKey: key)
        //print("r:\(rotationPoint)")
        //print("a:\(anchorPoint)")
    }
    
    func updateAnimation(view:UIView, animation:CABasicAnimation, speed:Double, key:String) {
        let layerFrame = view.layer.presentationLayer()?.frame
        blue.frame.origin = (layerFrame?.origin)!
        view.layer.removeAllAnimations()
        animateForwards(blue, radius: radius, time: blueTime, speed: timeMultiple, key: "blue")
        
    }
    
    func animateBackwards(forwardView:UIView, radius:CGFloat, time:Double, speed:Double, key:String) {
        /*
        let rotationPoint = centerPoint
        
        let anchorPoint = CGPointMake((rotationPoint.x + radius/2)/(radius), (rotationPoint.y + radius/2)/(radius))
        forwardView.layer.anchorPoint = anchorPoint
        forwardView.layer.position = rotationPoint*/
        
        let rotationPoint = centerPoint
        
        //let anchorPoint = CGPointMake((rotationPoint.x + radius/2)/(radius), (rotationPoint.y + radius/2)/(radius))
        //find center of blue
        
        let distanceUnit = radius/blue.frame.width
        //print(distanceUnit)
        let centerBlue = CGPointMake(distanceUnit * 0.494, distanceUnit * 0.494)
        //blue.layer.position = centerBlue
        //let anchorPoint = CGPointMake(0.5, 0.5)
        forwardView.layer.anchorPoint = centerBlue
        forwardView.layer.position = rotationPoint
        
        rotateBackward = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateBackward.toValue = (-M_PI) * 2
        rotateBackward.duration = time
        rotateBackward.repeatCount = Float.infinity
        forwardView.layer.addAnimation(rotateBackward, forKey: key)
    }
    
    func calculateSpeed() {
        var divisor = 250
        switch score {
        case 0...10:
            divisor = 200
        case 11...20:
            divisor = 450
        case 21...30:
            divisor = 690
        case 31...40:
            divisor = 900
        default:
            divisor = 1100
        }
        self.timeMultiple = (Double(score) / Double(divisor))
        
        self.blueTime += blueTime * timeMultiple
        self.redTime += redTime * timeMultiple
        
        let blueVal = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: blue.layer) - currentChangeSpeedTime
        let blueCurrentTimeLostResultingFromSpeedChange = Float(blueVal) - (Float(blueVal) * blue.layer.speed)
        blueTotalTimeLostResultingFromSpeedChange += blueCurrentTimeLostResultingFromSpeedChange
        
        currentChangeSpeedTime = blue.layer.convertTime(CACurrentMediaTime(), fromLayer: blue.layer)
        blue.layer.timeOffset = CFTimeInterval(Float(currentChangeSpeedTime) - blueTotalTimeLostResultingFromSpeedChange)
        blue.layer.beginTime = CACurrentMediaTime()
        blue.layer.speed += Float(timeMultiple)
        
        circle.layer.timeOffset = CFTimeInterval(Float(currentChangeSpeedTime) - blueTotalTimeLostResultingFromSpeedChange)
        circle.layer.beginTime = CACurrentMediaTime()
        circle.layer.speed += Float(timeMultiple)
    }
    
    func flashScreen() {
        if let wnd = self.view{
            let v = UIView(frame: wnd.bounds)
            v.backgroundColor = UIColor.whiteColor()
            v.alpha = 0.9
            wnd.addSubview(v)
            UIView.animateWithDuration(0.5, animations: {
                v.alpha = 0.0
                }, completion: {(finished:Bool) in
                    v.removeFromSuperview()
            })
        }
    }
    
    func startGame() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-large")!)
        centerInside.backgroundColor = UIColor.clearColor()
        scoreLabel.textColor = UIColor.blackColor()
        self.blue.hidden = false
        self.circle.hidden = false
        replacedHighscore = false
        playing = true
        timeMultiple = 1
        self.scoreLabel.text = "0"
        blue.layer.speed = 1
        circle.layer.speed = 1
        animateTextChange(statusLabel, text: "Tap when the circles overlap")
        calculateSpeed()
    }
    
    func tapped() {
        if overlayDisplayed { return }
        
        guard playing && interactionEnabled else {
            if !playing { startGame() }
            return
        }
        
        let blueFrame = self.blue.layer.presentationLayer()?.frame
        let redFrame = self.circle.layer.presentationLayer()?.frame
        let greenFrame = self.thirdCircle.layer.presentationLayer()?.frame
        if self.thirdCircle.hidden {
            if CGRectIntersectsRect(blueFrame!, redFrame!) {
                score++
                flashScreen()
                UILabel.animateWithDuration(5, animations: { () -> Void in
                    self.messageLabel.text = ""
                })
            } else {
                gameOver()
                return
            }
        } else {
            
            if CGRectIntersectsRect(blueFrame!, redFrame!) && CGRectIntersectsRect(greenFrame!, redFrame!) && CGRectIntersectsRect(blueFrame!, greenFrame!) {
                score += 6
                self.thirdCircle.hidden = true
                flashScreen()
                animateTextChange(messageLabel, text: "Triple!")
            } else if CGRectIntersectsRect(greenFrame!, redFrame!) || CGRectIntersectsRect(blueFrame!, greenFrame!) {
                score += 3
                self.thirdCircle.hidden = true
                flashScreen()
                let i = Int(arc4random_uniform(UInt32(2)))
                animateTextChange(messageLabel, text: messages2[i])
            } else if CGRectIntersectsRect(redFrame!, blueFrame!) {
                score++
                flashScreen()
            } else {
                gameOver()
                return
            }
        }
        animateTextChange(scoreLabel, text: "\(score)")
        
        if arc4random() % 3 == 0 {
            UIView.animateWithDuration(1, animations: { () -> Void in
                self.thirdCircle.hidden = false
            })
            
        }
        var index = score/10
        if index > messages.count - 1 { index = messages.count - 1 }
        if (score % 10 == 0 && score > 9) || (score == 1) {
            animateTextChange(statusLabel, text: messages[index])
        }
        if score <= 10 {
            let progress = Double(score)/10
            scoreProgressView.setProgress(Float(progress), animated: true)
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else {
            let progress = (Double(score) % 10) / 10
            scoreProgressView.setProgress(Float(progress), animated: true)
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        if score > highscore {
            highscore = score
            self.highScoreLabel.text = "High Score: \(highscore)"
            if !replacedHighscore {
                replaceHighscore()
            }
        }
        
        if score >= 30 {
            scoreLabel.textColor = UIColor.redColor()
        }
        
        if score >= 45 {
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-orange")!)
        }
        
        if score >= 85 {
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient-red")!)
        }
        saveHighScore(score)
        calculateSpeed()
    }
    
    func displayOverlay() {
        messageLabel.hidden = true
        statusLabel.hidden = true
        highScoreLabel.hidden = true
        scoreLabel.hidden = true
        interactionEnabled = false
        UIView.animateWithDuration(1) { () -> Void in
            self.overlay.frame.origin.x = 0
        }
        overlayDisplayed = true
        for element in overlay.subviews {
            UIView.animateWithDuration(0.6, delay: Double(overlay.subviews.indexOf(element)!) * 0.6, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                element.frame.origin.x = 8
                }, completion: nil)
        }
    }
    
    func removeOverlay() {
        messageLabel.hidden = false
        statusLabel.hidden = false
        highScoreLabel.hidden = false
        scoreLabel.hidden = false
        interactionEnabled = true
        UIView.animateWithDuration(0.8) { () -> Void in
            self.overlay.frame.origin.x = self.view.frame.width
            for element in self.overlay.subviews {
                element.frame.origin.x = self.view.frame.width + 8
            }
        }
        
        overlayDisplayed = false
        startGame()
    }
    
    func replaceHighscore() {
        let new = UILabel(frame: self.highScoreLabel.frame)
        new.frame.origin.x += self.view.frame.width + 8
        new.font = highScoreLabel.font
        new.text = "High Score: \(score)"
        UILabel.animateWithDuration(0.5) { () -> Void in
            new.frame.origin.x = self.highScoreLabel.frame.origin.x
        }
        UILabel.animateWithDuration(0.5) { () -> Void in
            self.highScoreLabel.frame.origin.x -= (self.view.frame.width + 8)
        }
        replacedHighscore = true
    }
    
    func gameOver() {
        self.blue.hidden = true
        self.circle.hidden = true
        self.thirdCircle.hidden = true
        score = 0
        playing = false
        animateTextChange(statusLabel, text: "Tap to begin")
        messageLabel.text = ""
        scoreProgressView.setProgress(0, animated: true)
        saveHighScore(highscore)
        displayOverlay()
    }
    
    func animateTextChange(label:UILabel, text:String) {
        label.alpha = 0.0
        label.text = text
        UILabel.animateWithDuration(1) { () -> Void in
            label.alpha = 1.0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

