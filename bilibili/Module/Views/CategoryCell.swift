//
//  LiveItemCell.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/31.
//

import UIKit

// protocol CategoryCellDelegate: NSObjectProtocol {
//    func categoryCellDidBecomeFocused(category: LiveCategory)
//    func categoryCellDidBecomeFocused(category: RankCategoryInfo)
//    func categoryCellDidBecomeFocused(category: PersonalInfoCategory)
// }

class CategoryCell: UICollectionViewCell {
    var titleLabel: UILabel!
//    weak var delegate: CategoryCellDelegate?
    var liveCategory: LiveCategory?
    var rankCategory: RankCategoryInfo?
    var personalInfoCategory: PersonalInfoCategory?
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        contentView.layer.cornerRadius = 20
        titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 30)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.trailing.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
        }
    }

    func update(with category: LiveCategory) {
        titleLabel.text = category.title
        liveCategory = category
    }

    func update(with category: RankCategoryInfo) {
        titleLabel.text = category.title
        rankCategory = category
    }

    func update(with category: PersonalInfoCategory) {
        titleLabel.text = category.title
        personalInfoCategory = category
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
                self.contentView.backgroundColor = .clear
                self.layer.shadowOffset = CGSizeMake(0, 0)
            }
        }
    }
}
