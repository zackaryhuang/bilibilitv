//
//  SidePanelItemView.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/24.
//

import UIKit

class SidePanelItemView: UIView {
    var type: CurrentFocusType!
    var imageView: UIImageView!
    var label: UILabel!
    var title: String! {
        didSet {
            label.text = title
        }
    }

    var image: String! {
        didSet {
            imageView.image = UIImage(named: image)
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

    private func configUI() {
        layer.cornerRadius = 20
        imageView = UIImageView()

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.leading.top.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-10)
        }

        label = UILabel()
        label.isHidden = true
        label.font = .systemFont(ofSize: 30)
        label.text = title
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(30)
            make.centerY.equalTo(imageView)
            make.trailing.equalTo(self)
        }
    }

    override var canBecomeFocused: Bool {
        return true
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.backgroundColor = .white
                self.label.textColor = .black
            }, completion: nil)
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.backgroundColor = .clear
                self.label.textColor = .white
            }, completion: nil)
        }
    }
}
