//
//  ImageGalleryTableViewController.swift
//  ImageGallery
//
//  Created by Dmitry Reshetnik on 19.07.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    private var lastIndexPath: IndexPath?
    private var splitViewDetailCollectionController: ImageGalleryCollectionViewController? {
        let navigationController = splitViewController?.viewControllers.last as? UINavigationController
        
        return navigationController?.viewControllers.first as? ImageGalleryCollectionViewController
    }
    
    var imageGalleries = [[ImageGallery]]()

    @IBAction func newGallery(_ sender: UIBarButtonItem) {
        imageGalleries[0] += [
            ImageGallery(name: "New Gallery".madeUnique(withRespectTo: imageGalleries.flatMap{$0}.map{$0.name}))
        ]
        tableView.reloadData()
        selectRow(at: IndexPath(row: imageGalleries[0].count - 1, section: 0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test Data Model
        imageGalleries = [
            [
                ImageGallery(name: "Gallery 1"),
                ImageGallery(name: "Gallery 2"),
                ImageGallery(name: "Gallery 3")
            ],
            [
                ImageGallery(name: "Gallery 69")
            ]
        ]

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let currentIndex = lastIndexPath != nil ? lastIndexPath! : IndexPath(row: 0, section: 0)
        selectRow(at: currentIndex)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if splitViewController?.preferredDisplayMode != UISplitViewController.DisplayMode.primaryOverlay {
            splitViewController?.preferredDisplayMode = UISplitViewController.DisplayMode.primaryOverlay
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return imageGalleries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageGalleries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        // Configure the cell...
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "Gallery Cell", for: indexPath)
            
            if let imageGalleryCell = cell as? ImageGalleryTableViewCell {
                imageGalleryCell.nameTextField.text = imageGalleries[indexPath.section][indexPath.row].name
                imageGalleryCell.resignationHandler = { [weak self, unowned imageGalleryCell] in
                    if let name = imageGalleryCell.nameTextField.text {
                        self?.imageGalleries[indexPath.section][indexPath.row].name = name
                        self?.tableView.reloadData()
                        self?.selectRow(at: indexPath)
                    }
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Title Cell", for: indexPath)
            cell.textLabel?.text = imageGalleries[indexPath.section][indexPath.row].name
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "Recently Deleted"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCollection(at: indexPath)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                tableView.performBatchUpdates({
                    imageGalleries[1].insert(imageGalleries[0].remove(at: indexPath.row), at: 0)
                    // Delete the row from the data source
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableView.RowAnimation.automatic)
                }, completion: { (_) in
                    self.selectRow(at: IndexPath(row: 0, section: 1), after: 0.3)
                })
            case 1:
                tableView.performBatchUpdates({
                    imageGalleries[1].remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                }, completion: { (_) in
                    self.selectRow(at: IndexPath(row: 0, section: 0))
                })
            default:
                break
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let lastIndex = self.imageGalleries[0].count
            let undelete = UIContextualAction(
                style: UIContextualAction.Style.normal,
                title: "Undelete",
                handler: { (contextAction, sourceView, completionHandler) in
                    tableView.performBatchUpdates({
                        self.imageGalleries[0].insert(self.imageGalleries[1].remove(at: indexPath.row), at: lastIndex)
                        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        tableView.insertRows(at: [IndexPath(row: lastIndex, section: 0)], with: UITableView.RowAnimation.automatic)
                    }, completion: { (_) in
                        self.selectRow(at: IndexPath(row: lastIndex, section: 0), after: 0.5)
                    })
                    completionHandler(true)
                }
            )
            undelete.backgroundColor = UIColor.systemBlue
            
            return UISwipeActionsConfiguration(actions: [undelete])
        } else {
            return nil
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func selectRow(at indexPath: IndexPath, after delay: TimeInterval = 0.0) {
        if tableView(self.tableView, numberOfRowsInSection: indexPath.section) >= indexPath.row {
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { (_) in
                self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
                self.tableView(self.tableView, didSelectRowAt: indexPath)
            })
        }
    }
    
    private func showCollection(at indexPath: IndexPath) {
        if let imageGalleryViewController = splitViewDetailCollectionController {
            lastIndexPath = indexPath
            if indexPath.section != 1 {
                imageGalleryViewController.gallery = imageGalleries[indexPath.section][indexPath.row]
                imageGalleryViewController.title = imageGalleries[indexPath.section][indexPath.row].name
                imageGalleryViewController.collectionView?.isUserInteractionEnabled = true
                imageGalleryViewController.collectionView?.backgroundColor = UIColor.systemBackground
            } else {
                let newTitle = "Recently Deleted '" + imageGalleries[indexPath.section][indexPath.row].name + "'"
                imageGalleryViewController.gallery = ImageGallery(name: newTitle)
                imageGalleryViewController.title = newTitle
                imageGalleryViewController.collectionView?.isUserInteractionEnabled = false
                imageGalleryViewController.collectionView?.backgroundColor = UIColor.secondarySystemFill
            }
            imageGalleryViewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        }
    }

}
