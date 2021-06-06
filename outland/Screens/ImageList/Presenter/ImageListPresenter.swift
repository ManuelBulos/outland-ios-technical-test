//
//  ImageListPresenter.swift
//  outland
//
//  Created by Manuel on 04/06/21.
//

import UIKit

class ImageListPresenter {

    let network: Network

    let cachedSearchResultsLimit: Int = 3

    lazy var cachedSearchResults: NSCache<NSString, ImageList> = {
        let cache = NSCache<NSString, ImageList>()
        cache.countLimit = cachedSearchResultsLimit
        return cache
    }()

    private(set) var imageList: ImageList = ImageList()

    private(set) weak var view: ImageListViewController?

    required init(network: Network, view: ImageListViewController) {
        self.network = network
        self.view = view
    }

    func onViewDidLoad() {
        view?.registerCells()
        view?.configureDelegatesAndDataSources()
        onSearchButtonTapped(searchQuery: "")
    }

    func onCancelSearchButtonTapped() {
        view?.toggleCancelSearchButton(hidden: true)
        view?.toggleCachedSearchQueries(hidden: true)
        onSearchButtonTapped(searchQuery: "")
    }

    func onPullToRefresh(searchQuery: String?) {
        onSearchButtonTapped(searchQuery: searchQuery ?? "")
    }

    func onSearchBarShouldBeginEditing() -> Bool {
        view?.toggleCancelSearchButton(hidden: false)
        view?.toggleCachedSearchQueries(hidden: false)
        view?.reloadSearchQueriesTableView()
        return true
    }

    func onSearchButtonTapped(searchQuery: String?) {
        let searchQuery = searchQuery ?? ""

        // Make sure whatever query is sent to the server is represented on the searchbar
        view?.replaceSearchBarText(searchQuery)

        // Only show cancel button if search query is not empty
        if !searchQuery.isEmpty {
            view?.toggleCancelSearchButton(hidden: false)
        }

        // Hide cached search query list
        view?.toggleCachedSearchQueries(hidden: true)

        // Hide keyboard
        view?.toggleSearchbarKeyboard(hidden: true)

        // Show loading indicator
        view?.toggleLoadingIndicator(hidden: false)

        // Use cache result if available
        if let cachedImageList = self.cachedSearchResults.object(forKey: NSString(string: searchQuery)) {
            // Hide loading indicator
            self.view?.toggleLoadingIndicator(hidden: true)

            // Save data to be in memory
            self.imageList = cachedImageList

            // Reload data
            self.view?.reloadImageListTableView()
        } else {
            fetchImageList(searchQuery: searchQuery) { [weak self] result in
                guard let self = self else { return }

                // Hide loading indicator
                self.view?.toggleLoadingIndicator(hidden: true)

                switch result {
                case .success(let imageList):
                    // Save data to be in memory
                    self.imageList = imageList

                    // Reload data
                    self.view?.reloadImageListTableView()

                    if imageList.hits?.isEmpty == true {
                        // Show empty state alert
                        self.view?.showEmptyStateAlert()
                    } else {
                        // Only cache data if hits array is not empty
                        self.cachedSearchResults.setObject(imageList, forKey: NSString(string: searchQuery))

                        // Only store search query to user defaults if search query is not empty
                        if !searchQuery.isEmpty {
                            self.storeSearchQuery(searchQuery)
                            // Update search queries table view
                            self.view?.reloadSearchQueriesTableView()
                        }
                    }

                case .failure(let error):
                    // Show error
                    self.view?.showErrorAlert(error: error)
                }
            }
        }
    }

    func onEmptyStateAlertDismissed() {
        view?.toggleSearchbarKeyboard(hidden: false)
        view?.replaceSearchBarText(nil)
    }

    func onDidSelectImageListRow(at indexPath: IndexPath) {
        guard let imageDetail = getImageDetail(at: indexPath) else {
            return
        }

        view?.showFullSizeImageDetail(imageDetail)
    }

    func onDidSelectSearchQueryRow(at indexPath: IndexPath) {
        guard let searchQuery = getSearchQuery(at: indexPath) else {
            return
        }

        onSearchButtonTapped(searchQuery: searchQuery)
    }

    func onImageDetailControllerDismissed(updatedImageDetail: ImageDetail) {
        guard let index = imageList.hits?.firstIndex(where: {$0.id == updatedImageDetail.id}) else { return }
        imageList.hits?[index] = updatedImageDetail
        view?.reloadImageListTableView()
    }

    func getImageDetail(at indexPath: IndexPath) -> ImageDetail? {
        guard let hits = imageList.hits, hits.indices.contains(indexPath.row) else {
            return nil
        }

        return hits[indexPath.row]
    }

    func getNumberOfRowsForImageListTableView() -> Int {
        return imageList.hits?.count ?? 0
    }

    func getNumberOfRowsForSearchQueriesTableView() -> Int {
        return getStoredSearchQueries()?.count ?? 0
    }

    func getSearchQuery(at indexPath: IndexPath) -> String? {
        guard let searchQueries = getStoredSearchQueries(), searchQueries.indices.contains(indexPath.row) else {
            return nil
        }

        return searchQueries[indexPath.row]
    }

}

// MARK: - Business Logic

extension ImageListPresenter {
    internal func fetchImageList(searchQuery: String?,
                                 completion: @escaping (Result<ImageList, NetworkError>) -> Void) {
        network.execute(Endpoint.imageList(searchQuery), completion: completion)
    }

    internal func storeSearchQuery(_ searchQuery: String) {
        // User defaults singleton
        let userDefaults = UserDefaults.standard
        let key = "searchQueries"

        // Get array from user defaults
        if var storedSearchQueries = userDefaults.value(forKey: key) as? [String] {

            // Pop first element if cache limit has been reached
            if storedSearchQueries.count == cachedSearchResultsLimit {
                storedSearchQueries = Array(storedSearchQueries.dropFirst())
            }

            // Add new element
            storedSearchQueries.append(searchQuery)

            // Store array in user defaults, reversed
            userDefaults.setValue(storedSearchQueries, forKey: key)
        } else {
            // Store array in user defaults
            userDefaults.setValue([searchQuery], forKey: key)
        }
    }

    internal func getStoredSearchQueries() -> [String]? {
        // User defaults singleton
        let userDefaults = UserDefaults.standard
        let key = "searchQueries"
        let storedSearchQueries = userDefaults.value(forKey: key) as? [String]
        return storedSearchQueries?.reversed()
    }
}
