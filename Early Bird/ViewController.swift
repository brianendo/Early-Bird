//
//  ViewController.swift
//  Early Bird
//
//  Created by Brian Endo on 8/21/16.
//  Copyright © 2016 Early Bird. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    
    @IBOutlet weak var hourButton: UIButton!
    @IBOutlet weak var minuteButton: UIButton!
    @IBOutlet weak var knobPlaceholderView: UIView!
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var amPmLabel: UILabel!
    
    
    var knob: Knob!
    
    var hourValue = 7
    var minuteValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        knobPlaceholderView.frame = CGRect(x: knobPlaceholderView.bounds.origin.x, y: knobPlaceholderView.bounds.origin.y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        
        knob = Knob(frame: knobPlaceholderView.frame)
        knobPlaceholderView.addSubview(knob)
        
        knob.addTarget(self, action: #selector(ViewController.knobValueChanged(_:)), for: .valueChanged)
        
        view.tintColor = UIColor.red
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        if hour > 12 {
            hourValue = hour - 12
            amPmLabel.text = "PM"
        } else if hour == 12 {
            hourValue = hour
            amPmLabel.text = "PM"
        } else if hour > 0 {
            hourValue = hour
            amPmLabel.text = "AM"
        } else {
            hourValue = 12
            amPmLabel.text = "AM"
        }
        
        minuteValue = minutes
        
        hourButton.setTitle("\(hourValue)", for: .normal)
        minuteButton.setTitle(String(format: "%02d", minuteValue), for: .normal)
    }
    

    @IBAction func setAlarmPressed(_ sender: UIButton) {
        let notif = UILocalNotification()
        // Specify date components
        
        let currentDate = Date()
        let calendar = Calendar.current
        var hour = hourValue
        if amPmLabel.text == "PM" {
            hour += 12
        }
        
        var dateComponents = DateComponents()
        
        
        let currentHour = calendar.component(.hour, from: currentDate)
        let currentMinute = calendar.component(.minute, from: currentDate)
        
        if hour < currentHour || (hour == currentHour && minuteValue < currentMinute) {
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                dateComponents.year = calendar.component(.year, from: tomorrow)
                dateComponents.month = calendar.component(.month, from: tomorrow)
                dateComponents.day = calendar.component(.day, from: tomorrow)
            }
        } else {
            dateComponents.year = calendar.component(.year, from: currentDate)
            dateComponents.month = calendar.component(.month, from: currentDate)
            dateComponents.day = calendar.component(.day, from: currentDate)
        }
        
        dateComponents.hour = hour
        dateComponents.minute = minuteValue
        
        let alarmDate = calendar.date(from: dateComponents)
        notif.fireDate = alarmDate
        notif.alertBody = "test"
        UIApplication.shared.scheduleLocalNotification(notif)
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        AudioManager.sharedInstance.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func knobValueChanged(_ knob: Knob) {
        
        
        print(knob.value)
        
        updateTime(value: knob.value)
    }
    
    private func incrementHour(value: Int) -> Int {
        if value >= 12 {
            
            return 1
        } else {
            if value == 11 {
                changeTimeLabel()
            }
            let hour = value + 1
            return hour
        }
    }
    
    
    
    private func decrementHour(value: Int) -> Int {
        if value <= 1 {
            return 12
        } else {
            if value == 12 {
               changeTimeLabel()
            }
            let hour = value - 1
            return hour
        }
    }
    
    private func changeTimeLabel() {
        if amPmLabel.text == "AM" {
            amPmLabel.text = "PM"
        } else {
            amPmLabel.text = "AM"
        }
    }
    
    private func updateTime(value: Float) {
        
        let time = Int(value * 60)
        
        if minuteValue > 50 && time < 10 {
            hourValue = incrementHour(value: hourValue)
            hourButton.setTitle("\(hourValue)", for: .normal)
        } else if minuteValue < 10 && time > 50 {
            hourValue = decrementHour(value: hourValue)
            hourButton.setTitle("\(hourValue)", for: .normal)
        }
        
        minuteValue = time
        minuteButton.setTitle(String(format: "%02d", time), for: .normal)
    }

}

