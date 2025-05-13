//
//  ViewController.swift
//  CalenderCount
//
//  Created by 中村健介 on 2025/05/11.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var count = 0
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
        view.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.84, alpha: 1.0) // #FFDFD6

        // ラベルの設定
        countLabel.text = "\(count)"
        countLabel.font = UIFont.systemFont(ofSize: 60)
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countLabel)

        // ＋ボタンの設定
        let plusButton = UIButton(type: .system)
        plusButton.setTitle("＋", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        plusButton.addTarget(self, action: #selector(incrementCount), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)

        // −ボタンの設定
        let minusButton = UIButton(type: .system)
        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        minusButton.addTarget(self, action: #selector(decrementCount), for: .touchUpInside)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(minusButton)

        // Auto Layout
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),

            minusButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            minusButton.trailingAnchor.constraint(equalTo: countLabel.leadingAnchor, constant: -30),

            plusButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            plusButton.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 30),
        ])
        
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        view.addSubview(calendarCollectionView)

        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 80),
            calendarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    @objc func incrementCount() {
        count = (count + 1) % 31
        countLabel.text = "\(count)"
        updateCalendarHighlight()
    }

    @objc func decrementCount() {
        count = max(0, count - 1)
        countLabel.text = "\(count)"
        updateCalendarHighlight()
    }
    
    func updateCalendarHighlight() {
        for i in 0..<30 {
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = calendarCollectionView.cellForItem(at: indexPath) {
                if i < count {
                    cell.backgroundColor = UIColor.systemBlue
                } else {
                    cell.backgroundColor = UIColor.systemGray5
                }
            }
        }
        if count == 30 {
            imageView.image = UIImage(named: "cokeImage2")
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30 // 1ヶ月分の日数
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        if indexPath.item < count {
            cell.backgroundColor = UIColor.systemBlue
        } else {
            cell.backgroundColor = UIColor.systemGray5
        }

        let label = UILabel(frame: cell.contentView.bounds)
        label.text = "\(indexPath.item + 1)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(label)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 6) / 7
        return CGSize(width: width, height: width)
    }
}
