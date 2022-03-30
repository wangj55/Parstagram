//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Ji Wang on 3/26/22.
//

import AlamofireImage
import Parse
import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    var posts = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20

        query.findObjectsInBackground { posts, _ in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()

        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser

        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as? String

        let imageFile = post["image"] as! PFFileObject
        let usrString = imageFile.url!
        let url = URL(string: usrString)!

        cell.photoView.af.setImage(withURL: url)

        return cell
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
