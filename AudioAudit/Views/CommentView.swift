//
//  CommentView.swift
//  AudioAudit
//
//  Created by Bersam Basagaoglu on 4/26/26.
//

import UIKit

class CommentView: UIView {

    let avatar = UIImageView()
    let textLabel = UILabel()
    let timestampLabel = UILabel()

    private var currentAvatarURL: String?

    init(comment: Interaction, username: String?, avatarURL: String?) {
        super.init(frame: .zero)
        setupLayout()
        configure(comment: comment, username: username, avatarURL: avatarURL)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = 16
        avatar.backgroundColor = .systemGray5
        addSubview(avatar)

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        addSubview(textLabel)

        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.font = UIFont.systemFont(ofSize: 11)
        timestampLabel.textColor = .tertiaryLabel
        addSubview(timestampLabel)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatar.topAnchor.constraint(equalTo: topAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 32),
            avatar.heightAnchor.constraint(equalToConstant: 32),
            avatar.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),

            textLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor),

            timestampLabel.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            timestampLabel.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 2),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func configure(comment: Interaction, username: String?, avatarURL: String?) {
        let displayName = username ?? "User"
        let text = comment.text ?? ""
        let combined = "\(displayName)  \(text)"
        let attributed = NSMutableAttributedString(string: combined)
        let nameRange = (combined as NSString).range(of: displayName)
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.label
        ], range: nameRange)
        let restStart = nameRange.location + nameRange.length
        let restRange = NSRange(location: restStart, length: (combined as NSString).length - restStart)
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.label
        ], range: restRange)
        textLabel.attributedText = attributed

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        timestampLabel.text = formatter.localizedString(for: comment.timestamp, relativeTo: Date())

        avatar.image = nil
        currentAvatarURL = avatarURL
        if let urlString = avatarURL, let url = URL(string: urlString) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    await MainActor.run {
                        if self.currentAvatarURL == avatarURL {
                            self.avatar.image = UIImage(data: data)
                        }
                    }
                } catch {
                    print("Failed to load comment avatar: \(error)")
                }
            }
        }
    }
}
