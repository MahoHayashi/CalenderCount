import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedItem: Item!
    var itemIndex: Int!
    var updateHandler: ((Item) -> Void)?
    
    let itemLabel = UILabel()
    let countLabel = UILabel()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()
    
    let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.733, green: 0.886, blue: 0.945, alpha: 1.0) // #bbe2f1

        // ラベル設定
        itemLabel.text = "\(selectedItem?.name ?? "我慢")を我慢中‼️"
        itemLabel.font = UIFont.systemFont(ofSize: 24)
        itemLabel.textAlignment = .center
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(itemLabel)

        countLabel.text = "\(selectedItem.count)"
        countLabel.font = UIFont.systemFont(ofSize: 60)
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countLabel)

        // ＋ボタン
        let plusButton = UIButton(type: .system)
        plusButton.setTitle("＋", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        plusButton.addTarget(self, action: #selector(incrementCount), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)

        // −ボタン
        let minusButton = UIButton(type: .system)
        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        minusButton.addTarget(self, action: #selector(decrementCount), for: .touchUpInside)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(minusButton)

        // レイアウト
        NSLayoutConstraint.activate([
            itemLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: itemLabel.bottomAnchor, constant: 10),
            minusButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            minusButton.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -30),
            plusButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            plusButton.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 30),
        ])
        
        // カレンダー表示
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(calendarCollectionView)

        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 80),
            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        // 達成画像
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func incrementCount() {
        selectedItem.count = (selectedItem.count + 1) % 31
        countLabel.text = "\(selectedItem.count)"
        updateCalendarHighlight()
        updateHandler?(selectedItem)
    }

    @objc func decrementCount() {
        selectedItem.count = max(0, selectedItem.count - 1)
        countLabel.text = "\(selectedItem.count)"
        updateCalendarHighlight()
        updateHandler?(selectedItem)
    }

    func updateCalendarHighlight() {
        for i in 0..<30 {
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = calendarCollectionView.cellForItem(at: indexPath) {
                cell.backgroundColor = i < selectedItem.count ? UIColor.systemBlue : .white
            }
        }
        if selectedItem.count == 30 {
            imageView.image = UIImage(named: "end2")
            imageView.isHidden = false
            saveAchievement(for: selectedItem)
        } else {
            imageView.isHidden = true
        }
    }

    func saveAchievement(for item: Item) {
        let achievement = Achievement(itemName: item.name, dateAchieved: Date())
        var saved = UserDefaults.standard.array(forKey: "achievements") as? [Data] ?? []
        if let encoded = try? JSONEncoder().encode(achievement) {
            saved.append(encoded)
            UserDefaults.standard.set(saved, forKey: "achievements")
        }
    }

    // MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = indexPath.item < selectedItem.count ? .systemBlue : .white

        let label = UILabel(frame: cell.contentView.bounds)
        label.text = "\(indexPath.item + 1)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(label)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 5
        let width = (collectionView.frame.width - totalSpacing) / 6
        let height = (collectionView.frame.height - totalSpacing) / 5
        return CGSize(width: width, height: height)
    }
}
