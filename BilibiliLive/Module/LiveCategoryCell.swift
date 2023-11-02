//
//  LiveItemCell.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/31.
//

import UIKit

protocol CategoryCellDelegate: NSObjectProtocol {
    func categoryCellDidBecomeFocused(category: LiveCategory)
    func categoryCellDidBecomeFocused(category: RankCategoryInfo)
}

class CategoryCell: UITableViewCell {
    var titleLabel: UILabel!
    weak var delegate: CategoryCellDelegate?
    var liveCategory: LiveCategory?
    var rankCategory: RankCategoryInfo?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configUI() {
        contentView.layer.cornerRadius = 10
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 30)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(5)
            make.bottom.equalTo(contentView).offset(-5)
            make.trailing.lessThanOrEqualTo(contentView).offset(-10)
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

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.contentView.backgroundColor = .white
                self.titleLabel.textColor = .black
            }, completion: nil)
            if let currentCategory = liveCategory {
                delegate?.categoryCellDidBecomeFocused(category: currentCategory)
            }
            if let currentRankCategory = rankCategory {
                delegate?.categoryCellDidBecomeFocused(category: currentRankCategory)
            }
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.contentView.backgroundColor = .clear
                self.titleLabel.textColor = .white
            }, completion: nil)
        }
    }
}
