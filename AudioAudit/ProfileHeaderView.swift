//
//  ProfileHeaderView.swift
//  AudioAudit
//
//  Created by Aguillon, Diego E on 3/10/26.
//

import UIKit

class ProfileHeaderView: UIView {
    
    let nameLabel = UILabel()
    let postCountLabel = UILabel()
    let friendsLabel = UILabel()
    let songButton = UIButton()
    let avatarButton = UIButton()
    
    var onBackTapped: (() -> Void)?
    var statsStack = UIStackView()
    
    init(user: AAUser) {
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
        //TODO play user song, probably store in firebase somehow
        // maybe simulate notif to show what song is playing
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
        setConstraints()
    }
    
    func getUserInfo(with user: AAUser) async {
        nameLabel.text = user.name
        do {
            let postCount = try await ActivityService.shared.fetchActivities(for: UserService.shared.currentUserId!).count
            postCountLabel.text = "\(postCount)"
        } catch {
            print("ERROR READING POST COUNT")
        }
        friendsLabel.text = "\(user.friends.count)"
        // TODO load from user url
        avatarButton.setImage(UIImage.loadLogoFinal, for: .normal)
    }
}
