//
//  FirebaseUserListener.swift
//  LetsChat
//
//  Created by K Praveen Kumar on 18/11/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseUserListener {
    static let shared = FirebaseUserListener()
    
    private init() {}
    
    //MARK: - Login
    func loginUserWithemail(email: String, password: String, completion:@escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadUserFromfirebse(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    
    func registerWith(email: String, password: String, completion:@escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let authUser = authDataResult?.user else {
                completion(NSError(domain: "FirebaseUserListener", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found in auth result"]))
                return
            }
            
            if error == nil {
                
                //send verification mail
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email sent in error:" , error?.localizedDescription)
                }
                
                // create user and save
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, userName: email, email: email, pushId: "",avatarLink: "" , status: "Hey there I am using LetsChat")
                    
                    saveUserLocally(user)
                    self.saveUserToFireStore(user)
                    completion(nil)
                }
            }
        }
    }
    
    func resendVerificationEmail(email: String, completion: @escaping(_ error: Error) -> Void ) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                completion(error!)
            })
        })
        
    }
    
    func resetPasswordFor(email: String, completion: @escaping(_ error: Error) -> Void ) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error!)
        }
        
    }
    
    //MARK: - save users
    
    func saveUserToFireStore(_ user: User) {
        do {
            try firebaseRreference(.User).document(user.id).setData(from: user){error in
                if let error = error {
                    print("Firestore save error: \(error.localizedDescription)")
                } else {
                    print("User saved successfully to Firestore!")
                }
            }
        } catch let error {
            print("Error saving user to Firestore: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Download User frm Firebase
    
    func downloadUserFromfirebse(userId: String, email: String? = nil) {
        firebaseRreference(.User).document(userId).getDocument { (querySnapshot, error) in
            guard let document = querySnapshot else {
                print("No document for user")
                return
            }
            
            let result = Result {
                try document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                saveUserLocally(userObject)
            case .failure(let error):
                print("Error decoding user:", error)
            }

        }
    }
    
}
