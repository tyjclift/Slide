//
//  LoginViewController.swift
//  Slide
//
//  Created by Valeriy Soltan on 6/6/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, LoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var facebookButton: FBLoginButton!
    @IBOutlet weak var googleButton: GIDSignInButton!
    
    @IBAction func LogInActivated(_ sender: Any) {
        let signInInfo: Array<(field: UITextField, type: String)>
            = [(email, "username"), (password, "password")]
        
        // TODO fix empty textfields working
        // checks that the user passed information to the application
        
        if (TextFieldParser.validate(textFields: signInInfo) == true) {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
                if (user != nil) {
                    // retrieves user data to create defaults for the current session
                    User.getUser(userID: Auth.auth().currentUser!.uid, completionHandler: { (error) in
                        if (error != nil) {
                            print("something went wrong")
                        } else {
                            self.performSegue(withIdentifier: "signInToMain", sender: self)
                        }
                    })
                } else {
                    CustomError.createWith(errorTitle: "Login Error", errorMessage: error!.localizedDescription).show()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // creates facebook login button
        let loginButton = FBLoginButton()
        loginButton.delegate = self

        // creates login button from GoogleSignIn
        //GIDSignIn.sharedInstance().uiDelegate = self
        
        // automatically signs the user into google.
        //GIDSignIn.sharedInstance().signIn()
        
        // TODO: Configure the sign-in button look/feel
    }

    @IBAction func facebookLogin(sender: AnyObject) {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (loginResult, error) in
            self.loginButton(self.facebookButton, didCompleteWith: loginResult, error: error)
        }
    }
    
    // Login Button protocol
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if let error = error {
            CustomError.createWith(errorTitle: "Facebook Login Error", errorMessage: error.localizedDescription).show()
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        
        // creates a new account and signs in the user
        Auth.auth().signIn(with: credential) { (authResult, error) in
            // something happened while logging in
            if (authResult == nil) {
                print("login cancelled")
                return
            }
            if let error = error {
                CustomError.createWith(errorTitle: "Facebook Login Error", errorMessage: error.localizedDescription).show()
                return
            } else {
                // checks if a document exists under this user's alias
                if ((authResult?.additionalUserInfo!.isNewUser)!) {
                    print("passed checkpoint 1")
                    // retrieves the data from the user's supplied facebook account
                    let r = GraphRequest(graphPath: "me", parameters: ["fields":"name, email"], tokenString: AccessToken.current?.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
                    
                    r.start(completionHandler: { (test, result, error) in
                        if(error != nil) {
                            print("something went wrong")
                        }
                        else {
                            print("we made it?")
                            let data = result as! NSDictionary
                            print("WOOOOO", data["name"] as! String)
                            let userID = Auth.auth().currentUser!.uid
                            let db = Firestore.firestore()
                            
                            let myGroup = DispatchGroup()
                            
                            myGroup.enter()
                            db.collection("users").document(userID).setData([
                                // set specified data entries
                                "Name": data["name"] as! String,
                                "ID": userID,
                                "Email": data["email"] as! String,
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                    myGroup.leave()
                                }
                            }
                        }
                    })
                }
                print("this runs btw")
                // update user defaults
                User.getUser(userID: Auth.auth().currentUser!.uid, completionHandler: { (error) in})
                
                self.performSegue(withIdentifier: "signInToMain", sender: self)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // Do something when the user logout
        print("Logged out")
    }
    
    // GOOGLE STUFF
    
    // to be implemented later for google signout...
    //    @IBAction func didTapSignOut(_ sender: AnyObject) {
    //        GIDSignIn.sharedInstance().signOut()
    //    }
    
    //
    
    //    func googleSignIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
    //                    withError error: NSError!) {
    //        if (error == nil) {
    //                // Perform any operations on signed in user here.
    //        } else {
    //            print("\(error.localizedDescription)")
    //        }
    //    }

}
