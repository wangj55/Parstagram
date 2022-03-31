//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Ji Wang on 3/26/22.
//

import AlamofireImage
import MessageInputBar
import Parse
import UIKit

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    @IBOutlet var tableView: UITableView!

    let commentBar = MessageInputBar()
    var showCommentBar: Bool = false

    var posts = [PFObject]()
    var selectedPost: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self

        tableView.keyboardDismissMode = .interactive

        let center = NotificationCenter.default

        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
    }

    override var inputAccessoryView: UIView? {
        return commentBar
    }

    override var canBecomeFirstResponder: Bool {
        return showCommentBar
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

    /// Log Out is pressed.
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()

        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window?.rootViewController = loginViewController
    }

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { success, error in
            if success {
                print("Comment saved.")
            } else {
                print("Error at saving comment: \(String(describing: error?.localizedDescription))")
            }
        }

        tableView.reloadData()

        // clear the comment
        commentBar.inputTextView.text = nil
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = post["comments"] as? [PFObject] ?? []

        return comments.count + 2 // each post and its many comments
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
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            if let user = comment["author"] as? PFUser {
                cell.nameLabel.text = user.username
            }
            cell.commentLabel.text = comment["text"] as? String ?? "Text"

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!

            return cell
        }
    }

    // A row is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []

        // AddCommentBar is selected
        if indexPath.row == comments.count + 1 {
            showCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
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
