//
//  LoginViewController.swift
//  LetsChat
//
//  Created by K Praveen Kumar on 14/11/24.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var haveAccountLabel: UILabel!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordetextField: UITextField!
    @IBOutlet weak var repeatPasswordextField: UITextField!
    
    @IBOutlet weak var emailseparatorView: UIView!
    @IBOutlet weak var passwordseparatorView: UIView!
    @IBOutlet weak var repeatPasswordseparatorView: UIView!
    
    //MARK: - Properties
    var isLogin: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundTap()
        setupTextFieldDelegate()
        updateUIFor(login: true)
    }
    
    //MARK: - Button Action
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        if isDataInputedFor(type: isLogin ? "Login" : "Register") {
            isLogin ? loginUser() : registerUser()
        } else {
            ProgressHUD.failed("All fields are required")
        }
    }
    
    @IBAction func forgotButtonTapped(_ sender: UIButton) {
        if isDataInputedFor(type: "password") {
            resetPassword()
        } else {
            ProgressHUD.failed("Email is required")
        }
    }
    
    @IBAction func resendButtonTapped(_ sender: UIButton) {
        if isDataInputedFor(type: "Password") {
            resendVarificationMail()
        } else {
            ProgressHUD.failed("Email is Required")
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        updateUIFor(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    //MARK: - Setup
    
    private func setupTextFieldDelegate() {
        emailTextField.addTarget(self, action: #selector(textFieldDidchange), for: .editingChanged)
        passwordetextField.addTarget(self, action: #selector(textFieldDidchange), for: .editingChanged)
        repeatPasswordextField.addTarget(self, action: #selector(textFieldDidchange), for: .editingChanged)
    }
    
    @objc func textFieldDidchange(textField: UITextField) {
        updatePlaceHolderLabels(textField: textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
    //MARK: - Animation
    
    private func updateUIFor(login: Bool) {
        logInButton.setImage(UIImage(named: login ? "loginBtn" : "registerBtn"), for: .normal)
        signUpButton.setTitle(login ? "SignUp" : "Login", for: .normal)
        haveAccountLabel.text = login ? "Don't have an account?" : "Have an Account?"
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordextField.isHidden = login
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordseparatorView.isHidden = login
        }
        
    }
    
    private func updatePlaceHolderLabels(textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email": ""
        case passwordetextField:
            passwordLabel.text = textField.hasText ? "Password": ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "RepeatPassword": ""
        }
    }
    
    private func isDataInputedFor(type: String) -> Bool {
        switch type {
        case "login":
            return emailTextField.text != "" && passwordetextField.text != ""
        case "registraion":
            return emailTextField.text != "" && passwordetextField.text != "" && repeatPasswordextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func loginUser() {
        FirebaseUserListener.shared.loginUserWithemail(email: emailTextField.text!, password: passwordetextField.text!) { error, isEmailVerified in
            if error == nil {
                if isEmailVerified {
                    self.gotoApp()
                    print("user has loggedin,", User.currentUser?.email)
                } else {
                    ProgressHUD.failed("Please verify email")
                    self.resendButton.isHidden = false
                }
            } else {
                ProgressHUD.failed(error?.localizedDescription)
            }
        }
    }
    
    private func registerUser() {
        if passwordetextField.text! == repeatPasswordextField.text! {
            FirebaseUserListener.shared.registerWith(email: emailTextField.text!, password: passwordetextField.text!) { (error) in
                if error == nil {
                    ProgressHUD.succeed("Verification email sent")
                    self.resendButton.isHidden = false
                } else {
                    ProgressHUD.failed(error?.localizedDescription)
                }
            }
        } else {
            ProgressHUD.failed("Password don't match")
        }
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.succeed("Reset link sent to email.")
            } else {
                ProgressHUD.failed(error.localizedDescription)
            }
        }
    }
    
    private func resendVarificationMail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
            if error == nil {
                ProgressHUD.succeed("New Varification Email sent")
            } else {
                ProgressHUD.failed(error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    
    private func gotoApp() {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Mainview") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }

}
