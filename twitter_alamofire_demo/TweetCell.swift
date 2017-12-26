//
//  TweetCell.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteNumberLabel: UILabel!
    @IBOutlet weak var retweetNumberLabel: UILabel!
    
    var retweeted = false
    var favorited = false
    
    var tweet: Tweet! {
        didSet {
            let tweetOwner = tweet.user
            retweeted = tweet.retweeted
            favorited = tweet.favorited
            
            if let profileUrl = tweetOwner.profileURL {
                Alamofire.request(profileUrl).responseImage { response in
                    self.profileImageView.image = response.result.value
                }
                
            } else {
                profileImageView.image = #imageLiteral(resourceName: "profile-Icon")
            }
            profileImageView.layer.cornerRadius = 8.0
            profileImageView.clipsToBounds = true
            
            if let name = tweetOwner.name {
                nameLabel.text = name
            } else {
                nameLabel.text = ""
            }
            
            if let username = tweetOwner.screenName {
                usernameLabel.text = "@\(username as String)"
            } else {
                usernameLabel.text = ""
            }
            

            timeLabel.text = tweet.createdAtString

            tweetLabel.text = tweet.text
            
            favoriteNumberLabel.text = formatFavoriteRetweetNumbers(number: tweet.favoriteCount)
            retweetNumberLabel.text = formatFavoriteRetweetNumbers(number: tweet.retweetCount)
            
            replyButton.setBackgroundImage(#imageLiteral(resourceName: "reply-icon"), for: .normal)
            replyButton.setTitle("", for: .normal)
            
            if tweet.retweeted {
                retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
            } else {
                retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
            }
            retweetButton.setTitle("", for: .normal)
            
            if tweet.favorited {
                favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
            } else {
                favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
            }
            favoriteButton.setTitle("", for: .normal)
        }
    }
    
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
    }
    
    @IBAction func didTapFavorite(_ sender: Any) {
        if tweet.favorited {
            APIManager.shared.unfavorite(tweet) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error unfavoriting tweet: \(error.localizedDescription)")
                } else if tweet != nil {
                    self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                    self.tweet.favoriteCount -= 1
                    self.favoriteNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.favoriteCount)
                    self.tweet.favorited = false
                }
            }
        } else {
            APIManager.shared.favorite(tweet) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error favoriting tweet: \(error.localizedDescription)")
                } else if tweet != nil {
                    self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                    self.tweet.favoriteCount += 1
                    self.favoriteNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.favoriteCount)
                    self.tweet.favorited = true
                }
            }
        }
    }
    
    @IBAction func didTapRetweet(_ sender: Any) {
        if tweet.retweeted {
            APIManager.shared.unretweet(tweet) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error unretweeting tweet: \(error.localizedDescription)")
                } else if tweet != nil {
                    self.retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
                    self.tweet.retweetCount -= 1
                    self.retweetNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.retweetCount)
                    self.tweet.retweeted = false
                }
            }
        } else {
            APIManager.shared.retweet(tweet) { (tweet: Tweet?, error: Error?) in
                if let  error = error {
                    print("Error retweeting tweet: \(error.localizedDescription)")
                } else if tweet != nil {
                    self.retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
                    self.tweet.retweetCount += 1
                    self.retweetNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.retweetCount)
                    self.tweet.retweeted = true
                }
            }
        }
        
    }
    
    @IBAction func didTapReply(_ sender: Any) {
        
    }
    
    func formatFavoriteRetweetNumbers(number: Int) -> String {
        if number > 1000000 {
            return "\(number / 1000000)M"
        }
        if number > 1000 {
            return "\(number / 1000)K"
        }
        return "\(number)"
    }
}
