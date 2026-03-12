//
//  EditPicViewController.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/11/26.
//

import UIKit
import PhotosUI

class EditPicViewController: UIViewController, PHPickerViewControllerDelegate {
    
    var currentImage: UIImage?
    var saveChanges: ((UIImage) -> Void)? // TODO add text field too
    
    let imageView = UIImageView()
    let photoButton = UIButton()
    let uploadButton = UIButton()
    //let nameField = UIButton() TODO allow users to change name later
    let saveButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage.loadLogoFinal
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    
        makeButton(photoButton, "Take Photo")
        makeButton(uploadButton, "Upload Image")
        makeButton(saveButton, "Save Changes")
        
        let photoAction = UIAction { action in
            print("photo button pressed")
            
        }
        photoButton.addAction(photoAction, for: .touchUpInside)
        
        let uploadAction = UIAction { action in
            print("upload button pressed")
            self.openPicker()
        }
        uploadButton.addAction(uploadAction, for: .touchUpInside)
        
        let saveAction = UIAction { [weak self] action in
            print("save changes button pressed")
            guard let image = self?.imageView.image else {
                print("image is nil")
                return
            }
            self?.saveChanges?(image)
        }
        saveButton.addAction(saveAction, for: .touchUpInside)

        view.addSubview(imageView)
        view.addSubview(photoButton)
        view.addSubview(uploadButton)
        view.addSubview(saveButton)
        setConstraints()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        imageView.image = currentImage
//    }
    
    
    func makeButton(_ b: UIButton, _ title: String) {
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(title, for: .normal)
        b.backgroundColor = UIColor.audioRed
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 20)
    }
    
    func openPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    // TODO send to firebase
                }
            }
        }
    }
    
    func setConstraints() {
        let imageWidth = CGFloat(300)
        let buttonWidth = CGFloat(200)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageWidth),
            
            photoButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            photoButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            photoButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            photoButton.heightAnchor.constraint(equalToConstant: buttonWidth / 4),
            
            uploadButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            uploadButton.topAnchor.constraint(equalTo: photoButton.bottomAnchor, constant: 16),
            uploadButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            uploadButton.heightAnchor.constraint(equalToConstant: buttonWidth / 4),
            
            saveButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: uploadButton.bottomAnchor, constant: 200),
            saveButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            saveButton.heightAnchor.constraint(equalToConstant: buttonWidth / 4)

        ])
        
        imageView.layer.cornerRadius = imageWidth / 2
        photoButton.layer.cornerRadius = 10
        uploadButton.layer.cornerRadius = 10
        saveButton.layer.cornerRadius = 10
    }
    
}
