//
//  NotificationsPreferencesViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsPreferencesViewController: UITableViewController {
    private let viewModel = NotificationsPreferencesViewModel()
    var subscription: Subscription? {
        didSet {
            updateModel(subscription: subscription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        viewModel.enableModel.value.bind { [unowned self] _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.saveButtonTitle, style: .done, target: self, action: #selector(saveSettings))
    }

    @objc private func saveSettings() {
        guard let subscription = subscription else {
            Alert(key: "alert.update_notifications_preferences_save_error").present()
            return
        }

        let saveNotificationsRequest = SaveNotificationRequest(rid: subscription.rid, notificationPreferences: viewModel.notificationPreferences)
        API.current()?.fetch(saveNotificationsRequest) { [weak self] response in
            guard let strongSelf = self else { return }

            switch response {
            case .resource(let resource):
                strongSelf.alertSuccess(title: strongSelf.viewModel.saveSuccessTitle)
            case .error:
                Alert(key: "alert.update_notifications_preferences_save_error").present()
            }
        }
    }

    private func updateModel(subscription: Subscription?) {
        guard let subscription = subscription else {
            return
        }

        self.viewModel.enableModel.value.value = !subscription.disableNotifications
        self.viewModel.counterModel.value.value = !subscription.hideUnreadStatus
        self.viewModel.desktopAlertsModel.value.value = subscription.desktopNotifications
        self.viewModel.desktopAudioModel.value.value = subscription.audioNotifications
        self.viewModel.desktopSoundModel.value.value = subscription.audioNotificationValue
        self.viewModel.desktopDurationModel.value.value = subscription.desktopNotificationDuration
        self.viewModel.mobileAlertsModel.value.value = subscription.mobilePushNotifications
        self.viewModel.mailAlertsModel.value.value = subscription.emailNotifications
    }
}

extension NotificationsPreferencesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingModel = viewModel.settingModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: settingModel.type.rawValue, for: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let settingModel = viewModel.settingModel(for: indexPath)
        guard var cell = cell as? NotificationsCellProtocol else {
            fatalError("Could not dequeue reusable cell with type \(settingModel.type.rawValue)")
        }

        cell.cellModel = settingModel

        if let chooseCell = cell as? NotificationsChooseCell {
            chooseCell.tableView = tableView
            chooseCell.dropDownRect = tableView.rectForRow(at: indexPath)
        }
    }
}

extension NotificationsPreferencesViewController {

}
