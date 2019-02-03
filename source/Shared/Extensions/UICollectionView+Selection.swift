//
//  UICollectionView+Selection.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 12/27/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit

extension UICollectionView {
    func deselectAll(animated: Bool) {
        if let indexesFound = self.indexPathsForSelectedItems {
            for indexPath in indexesFound {
                self.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
        
}
