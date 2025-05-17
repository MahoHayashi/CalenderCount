//
//  SelectViewController.swift
//  CalenderCount
//
//  Created by 中村健介 on 2025/05/14.
//

import UIKit

struct Item {
    var name: String
    var count: Int
}

struct Achievement: Codable {
    var itemName: String
    var dateAchieved: Date
}

class SelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items: [Item] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private var addButton: UIButton!
    private var achievementsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.733, green: 0.886, blue: 0.945, alpha: 1.0) // #bbe2f1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 0.733, green: 0.886, blue: 0.945, alpha: 1.0) // #bbe2f1

        addButton = UIButton(type: .system)
        addButton.setTitle("+", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 30
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        view.addSubview(addButton)

        achievementsButton = UIButton(type: .system)
        achievementsButton.setTitle("達成履歴を見る", for: .normal)
        achievementsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        achievementsButton.backgroundColor = .systemGreen
        achievementsButton.setTitleColor(.white, for: .normal)
        achievementsButton.layer.cornerRadius = 10
        achievementsButton.translatesAutoresizingMaskIntoConstraints = false
        achievementsButton.addTarget(self, action: #selector(showAchievements), for: .touchUpInside)
        view.addSubview(achievementsButton)

        NSLayoutConstraint.activate([
            achievementsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            achievementsButton.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
            achievementsButton.widthAnchor.constraint(equalToConstant: 160),
            achievementsButton.heightAnchor.constraint(equalToConstant: 40),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    func loadAchievements() -> [Achievement] {
        let dataArray = UserDefaults.standard.array(forKey: "achievements") as? [Data] ?? []
        return dataArray.compactMap { try? JSONDecoder().decode(Achievement.self, from: $0) }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = items[indexPath.row].name
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        vc.selectedItem = items[indexPath.row]
        vc.itemIndex = indexPath.row
        vc.updateHandler = { updatedItem in
            self.items[indexPath.row] = updatedItem
            self.tableView.reloadData()
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addItem() {
        let alert = UIAlertController(title: "我慢項目を追加", message: "例：甘いもの、SNS など", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "我慢する項目"
        }
        let addAction = UIAlertAction(title: "追加", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.items.append(Item(name: text, count: 0))
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        alert.addAction(addAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    @objc func showAchievements() {
        let vc = AchievementListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

class AchievementListViewController: UIViewController, UITableViewDataSource {

    var achievements: [Achievement] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "達成履歴"
        view.backgroundColor = .white

        let tableView = UITableView(frame: view.bounds)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)

        let dataArray = UserDefaults.standard.array(forKey: "achievements") as? [Data] ?? []
        achievements = dataArray.compactMap { try? JSONDecoder().decode(Achievement.self, from: $0) }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievements.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let achievement = achievements[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.textLabel?.text = "\(achievement.itemName): \(formatter.string(from: achievement.dateAchieved))"
        return cell
    }
}
