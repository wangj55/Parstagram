//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Ji Wang on 3/26/22.
//

import Parse
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onLogIn(_ sender: Any) {
        // TODO: check if username and password are valid and non-empty

        PFUser.logInWithUsername(inBackground: usernameField.text!, password: passwordField.text!) { (user: PFUser?, error: Error?) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    @IBAction func onSignUp(_ sender: Any) {
        // TODO: check if username and password are valid and non-empty

        // sign up
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text

        user.signUpInBackground { success, error in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
