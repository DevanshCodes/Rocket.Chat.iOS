//
//  ChannelInfoViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChannelInfoViewController: BaseViewController {

    var tableViewData: [[Any]] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var subscription: Subscription! {
        didSet {
            let channelInfoData = [
                ChannelInfoDetailCellData(title: localized("chat.info.item.members"), detail: ""),
                ChannelInfoDetailCellData(title: localized("chat.info.item.pinned"), detail: ""),
                ChannelInfoDetailCellData(title: localized("chat.info.item.starred"), detail: "")
            ]

            if subscription.type == .directMessage {
                tableViewData = [[
                    ChannelInfoUserCellData(user: subscription.directMessageUser)
                ], channelInfoData]
            } else {
                let topic = subscription.roomTopic?.characters.count ?? 0 == 0 ? localized("chat.info.item.no_topic") : subscription.roomTopic
                let description = subscription.roomDescription?.characters.count ?? 0 == 0 ? localized("chat.info.item.no_description") : subscription.roomDescription

                tableViewData = [[
                    ChannelInfoBasicCellData(title: "#\(subscription.name)"),
                    ChannelInfoDescriptionCellData(
                        title: localized("chat.info.item.topic"),
                        description: topic
                    ),
                    ChannelInfoDescriptionCellData(
                        title: localized("chat.info.item.description"),
                        description: description
                    )
                ], channelInfoData]
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    weak var buttonFavorite: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized("chat.info.title")

        if let auth = AuthManager.isAuthenticated() {
            if auth.settings?.favoriteRooms ?? false {
                let defaultImage = UIImage(named: "Star")?.imageWithTint(UIColor.RCGray()).withRenderingMode(.alwaysOriginal)
                let buttonFavorite = UIBarButtonItem(image: defaultImage, style: .plain, target: self, action: #selector(buttonFavoriteDidPressed))
                navigationItem.rightBarButtonItem = buttonFavorite
                self.buttonFavorite = buttonFavorite
                updateButtonFavoriteImage()
            }
        }
    }

    func updateButtonFavoriteImage(_ force: Bool = false, value: Bool = false) {
        guard let buttonFavorite = self.buttonFavorite else { return }
        let favorite = force ? value : subscription.favorite
        var image: UIImage?

        if favorite {
            image = UIImage(named: "Star-Filled")?.imageWithTint(UIColor.RCFavoriteMark())
        } else {
            image = UIImage(named: "Star")?.imageWithTint(UIColor.RCGray())
        }

        buttonFavorite.image = image?.withRenderingMode(.alwaysOriginal)
    }

    // MARK: IBAction

    func buttonFavoriteDidPressed(_ sender: Any) {
        SubscriptionManager.toggleFavorite(self.subscription) { [unowned self] (response) in
            if response.isError() {
                self.subscription.updateFavorite(!self.subscription.favorite)
            }

            self.updateButtonFavoriteImage()
        }

        self.subscription.updateFavorite(!subscription.favorite)
        updateButtonFavoriteImage()
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: UITableViewDelegate

extension ChannelInfoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoBasicCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoBasicCell.identifier) as? ChannelInfoBasicCell {
                cell.data = data
                return cell
            }
        }

        if let data = data as? ChannelInfoDetailCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoDetailCell.identifier) as? ChannelInfoDetailCell {
                cell.data = data
                return cell
            }
        }

        if let data = data as? ChannelInfoUserCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoUserCell.identifier) as? ChannelInfoUserCell {
                cell.data = data
                return cell
            }
        }

        if let data = data as? ChannelInfoDescriptionCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoDescriptionCell.identifier) as? ChannelInfoDescriptionCell {
                cell.data = data
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let _ = data as? ChannelInfoBasicCellData {
            return CGFloat(ChannelInfoBasicCell.defaultHeight)
        }

        if let _ = data as? ChannelInfoDetailCellData {
            return CGFloat(ChannelInfoDetailCell.defaultHeight)
        }

        if let _ = data as? ChannelInfoUserCellData {
            return CGFloat(ChannelInfoUserCell.defaultHeight)
        }

        if let _ = data as? ChannelInfoDescriptionCellData {
            return CGFloat(ChannelInfoDescriptionCell.defaultHeight)
        }

        return CGFloat(0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let _ = data as? ChannelInfoDetailCellData {
            let alert = UIAlertController(title: "Ops!", message: "We're still working on this feature, stay tunned!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)

            if let selectedIndex = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndex, animated: true)
            }
        }
    }

}

// MARK: UITableViewDataSource

extension ChannelInfoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].count
    }

}
