//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Ji Wang on 3/27/22.
//

import AlamofireImage
import Parse
import PhotosUI
import UIKit

class CameraViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        
        let itemProviders = results.map(\.itemProvider)
        for provider in itemProviders {
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            // scale image
                            let size = CGSize(width: 300, height: 300)
                            let scaledImage = image.af.imageAspectScaled(toFill: size)
                            
                            self.imageView.image = scaledImage
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func onImageTapped(_ sender: Any) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.preferredAssetRepresentationMode = .current
        configuration.filter = .images
        configuration.selection = .ordered
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text
        post["author"] = PFUser.current()
        
        if let imageData = imageView.image?.pngData() {
            let file = PFFileObject(name: "image.png", data: imageData)
            post["image"] = file
        }
        
        post.saveInBackground { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("Post saved")
            } else {
                print("Post saving failed: \(String(describing: error?.localizedDescription))")
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
