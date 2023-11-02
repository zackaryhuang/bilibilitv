//
//  Int.swift
//  BilibiliLive
//
//  Created by whw on 2022/11/4.
//

import Foundation

extension Int {
    func string() -> String {
        return String(self)
    }

    func numberString() -> String {
        if self > 10000 {
            return String(format: "%.1f 万", floor(Double(self) / 1000) / 10)
        }
        return String(self)
    }

    var durationString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .brief
        return formatter.string(from: TimeInterval(self)) ?? ""
    }
}
