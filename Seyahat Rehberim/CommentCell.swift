//
//  CommentCell.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 24.12.2024.
//

import UIKit

class CommentCell: UITableViewCell {
    
    private let usernameLabel = UILabel()
    private let commentLabel = UILabel()
    private let timestampLabel = UILabel()
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Ana kapsayıcı görünüm
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Kullanıcı adı etiketi
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        usernameLabel.textColor = .darkGray
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usernameLabel)
        
        // Yorum etiketi
        commentLabel.font = UIFont.systemFont(ofSize: 14)
        commentLabel.textColor = .black
        commentLabel.numberOfLines = 0
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(commentLabel)
        
        // Zaman etiketi
        timestampLabel.font = UIFont.italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .lightGray
        timestampLabel.textAlignment = .right
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timestampLabel)
        
        // Otomatik yerleşim
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            // Kullanıcı adı
            usernameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10),
            
            // Yorum
            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5),
            commentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            // Zaman
            timestampLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 5),
            timestampLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            timestampLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            timestampLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with comment: (username: String, comment: String, userId: String, timestamp: String)) {
        usernameLabel.text = comment.username
        commentLabel.text = comment.comment
        timestampLabel.text = comment.timestamp
    }
}
