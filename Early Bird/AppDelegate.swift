//
//  AppDelegate.swift
//  Early Bird
//
//  Created by Brian Endo on 8/21/16.
//  Copyright © 2016 Early Bird. All rights reserved.
//

import UIKit
import AVFoundation

//var audioPlayer = AVAudioPlayer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // TODO: When app becomes inactive: raise volume of app
        // TODO: Spam local notifications if person does not swipe
        
        // TODO: Should register on onboarding... Don't allow user to go to next step unless passed
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.alert,
            UIUserNotificationType.badge], categories: nil
            ))
        
        
        return true
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let state : UIApplicationState = application.applicationState
        
        if (state == UIApplicationState.active || state == UIApplicationState.background || state == UIApplicationState.inactive) {
            // Create sound
            
            AudioManager.sharedInstance.audioView("alarm", format: "mp3")
            
//            do {
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//                try AVAudioSession.sharedInstance().setActive(true)
//                let sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("alarm", ofType: "mp3")!)
//                try audioPlayer = AVAudioPlayer(contentsOfURL: sound)
//                audioPlayer.prepareToPlay()
//                audioPlayer.play()
//            } catch {
//                
//            }
            
            // Create alert
            let alertController = UIAlertController(title: "Alert title", message: "Alert message.", preferredStyle: .alert)
            
            let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
                
            }
            let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                
            }
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

