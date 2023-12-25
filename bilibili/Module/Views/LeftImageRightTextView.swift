//
//  LeftImageRightTextView.swift
//  bilibili
//
//  Created by Zackary on 2023/12/4.
//

import UIKit

class LeftImageRightTextView: UIView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let spacing: CGFloat = 20.0
    let imageSize: CGSize = CGSizeMake(80, 80)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(imageSize)
            make.leading.top.bottom.equalTo(self).offset(20)
            make.top.equalTo(self).offset(20)
            make.bottom.equalTo(self).offset(-20)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(spacing)
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.size.height / 2.0
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
                self.backgroundColor = .biliPink
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.backgroundColor = .clear
                self.layer.shadowOffset = CGSizeMake(0, 0)
            }
        }
    }
}
