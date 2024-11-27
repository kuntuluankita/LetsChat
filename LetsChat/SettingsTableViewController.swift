//
//  SettingsTableViewController.swift
//  LetsChat
//
//  Created by K Praveen Kumar on 26/11/24.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
   //MARK: - Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showUserinfo()
    }
    
    //MARK: - Tableview Delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewbackgroundColour")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - Button Action
    
    @IBAction func tellfriendButtonPressed(_ sender: UIButton) {
        print("Tell a friend")
    }
    
    @IBAction func termsAndConditionButtonpressed(_ sender: UIButton) {
        print("t & c")
    }
    
    @IBAction func logOutbuttonPressed(_ sender: Any) {
        print("logout")
    }
    
    //MARK: - UpdateUI
    
    private func showUserinfo() {
        if let user = User.currentUser {
            userNameLabel.text = user.userName
            userStatusLabel.text = user.status
            appVersionLabel.text = "App Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            if user.avatarLink != "" {
                
            }
        }
    }
    
}
