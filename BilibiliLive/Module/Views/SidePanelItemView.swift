//
//  SidePanelItemView.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/24.
//

import UIKit

class SidePanelItemView: UITableViewCell {
    var type: CurrentFocusType!
    var iconView: UIImageView!
    var label: UILabel!
    var canBeF = true
    var title: String! {
        didSet {
            label.text = title
        }
    }

    var image: String! {
        didSet {
            iconView.image = UIImage(named: image)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        layer.cornerRadius = 20
        iconView = UIImageView()

        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.width.height.equalTo(50)
            make.leading.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-20)
        }

        label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.text = title
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(30)
            make.centerY.equalTo(iconView)
            make.trailing.equalTo(contentView)
        }
    }

    func updateCell(with item: SidePanelItem) {
        type = item.type
        if item.type == .userInfo {
            iconView.layer.cornerRadius = 25
            iconView.clipsToBounds = true
            iconView.kf.setImage(with: URL(string: item.avatar!))
        } else {
            iconView.layer.cornerRadius = 0
            iconView.clipsToBounds = false
            iconView.image = UIImage(named: item.icon)
        }

        label.text = item.title
    }

    override var canBecomeFocused: Bool {
        return canBeF
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
