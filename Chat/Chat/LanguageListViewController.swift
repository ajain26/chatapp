//
//  LanguageListViewController.swift
//  TakaraApp
//
//  Created by AnshulJain on 24/07/18.
//  Copyright © 2018 Dnyaneshwar Surywanshi. All rights reserved.
//

import UIKit
protocol ChatViewControllerDelegate : class{
    
    func  targetLanguage( addTargetLanguageCode: String)
    
}

class LanguageListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    @IBOutlet weak var tblUserList: UITableView!
      var targetLanguageCode : String!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    var filtered: [Language] = []

   let appDelegate = UIApplication.shared.delegate as? AppDelegate
    weak var delegate: ChatViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        searchBar.delegate = self
        filtered = (appDelegate?.languageArray)!

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(named: "logout"),
                            style: .plain,
                            target: self,
                            action: #selector(UserListViewController.logout)),
            
        ]
        
        // Do any additional setup after loading the view.
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.count == 0)
        {
              filtered = (appDelegate?.languageArray)!
        }
        else
        {
            
            
            
          //  var language = appDelegate?.languageArray.map({$0.language})
            
            
        filtered = (appDelegate?.languageArray.filter {(($0.language)?.lowercased())?.range(of:(searchText.lowercased())) != nil ? true : false})!
    
        }
        self.tblUserList.reloadData()
    }

    @objc func logout()
    {
        //        self.navigationController?.popViewController(animated: true)
        
        self.navigationController?.popToRootViewController(animated: true);
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
           // self.navigationController?.navigationBar.isHidden=true;
            configureTableView()
        
    }
    
    func configureTableView() {
        tblUserList.delegate = self
        tblUserList.dataSource = self
        tblUserList.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        //        tblUserList.isHidden = true
        tblUserList.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        
        return (filtered.count)

       // return (appDelegate?.languageArray.count)!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellUser", for: indexPath) as! UserCell
        
        let lanclass: Language  = filtered[indexPath.row] as! Language;

       // let lanclass: Language  =  appDelegate?.languageArray[indexPath.row] as! Language;
        cell.textLabel?.text = lanclass.language!
      
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
//        let lanclass: Language  =       appDelegate?.languageArray[indexPath.row] as! Language
        
        let lanclass: Language  =       filtered[indexPath.row] as! Language
        delegate?.targetLanguage(addTargetLanguageCode:lanclass.code!);
        
        self.navigationController?.popViewController(animated: true);

        
        
    }
    
    
    @IBAction func backToUserList(_ sender: AnyObject)
    {

        self.dismiss(animated: true, completion: {
            
        })
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
