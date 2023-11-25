//
//  PersonalInfoCard.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import Kingfisher
import UIKit

class PersonalInfoCard: UIView {
    let avatarView = UIImageView()
    let badgeView = UIImageView()
    let nameLabel = UILabel()
    let vipView = UIImageView()
    let balanceLabel = UILabel()
    let backgroundView = UIView()
    let progressView = ProgressView()
    let currentLevelIcon = UIImageView()
    let nextLevelIcon = UIImageView()
    let tipsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configUI() {
        backgroundView.layer.cornerRadius = 20
        backgroundView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.16)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(self)
            make.top.equalTo(self).offset(30)
        }

        avatarView.layer.cornerRadius = 60
        avatarView.layer.masksToBounds = true
        backgroundView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.width.height.equalTo(120)
            make.leading.equalTo(self).offset(280)
            make.trailing.equalTo(self).offset(-280)
        }

        badgeView.image = UIImage(named: "icon_vip")
        badgeView.isHidden = true
        backgroundView.addSubview(badgeView)
        badgeView.snp.makeConstraints { make in
            make.bottom.equalTo(avatarView)
            make.trailing.equalTo(avatarView).offset(10)
            make.width.height.equalTo(40)
        }

        nameLabel.textAlignment = .center
        backgroundView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.top.equalTo(avatarView.snp.bottom).offset(10)
        }

        backgroundView.addSubview(vipView)

        balanceLabel.textAlignment = .center
        backgroundView.addSubview(balanceLabel)

        progressView.cornerRadius = 4
        progressView.isHidden = true
        backgroundView.addSubview(progressView)

        backgroundView.addSubview(currentLevelIcon)
        currentLevelIcon.snp.makeConstraints { make in
            make.trailing.equalTo(progressView.snp.leading).offset(-10)
            make.centerY.equalTo(progressView)
            make.width.height.equalTo(40)
        }

        backgroundView.addSubview(nextLevelIcon)
        nextLevelIcon.snp.makeConstraints { make in
            make.leading.equalTo(progressView.snp.trailing).offset(10)
            make.centerY.equalTo(progressView)
            make.width.height.equalTo(40)
        }

        tipsLabel.font = UIFont.systemFont(ofSize: 20)
        tipsLabel.textAlignment = .center
        tipsLabel.textColor = .lightGray
        backgroundView.addSubview(tipsLabel)

        setNeedsUpdateConstraints()
    }

    func update(with info: UserInfoResp) {
        avatarView.kf.setImage(with: (info.avatarUrl != nil) ? URL(string: info.avatarUrl!) : URL(string: ""))
        nameLabel.text = info.userName
        if let vipIconUrl = info.vipInfo?.imageUrl {
            vipView.kf.setImage(with: URL(string: vipIconUrl))
            vipView.isHidden = false
        } else {
            vipView.isHidden = true
        }

        if let coinCount = info.coinBalance,
           let BCoinCount = info.walletInfo?.BCoinBalance
        {
            balanceLabel.isHidden = false
            let attributedStr = NSMutableAttributedString(string: "硬币：", attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 20),
            ])
            attributedStr.append(NSAttributedString(string: "\(coinCount)", attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 20),
            ]))
            attributedStr.append(NSAttributedString(string: "  B币：", attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 20),
            ]))

            attributedStr.append(NSAttributedString(string: "\(BCoinCount)", attributes: [
                .foregroundColor: UIColor.gray,
                .font: UIFont.systemFont(ofSize: 20),
            ]))
            balanceLabel.attributedText = attributedStr
        } else {
            balanceLabel.isHidden = true
        }

        var currentExpProgress = 0.0
        var maxExp = 0
        var curExp = 0
        if let max = info.levelInfo?.nextLevelExp,
           let min = info.levelInfo?.currentLevelExpMin,
           let cur = info.levelInfo?.currentExp
        {
            maxExp = max
            curExp = cur
            currentExpProgress = Double(cur) / Double(max - min)
            progressView.updateProgress(progress: currentExpProgress, animated: true)
            progressView.isHidden = false
        } else {
            progressView.isHidden = true
        }

        if let currentLevel = info.levelInfo?.currentLevel,
           !progressView.isHidden
        {
            currentLevelIcon.isHidden = false
            nextLevelIcon.isHidden = false
            tipsLabel.isHidden = false
            currentLevelIcon.image = UIImage(named: "icon_level_\(currentLevel)")
            let nextLevel = currentLevel + 1
            if nextLevel > 6 {
                nextLevelIcon.isHidden = true
                tipsLabel.isHidden = true
            } else {
                nextLevelIcon.image = UIImage(named: "icon_level_\(nextLevel)")
                tipsLabel.text = "当前成长\(curExp)，距离升级到 Lv.\(nextLevel) 还需要\(maxExp - curExp)"
            }
        } else {
            currentLevelIcon.isHidden = true
            nextLevelIcon.isHidden = true
            tipsLabel.isHidden = true
        }

        badgeView.isHidden = !info.isBigVip
        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        super.updateConstraints()
        var lastView: UIView = nameLabel
        if !vipView.isHidden {
            vipView.snp.remakeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(10)
                make.centerX.equalTo(backgroundView)
                make.width.equalTo(140)
                make.height.equalTo(140 * 60 / 207.0)
            }
            lastView = vipView
        }

        if !balanceLabel.isHidden {
            balanceLabel.snp.remakeConstraints { make in
                make.leading.equalTo(self).offset(40)
                make.trailing.equalTo(self).offset(-40)
                make.top.equalTo(lastView.snp.bottom).offset(10)
            }
            lastView = balanceLabel
        }

        if !progressView.isHidden {
            progressView.snp.remakeConstraints { make in
                make.leading.equalTo(self).offset(100)
                make.trailing.equalTo(self).offset(-100)
                make.height.equalTo(4)
                make.top.equalTo(lastView.snp.bottom).offset(10)
            }
            lastView = progressView
        }

        if !tipsLabel.isHidden {
            tipsLabel.snp.remakeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(15)
                make.leading.equalTo(currentLevelIcon)
                make.trailing.equalTo(nextLevelIcon)
            }
            lastView = tipsLabel
        }

        lastView.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-30)
        }
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
                self.backgroundView.backgroundColor = .green
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.backgroundView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.16)
                self.layer.shadowOffset = CGSizeMake(0, 0)
            }
        }
    }
}
