//
//  AppDelegate.swift
//  Chat
//
//  Created by AnshulJain on 06/08/18.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics
import UserNotifications
import Alamofire
import LocalAuthentication


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var chatDetail: [NSManagedObject] = []
   var reciverName: String?
  var checkMessage:Bool!
    var  languageArray: [Language] = []



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
              Fabric.with([Crashlytics.self])
        checkMessage = false;
        
        if let path = Bundle.main.path(forResource: "language", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let languagelist = jsonResult["languagelist"] as? [Any] {                    
                    for res in languagelist {
                        let title:[String:String] = res as! [String:String]
                        let val = Language(response: title)
                        languageArray.append(val)
                    }


                }
            } catch {
            }
        }
        UNUserNotificationCenter.current().delegate = self

//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print(urls[urls.count-1] as URL)
//
        
        self.configureNotification();
        
        return false
    }
    
    func configureNotification() {
//        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
    //    }
//        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()

    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        let deviceTokenStringn = deviceToken.hexString
        print(deviceTokenString)
        print(deviceTokenStringn)

        UserDefaults.standard.set(deviceTokenString, forKey: "deviceTokenString") //setObject

      
    }
    
  
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    
    func sendNotificaton(messgae: [String: AnyObject])
    {
        // Request Notification Settings
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    // Schedule Local Notification
                    self.scheduleLocalNotification(messgae: messgae)
                })
            case .authorized:
                // Schedule Local Notification
                self.scheduleLocalNotification(messgae: messgae)
            case .denied:
                print("Application Not Allowed to Display Notifications")
//                 case .provisional:
//                       print("default")
                
            case .provisional:
                print("Application Not Allowed to Display Notifications")
            }
        }
    }
    
    
    private func scheduleLocalNotification(messgae: [String: AnyObject])
    {
        // Create Notification Content
        
        
        

        
        let senderNickname = messgae["nickname"] as! String
        let messageResponse = messgae["message"] as! String
        let messageDate = messgae["date"] as! String
        
        self.reciverName = senderNickname;
        self.saveData(messages: messgae);
        let notificationContent = UNMutableNotificationContent()
        notificationContent.categoryIdentifier = "cocoacasts_local_notification"
        
        // Configure Notification Content
        notificationContent.title = senderNickname
      notificationContent.userInfo = messgae
    notificationContent.body = "by \(senderNickname.uppercased()) @ \(messageResponse)"
        
      
        
        // uncoomment below code for image

//
//   let imageDatas = NSData(base64Encoded: messageResponse, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) ?? nil
//
//        if  (imageDatas != nil)
//        {
//            if(UIImage(data: imageDatas! as Data) != nil)
//
//            {
//                guard let attachment = UNNotificationAttachment.create(imageFileIdentifier: "image.jpg", data: imageDatas!, options: nil) else {
//                    print("error in UNNotificationAttachment.create()")
//                    return
//                }
//                notificationContent.attachments = [attachment]
//
//            }
//        }
//
//
      
        
        
        
        
        
        
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
            
        }
    }
    
    
    func getFetchrequest()
    {
     
        let managedContext = self.persistentContainer.viewContext
        let chatUserName =  (UserDefaults.standard.string(forKey: "name"))! + self.reciverName!
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ChatDetail")
        fetchRequest.predicate = NSPredicate(format: "chatUname == %@", chatUserName)
        do
        {
            chatDetail = try managedContext.fetch(fetchRequest)
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    func saveData(messages: [String: AnyObject])
      {
        self.getFetchrequest();
        
        
        var array: NSMutableArray = []
        
        
   
      
        let chatUserName =  (UserDefaults.standard.string(forKey: "name"))! + self.reciverName!

    let managedContext = self.persistentContainer.viewContext
    
    if(chatDetail.count>0)
    {
    
//        array.add(managedObject);
//
//        let data = try? JSONSerialization.data(withJSONObject:array, options:[])
//        let string = String(data: data!, encoding: .utf8)
        let chatFirst = chatDetail[0]
        
        let string =     chatFirst.value(forKeyPath: "messages") as? String
        
        let data = string!.data(using: .utf8)
        let jsonResponse = try? JSONSerialization.jsonObject(with:
        data!, options: []) as! [Any]
        
        array.addObjects(from: jsonResponse! );
        array.add(messages);
        
        
        let datafinal = try? JSONSerialization.data(withJSONObject:array, options:[])
        let stringfinal = String(data: datafinal!, encoding: .utf8)
        


    chatFirst.setValue(stringfinal, forKey: "messages")
        
        
    chatFirst.setValue(chatUserName, forKey: "chatUname")
    
    do {
    try managedContext.save()
    } catch let error as NSError {
    print("Could not save. \(error), \(error.userInfo)")
    }
    }
    
    else
    
    {
        array.add(messages);

        let data = try? JSONSerialization.data(withJSONObject:array, options:[])
        let string = String(data: data!, encoding: .utf8)
        
        
    let entity = NSEntityDescription.entity(forEntityName: "ChatDetail",
    in: managedContext)!
    let person = NSManagedObject(entity: entity,
    insertInto: managedContext)
    person.setValue((UserDefaults.standard.string(forKey: "name")), forKeyPath: "uName")
    
    person.setValue(string, forKeyPath: "messages")
    person.setValue(chatUserName, forKey: "chatUname")
    
    do {
    try managedContext.save()
    chatDetail.append(person)
    } catch let error as NSError {
    print("Could not save. \(error), \(error.userInfo)")
    }
    }
    }
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
        
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Chat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    
    
    
    
  
    }
    



extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
}



}


extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
