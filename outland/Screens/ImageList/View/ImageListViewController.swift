//
//  ImageListViewController.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

class ImageListViewController: UIViewController {

    static func make() -> ImageListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ImageListViewController.objectName) as! ImageListViewController
        let presenter = ImageListPresenter(network: Network(), view: controller)
        controller.presenter = presenter
        return controller
    }

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    @IBOutlet weak var searchbar: UISearchBar!

    @IBOutlet weak var searchQueriesTableView: UITableView!

    @IBOutlet weak var imageListTableView: UITableView! {
        didSet {
            imageListTableView.refreshControl = refreshControl
        }
    }

    var presenter: ImageListPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.onViewDidLoad()
    }

    @objc func onPullToRefresh() {
        presenter.onPullToRefresh(searchQuery: searchbar.text)
    }
}

// MARK: - SearchBar

extension ImageListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return presenter.onSearchBarShouldBeginEditing()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.onSearchButtonTapped(searchQuery: searchbar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.onCancelSearchButtonTapped()
    }
}

// MARK: - TableView

extension ImageListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == imageListTableView {
            return presenter.getNumberOfRowsForImageListTableView()
        } else {
            return presenter.getNumberOfRowsForSearchQueriesTableView()
        }
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == imageListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.objectName) as! ImageListCell
            if let imageDetail = presenter.getImageDetail(at: indexPath) {
                cell.setImageDetail(imageDetail)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchQueryCell.objectName) as! SearchQueryCell
            if let searchQuery = presenter.getSearchQuery(at: indexPath) {
                cell.setSearchQuery(searchQuery)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == imageListTableView {
            if view.frame.height > view.frame.width {
                return tableView.frame.height / 2.5
            } else {
                return tableView.frame.height / 1.5
            }
        } else {
            return 52
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == imageListTableView {
            presenter.onDidSelectImageListRow(at: indexPath)
        } else {
            presenter.onDidSelectSearchQueryRow(at: indexPath)
        }
    }
}

// MARK: - ImageListViewProtocol

extension ImageListViewController {

    func toggleCachedSearchQueries(hidden: Bool) {
        searchQueriesTableView.isHidden = hidden
    }

    func toggleSearchbarKeyboard(hidden: Bool) {
        if hidden {
            searchbar.resignFirstResponder()
        } else {
            searchbar.becomeFirstResponder()
        }
    }

    func toggleLoadingIndicator(hidden: Bool) {
        if hidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                self.imageListTableView.refreshControl?.endRefreshing()
            }
        } else {
            imageListTableView.refreshControl?.beginRefreshing()
        }
    }

    func toggleCancelSearchButton(hidden: Bool) {
        searchbar.showsCancelButton = !hidden
    }

    func showEmptyStateAlert() {
        let alert = UIAlertController(title: "Sorry, we couldn't find any results",
                                      message: "Try with a different search",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presenter.onEmptyStateAlertDismissed()
        })

        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }

    func replaceSearchBarText(_ newText: String?) {
        searchbar.text = newText
    }

    func showErrorAlert(error: NetworkError) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func reloadImageListTableView() {
        imageListTableView.reloadData()
    }

    func reloadSearchQueriesTableView() {
        searchQueriesTableView.reloadData()
    }

    func configureDelegatesAndDataSources() {
        imageListTableView.delegate = self
        imageListTableView.dataSource = self

        searchQueriesTableView.delegate = self
        searchQueriesTableView.dataSource = self

        searchbar.delegate = self
    }

    func registerCells() {
        let imageListCell = UINib(nibName: ImageListCell.objectName, bundle: nil)
        imageListTableView.register(imageListCell, forCellReuseIdentifier: ImageListCell.objectName)

        let searchQueryCell = UINib(nibName: SearchQueryCell.objectName, bundle: nil)
        searchQueriesTableView.register(searchQueryCell, forCellReuseIdentifier: SearchQueryCell.objectName)
    }

    func showFullSizeImageDetail(_ imageDetail: ImageDetail) {
        let controller = ImageDetailViewController.make(imageDetail: imageDetail, onDismiss: { [weak self] updatedImageDetail in
            guard let self = self else { return }
            self.presenter.onImageDetailControllerDismissed(updatedImageDetail: updatedImageDetail)
        })
        present(controller, animated: true, completion: nil)
    }
}
