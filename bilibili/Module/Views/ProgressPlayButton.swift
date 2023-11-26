//
//  ProgressPlayButton.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class ProgressPlayButton: UIView {
    let progressView = UIView()

    let label = UILabel()

    var progress = 0.0 {
        didSet {
            progressView.snp.remakeConstraints { make in
                make.leading.top.bottom.equalTo(self)
                make.width.equalTo(self).multipliedBy(progress)
            }
            if progress > 0 {
                label.text = "继续播放"
            } else {
                label.text = "播放"
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configUI() {
        layer.cornerRadius = 10
        layer.masksToBounds = true

        backgroundColor = UIColor(hex: 0xFF9552, alpha: 0.6)
        progressView.backgroundColor = UIColor(hex: 0xFF9552)
        addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self)
            make.width.equalTo(self)
        }

        label.font = UIFont.systemFont(ofSize: 32)
        label.text = "播放"
        addSubview(label)
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.center.equalTo(self)
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
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.transform = CGAffineTransformIdentity
                self.layer.shadowOpacity = 0
                self.layer.shadowOffset = CGSizeMake(0, 0)
            }
        }
    }

    func addTapGesture(target: Any?, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tap)
    }
}
