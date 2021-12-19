//
//  EditProfileFooter.swift
//  TwitterTutorial
//
//  Created by Ling on 12/19/21.
//

import UIKit

protocol EditProfileFooterDelegate: AnyObject {
    func handleLogout()
}

class EditProfileFooter: UIView{
  
    //MARK - Properties
    
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logoutButton: UIButton = {
        print("button")
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        return button
    }()
    
    //MARK - Lifecyle
    override init(frame: CGRect){
        super.init(frame: frame)
        
        addSubview(logoutButton)
        logoutButton.anchor(left: leftAnchor, right: rightAnchor,paddingLeft: 16, paddingRight: 16)
        logoutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoutButton.centerY(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK - Selectors
    @objc func handleLogout(){
        delegate?.handleLogout()
    }
}
