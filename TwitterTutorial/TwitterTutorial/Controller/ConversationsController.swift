//
//  ConversationsController.swift
//  TwitterTutorial
//
//  Created by Ling on 11/27/21.
//

import UIKit

class ConversationsController: UIViewController{
    
   
    //MARK - Properties
    
    //MARK - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

    }
    
    //MARK - Helpers

    func configureUI(){
        view.backgroundColor = .white
        navigationItem.title = "Messages"
    }
}
