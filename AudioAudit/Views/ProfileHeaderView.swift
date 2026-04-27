//
//  ProfileHeaderView.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/10/26.
//

import UIKit
import AVFoundation

let DEFAULT_PFP = "https://firebasestorage.googleapis.com/v0/b/audioaudit-3a29c.firebasestorage.app/o/logo_transparent.jpg?alt=media&token=c5ec3413-6c78-4947-aa6e-57d8bb819224"

class ProfileHeaderView: UIView {
    
    let nameLabel = UILabel()
    let postCountLabel = UILabel()
    let friendsLabel = UILabel()
    let songButton = UIButton()
    let avatarButton = UIButton()
    
    let songTitleLabel = UILabel()
    let songArtistLabel = UILabel()
    let songInfoStack = UIStackView()
    
    var onBackTapped: (() -> Void)?
    var statsStack = UIStackView()
    var player: AVPlayer?
    var user: AAUser
    
    init(user: AAUser) {
        self.user = user
        super.init(frame: .zero)
        setupLayout()
        Task {
            await getUserInfo(with: user)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeStatColumn(label: UILabel, title: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        // TODO adjust font via brett's code
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.systemGray2
        titleLabel.textAlignment = .center
        
        let sv = UIStackView(arrangedSubviews: [label, titleLabel])
        sv.axis = .vertical
        sv.alignment = .center
        sv.spacing = 2
        return sv
    }
    
    func setStack() {
        statsStack.addArrangedSubview(songButton)
        statsStack.addArrangedSubview(makeStatColumn(label: postCountLabel, title: "Posts"))
        statsStack.addArrangedSubview(makeStatColumn(label: friendsLabel, title: "Friends"))
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints() {
        
        let imageWidth = CGFloat(100)
        NSLayoutConstraint.activate([
            // avatar on left
            avatarButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            avatarButton.widthAnchor.constraint(equalToConstant: imageWidth),
            avatarButton.heightAnchor.constraint(equalToConstant: imageWidth),
            
            // stats to the right of avatar
            statsStack.centerYAnchor.constraint(equalTo: avatarButton.centerYAnchor),
            statsStack.leadingAnchor.constraint(equalTo: avatarButton.trailingAnchor, constant: 40),
            statsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // name below avatar
            nameLabel.topAnchor.constraint(equalTo: avatarButton.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            songInfoStack.bottomAnchor.constraint(equalTo: songButton.topAnchor, constant: -4),
            songInfoStack.centerXAnchor.constraint(equalTo: songButton.centerXAnchor),
        ])
        
        avatarButton.layer.cornerRadius = imageWidth / 2
    }
    
    func setLabel(_ l: UILabel) {
        l.textAlignment = .center
        // TODO set font via brett's system
        l.font = .boldSystemFont(ofSize: 20)
        l.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func playSong() {
        Task {
            await playSongAsync()
        }
    }
    
    func playSongAsync() async {
        do {
            guard let userId = user.id else { return }

            let freshUser = try await UserService.shared.fetchUser(uid: userId)

            DispatchQueue.main.async {
                self.user = freshUser
            }

            guard let urlString = freshUser.profileSongPreviewURL,
                  let url = URL(string: urlString) else {
                print("No song")
                return
            }

            if let player = player,
               let currentURL = (player.currentItem?.asset as? AVURLAsset)?.url,
               currentURL == url {

                if player.timeControlStatus == .playing {
                    player.pause()
                    switchIcon(play: true)
                } else {
                    player.play()
                    switchIcon(play: false)
                }
                return
            }

            player?.pause()
            player = AVPlayer(url: url)
            player?.play()
            switchIcon(play: false)

        } catch {
            print("Failed to refresh user/song: \(error)")
        }
    }
    
    func stopSong() {
        if let player = player {
            player.pause()
        }
    }
    
    func switchIcon(play: Bool) {
        var name = "pause.circle"
        if play {
            name = "play.circle"
        }
        DispatchQueue.main.async {
            self.songButton.setImage(UIImage(systemName: name, withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)), for: .normal)
        }

    }
    
    func openEditPage() {
        onBackTapped?()
    }
    
    func setButtons() {
        songButton.setImage(UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)), for: .normal)
        songButton.translatesAutoresizingMaskIntoConstraints = false
        songButton.tintColor = UIColor.label
        let songAction = UIAction { action in
            print("song button tapped")
            self.playSong()
        }
        songButton.addAction(songAction, for: .touchUpInside)
        
        avatarButton.clipsToBounds = true
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.imageView?.contentMode = .scaleAspectFill
        
        let avatarAction = UIAction { _ in
            print("avatar button pressed")
            self.openEditPage()
        }
        avatarButton.addAction(avatarAction, for: .touchUpInside)
    }
    
    func setupLayout() {
        setButtons()
        setLabel(postCountLabel)
        setLabel(friendsLabel)
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //setImage()
        setStack()
        addSubview(avatarButton)
        addSubview(nameLabel)
        addSubview(statsStack)
        setupSongInfoUI()
        addSubview(songInfoStack)
        setConstraints()
    }
    
    func getFriends() {
        friendsLabel.text = "\(user.friends.count)"
    }
    
    func getUserInfo(with user: AAUser) async {
        nameLabel.text = user.name
        do {
            let postCount = try await ActivityService.shared.fetchActivities(for: user.id!).count
            postCountLabel.text = "\(postCount)"
        } catch {
            print("ERROR READING POST COUNT")
            return
        }
        getFriends()
        // loads user pic from firestorage
        songTitleLabel.text = user.profileSongTitle ?? "No song"
        songArtistLabel.text = user.profileSongArtist ?? ""
        await getUserPic()
    }
    
    func getUserPic() async {
        let imageURL = URL(string: "\(user.profilePicURL ?? DEFAULT_PFP)")!

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: imageURL) { (data, response, error) in
            
            // ensure we did not get an error
            guard error == nil else {
                print("Error fetching data")
                return
            }
            
            // adapted from bulko's networking lecture.
            // Convert the response to an HTTPURLResponse so we can get
            // a status code
            
            if let httpResponse = response as? HTTPURLResponse {
                
                // ensure we got back a status code of 200 - "Success"
                guard httpResponse.statusCode == 200 else {
                    return
                }
                
                // Make sure we received the data
                
                if let receivedData = data {
                    
                    guard let image = UIImage(data: receivedData) else {
                        return
                    }
                    guard let compressedData = image.jpegData(compressionQuality: 0.5) else {
                        return
                    }
                    
                    let compressedImage = UIImage(data: compressedData)
                    
                    DispatchQueue.main.async {
                        self.avatarButton.setImage(compressedImage, for: .normal)
                    }
                }
            }
        }
        
        task.resume( )
    }
    
    func setupSongInfoUI() {
        songTitleLabel.font = .boldSystemFont(ofSize: 14)
        songTitleLabel.textAlignment = .center
        
        songArtistLabel.font = .systemFont(ofSize: 12)
        songArtistLabel.textColor = .systemGray
        songArtistLabel.textAlignment = .center
        
        songInfoStack.axis = .vertical
        songInfoStack.alignment = .center
        songInfoStack.spacing = 2
        
        songInfoStack.addArrangedSubview(songTitleLabel)
        songInfoStack.addArrangedSubview(songArtistLabel)
        
        songInfoStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateUser(_ newUser: AAUser) {
        self.user = newUser
        
        DispatchQueue.main.async {
            self.songTitleLabel.text = newUser.profileSongTitle ?? "No song"
            self.songArtistLabel.text = newUser.profileSongArtist ?? ""
        }
    }
}
