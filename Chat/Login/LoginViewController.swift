//
//  LoginViewController.swift
//  Chat
//
//  Created by AnshulJain on 06/08/18.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD


class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak  var textFiled: UITextField!
    @IBOutlet weak  var textFiledEmail: UITextField!


    @IBOutlet weak   var button: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
         self.title = "Login"
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if ((UserDefaults.standard.string(forKey: "name")) != nil)
        {
            self.navigateToHome();
            
        }
        else
        {
        
        SocketIOManager.sharedInstance.closeConnection()
        if UIScreen.main.nativeBounds.height <= 568 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        }
        }
    }
    
    
    @IBAction func nextButtonCLicked()
    {
        
    
        if (textFiled.text?.isEmpty)! || (textFiledEmail.text?.isEmpty)!
        {
            let alertController = UIAlertController(title: "", message:
                "Please enter require filed!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        else if(!self.isValidEmail(testStr: textFiledEmail.text as! String))
        {
            
            
            let alertController = UIAlertController(title: "", message:
                "Please enter valid email!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
            
            
        else
        {
            UserDefaults.standard.set(textFiledEmail.text, forKey: "eID") //setObject
            UserDefaults.standard.set(textFiled.text, forKey: "name")
            SVProgressHUD.show()
            self.sendMesageToServer();

            
         //   SVProgressHUD.show()

//            var parameters  = NetworkConstant.baseUrl + "/sendOTP" + "?"
//            parameters =      parameters   + "eID=" + textFiledEmail.text!
//            parameters = parameters   + "&" + "uName=" + textFiled.text!
//
//            Alamofire.request(parameters)
//                .responseString { response in
//                    if let error = response.result.error {
//                        print(error)
//                    }
//                    if let value = response.result.value {
//                        do {
//                            let data = value.data(using: .utf8)!
//
//                            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
//                            print(json["status"]!)
//
//                            if (json["status"]! as! String == "OK")
//                            {
//                            self.navigateToOTP();
//
//                            }
//
//                        } catch let error as NSError {
//                            print("Failed to load: \(error.localizedDescription)")
//
//
//                        }
//                    }
//            }
       
            
        }
        
    }
    
    
    
    func navigateToOTP() {
        SVProgressHUD.dismiss()

        let userListViewController =  self.storyboard?.instantiateViewController(withIdentifier:"LoginViewControllerOTP") as! OTPViewController?;
        
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.set(textFiledEmail.text, forKey: "eID") //setObject
        UserDefaults.standard.set(textFiled.text, forKey: "name") //setObject
        self.navigationController?.pushViewController(userListViewController!, animated: true);
    }
    
    
    
    func navigateToHome()
    {
      //setObject
        let userListViewController =  self.storyboard?.instantiateViewController(withIdentifier:"UserListViewController") as! UserListViewController!;
        userListViewController?.nickname = (UserDefaults.standard.string(forKey: "name"))
        
        self.navigationController?.pushViewController(userListViewController!, animated: true);
    }
    
    
    func sendMesageToServer()
    {
        
        let  urlString : String = NetworkConstant.baseUrl+"/send_deviceToken";
        let headers = ["Content-Type": "application/x-www-form-urlencoded"];
        
        let parameters  =
            ["token":(UserDefaults.standard.string(forKey: "deviceTokenString"))!,
             "nickname":(UserDefaults.standard.string(forKey: "name"))!
        ]
        
//        let parameters  =
//            ["token":"Simulator",
//             "nickname":(UserDefaults.standard.string(forKey: "name"))!
//        ]
        Alamofire.request(urlString, method: .post, parameters:parameters as Parameters,encoding: URLEncoding(), headers: headers).responseJSON
            {
                response in
                switch response.result
                {
                case .success:
                    let AnyValue = response.result.value as! Dictionary<String, String>;
                    
                       if let value = AnyValue["status"]
                       {
                        if(value == "OK")
                        {
                            self.navigateToHome()
                        }
                        else
                        {
                            let alert  = UIAlertController(title: "username already exists", message: "Please enter different username", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        SVProgressHUD.dismiss();

                    }
                    
                    
                    break
                case .failure(let error):
                    print(response)
                    SVProgressHUD.dismiss();

                    break
                }
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print(response.result.error!)
                    SVProgressHUD.dismiss();

                    return
                }
        }
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true;
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
          self.textFiled.resignFirstResponder();
          self.textFiledEmail.resignFirstResponder();
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y = self.view.frame.origin.x + (50 - keyboardHeight)
            print(keyboardHeight)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        // scrollViewBottomConstraint.constant = 0
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
