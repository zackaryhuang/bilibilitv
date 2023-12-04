//
//  NormalButton.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class NormalButton: UIView {
    let imageView = UIImageView()

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    convenience init(image: String, title: String) {
        self.init(frame: CGRectZero)
        imageView.image = UIImage(named: image)
        label.text = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configUI() {
        layer.cornerRadius = 20
        backgroundColor = UIColor(hex: 0x000000, alpha: 0.16)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.equalTo(self).offset(10)
            make.leading.equalTo(self).offset(30)
            make.trailing.equalTo(self).offset(-30)
        }

        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .lightGray
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.bottom.equalTo(self).offset(-10)
            make.leading.trailing.equalTo(self)
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
                self.backgroundColor = .biliBlue
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.16)
                self.layer.shadowOffset = CGSizeMake(0, 0)
            }
        }
    }
}
