//
//  TagLabel.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

final class TagLabel: UILabel {

    private let padding = UIEdgeInsets(
        top: 4,
        left: 12,
        bottom: 4,
        right: 12
    )

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }
}
