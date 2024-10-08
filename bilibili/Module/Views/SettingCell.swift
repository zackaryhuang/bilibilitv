//
//  SettingView.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import UIKit

class SettingCell: UICollectionViewCell {
    let label = UILabel()
    let selectIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        contentView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.16)
        contentView.layer.cornerRadius = 10
        label.textAlignment = .center
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
        selectIcon.image = UIImage(named: "icon_selected")
        contentView.addSubview(selectIcon)
        selectIcon.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalTo(label.snp.leading).offset(-10)
            make.width.height.equalTo(40)
        }
    }

    func update(with option: SettingOptions) {
        label.text = option.title
        let isSelected = option.checkSelected()
        selectIcon.isHidden = !isSelected
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
                self.contentView.backgroundColor = UIColor(hex: 0x2197F3)
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.contentView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.16)
                self.layer.shadowOffset = CGSizeMake(0, 0)
            }
        }
    }
}
