//
//  SettingCell.swift
//  BilibiliLive
//
//  Created by Zackary on 2023/10/26.
//

import UIKit

class SettingCell: UITableViewCell {
    var titleLabel: UILabel!
    var statusLabel: UILabel!
    var indicator: UIImageView!

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
        titleLabel.numberOfLines = 2
        titleLabel.font = .systemFont(ofSize: 30)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).offset(5)
            make.bottom.equalTo(contentView).offset(-5)
            make.trailing.lessThanOrEqualTo(contentView).offset(-80)
        }

        statusLabel = UILabel()
        statusLabel.textAlignment = .right
        statusLabel.textColor = UIColor(hex: 0xA0A4A9)
        statusLabel.font = .systemFont(ofSize: 20)
        contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
        }

        indicator = UIImageView()
        contentView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-10)
            make.centerY.equalTo(contentView)
        }
    }

    func update(with item: SettingItem) {
        titleLabel.text = item.title
        if item.settingKey == "Settings.playVideoDirectly" {
            statusLabel.text = Settings.playVideoDirectly ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.mediaQuality" {
            let quality = Settings.mediaQuality
            for style in MediaQualityEnum.allCases {
                if style == quality {
                    statusLabel.text = style.desp
                    break
                }
            }
            indicator.isHidden = false
        } else if item.settingKey == "Settings.danmuArea" {
            let area = Settings.danmuArea
            for style in DanmuArea.allCases {
                if style == area {
                    statusLabel.text = style.title
                    break
                }
            }
            indicator.isHidden = false
        } else if item.settingKey == "Settings.displayStyle" {
            let value = Settings.displayStyle
            for style in FeedDisplayStyle.allCases {
                if style == value {
                    statusLabel.text = style.desp
                    break
                }
            }
            indicator.isHidden = false
        } else if item.settingKey == "Settings.showRelatedVideoInCurrentVC" {
            statusLabel.text = Settings.showRelatedVideoInCurrentVC ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.continuePlay" {
            statusLabel.text = Settings.continuePlay ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.continouslyPlay" {
            statusLabel.text = Settings.continouslyPlay ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.losslessAudio" {
            statusLabel.text = Settings.losslessAudio ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.preferHevc" {
            statusLabel.text = Settings.preferHevc ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.danmuSize" {
            let value = Settings.danmuSize
            for style in DanmuSize.allCases {
                if style == value {
                    statusLabel.text = style.title
                    break
                }
            }
            indicator.isHidden = false
        } else if item.settingKey == "Settings.danmuMask" {
            statusLabel.text = Settings.danmuMask ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.vnMask" {
            statusLabel.text = Settings.vnMask ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.contentMatch" {
            statusLabel.text = Settings.contentMatch ? "已开启" : "已关闭"
            indicator.isHidden = true
        } else if item.settingKey == "Settings.play.autoSkip" {
            statusLabel.text = Settings.autoSkip ? "已开启" : "已关闭"
            indicator.isHidden = true
        }
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.contentView.backgroundColor = .white
                self.titleLabel.textColor = .black
            }, completion: nil)
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () in
                self.contentView.backgroundColor = .clear
                self.titleLabel.textColor = .white
            }, completion: nil)
        }
    }
}
