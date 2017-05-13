//
//  ViewController.swift
//  Protocol Oriented Programming View in Swift 3
//
//  Created by sunny on 2017/5/14.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit

class BuzzableTextField: UITextField, Buzzable {}
class BuzzableButton: UIButton, Buzzable {}
class BuzzableImageView: UIImageView, Buzzable {}
class BuzzablePoppableLabel: UILabel, Buzzable, Poppable {}

class ViewController: UIViewController {

    @IBOutlet weak var passcodTextField: BuzzableTextField!
    @IBOutlet weak var loginButton: BuzzableButton!
    @IBOutlet weak var errorMessageLabel: BuzzablePoppableLabel!
    @IBOutlet weak var profileImageView: BuzzableImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCornerRadius()
    }
    
    func setUpCornerRadius() {
        let imageHeight = profileImageView.frame.height/2
        profileImageView.layer.cornerRadius = imageHeight
        profileImageView.layer.masksToBounds = true
        
    }
    
    @IBAction func didTabLoginButton(_ sender: UIButton) {
        
        passcodTextField.buzz()
        loginButton.buzz()
        errorMessageLabel.buzz()
        errorMessageLabel.pop()
        profileImageView.buzz()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

