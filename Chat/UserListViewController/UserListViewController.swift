//
//  UserListViewController.swift
//  Chat
//
//  Created by AnshulJain on 06/08/18.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit
import MessageKit
import UserNotifications
import MapKit
import CoreData
import Alamofire
import SVProgressHUD


class CounterModel : NSObject {
    
    @objc dynamic var users = [[String: AnyObject]]()
    
    @objc dynamic var storeusers = [[String: AnyObject]]()

}

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    
    @IBOutlet weak var tableviewUserList: UITableView!;
    
    let model = CounterModel()

    var nickname: String!
    var logiNicknameId: String!
    var isMoveToChat = false
    


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Welcome " + (UserDefaults.standard.string(forKey: "name"))!
        tableviewUserList.register(UINib(nibName: "UserLIstTableViewCell", bundle: nil), forCellReuseIdentifier: "UserLIstTableViewCell")
        tableviewUserList.delegate = self
        tableviewUserList.dataSource = self

      //  getuserlist();
        UNUserNotificationCenter.current().delegate = self


        self.navigationItem.setHidesBackButton(true, animated:true);

//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(image: UIImage(named: "logout"),
//                            style: .plain,
//                            target: self,
//                            action: #selector(UserListViewController.logout)),
//         ]
        
        
        SVProgressHUD.show()
        self.getServerStatus { (messageInfo) -> Void in
            
            if(messageInfo)
            {        self.connectToServerWithName()

                SocketIOManager.sharedInstance.getChatMessage
                    { (messageInfo) -> Void in
                        
                        if (!self.isMoveToChat)
                        {
                            var localchatMessages = [[String: AnyObject]]()
                            localchatMessages.append(messageInfo)
                            
                            let currentChatMessage = localchatMessages[0]
                            
                            
                            
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
                            {
                                return
                            }
                            
                            appDelegate.sendNotificaton(messgae: currentChatMessage)
                        }
                        
                }
            }
            
            else
            {
                let alert = UIAlertView(title: "", message: "Fujitsu server is not active", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                
                
                SVProgressHUD.dismiss()

            }
            
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func getServerStatus(completionHandler: @escaping (_ messageInfo: Bool) -> Void) {
       
        let parameters  = NetworkConstant.baseUrl + "/getServerStatus"
        
        
        
                   Alamofire.request(parameters)
                        .responseString { response in
                            if let error = response.result.error {
                                print(error)
                            }
                            if let value = response.result.value {
                                do {
                                    let data = value.data(using: .utf8)!
        
                                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
                                    print(json["status"]!)
        
                                    if (json["status"]! as! String == "OK")
                                    
                                    {
                                    completionHandler(true)

                                    }
                                    else
                                    {
                                        completionHandler(false)

                                        
                                    }
                                    
        
                                } catch let error as NSError {
                                    print("Failed to load: \(error.localizedDescription)")
                                    completionHandler(false)

        
                                }
                            }
                    }
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        //  - Handle notification
      let  userInfo: [String : AnyObject] = response.notification.request.content.userInfo as! [String : AnyObject]
       self.handleNotification(dict: userInfo as AnyObject);
 
    }
    
    
    
    func handleNotification( dict : AnyObject )
    {
        
        
        let respon: NSMutableDictionary  = [:]
        
        respon["message"] = dict["message"] as? String
        respon["senderName"] = dict["nickname"] as? String
         respon["reciverName"] = dict["to"] as? String
        


        
        for i in 0..<model.users.count
        {
            if( model.users[i]["nickname"]  as? String == dict["nickname"]  as? String)
            {
               
                let converstionViewCoontroler = self.storyboard?.instantiateViewController(withIdentifier:"ConversationViewController") as! ConversationViewController!
                converstionViewCoontroler?.reciverName = model.users[i]["nickname"] as? String
                converstionViewCoontroler?.nicknameID = model.users[i]["id"] as! String
                converstionViewCoontroler?.logiNicknameId = self.logiNicknameId
                if !(model.users[i]["isConnected"] as! Bool)
                {
                    let alert = UIAlertView(title: "", message: "User is offline", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                    
                    converstionViewCoontroler?.isOffline = true;
                }
                isMoveToChat = true;
                self.navigationController?.pushViewController(converstionViewCoontroler!, animated: true);
                
                
                break;
                }


            
        }
      
     
      
            
        

    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(true)
        isMoveToChat = false;
        
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        isMoveToChat = true;
    }
    

    
    @objc func logout()
    {
        //        self.navigationController?.popViewController(animated: true)
        UserDefaults.standard.removeObject(forKey: "name");
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatDetail")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do
        {
            let result = try managedContext.execute(request)
            
            print(result);
        }
        catch let error as NSError
        {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.navigationController?.popToRootViewController(animated: true);
        
    }
    
        
        

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return model.users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserLIstTableViewCell")as! UserLIstTableViewCell
        cell.labelName.text  =  model.users[indexPath.row]["nickname"] as? String
       cell.viewCircle.backgroundColor =  (model.users[indexPath.row]["isConnected"] as! Bool) ? UIColor.green : UIColor.red

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {        let converstionViewCoontroler = self.storyboard?.instantiateViewController(withIdentifier:"ConversationViewController") as! ConversationViewController!
        
        converstionViewCoontroler?.reciverName = model.users[indexPath.row]["nickname"] as? String
        converstionViewCoontroler?.nicknameID = model.users[indexPath.row]["id"] as! String
        converstionViewCoontroler?.logiNicknameId = self.logiNicknameId
        converstionViewCoontroler?.model = model;
        isMoveToChat = true;
        if !(model.users[indexPath.row]["isConnected"] as! Bool)
        {
            let alert = UIAlertView(title: "", message: "User is offline", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            
            converstionViewCoontroler?.isOffline = true;
        }
     
        self.navigationController?.pushViewController(converstionViewCoontroler!, animated: true);

        [tableView .deselectRow(at: indexPath, animated: false)];

    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func connectToServerWithName() {
        
        SVProgressHUD.show()
        
      // DispatchQueue.main.async {
            SocketIOManager.sharedInstance.connectToServerWithNickname(nickname:self.nickname, completionHandler: { (userList) -> Void in
                    if userList != nil {
                        SVProgressHUD.dismiss()
                        self.model.users = userList!
                        var index = 0
                        for  recordSettings : [String : AnyObject] in    self.model.users
                        {
                            index = index + 1
                            print(recordSettings);
                            for (_, theValue) in recordSettings
                            {
                                if(self.nickname != nil)
                                {
                                    let val = theValue as? String
                                    if val == self.nickname
                                    {
                                        self.logiNicknameId =  self.model.users[index - 1]["id"] as! String;
                                        self.model.users.remove(at: index - 1)
                                    }
                                }
                            }
                        }
                        
                        self.tableviewUserList.reloadData()
                        
                        
                    }
               // })
            })
       // }
    }
    
    
    
    private func scheduleLocalNotification(messgae: [String: AnyObject]) {
        // Create Notification Content
        
        
        
        let senderNickname = messgae["nickname"] as! String
        let messageResponse = messgae["message"] as! String
        let messageDate = messgae["date"] as! String
        let notificationContent = UNMutableNotificationContent()
        notificationContent.categoryIdentifier = "cocoacasts_local_notification"
        
        // Configure Notification Content
        notificationContent.title = senderNickname
        notificationContent.userInfo = messgae
        notificationContent.body = "From \(senderNickname.uppercased()) : \(messageResponse)"
        
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
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
        
    }
    
    
    func getuserlist()
    {
        
        let  check : String = NetworkConstant.baseUrl + "/getUserList";
        
        let encodedUrl = check.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedUrl!)
            .responseJSON { response in
                // check for errors
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /todos/1")
                    print(response.result.error!)
                    return
                }
                
                
               
                
                let AnyValue = response.result.value as! [[String: Any]];
                
                
                
                for i in 0..<AnyValue.count
                {
                    
                    
                    let val = AnyValue[i]["nickname"] as? String
                    if !(val! == self.nickname)
                       {
                    
                    var dictionary  = [String: AnyObject]();
                    dictionary["nickname"] = AnyValue[i]["nickname"]  as  AnyObject
                    dictionary["isConnected"] = false  as  AnyObject
                    dictionary["id"] = ""  as  AnyObject
                    self.model.storeusers.append(dictionary)
                    }
        
                }
                
                self.tableviewUserList.reloadData()
        }
    }

}
extension UIView {
    func makeCircular() {
        let cntr:CGPoint = self.center
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.clipsToBounds = true
        self.center = cntr
    }
}

extension UserListViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}
