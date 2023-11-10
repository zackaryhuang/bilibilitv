//
//  FollowerCell.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/11/9.
//

import UIKit

class FollowerCell: UICollectionViewCell {
    var avatarImageView: UIImageView!
    var nameLabel: UILabel!
    var descLabel: UILabel!
    var officialIcon: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.masksToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.leading.equalTo(contentView).offset(15)
            make.centerY.equalTo(contentView)
        }

        officialIcon = UIImageView()
        officialIcon.layer.borderColor = UIColor(named: "bgColor")?.cgColor
        officialIcon.layer.borderWidth = 3.0
        officialIcon.layer.cornerRadius = 15.0
        officialIcon.image = UIImage(named: "icon_famous_uper")
        contentView.addSubview(officialIcon)
        officialIcon.snp.makeConstraints { make in
            make.bottom.equalTo(avatarImageView)
            make.trailing.equalTo(avatarImageView)
            make.width.height.equalTo(30)
        }

        nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 32)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.bottom.equalTo(avatarImageView.snp.centerY).offset(-10)
            make.trailing.lessThanOrEqualTo(contentView).offset(-5)
        }

        descLabel = UILabel()
        descLabel.font = .systemFont(ofSize: 22)
        contentView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualTo(contentView).offset(-10)
            make.top.equalTo(avatarImageView.snp.centerY).offset(10)
        }

        contentView.backgroundColor = UIColor(named: "bgColor")
        contentView.layer.cornerRadius = 16
    }

    func update(with follower: WebRequest.FollowingUser) {
        nameLabel.text = follower.uname
        descLabel.text = follower.sign
        avatarImageView.kf.setImage(with: follower.face)
        if follower.isFamousUper {
            officialIcon.image = UIImage(named: "icon_famous_uper")
            officialIcon.isHidden = false
        } else if follower.isOfficialUper {
            officialIcon.image = UIImage(named: "icon_official_uper")
            officialIcon.isHidden = false
        } else {
            officialIcon.isHidden = true
        }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if isFocused {
            contentView.backgroundColor = .white
            nameLabel.textColor = .black
            descLabel.textColor = .black
            officialIcon.layer.borderColor = UIColor.white.cgColor
        } else {
            contentView.backgroundColor = UIColor(named: "bgColor")
            nameLabel.textColor = .white
            descLabel.textColor = .white
            officialIcon.layer.borderColor = UIColor(named: "bgColor")?.cgColor
        }
    }
}
