//
//  SettingsTableViewCell.swift
//  GymLeague
//
//  Created by Oliver Raney on 2/8/24.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    var switchControl: UISwitch!
    
    var switchValueChangedClosure: ((Bool) -> Void)?

    @objc func switchValueChanged(_ sender: UISwitch) {
        // Call the closure with the new switch state
        switchValueChangedClosure?(sender.isOn)
    }
    
    func configureSwitch() {
        let showSwitch = UISwitch()
        showSwitch.setOn(UserData.shared.showOnLeaderboards!, animated: false)
        showSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        accessoryView = showSwitch
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
