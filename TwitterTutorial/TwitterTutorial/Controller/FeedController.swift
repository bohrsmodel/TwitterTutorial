//
//  FeedController.swift
//  TwitterTutorial
//
//  Created by Ling on 11/27/21.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController{
    
   
    //MARK - Properties
    var user: User? {
        didSet { configureLeftBarButton()}
    }
    
    private var tweets = [Tweet]()
    {
        didSet{ collectionView.reloadData()}
    }
    //MARK - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK - Selectors
    @objc func handleRefresh(){
        fetchTweets()
        
    }
    @objc func handleProfileImageTap(){
        guard let user = user else { return}
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        
        
    }
    
    //MARK - API
    
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedTweets()
//            self.tweets =  tweets.sorted(by: { (tweet1, tweet2) -> Bool in
//                return tweet1.timestamp > tweet2.timestamp
//        })
            
            self.collectionView.refreshControl?.endRefreshing()
       }
    }
    
    func checkIfUserLikedTweets (){
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: { $0.tweetID == tweet.tweetID}) {
                    self.tweets[index].didLike = true
                }
            }
        }
       
            
    }
    
    //MARK - Helpers
    func configureUI(){
        view.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
       collectionView.backgroundColor = .white
        
        let imageview = UIImageView(image:UIImage(named: "twitter_logo_blue"))
        imageview.contentMode = .scaleAspectFit
        imageview.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageview
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageview = UIImageView()
        profileImageview.setDimensions(width: 32, height: 32)
        profileImageview.layer.cornerRadius = 32/2
        profileImageview.layer.masksToBounds = true
        profileImageview.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        profileImageview.addGestureRecognizer(tap)
        
        profileImageview.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageview)
        
    }
   
}

//MARK - UICollectionViewDelegate/Datasource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72)
    }
    
}

//MARK - TweetCellDelegate

extension FeedController: TweetCellDelegate{
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
    
        TweetService.shared.likeTweet(tweet: tweet) { (err, ref) in
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            // only upload notification if tweet is being liked
            guard !tweet.didLike else { return }
            NotificationService.shared.uploadNotification(toUser: tweet.user, type:.like, tweetID: tweet.tweetID)
        }
    }
    
   
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }    
}
