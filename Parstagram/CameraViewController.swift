//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Ji Wang on 3/27/22.
//

import AlamofireImage
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
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            // scale image
                            let size = CGSize(width: 300, height: 300)
                            let scaledImage = image.af.imageScaled(to: size)
                            
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
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {}
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
