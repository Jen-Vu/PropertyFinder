//
//  PropertiesViewController.swift
//  PropertyFinder
//
//  Created by Raul Brito on 21/02/19.
//  Copyright © 2019 Raul Brito. All rights reserved.
//

import UIKit
import Hero

class PropertiesViewController: BaseViewController, FilterViewControllerDelegate {
	
	// MARK: - Properties
	
	let searchController = UISearchController(searchResultsController: nil)
	
	var propertyViewModels = [PropertyViewModel]()
	var filteredPropertyViewModels = [PropertyViewModel]()
	var filteringByParameters = false
	
	@IBOutlet var tableView: UITableView!
	
	
	// MARK: - ViewController Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		fetchData()
		searchSetup()
    }
	
	
	// MARK: - Methods
	
	@objc func fetchData() {
		PropertyService.fecthProperties { (error, properties) in
			if let error = error {
				print(error.domain)
				return
			}
			
			self.tableView.hero.modifiers = [.cascade]
			self.propertyViewModels = properties.map({return PropertyViewModel(property: $0)})
			
			self.tableView.reloadData()
		}
	}
	
	func searchSetup() {
		searchController.searchResultsUpdater = self as UISearchResultsUpdating
		searchController.searchBar.placeholder = "Search"
		searchController.searchBar.setValue("Cancel", forKey:"_cancelButtonText")
		searchController.searchBar.tintColor = UIColor(red: 237/255, green: 79/255, blue: 63/255, alpha: 1)
		searchController.searchBar.backgroundColor = .white
		searchController.searchBar.barTintColor = .white
		
		if #available(iOS 11.0, *) {
			searchController.obscuresBackgroundDuringPresentation = false
			navigationItem.searchController = searchController
		}
	}
	
	func searchBarIsEmpty() -> Bool {
	  	return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func isFiltering() -> Bool {
		return (searchController.isActive && !searchBarIsEmpty()) || filteringByParameters
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredPropertyViewModels = propertyViewModels.filter {
			$0.name.lowercased().contains(searchText.lowercased())
		}

		tableView.reloadData()
	}
	
	func filter(by parameters: Filter) {
//		filteringByParameters = true
//
//		filteredPropertyViewModels = propertyViewModels.filter {
//			return parameters.propertyTypes.map({ (tagView) -> String in
//				return tagView.currentTitle ?? ""
//			}).contains($0.type) && $0.area > parameters.minArea && $0.area < parameters.maxArea
//		}
		
		tableView.reloadData()
	}
	
	@objc func filter(sender: UIButton) {
		UISelectionFeedbackGenerator().selectionChanged()
		performSegue(withIdentifier: "FilterSegue", sender: nil)
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let propertyVC = segue.destination as? PropertyViewController {
			propertyVC.propertyViewModel = sender as? PropertyViewModel
        }
		
        if let filterVC = segue.destination as? FilterViewController {
			filterVC.delegate = self
        }
	}

}


// MARK: - Extensions

extension PropertiesViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering() {
			return filteredPropertyViewModels.count
		}
		
		return propertyViewModels.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 258
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))

		let label = UILabel(frame: CGRect(x: 16, y: 0, width: view.frame.size.width, height: 40))
		label.text = "\(propertyViewModels.count) properties found"
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.textColor = .darkGray
		
		let filterButton = UIButton(frame: CGRect(x: view.frame.size.width - 50, y: 6, width: 25, height: 25))
		filterButton.setTitle("", for: .normal)
		filterButton.showsTouchWhenHighlighted = true
		filterButton.setTitleColor(.darkGray, for: .normal)
		filterButton.setTitleColor(.lightGray, for: .selected)
		filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
		filterButton.tintColor = .darkGray
		
		let filterIconImage = UIImage(named: "filter_icon")
		let tintedImage = filterIconImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
		filterButton.setImage(tintedImage, for: .normal)
		
		filterButton.addTarget(self, action: #selector(PropertiesViewController.filter(sender:)), for: .touchUpInside)

		headerView.backgroundColor = .white
		headerView.addSubview(label)
		headerView.addSubview(filterButton)

		return headerView
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyTableViewCell", for: indexPath) as? PropertyTableViewCell
		
		if isFiltering() {
			cell?.propertyViewModel = filteredPropertyViewModels[indexPath.row]
		} else {
			cell?.propertyViewModel = propertyViewModels[indexPath.row]
		}
		
		cell?.selectionStyle = .none
		cell?.selectedBackgroundView = UIView()
		
		return cell ?? UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if isFiltering() {
			performSegue(withIdentifier: "PropertySegue", sender: filteredPropertyViewModels[indexPath.row])
		} else {
			performSegue(withIdentifier: "PropertySegue", sender: propertyViewModels[indexPath.row])
		}
	}
}

extension PropertiesViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}
