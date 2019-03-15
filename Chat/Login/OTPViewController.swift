//
//  OTPViewController.swift
//  Chat
//
//  Created by AnshulJain on 21/09/18.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
class OTPViewController: UIViewController {
    @IBOutlet weak  var textFiledOTP: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        if UIScreen.main.nativeBounds.height <= 568 {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        }

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        self.textFiledOTP.resignFirstResponder();
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func nextButtonOTPCLicked()
    {
        
        SVProgressHUD .show()
        
        var parameters  = NetworkConstant.baseUrl + "/getOTP" + "?"
        parameters =      parameters   + "eID=" + UserDefaults.standard.string(forKey: "eID")!
        parameters = parameters   + "&" + "uName=" + UserDefaults.standard.string(forKey: "name")!
        parameters = parameters   + "&" + "OTP=" + textFiledOTP.text!
        
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
                            SVProgressHUD.dismiss()
                            self.navigateToHome();
                            
                        }
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                        
                        
                    }
                }
        }
        
    }
    
    
    
    func navigateToHome()
    {
        let userListViewController =  self.storyboard?.instantiateViewController(withIdentifier:"UserListViewController") as! UserListViewController!;
        userListViewController?.nickname = (UserDefaults.standard.string(forKey: "name"))
        
        self.navigationController?.pushViewController(userListViewController!, animated: true);
    }
    

}
