//
//  SlideUser.swift
//  Slide
//
//  Created by Valeriy Soltan on 6/12/19.
//  Copyright © 2019 Roodac. All rights reserved.
//

import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

// an interface between the database and the user
class AppUser {
    
    // MARK: - PROPERTIES
    let defaults = UserDefaults.standard

    // MARK: - BACKEND AND LOCAL STORAGE

    // retrieves the data tree belonging to the current user
    private static func getDocument(forUserWithID currentUserID: String, completionHandler: @escaping ([QueryDocumentSnapshot]?, Error?) -> Void) {
        // reference to the database
        let db = Firestore.firestore()

        // asynchronous call to the database
        db.collection("users").whereField("ID", isEqualTo: currentUserID).getDocuments { (snapshot, error) in
            if error != nil {
                // user was not found
                CustomError.createWith(errorTitle: "Data Retrieval", errorMessage: error!.localizedDescription)
                completionHandler(nil, error)
            } else {
                // upon completion, returns a reference to the document
                completionHandler((snapshot?.documents)!, nil)
            }
        }
    }
    
    // downloads user data to local storage
    static func setLocalData(for userID: String, completionHandler: @escaping (Error?) -> Void) {
        // thread deployed to interact with database
        getDocument(forUserWithID: userID) { (userData, error) in
            if (error == nil && userData != nil) {
                // iterates through the array, as there may be several docs
                for document in userData! {
                    // retrieves user data from Firebase into UserDefaults
                    UserDefaults.standard.setAllDefaults(source: document)
                    completionHandler(nil)
                }
            } else {
                print("\(error!)")
                // Notify that there was indeed an error
                completionHandler(error)
            }
        }
    }
    
    // wipe defaults
    static func clearLocalData() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    // retrieve key value pairs in defaults for processing
    static func generateKeyDictionary() -> NSDictionary {
        let defaults = UserDefaults.standard
        
        let dictionary: NSDictionary = [
            "name"     : defaults.getName(),
            "email"    : defaults.getEmail(),
            "mobile"   : defaults.getPhoneNumber() ?? NSNull(),
            "facebook" : defaults.getFacebookID() ?? NSNull(),
        ]
        return dictionary
    }
    
    // MARK: - ACCOUNT
    
    static func logout() {
        let auth = Auth.auth()

        // checks the provider
        if let providerData = auth.currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                    
                    case "facebook.com":
                        let loginManager = LoginManager()
                        loginManager.logOut()
        
                    case "google.com":
                        GIDSignIn.sharedInstance()?.signOut()
                    
                    default:
                        print("provider is \(userInfo.providerID)")
                }
            }
        }

        // end the user session in firebase
        do {
            try auth.signOut()
            
            // removes user data from local storage
            AppUser.clearLocalData()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    static func deleteUser(caller: UIViewController) {
        
        // reauthenticate for auth method linked to user account
        if let user = Auth.auth().currentUser {
            
            switch user.providerID {
                
            case "facebook.com":
                if let credential = facebookCredential(){
                    self.reauthenticateAndDelete(credential: credential, currUser: user, caller: caller)
                }
                
            case "google.com":
                if let credential = googleCredential(){
                    self.reauthenticateAndDelete(credential: credential, currUser: user, caller: caller)
                }
                
            case "Firebase":
                reauthenticateAlert(usr: user, caller: caller)
                
            // couldn't find auth method
            default:
                print(user.providerID)
                print("unknown auth provider")
            }
        }
    }
    
    // reauthenticate user using provided credential
    static func reauthenticateAndDelete(credential: AuthCredential, currUser: User, caller: UIViewController){
        
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (user, error) in
            if let error = error {
                print("reauth error \(error.localizedDescription)")
            } else {
                print("no reauth error")
                // attempt to delete
                currUser.delete(completion: { (error) in
                    if (error == nil) {
                        // clear user's database data
                        self.deleteData(userID: currUser.uid)
                        
                        // segue into LoginViewController
                        let login = Login()
                        caller.present(login, animated: true, completion: nil)
                    }
                })
            }
        })
    }
    
    // prompts the user to reenter login information before account deletion
    static func reauthenticateAlert(usr: User, caller: UIViewController) {

        let alert = UIAlertController(title: "Sign In", message: "Sign in to confirm deletion of all account data", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Email"}
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let confirm = UIAlertAction(title: "OK", style: .destructive, handler: { (action: UIAlertAction) in
            let email = alert.textFields![0]
            let password = alert.textFields![1]
            
            let signInInfo: Array<(field: UITextField, type: String)>
                = [(email, "username"), (password, "password")]
            
            if (TextParser.validate(textFields: signInInfo)) {
                if let credential = self.emailCredential(email: email.text!, password: password.text!) {
                    self.reauthenticateAndDelete(credential: credential, currUser: usr, caller: caller)
                } else {
                    print("error")
                }
            }
        })
        
        // create the buttons on the prompt
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        // create the prompt
        caller.present(alert, animated: true, completion: nil)
    }
    
    // deletes all other data in user's documents and local storage
    static func deleteData(userID: String){
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).delete() { error in
            if let error = error {
                CustomError.createWith(errorTitle: "Document Removal Error", errorMessage: error.localizedDescription)
            } else {
                print("Document successfully removed")
            }
        }
        AppUser.clearLocalData()
    }
    
    
    // MARK: - API
    
    // get facebook credential
    static func facebookCredential() -> AuthCredential? {
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        return credential
    }
    
    // get email-password credendtial
    static func emailCredential(email:String,password:String) -> AuthCredential? {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return credential
    }
    
    // get google credential
    static func googleCredential() -> AuthCredential? {
        guard let user = GIDSignIn.sharedInstance().currentUser else { return nil }
        guard let authentication = user.authentication else { return nil }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        return credential
    }
    
    // MARK: - GETTERS AND SETTERS
    func getName() -> String {
        return defaults.getName()
    }
    
    func setName(value: String) {
        defaults.setName(value: value)
    }
    
    func getEmail() -> String {
        return defaults.getEmail()
    }
    
    func setEmail(value: String) {
        defaults.setEmail(value: value)
    }
    
    func getPhone() -> String? {
        return defaults.getPhoneNumber()
    }
    
    func setPhone(value: String) {
        defaults.setPhoneNumber(value: value)
    }
    
    // TODO finish this or figure out a way to make it more elegant (not have to define funcs twice)
}

// MARK: - USER DEFAULTS

// implemented properties for UserDefaults
enum UserDefaultsKeys: String {
    case email
    case id
    case name
    case phone
    case groups
    case fbid
}


