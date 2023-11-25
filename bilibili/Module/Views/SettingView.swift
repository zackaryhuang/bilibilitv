//
//  SettingView.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import UIKit

class SettingView: UIView {
    let label = UILabel()
    let selectIcon = UIImageView()

    var isSelected: Bool = false {
        didSet {
            selectIcon.isHidden = !isSelected
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
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        selectIcon.image = UIImage(named: "icon_selected")
        addSubview(selectIcon)
        selectIcon.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalTo(label.snp.leading).offset(-10)
            make.width.height.equalTo(60)
        }
    }
}
