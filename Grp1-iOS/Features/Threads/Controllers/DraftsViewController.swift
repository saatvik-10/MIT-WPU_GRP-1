//
//  DraftsViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class DraftsViewController: UIViewController
                            {


    @IBOutlet weak var collectionView: UICollectionView!
    private let drafts = ThreadsDataStore.shared.getMyThreads()

        override func viewDidLoad() {
            super.viewDidLoad()

            collectionView.dataSource = self
            collectionView.delegate = self

          
            collectionView.register(
                UINib(nibName: "DraftCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "DraftCollectionViewCell"
            )

            
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero
                layout.scrollDirection = .vertical
            }
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    
    extension DraftsViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            drafts.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DraftCollectionViewCell",
                for: indexPath
            ) as! DraftCollectionViewCell

            let draft = drafts[indexPath.item]
            cell.configure(imageName: draft.imageName)
            
            return cell
        }
    }

    
    extension DraftsViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            12
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            12
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let columns: CGFloat = 3
            let spacing: CGFloat = 12
            let horizontalInsets: CGFloat = 16 * 2

            let totalSpacing = (columns - 1) * spacing + horizontalInsets
            let itemWidth = (collectionView.bounds.width - totalSpacing) / columns

            return CGSize(width: itemWidth, height: itemWidth * 1.4)
        }
    }
extension DraftsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                          didSelectItemAt indexPath: IndexPath) {

          let selectedDraft = drafts[indexPath.item]

          let storyboard = UIStoryboard(name: "threadsMain", bundle: nil)
          let createVC = storyboard.instantiateViewController(
              withIdentifier: "CreatePostViewController"
          ) as! CreatePostViewController

          createVC.draft = Draft(
              id: UUID(),
              title: selectedDraft.title,
              topic: selectedDraft.tags.first,
              body: selectedDraft.description,
              imageName: selectedDraft.imageName,
              lastUpdated: Date()
          )

          createVC.mode = .editDraft

          navigationController?.pushViewController(createVC, animated: true)
      }
}
