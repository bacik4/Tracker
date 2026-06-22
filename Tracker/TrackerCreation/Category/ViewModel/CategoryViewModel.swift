//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Игорь Глебов on 22.06.2026.
//
import Foundation

final class CategoryViewModel {
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }
    
    private(set) var selectedCategoryTitle: String?
    
    var isEmpty: Bool {
        categories.isEmpty
    }
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
         selectedCategoryTitle: String? = nil ) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        self.categoryStore.delegate = self
    }
    
    func loadCategories() {
        do {
            categories = try categoryStore.categories()
        } catch {
            onError?(error)
        }
    }
    
    func addCategory(_ title: String) {
        do {
            try categoryStore.addCategory(title: title)
        } catch {
            onError?(error)
        }
    }
    
    func numberOfRows() -> Int {
        categories.count
    }

    func selectCategory(at index: Int) {
        let category = categories[index]
        selectedCategoryTitle = category.title
        
        onCategoriesChanged?()
        onCategorySelected?(category.title)
    }
    
    func cellViewModel(at index: Int) -> CategoryCellViewModel {
        let category = categories[index]
        
        return CategoryCellViewModel(title: category.title,
                                     isSelected: category.title == selectedCategoryTitle,
                                     isLast: index == categories.count - 1
        )
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        loadCategories()
    }
}
