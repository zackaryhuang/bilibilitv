//
//  UperSpaceSectionHeader.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class UperSpaceSectionHeader: UICollectionReusableView {
    let avatarView = UIImageView()
    let genderView = UIImageView()
    let levelView = UIImageView()
    let bannerView = UIImageView()
    let nameLabel = UILabel()
    let signLabel = UILabel()
    let likeCountLabel = UILabel()
    let archiveCountLabel = UILabel()
    let fansCountLabel = UILabel()
    let followedButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        let mask = UIImageView(image: UIImage(named: "banner_mask"))
        bannerView.addSubview(mask)
        mask.snp.makeConstraints { make in
            make.edges.equalTo(bannerView)
        }

        avatarView.layer.cornerRadius = 60
        avatarView.layer.masksToBounds = true
        mask.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalTo(mask).offset(60)
            make.width.height.equalTo(120)
            make.centerY.equalTo(mask).offset(30)
        }

        mask.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(20)
            make.bottom.equalTo(avatarView.snp.centerY).offset(-2)
        }

        mask.addSubview(genderView)

        mask.addSubview(levelView)

        signLabel.font = UIFont.systemFont(ofSize: 26)
        mask.addSubview(signLabel)
        signLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(avatarView.snp.centerY).offset(2)
        }

        mask.addSubview(followedButton)
        followedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 26)
        followedButton.layer.cornerRadius = 30
        followedButton.layer.borderWidth = 2
        followedButton.layer.borderColor = UIColor.white.cgColor
        followedButton.layer.masksToBounds = true
        followedButton.isUserInteractionEnabled = false
        followedButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(60)
            make.centerY.equalTo(avatarView)
            make.trailing.equalTo(mask).offset(-60)
        }

        let likeCountTitleLabel = UILabel()
        likeCountTitleLabel.font = UIFont.systemFont(ofSize: 22)
        likeCountTitleLabel.textColor = .lightGray
        likeCountTitleLabel.text = "获赞数"
        likeCountTitleLabel.textAlignment = .center
        mask.addSubview(likeCountTitleLabel)
        likeCountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.centerY).offset(10)
            make.trailing.equalTo(followedButton.snp.leading).offset(-80)
        }

        likeCountLabel.font = UIFont.systemFont(ofSize: 28)
        likeCountLabel.textAlignment = .center
        mask.addSubview(likeCountLabel)
        likeCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(likeCountTitleLabel.snp.top).offset(-10)
            make.centerX.equalTo(likeCountTitleLabel)
        }

        let archiveCountTitleLabel = UILabel()
        archiveCountTitleLabel.font = UIFont.systemFont(ofSize: 22)
        archiveCountTitleLabel.textColor = .lightGray
        archiveCountTitleLabel.text = "稿件数"
        archiveCountTitleLabel.textAlignment = .center
        mask.addSubview(archiveCountTitleLabel)
        archiveCountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.centerY).offset(10)
            make.centerX.equalTo(likeCountTitleLabel).offset(-120)
        }

        archiveCountLabel.font = UIFont.systemFont(ofSize: 28)
        archiveCountLabel.textAlignment = .center
        mask.addSubview(archiveCountLabel)
        archiveCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(archiveCountTitleLabel.snp.top).offset(-10)
            make.centerX.equalTo(archiveCountTitleLabel)
        }

        let fansCountCountTitleLabel = UILabel()
        fansCountCountTitleLabel.font = UIFont.systemFont(ofSize: 22)
        fansCountCountTitleLabel.textColor = .lightGray
        fansCountCountTitleLabel.text = "粉丝数"
        fansCountCountTitleLabel.textAlignment = .center
        mask.addSubview(fansCountCountTitleLabel)
        fansCountCountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.centerY).offset(10)
            make.centerX.equalTo(archiveCountTitleLabel).offset(-120)
        }

        fansCountLabel.font = UIFont.systemFont(ofSize: 28)
        fansCountLabel.textAlignment = .center
        mask.addSubview(fansCountLabel)
        fansCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(fansCountCountTitleLabel.snp.top).offset(-10)
            make.centerX.equalTo(fansCountCountTitleLabel)
        }

        setNeedsUpdateConstraints()
    }

    func update(with spaceInfo: UperData) {
        bannerView.kf.setImage(with: spaceInfo.space?.bannerURL)
        avatarView.kf.setImage(with: spaceInfo.card?.faceURL)
        signLabel.text = spaceInfo.card?.sign
        nameLabel.text = spaceInfo.card?.name

        if spaceInfo.card?.sex == "男" {
            genderView.image = UIImage(named: "icon_male")
        } else if spaceInfo.card?.sex == "女" {
            genderView.image = UIImage(named: "icon_female")
        } else {
            genderView.image = nil
        }

        if let level = spaceInfo.card?.levelInfo?.currentLevel {
            levelView.image = UIImage(named: "icon_level_\(level)")
        } else {
            levelView.image = nil
        }

        if spaceInfo.isFollowing {
            followedButton.setTitle("已关注", for: .normal)
            followedButton.titleLabel?.textColor = .white
            followedButton.layer.borderColor = UIColor.white.cgColor
            followedButton.backgroundColor = UIColor.biliPink
        } else {
            followedButton.setTitle("未关注", for: .normal)
            followedButton.layer.borderColor = UIColor.lightGray.cgColor
            followedButton.titleLabel?.textColor = .lightGray
            followedButton.backgroundColor = UIColor.gray
        }

        fansCountLabel.text = "\(spaceInfo.fansCount?.numberString() ?? "0")"
        archiveCountLabel.text = "\(spaceInfo.archiveCount ?? 0)"
        likeCountLabel.text = "\(spaceInfo.likeCount?.numberString() ?? "0")"

        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        super.updateConstraints()

        var attribute = nameLabel.snp.trailing
        var offset = 10.0
        if genderView.image != nil {
            genderView.snp.remakeConstraints { make in
                make.leading.equalTo(attribute).offset(offset)
                make.centerY.equalTo(nameLabel)
                make.width.height.equalTo(40)
            }
            attribute = genderView.snp.trailing
            offset = 10.0
        }

        if levelView.image != nil {
            levelView.snp.remakeConstraints { make in
                make.leading.equalTo(attribute).offset(offset)
                make.centerY.equalTo(nameLabel)
                make.width.height.equalTo(60)
            }
            attribute = levelView.snp.trailing
            offset = 10.0
        }
    }
}
