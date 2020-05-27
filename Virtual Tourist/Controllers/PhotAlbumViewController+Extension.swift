//
//  PhotAlbumViewController+Extension.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/27/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = placePhotos[indexPath.row]
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as! PhotoCellView
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
        } else {
            HttpHelper.downloadPhoto(photo: photo, cell: cell, onSuccess: updateCollectionViewImage(photo:imageData:cell:))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ask if user wants to delete.
        let question = UIAlertController(title: "Confirm delete", message: "Are you sure you sure you want to delete the selected photo?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .destructive) { (_) in
            // Delete the photo
            collectionView.deleteItems(at: [indexPath])
            let photo = self.placePhotos.remove(at: indexPath.row)
            photo.managedObjectContext?.delete(photo)
            try? photo.managedObjectContext?.save()
        }
        question.addAction(cancelAction)
        question.addAction(deleteAction)
        present(question, animated: true)
    }
}
