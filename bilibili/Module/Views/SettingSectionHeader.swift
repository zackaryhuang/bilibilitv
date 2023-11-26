//
//  SettingSectionHeader.swift
//  bilibili
//
//  Created by Zackary on 2023/11/26.
//

import UIKit

class SettingSectionHeader: UICollectionReusableView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configUI() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.centerY.equalTo(self)
        }
    }

    func update(with title: String) {
        label.text = title
    }
}
