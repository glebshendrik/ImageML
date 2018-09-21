//
//  ViewController.swift
//  ImageML
//
//  Created by Gleb Shendrik on 21/09/2018.
//  Copyright © 2018 Gleb Shendrik. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainProgress: UIProgressView!
    @IBOutlet weak var titleResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        detectImageContent()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        detectImageContent()
    }

    
    @IBAction func takePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
            
        }
    }
    @IBAction func getPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func detectImageContent() {
        titleResult.text = "🤔"
        
        guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else {
            fatalError("Ошибка загрузки модели")
        }
        
        //        MARK: Создание запроса Vision
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Не определился")
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.mainProgress.setProgress(Float(topResult.confidence * 100), animated: true)
                
                self?.titleResult.text = "\(topResult.identifier) с \(Int(topResult.confidence * 100))% вероятностью"
                
            }
        }
        
        guard let ciImage = CIImage(image: self.mainImage.image!) else {
            fatalError("Ошибка создания CIImage")
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            mainImage.contentMode = .scaleToFill
            mainImage.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        //        TODO: DetectImage
        detectImageContent()
    }
}

