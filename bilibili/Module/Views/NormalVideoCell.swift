//
//  NormalVideoCell.swift
//  bilibili
//
//  Created by Zackary on 2023/11/28.
//

import UIKit

class NormalVideoCell: UICollectionViewCell {
    static var CellSize = CGSize(width: 420, height: 275)

    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let secondTitleLabel = UILabel()
    private let shadowView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = 15
        coverImageView.clipsToBounds = true
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.centerX.equalTo(self)
            make.width.equalTo(400)
            make.height.equalTo(225)
        }

        shadowView.image = UIImage(named: "bg_shadow")
        coverImageView.addSubview(shadowView)
        shadowView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(coverImageView)
            make.height.equalTo(45)
        }

        titleLabel.font = .systemFont(ofSize: 25)
        shadowView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(shadowView).offset(20)
            make.trailing.equalTo(shadowView).offset(-20)
            make.centerY.equalTo(shadowView)
        }

        secondTitleLabel.font = .systemFont(ofSize: 28)
        secondTitleLabel.textColor = .black
        secondTitleLabel.isHidden = true
        shadowView.addSubview(secondTitleLabel)
        secondTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(shadowView).offset(20)
            make.trailing.equalTo(shadowView).offset(-20)
            make.centerY.equalTo(shadowView)
        }
    }

    func update(title: String, subTitle: String, imageURL: URL?) {
        if let episodeIndex = Int(title) {
            titleLabel.text = "第\(episodeIndex)集"
        } else {
            titleLabel.text = title
        }
        secondTitleLabel.text = subTitle.isEmpty ? titleLabel.text : subTitle
        coverImageView.kf.setImage(with: imageURL)
    }

    override var canBecomeFocused: Bool {
        return true
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if isFocused {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformMakeScale(1.1, 1.1)
                let scaleDiff = (self.bounds.size.height * 1.1 - self.bounds.size.height) / 2
                self.transform = CGAffineTransformTranslate(self.transform, 0, -scaleDiff)
                self.layer.shadowOffset = CGSizeMake(0, 10)
                self.layer.shadowOpacity = 0.15
                self.layer.shadowRadius = 16.0
                self.secondTitleLabel.isHidden = false
                self.titleLabel.isHidden = true
                self.shadowView.image = nil
                self.shadowView.backgroundColor = .white
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.layer.shadowOffset = CGSizeMake(0, 0)
                self.contentView.backgroundColor = .clear
                self.secondTitleLabel.isHidden = true
                self.titleLabel.isHidden = false
                self.shadowView.image = UIImage(named: "bg_shadow")
                self.shadowView.backgroundColor = .clear
            }
        }
    }
}
