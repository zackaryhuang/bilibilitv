//
//  UperSpaceSectionHeader.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class UperSpaceSectionHeader: UICollectionReusableView {
    let avatarView = UIImageView()
    let bannerView = UIImageView()
    let nameLabel = UILabel()
    let signLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        bannerView.layer.cornerRadius = 30
        bannerView.layer.masksToBounds = true
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
            make.centerY.equalTo(mask).offset(50)
        }

        mask.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(20)
            make.bottom.equalTo(avatarView.snp.centerY).offset(-2)
        }

        signLabel.font = UIFont.systemFont(ofSize: 26)
        mask.addSubview(signLabel)
        signLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(avatarView.snp.centerY).offset(2)
        }
    }

    func update(with spaceInfo: UperData) {
        bannerView.kf.setImage(with: spaceInfo.space?.bannerURL)
        avatarView.kf.setImage(with: spaceInfo.card?.faceURL)
        signLabel.text = spaceInfo.card?.sign
        nameLabel.text = spaceInfo.card?.name
    }
}
