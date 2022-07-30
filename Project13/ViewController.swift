//
//  ViewController.swift
//  Project13
//
//  Created by Alex Liou on 7/26/22.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {


    @IBOutlet var changeFilterButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!

    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        imageView.alpha = 0.0
    }

    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true) {
            UIView.animate(withDuration: 2.0) {
                self.imageView.alpha = 1.0
            }
        }

        currentImage = image

        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        applyProcessing()
    }

    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
    }

    func setFilter(action: UIAlertAction) {
        changeFilterButton.setTitle(action.title, for: .normal)
        // make sure we have a valid image before continuing!
        guard currentImage != nil else { return }

        // safely read the alert action's title
        guard let actionTitle = action.title else { return }

        currentFilter = CIFilter(name: actionTitle)

        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)


        applyProcessing()
    }

    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "Error!", message: "No image present to be saved.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
//            we got an error
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your album", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }

    func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }

        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }


        if let cgimg = context.createCGImage(image, from: image.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
            UIView.animate(withDuration: 0.25) {
                self.imageView.alpha = 1.0
            }
        }
    }

}

