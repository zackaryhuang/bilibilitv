//
//  SettingsViewController.swift
//  bilibili
//
//  Created by Zackary on 2023/11/25.
//

import UIKit

class SettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    private func configUI() {
        let label = UILabel()
        label.text = "设置"
        label.font = .boldSystemFont(ofSize: 50)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(80)
            make.top.equalTo(view).offset(100)
        }

        let line = UIView()
        line.backgroundColor = .gray
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(80)
            make.trailing.equalTo(view).offset(-80)
            make.height.equalTo(2)
            make.top.equalTo(label.snp.bottom).offset(50)
        }

        let playVideoDirectly = UILabel()
        playVideoDirectly.text = "直接播放视频"
        view.addSubview(playVideoDirectly)
        playVideoDirectly.snp.makeConstraints { make in
            make.leading.equalTo(label)
            make.top.equalTo(line.snp.bottom).offset(20)
        }
    }
}
