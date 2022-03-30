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
        query.includeKeys(["author", "comments", "comments.author"])
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
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? []

        return 1 + comments.count // each post and its many comments
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }

    // What to display in each cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

            let user = post["author"] as! PFUser

            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String

            let imageFile = post["image"] as! PFFileObject
            let usrString = imageFile.url!
            let url = URL(string: usrString)!

            cell.photoView.af.setImage(withURL: url)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row-1]
            if let user = comment["author"] as? PFUser {
                cell.nameLabel.text = user.username
            }
            cell.commentLabel.text = comment["text"] as? String ?? "Text"

            return cell
        }
    }

    // What to do when a row is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]

        let comment = PFObject(className: "Comments")
        comment["text"] = "This is an auto-generated comments."
        comment["post"] = post
        comment["author"] = PFUser.current()

        post.add(comment, forKey: "comments")
        post.saveInBackground { success, error in
            if success {
                print("Comment saved.")
            } else {
                print("Error at saving comment: \(String(describing: error?.localizedDescription))")
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
