//
//  ActivityCellTableViewCell.swift
//  AudioAudit
//
//  Created by Leo Lei on 3/6/26.
//

import UIKit
import MusicKit

class ActivityCellTableViewCell: UITableViewCell {
    
    
    var currentSongTitle: String?
    var currentAvatarURL: String?

    let cardView = UIView()
    let profileImageView = UIImageView()
    let titleLabel = UILabel()

    let mediaBoxView = UIView()
    let albumCoverImageView = UIImageView()
    let songNameLabel = UILabel()
    let artistNameLabel = UILabel()

    let descriptionLabel = UILabel()
    
    let commentButton = UIButton(type: .system)
    let commentNum = UILabel()
    var onCommentTapped: (() -> Void)?
    
    let likeButton = UIButton(type: .system)
    let likeNum = UILabel()
    var onLikeTapped: (() -> Void)?
    // TODO get info from firebase to know if user liked this activity.
    // use to update likebutton icon and color
    var userLiked: Bool?
    
    let ratingStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        var fontSize = 0
        if UserDefaults.standard.object(forKey: "fontSize") != nil {
            fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        } else {
            fontSize = 15
        }
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Main card
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 14

        // Profile image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 24
        profileImageView.backgroundColor = .systemGray5

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        // Media box
        mediaBoxView.translatesAutoresizingMaskIntoConstraints = false
        mediaBoxView.backgroundColor = .systemBackground
        mediaBoxView.layer.cornerRadius = 12
        mediaBoxView.layer.borderWidth = 1
        //mediaBoxView.clipsToBounds = false
        mediaBoxView.layer.borderColor = UIColor.systemGray5.cgColor

        // Album cover
        albumCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        albumCoverImageView.contentMode = .scaleAspectFill
        albumCoverImageView.clipsToBounds = true
        albumCoverImageView.layer.cornerRadius = 8
        albumCoverImageView.backgroundColor = .systemGray5

        // Song name
        songNameLabel.translatesAutoresizingMaskIntoConstraints = false
        songNameLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .semibold)
        songNameLabel.textColor = .label
        songNameLabel.numberOfLines = 1

        // Artist name
        artistNameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistNameLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize - 2), weight: .regular)
        artistNameLabel.textColor = .secondaryLabel
        artistNameLabel.numberOfLines = 1

        // Review text
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize - 1))
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        // rating stack
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 4

        // Comment button
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setImage(UIImage(systemName: "bubble.left"), for: .normal)
        commentButton.tintColor = .secondaryLabel
        commentButton.contentHorizontalAlignment = .leading
        let action = UIAction() {_ in 
            self.onCommentTapped!()
        }
        commentButton.addAction(action, for: .touchUpInside)
        onCommentTapped = {
            print("COMMENT TAPPED")
            // can add functionality to open expandreviewvc and write comment if we want
        }
        
        // comment num
        commentNum.translatesAutoresizingMaskIntoConstraints = false
        commentNum.font = UIFont.systemFont(ofSize: CGFloat(18))
        commentNum.textColor = .secondaryLabel
        
        //like button
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.tintColor = .secondaryLabel
        likeButton.contentHorizontalAlignment = .leading
        let likeAction = UIAction() {_ in
            self.onLikeTapped!()
        }
        likeButton.addAction(likeAction, for: .touchUpInside)
        onLikeTapped = {
            print("LIKE TAPPED")
            // TODO change icon to either filled or outline
            // increment num likes in firebase
            // reload likenum
        }
        
        // likenum
        //TODO

        contentView.addSubview(cardView)

        cardView.addSubview(profileImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(mediaBoxView)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(commentButton)
        cardView.addSubview(commentNum)
        cardView.addSubview(likeButton)
        //cardView.addSubview(likeNum)

        mediaBoxView.addSubview(albumCoverImageView)
        mediaBoxView.addSubview(songNameLabel)
        mediaBoxView.addSubview(artistNameLabel)
        
        // stars
        cardView.addSubview(ratingStackView)
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([

            // Main card
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            // Profile image
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),

            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            // Media box
            mediaBoxView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            mediaBoxView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            mediaBoxView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            mediaBoxView.heightAnchor.constraint(equalToConstant: 76),

            // Album cover inside media box
            albumCoverImageView.leadingAnchor.constraint(equalTo: mediaBoxView.leadingAnchor, constant: 12),
            albumCoverImageView.topAnchor.constraint(equalTo: mediaBoxView.topAnchor, constant: 12),
            albumCoverImageView.bottomAnchor.constraint(equalTo: mediaBoxView.bottomAnchor, constant: -12),
            albumCoverImageView.widthAnchor.constraint(equalToConstant: 52),
            albumCoverImageView.heightAnchor.constraint(equalToConstant: 52),

            // Song name
            songNameLabel.topAnchor.constraint(equalTo: mediaBoxView.topAnchor, constant: 14),
            songNameLabel.leadingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor, constant: 12),
            songNameLabel.trailingAnchor.constraint(equalTo: mediaBoxView.trailingAnchor, constant: -12),
            
            // stars
            ratingStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            ratingStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingStackView.heightAnchor.constraint(equalToConstant: 16),

            // Artist name
            artistNameLabel.topAnchor.constraint(equalTo: songNameLabel.bottomAnchor, constant: 6),
            artistNameLabel.leadingAnchor.constraint(equalTo: songNameLabel.leadingAnchor),
            artistNameLabel.trailingAnchor.constraint(equalTo: songNameLabel.trailingAnchor),
            artistNameLabel.bottomAnchor.constraint(equalTo: mediaBoxView.bottomAnchor, constant: -12),

            // Review
            descriptionLabel.topAnchor.constraint(equalTo: mediaBoxView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Comment button
            commentButton.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 12),
            commentButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            commentButton.widthAnchor.constraint(equalToConstant: 44),
            commentButton.heightAnchor.constraint(equalToConstant: 30),
            commentButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            // comment num
            commentNum.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: -8),
            commentNum.centerYAnchor.constraint(equalTo: commentButton.centerYAnchor, constant: -1),
            
            likeButton.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 12),
            likeButton.leadingAnchor.constraint(equalTo: commentNum.trailingAnchor, constant: 12),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 30),
            likeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with activity: Activity, username: String? = nil, avatarURL: String?) {
        let displayName = username ?? "User"
        let action = activity.type == .review ? "reviewed" : "listened to"
        let fullText = "\(displayName) \(action) \(activity.song)"
        let attributedText = NSMutableAttributedString(string: fullText)

        let usernameRange = (fullText as NSString).range(of: displayName)
        let songRange = (fullText as NSString).range(of: activity.song)

        attributedText.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 16, weight: .bold),
            range: usernameRange
        )

        attributedText.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 16, weight: .semibold),
            range: songRange
        )

        titleLabel.attributedText = attributedText
        songNameLabel.text = activity.song
        artistNameLabel.text = activity.artist
        setRating(activity.rating)
        
        currentSongTitle = activity.song
        loadSongInfo(title: activity.song, artist: activity.artist)

        if let review = activity.review,
           !review.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionLabel.text = review
            descriptionLabel.isHidden = false
            //TODO connect to comment backend
            commentNum.text = "0"
        } else {
            descriptionLabel.text = nil
            descriptionLabel.isHidden = true
            commentNum.text = "0"
        }
        currentAvatarURL = avatarURL
        if let urlString = avatarURL, let url = URL(string: urlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    await MainActor.run {
                        if self.currentAvatarURL == avatarURL {
                            self.profileImageView.image = UIImage(data: data)
                        }
                    }
                } catch {
                    print("ERROR, FAILED TO LOAD AVATAR: \(error)")
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        albumCoverImageView.image = nil
        titleLabel.attributedText = nil
        songNameLabel.text = nil
        artistNameLabel.text = nil
        descriptionLabel.text = nil
        descriptionLabel.isHidden = false
    }
    
    func loadSongInfo(title: String, artist: String) {
        // Placeholder while loading
        albumCoverImageView.image = UIImage(systemName: "music.note")

        Task {
            do {
                guard let info = try await getSongInfoFromITunes(title: title, artist: artist) else { return }

                await MainActor.run {
                    // Prevent wrong data due to reuse
                    if self.currentSongTitle == title {
                        self.artistNameLabel.text = info.artist
                        self.albumCoverImageView.image = info.artwork
                    }
                }

            } catch {
                print("Failed to load song info from iTunes: \(error)")
            }
        }
    }
    
    func setRating(_ rating: Int?) {

        let maxStars = 5
        let rating = rating ?? 0

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2

        for i in 1...maxStars {

            let imageView = UIImageView()

            let isFilled = i <= rating

            imageView.image = UIImage(
                systemName: isFilled ? "star.fill" : "star"
            )

            imageView.tintColor = isFilled ? .systemYellow : .systemGray3
            imageView.contentMode = .scaleAspectFit

            imageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 14).isActive = true

            stack.addArrangedSubview(imageView)
        }

        ratingStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        ratingStackView.addArrangedSubview(stack)
    }
}
