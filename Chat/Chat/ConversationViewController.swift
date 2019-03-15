/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit
import MapKit
import Alamofire
import CoreData
import AVFoundation
import Speech






internal class ConversationViewController: MessagesViewController, ChatViewControllerDelegate{

    let refreshControl = UIRefreshControl()
    var nickname: String!
    var nicknameID: String!
    var logiNicknameId: String!
    var reciverName: String!
    var chatDetail: [NSManagedObject] = []
    var isOffline = false
    var   targetLanguageCode: String!
    var messageList: [MockMessage] = []
    var serverArray: NSMutableArray = []
    var offlineArray: NSMutableArray = []
    var model = CounterModel();
    var imagePicker = UIImagePickerController()
    
    var imageStr: String!
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!


var notifictionArray: NSMutableArray = []
    var isTyping = false
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func recordingButtonClcik()
    {
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                        self.startRecording();
//                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    
    }
    
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    
    func finishRecording(success: Bool)
    {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
 print("record succesfully")
        } else {
            print("recording error")
            // recording failed :(
        }
    }
    
    
    
    //MARK: - Choose image from camera roll
    
    func openGallary(){
        
        self.finishRecording(success: true);
        
//        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        //If you dont want to edit the photo then you can set allowsEditing to false
//        imagePicker.allowsEditing = true
//        imagePicker.delegate = self
//        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initalizeNavigationBar();
        self.intializeViewDidload();
        recordingSession = AVAudioSession.sharedInstance()

        
        if(!isOffline)
        {
     //   self.slack()
        }
        
       
        
        
        
        
        
        
      
       //    SocketIOManager.sharedInstance.joinRoom(name: (UserDefaults.standard.string(forKey: "name"))!, room: "123")
        
        
        self.getOfflineMessages();
       self.getSocketCheatMessage();
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        
    }
    
    
   func slack()  {
    defaultStyle()
    messageInputBar.backgroundView.backgroundColor = .white
    messageInputBar.isTranslucent = false
    messageInputBar.inputTextView.backgroundColor = .clear
    messageInputBar.inputTextView.layer.borderWidth = 0
    let items = [
        
        makeButton(named: "audio").onTextViewDidChange { button, textView in
            button.isEnabled = textView.text.isEmpty
        },
    makeButton(named: "ic_camera").onTextViewDidChange { button, textView in
    button.isEnabled = textView.text.isEmpty
    },
    makeButton(named: "ic_at").onSelected {
    $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    },
    makeButton(named: "ic_hashtag").onSelected {
    $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    },
    .flexibleSpace,
    makeButton(named: "ic_library").onTextViewDidChange { button, textView in
    button.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    button.isEnabled = textView.text.isEmpty
    },
    messageInputBar.sendButton
    .configure {
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1.5
    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
    $0.setTitleColor(.white, for: .normal)
    $0.setTitleColor(.white, for: .highlighted)
    $0.setSize(CGSize(width: 52, height: 30), animated: true)
    }.onDisabled {
    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
    $0.backgroundColor = .white
    }.onEnabled {
    $0.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    $0.layer.borderColor = UIColor.clear.cgColor
    }.onSelected {
    // We use a transform becuase changing the size would cause the other views to relayout
    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }.onDeselected {
    $0.transform = CGAffineTransform.identity
    }
    ]
    items.forEach { $0.tintColor = .lightGray }
    
    // We can change the container insets if we want
    messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    
    // Since we moved the send button to the bottom stack lets set the right stack width to 0
    messageInputBar.setRightStackViewWidthConstant(to: 0, animated: true)
    
    // Finally set the items
    messageInputBar.setStackViewItems(items, forStack: .bottom, animated: true)
    }
    
    @objc func update()  {
      //   SocketIOManager.sharedInstance.joinRoom(name: (UserDefaults.standard.string(forKey: "name"))!, room: "123")
    }
    
    func  initalizeNavigationBar()
    {
        
        targetLanguageCode  = "en"

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
       navigationItem.rightBarButtonItem?.title = "Translate"
        navigationItem.rightBarButtonItems = [
            
            UIBarButtonItem(image: UIImage(named: "translator"),
                            style: .plain,
                             target: self,
                            action: #selector(ConversationViewController.targetLanguageController))
            
            
        ]
        navigationItem.leftBarButtonItems = [
            
            UIBarButtonItem(image: UIImage(named: "back"),
                            style: .plain,
                            target: self,
                            action: #selector(ConversationViewController.back))
            
            
        ]
        navigationItem.leftBarButtonItem?.title = "Back"
        
    }
    
    
    func getSocketCheatMessage()
    {
      
        
        
        


        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            
    
            if(self.navigationController  != nil)
            {
            
            var localchatMessages = [[String: AnyObject]]()
            localchatMessages.append(messageInfo)
            let currentChatMessage = localchatMessages[0]
            let loginNicknameID = currentChatMessage["nickname"] as! String
            let senderNicknameID = currentChatMessage["to"] as! String
                
//                let imageDatas = Data(base64Encoded: currentChatMessage["message"] as! String, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) ?? nil
//
                var message:MockMessage!
//
//                if  (imageDatas != nil)
//                {
//                    if(UIImage(data: imageDatas!) != nil)
//
//                    {
//
//                      message = MockMessage(image: UIImage(data: imageDatas!)!,sender:Sender(id: self.nicknameID, displayName: loginNicknameID), messageId: UUID().uuidString, date: Date())
//                    }
//
//                        // ...UIImage(data: imageDatas)!
//                    else {
//
//                        message =  MockMessage(text: currentChatMessage["message"] as! String , sender:Sender(id: self.nicknameID, displayName: loginNicknameID), messageId: UUID().uuidString, date: Date())
//                    }
//
//                }
//                    // ...UIImage(data: imageDatas)!
//                else {
//
                   message =  MockMessage(text: currentChatMessage["message"] as! String , sender:Sender(id: self.nicknameID, displayName: loginNicknameID), messageId: UUID().uuidString, date: Date())
              //  }
           
          
            if(loginNicknameID == self.reciverName)
            {
                //  self.chatMessages.append(messageInfo)
                // self.tblChat.reloadData()
                // self.isMessageSend = false
                //  self.scrollToBottom()
                let serverDic:Dictionary<String, String> =  [
                    "message": currentChatMessage["message"] as! String,
                    "reciverName":senderNicknameID ,
                    "senderName":loginNicknameID
                ]
                self.serverArray.add(serverDic);
                self.messageList.append(message)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
           }
            else
            {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
                {
                    return
                }
                
                appDelegate.sendNotificaton(messgae: currentChatMessage)
            }
        }
        
        }

        
    }
    
    
    func getFetchrequest()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
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
    
    
    func intializeViewDidload()
    {
        
        self.getFetchrequest();
  
    

    do
    {
    if(chatDetail.count > 0)
    {
    let chatFirst = chatDetail[0]
    
    let string =     chatFirst.value(forKeyPath: "messages") as? String
    
    let data = string!.data(using: .utf8)
    let jsonResponse = try JSONSerialization.jsonObject(with:
    data!, options: []) as! [Any]
    
    self.serverArray .addObjects(from: jsonResponse );
   var message :MockMessage
        
        
        self.serverArray.addObjects(from: self.notifictionArray as! [Any])

     for i in 0..<self.serverArray.count
    {
    let dict:NSDictionary = self.serverArray[i] as! NSDictionary
      
        let nick : String =   (dict["senderName"] != nil)  ?  dict["senderName"] as! String : dict["nickname"] as! String
          let to : String =   (dict["reciverName"] != nil)  ?  dict["reciverName"] as! String : dict["to"] as! String
        
        
//        let imageDatas = Data(base64Encoded: dict["message"]  as! String, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) ?? nil
//
//        if  (imageDatas != nil)
//        {
//            if(UIImage(data: imageDatas!) != nil)
//
//            {
//
//            if ((UserDefaults.standard.string(forKey: "name")) == nick )
//            {
//
//
//                message = MockMessage(image: UIImage(data: imageDatas!)!, sender:self.currentSender(), messageId: UUID().uuidString, date: Date())
//            }
//            else
//            {
//                message = MockMessage(image: UIImage(data: imageDatas!)!  , sender:Sender(id: to , displayName:nick), messageId: UUID().uuidString, date: Date())
//            }
//
//            }
//            else
//            {
//
//                  message =  MockMessage(text: dict["message"]  as! String , sender:Sender(id: to , displayName:nick), messageId: UUID().uuidString, date: Date())
//            }
//
//        }
//            // ...UIImage(data: imageDatas)!
//        else {
        
            message =  MockMessage(text: dict["message"]  as! String , sender:Sender(id: to , displayName:nick), messageId: UUID().uuidString, date: Date())
       // }
        
        
   
    self.messageList.append(message)
    }
        
   }
    else
    {
        var message :MockMessage
        
        self.serverArray.addObjects(from: self.notifictionArray as! [Any])
        for i in 0..<self.serverArray.count
        {
            let dict:NSDictionary = self.serverArray[i] as! NSDictionary
            if ((UserDefaults.standard.string(forKey: "name")) ==  dict["senderName"] as! String )
            {
                message = MockMessage(text: dict["message"]  as! String , sender:self.currentSender(), messageId: UUID().uuidString, date: Date())
            }
            else
            {
                message = MockMessage(text:dict["message"]  as! String  , sender:Sender(id: dict["reciverName"] as! String, displayName: dict["senderName"] as! String), messageId: UUID().uuidString, date: Date())
            }
            self.messageList.append(message)
        }
    }
    }
    catch let error as NSError
    {
    print("Could not fetch. \(error), \(error.userInfo)")
    }

    
    }
    
    

    
    
    
    

    
    
    func getOfflineMessages()
    {
        
      let  check : String = NetworkConstant.baseUrl + "/get_messages?id="+(UserDefaults.standard.string(forKey: "name"))!+self.reciverName;
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
                

                
                let AnyValue = response.result.value as! Array<Any>;
                
                
                
                for i in 0..<AnyValue.count
                {
                    
                    let currentChatMessage : Dictionary<String, String> = AnyValue[i] as! Dictionary<String, String>
                    
                    let loginNicknameID = currentChatMessage["senderName"]
                    let senderNicknameID = currentChatMessage["reciverName"]
                    
                    var message :MockMessage!
                    if ((UserDefaults.standard.string(forKey: "name")) == loginNicknameID )
                    {
                        
                        
                                message =  MockMessage(text: currentChatMessage["message"]!  ,sender:self.currentSender(), messageId: UUID().uuidString, date: Date())
                        
                    }
                    else
                    {
                        message = MockMessage(text: currentChatMessage["message"]!  , sender:Sender(id: senderNicknameID!, displayName: loginNicknameID!), messageId: UUID().uuidString, date: Date())
                        
                    }
                    
                    let serverDic:Dictionary<String, String> =  [
                        "message": currentChatMessage["message"]! ,
                        "reciverName":senderNicknameID! ,
                        "senderName":loginNicknameID!
                    ]
                    
                    self.serverArray.add(serverDic);
                    
                    self.messageList.append(message)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
                
        }
    }
    
    
    
    
    
    @objc func logout()
    {
        //        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true);
    }
    
  
    @objc func handleTyping() {
        
        defer {
            isTyping = !isTyping
        }
        
        if isTyping {
            
            messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
            messageInputBar.topStackViewPadding = .zero
            
        } else {
            
            let label = UILabel()
            label.text = "nathan.tannar is typing..."
            label.font = UIFont.boldSystemFont(ofSize: 16)
            messageInputBar.topStackView.addArrangedSubview(label)
            messageInputBar.topStackViewPadding.top = 6
            messageInputBar.topStackViewPadding.left = 12
            
            // The backgroundView doesn't include the topStackView. This is so things in the topStackView can have transparent backgrounds if you need it that way or another color all together
            messageInputBar.backgroundColor = messageInputBar.backgroundView.backgroundColor
            
        }

    }
    
    
    
    @objc func back()
    {
        
   
      self.saveData();
     if(isOffline)
     {
   // self.sendMesageToServer(array: self.offlineArray);

     }
    self.navigationController?.popViewController(animated: false);
    }
    @objc func targetLanguageController()
    {
        //        self.navigationController?.popViewController(animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatvc = storyboard.instantiateViewController(withIdentifier: "LanguageListViewController") as? LanguageListViewController
        target
        chatvc?.delegate = self as ChatViewControllerDelegate;
        chatvc?.targetLanguageCode = targetLanguageCode;
        self.navigationController?.pushViewController(chatvc!, animated: true)
        
    }
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 4) {
            SampleData.shared.getMessages(count: 10) { messages in
                DispatchQueue.main.async {
                    self.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc func handleKeyboardButton() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        let actionSheetController = UIAlertController(title: "Change Keyboard Style", message: nil, preferredStyle: .actionSheet)
        let actions = [
            UIAlertAction(title: "Slack", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.slack()
                })
            }),
            UIAlertAction(title: "iMessage", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.iMessage()
                })
            }),
            UIAlertAction(title: "Default", style: .default, handler: { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.defaultStyle()
                })
            }),
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ]
        actions.forEach { actionSheetController.addAction($0) }
        actionSheetController.view.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Style

    
    func iMessage() {
        defaultStyle()
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: true)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: true)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.sendButton.backgroundColor = .clear
        messageInputBar.textViewPadding.right = -38
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    // MARK: - Helpers
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                
                if(named == "audi")
                
                {
                    
                    self.recordingButtonClcik();

                }
                
                if(named == "ic_camera")
                {
                    self.openCamera();
                    
                    
                   // self.recordingButtonClcik();
                }
                else if(named == "ic_library")
                {
                    self.openGallary()

                }
                
                
        }
    }
}




// MARK: - MessagesDataSource

extension ConversationViewController: MessagesDataSource {

    func currentSender() -> Sender {
       // return SampleData.shared.currentSender
        
        let steven = Sender(id: self.logiNicknameId, displayName: (UserDefaults.standard.string(forKey: "name"))!)

        var currentSender: Sender {
            return steven
        }
        return currentSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {

    // MARK: - Text Messages

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey: Any] {
        return MessageLabel.defaultAttributes
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }

    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
//        let configurationClosure = { (view: MessageContainerView) in}
//        return .custom(configurationClosure)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
       let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }

    // MARK: - Location Messages

    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }

    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 10
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

}

// MARK: - MessageCellDelegate

extension ConversationViewController: MessageCellDelegate
{

    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }

    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }

    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ConversationViewController: MessageLabelDelegate
{

    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }

    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

}

// MARK: - MessageInputBarDelegate

extension ConversationViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
                let imageData: Data? = UIImageJPEGRepresentation(image, 0.1)
                imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
                
                let serverDic:Dictionary<String, String> =  [
                    "message": imageStr,
                    "reciverName":reciverName ,
                    "senderName":(UserDefaults.standard.string(forKey: "name"))!
                ]
                
                

                if(isOffline)
                {
                //    self.offlineArray.add(serverDic);
                }
                
                self.serverArray.add(serverDic);

                    SocketIOManager.sharedInstance.sendMessageData(message: imageStr, withNickname:(UserDefaults.standard.string(forKey: "name"))! , withReciver: reciverName, withID: nicknameID, withLoginId: logiNicknameId, translationCode: targetLanguageCode)
                
            }
            else if let text = component as? String
            {
                
                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])
                
                let serverDic:Dictionary<String, String> =  [
                    "message": text,
                    "reciverName":reciverName ,
                    "senderName":(UserDefaults.standard.string(forKey: "name"))!
                ]
                
                
                
                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                
//                if (!isOffline)
//                {
                
            
                    
                    
                SocketIOManager.sharedInstance.sendMessage(message: text, withNickname:(UserDefaults.standard.string(forKey: "name"))! , withReciver: reciverName, withID: nicknameID, withLoginId: logiNicknameId, translationCode: targetLanguageCode)
//                }
                
                
                if(isOffline)
                {
               // self.offlineArray.add(serverDic);
                }
                
                self.serverArray.add(serverDic);

                
            messageList.append(message)
           messagesCollectionView.insertSections([messageList.count - 1])
                
            }
            
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
    func  targetLanguage( addTargetLanguageCode: String)
    {
        targetLanguageCode  = addTargetLanguageCode;
    }
    
    
    func sendMesageToServer(array:NSMutableArray)
    {

        let  urlString : String = NetworkConstant.baseUrl+"/send_message";
        let data = try? JSONSerialization.data(withJSONObject: array, options:[])
        let string = String(data: data!, encoding: .utf8)
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters  =
            ["messages":string!,
             "Uname":(UserDefaults.standard.string(forKey: "name"))!,
              "Rname":self.reciverName!
        ]
        Alamofire.request(urlString, method: .post, parameters:parameters,encoding: URLEncoding(), headers: headers).responseJSON
            {
            response in
            switch response.result
            {
            case .success:
                print(response)
                break
            case .failure(let error):
                print(response)
                break
            }
            guard response.result.error == nil else {
                // got an error in getting the data, need to handle it
                print("error calling GET on /todos/1")
                print(response.result.error!)
                return
            }
        }
       
    }

    func saveData()
    {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {
            return
        }
        let chatUserName =  (UserDefaults.standard.string(forKey: "name"))! + self.reciverName!
        let data = try? JSONSerialization.data(withJSONObject: self.serverArray, options:[])
        let string = String(data: data!, encoding: .utf8)
        let managedContext = appDelegate.persistentContainer.viewContext

        if(chatDetail.count>0)
        {

            var managedObject = chatDetail[0]
            managedObject.setValue(string, forKey: "messages")
            managedObject.setValue(chatUserName, forKey: "chatUname")

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }

            else
            
        {
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
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        print("observeValue keyPath:\(String(describing: keyPath)) object: \(String(describing: object))")
        
        guard let object = object else { return }
        
        if let model = object as? CounterModel {
            if keyPath == "users"
            {
                
                for i in 0..<model.users.count
                  {
                    if(model.users[i]["nickname"] as? String == self.reciverName)
                    {
                        self.nicknameID =  model.users[i]["id"] as? String
                    }
 
                    
                }
               
            }
          
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
  model.addObserver(self, forKeyPath: "users", options: NSKeyValueObservingOptions(), context: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        model.removeObserver(self, forKeyPath: "users")
    }
    

    

   
    
}
    

extension ConversationViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{

          
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = editedImage

            let image1String = NSAttributedString(attachment: image1Attachment)

            messageInputBar.inputTextView.attributedText = image1String
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}


extension ConversationViewController:  AVAudioRecorderDelegate, SFSpeechRecognizerDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
