//
//  ViewController.swift
//  MeMe
//
//  Created by Deborah on 12/8/16.
//  Copyright © 2016 Deborah. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.0
        ] as [String : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func stylizeTextField(textField: UITextField) {
            textField.defaultTextAttributes = memeTextAttributes
            
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            textField.textAlignment = .center
            textField.delegate = self
        }
        stylizeTextField(textField: topTextField)
        stylizeTextField(textField: bottomTextField)
    }
    
    func pickAnImageFromSource(source: UIImagePickerControllerSourceType) {
        //Code To Pick An Image From Source
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func cameraButtonAction(_ sender: Any) {
        pickAnImageFromSource(source: .camera)
    }
    @IBAction func photoLibraryAction(_ sender: Any) {
        pickAnImageFromSource(source: .photoLibrary)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage; dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        unsubscribeToKeyboardNotifications()
        
        func textFieldDidBeginEditing(textField: UITextField) {
            if textField.text == "TOP" || textField.text == "BOTTOM"{
                textField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            print("keyboardWillShow BT")
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }

    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            print("keyboardWillHide BT")
            view.frame.origin.y = 0
        }
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        //Hide Toolbar And Navigation Bar
        navigationBar.isHidden = true
        toolBar.isHidden = true
        
        // Render View To An Image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show Toolbar and Navigation Bar
        navigationBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    func save() {
        // Create The Meme
        let memedImage = generateMemedImage()
        _ = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imageView.image, memedImage:memedImage)
        //TODO: Add to memes array in AppDelegate
        
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        self.imageView.image = nil
    }
    
}
