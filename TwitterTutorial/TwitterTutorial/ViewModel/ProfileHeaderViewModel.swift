//
//  ProfileHeaderViewModel.swift
//  TwitterTutorial
//
//  Created by Ling on 12/11/21.
//

import UIKit

enum ProfileFilterOptions: Int, CaseIterable {
    
    //typealias RawValue = <#type#>
    
    case tweets
    case replies
    case likes
    
    var description: String{
        switch self{
        case .tweets: return "tweets"
        case .replies: return "tweets & replices"
        case .likes: return "likes"
        }
    }
}

struct ProfileHeaderViewModel {
    private let user: User
    
    let usernameText: String
    
    
    var followerString: NSAttributedString?{
        return attributedText(withValue: 0, text: "follower", valueColor: .black, textColor: .blue)
    }
    
    var followingString: NSAttributedString?{
        return attributedText(withValue: 2, text: "following", valueColor: .black, textColor: .blue)
        
    }
    
    var actionButtonTitle: String {
        //if user is current user then set to edit profile
        //else figure out following/not following
        
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        }
        
        if user.isFollowed {
            return "Following"
        }
        return "Loading"
    }
    init(user: User)
    {
        self.user = user
        
        self.usernameText = "@" + user.username
        
    }
    
    
    fileprivate func attributedText(withValue value: Int, text: String,
                                    valueColor: UIColor, textColor: UIColor) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)",
            attributes: [.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor: valueColor])
        
        attributedTitle.append(NSAttributedString(string: " \(text)",
                                                  attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                               .foregroundColor: textColor]))
        return attributedTitle
    }
}
