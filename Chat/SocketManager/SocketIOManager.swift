//
//  SocketIOManager.swift
//  Chat
//
//  Created by AnshulJain on 07/08/18.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit
import SocketIO


class SocketIOManager: NSObject
{
    let manager = SocketManager(socketURL: URL(string: NetworkConstant.baseUrl)!, config: [.log(true), .compress])
    static let sharedInstance = SocketIOManager()

    var socket:SocketIOClient!
    
    
    func establishConnection()
    {
        
        if socket == nil
        {
            self.socket = manager.defaultSocket;
            socket.connect()
        }
        
    }
    
    
    
    func connectToServer(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void)
    {
        
        
    }

    func connectToServerWithNickname(nickname: String, completionHandler: @escaping (_ userList: [[String: AnyObject]]?) -> Void)
    {
        
        self.establishConnection()
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            
            
            

          let check =   (UserDefaults.standard.string(forKey: "name"))
        
            if((check) != nil)
            {
                self.socket.emit("connectUser", check!)

            }

        }
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
            
        }
        
        
        socket.on("exist") { ( dataArray, ack) -> Void in
            completionHandler(nil)
            return
            
        }
        

       // listenForOtherMessages()
    }
    
    private func listenForOtherMessages()
    {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! [String: AnyObject])
        }

        socket.on("userExitUpdate")
        { (dataArray, socketAck) -> Void in
            if let stringVal = dataArray[0] as? String {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userWasDisconnectedNotification"), object: stringVal)

            }
        }
    }
    
    func sendMessage(message: String, withNickname nickname: String, withReciver to: String, withID nID: String, withLoginId lID: String, translationCode: String)
    {
        socket.emit("chatMessage", nickname, message, to, nID,lID, translationCode)
        
        
    }
    
    
    func sendMessageData(message: String, withNickname nickname: String, withReciver to: String, withID nID: String, withLoginId lID: String, translationCode: String)
    {
        socket.emit("chatMessage", nickname, message, to, nID,lID, translationCode)
        
        
    }
    
    func getChatMessage(completionHandler: @escaping (_ messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String as AnyObject?
            messageDictionary["message"] = dataArray[1] as! String as AnyObject?
            messageDictionary["date"] = dataArray[2] as! String as AnyObject?
            messageDictionary["to"] = dataArray[3] as! String as AnyObject?
            
            completionHandler(messageDictionary)
        }

    }
    
 
    func joinRoom(name: String, room: String)
    {
        
        
        self.socket.emit("join", ["name":name, "room": room]);
        
        
      //  socket.emit.to(room).emit();

        
    }
    
    

    
    
    func closeConnection()
    {
        if socket == nil {
            self.socket = manager.defaultSocket;
        }
        socket.disconnect()
        socket = nil
    }
    
    
}
