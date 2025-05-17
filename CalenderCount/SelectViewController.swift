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

class SelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items: [Item] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    private var addButton: UIButton!
    
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

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = items[indexPath.row].name
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
}
