//
//  ProgressView.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import UIKit

class ProgressView: UIView {
    let progressBar = UIView()

    var cornerRadius: CGFloat = 0 {
        didSet {
            progressBar.layer.cornerRadius = cornerRadius
            self.layer.cornerRadius = cornerRadius
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
        backgroundColor = .gray
        progressBar.backgroundColor = UIColor(hex: 0xE8C27D)
        addSubview(progressBar)
        progressBar.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self)
            make.width.equalTo(0)
        }
    }

    func updateProgress(progress: Double, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.progressBar.snp.makeConstraints { make in
                    make.leading.top.bottom.equalTo(self)
                    make.width.equalTo(self.snp.width).multipliedBy(progress)
                }
                self.layoutIfNeeded()
            }
        } else {
            progressBar.snp.makeConstraints { make in
                make.leading.top.bottom.equalTo(self)
                make.width.equalTo(self.snp.width).multipliedBy(progress)
            }
        }
    }
}
