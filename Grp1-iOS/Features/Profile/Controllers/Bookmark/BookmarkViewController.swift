//
//  BookmarkViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit
 
// MARK: - Segment Type
enum BookmarkSegment: Int {
    case articles = 0
    case blogs = 1
}
 
class BookmarkViewController: UIViewController {
 
    // Connect both of these from Storyboard
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
 
    // MARK: - Data Source (separate arrays per segment)
    private var articleItems: [BookmarkItem] = Bookmarks.mockBookmarks
    private var blogItems: [BookmarkItem] = []
 
    // MARK: - Computed active items
    private var currentSegment: BookmarkSegment {
        return BookmarkSegment(rawValue: segmentControl.selectedSegmentIndex) ?? .articles
    }
 
    private var currentItems: [BookmarkItem] {
        get {
            switch currentSegment {
            case .articles: return articleItems
            case .blogs:    return blogItems
            }
        }
        set {
            switch currentSegment {
            case .articles: articleItems = newValue
            case .blogs:    blogItems = newValue
            }
        }
    }
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
 
        title = "Bookmarks"
        setupNavBar()
        setupSegmentControl()
        setupCollectionView()
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
 
    // MARK: - Setup
 
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemGray6
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        view.backgroundColor = UIColor.systemGray6
    }
 
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = UIColor.systemGray5
        segmentControl.selectedSegmentTintColor = .white
        segmentControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 14, weight: .medium)],
            for: .normal
        )
        segmentControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .selected
        )
    }
 
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.systemGray6
        collectionView.register(
            UINib(nibName: "BookmarkViewCell", bundle: nil),
            forCellWithReuseIdentifier: "BookmarkViewCell"
        )
    }
 
    // MARK: - IBActions
 
    // Connect this to the segment control's "Value Changed" event in Storyboard
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        collectionView.reloadData()
    }
 
    // Connect this to the + bar button in Storyboard
    @IBAction func addBookmarkTapped(_ sender: UIBarButtonItem) {
        showCreateBookmarkAlert()
    }
 
    // MARK: - Alert
 
    private func showCreateBookmarkAlert() {
        let segmentName = currentSegment == .articles ? "Articles" : "Blogs"
 
        let alert = UIAlertController(
            title: "New Bookmark",
            message: "Enter a name for this \(segmentName) folder",
            preferredStyle: .alert
        )
 
        alert.addTextField { textField in
            textField.placeholder = "Folder name"
            textField.autocapitalizationType = .words
        }
 
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
 
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard
                let self = self,
                let name = alert.textFields?.first?.text,
                !name.trimmingCharacters(in: .whitespaces).isEmpty
            else { return }
            self.createBookmarkFolder(named: name)
        }
 
        saveAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
 
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields?.first,
            queue: .main
        ) { _ in
            let text = alert.textFields?.first?.text ?? ""
            saveAction.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
        }
 
        present(alert, animated: true)
    }
 
    private func createBookmarkFolder(named name: String) {
        let newItem = BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            id: UUID().uuidString,
            title: name
        )
 
        switch currentSegment {
        case .articles: articleItems.append(newItem)
        case .blogs:    blogItems.append(newItem)
        }
 
        let indexPath = IndexPath(item: currentItems.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "savedScreen",
           let vc = segue.destination as? SavedViewController,
           let folderName = sender as? String {
            vc.folderName = folderName
        }
    }

}
 
// MARK: - Layout
private func generateLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(70)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
 
    let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(500)
    )
    let group = NSCollectionLayoutGroup.vertical(
        layoutSize: groupSize,
        subitems: [item]
    )
 
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 12
    section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
 
    return UICollectionViewCompositionalLayout(section: section)
}
 
// MARK: - UICollectionView DataSource & Delegate
extension BookmarkViewController: UICollectionViewDataSource, UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentItems.count
    }
 
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BookmarkViewCell",
            for: indexPath
        ) as! BookmarkViewCell
 
        cell.configure(currentItems[indexPath.row])
        cell.delegate = self
        return cell
    }
}
 
// MARK: - BookmarkCellDelegate
extension BookmarkViewController: BookmarkCellDelegate {
    func didTapBookmark(in cell: BookmarkViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let folder = currentItems[indexPath.row]
        performSegue(withIdentifier: "savedScreen", sender: folder.title)
    }
}

