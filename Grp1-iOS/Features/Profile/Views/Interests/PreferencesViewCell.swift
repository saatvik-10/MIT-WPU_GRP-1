//
//  InterestCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class PreferencesViewCell: UICollectionViewCell {

    @IBOutlet weak var interestIconView: UIImageView!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var subtitleInterestLabel: UILabel!
    @IBOutlet weak var checkmarkView: UIImageView!
    let selectedBorderWidth : CGFloat = 2
    let unselectedBorderWidth : CGFloat = 1
    let config = UIImage.SymbolConfiguration(weight: .light)
    override var isSelected: Bool {
        didSet {
            updateSelectionUI()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            isHighlighted ? touchDown() : touchUp()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        interestLabel.isUserInteractionEnabled = false
        interestIconView.isUserInteractionEnabled = false

        setupUI()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
        checkmarkView.alpha = 0
        contentView.transform = .identity
    }
    
    func touchDown() {
       UIView.animate(
           withDuration: 0.12,
           delay: 0,
           options: [.curveEaseOut, .allowUserInteraction],
           animations: {
               self.contentView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
           }
       )
   }

    func touchUp() {
       UIView.animate(
           withDuration: 0.18,
           delay: 0,
           options: [.curveEaseOut, .allowUserInteraction],
           animations: {
               self.contentView.transform = self.isSelected
                   ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                   : .identity
           }
       )
   }
    
    func updateSelectionUI() {
       UIView.animate(
           withDuration: 0.18,
           delay: 0,
           options: [.curveEaseOut, .allowUserInteraction],
           animations: {
               self.contentView.backgroundColor = self.isSelected
                   ? UIColor.systemBlue.withAlphaComponent(0.08)
               : UIColor.white

               self.contentView.layer.borderColor = self.isSelected
                   ? UIColor.systemBlue.cgColor
                   : UIColor.clear.cgColor
               
               self.contentView.layer.borderWidth = self.isSelected ? self.selectedBorderWidth : self.unselectedBorderWidth
               
               self.contentView.layer.borderColor = self.isSelected ?
               UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
               
               self.checkmarkView.alpha = self.isSelected ? 1 : 0
               self.checkmarkView.transform = self.isSelected
                              ? .identity
                              : CGAffineTransform(scaleX: 0.6, y: 0.6)
           }
       )
   }
    func setupUI() {
       contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1.75
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = UIColor.white
        
        checkmarkView.tintColor = .systemBlue
        checkmarkView.alpha = 0
        checkmarkView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
   }
    func configure(_ model: InterestModel) {
        interestLabel.text = model.title
        subtitleInterestLabel.text = model.subtitle

        if let iconName = model.icon {
            interestIconView.image = UIImage(systemName: iconName ,withConfiguration: config)
            interestIconView.tintColor = .label
            interestIconView.isHidden = false
        } else {
            interestIconView.isHidden = true
        }
    }
}
