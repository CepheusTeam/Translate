/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import ReSwift

private struct CategoriesReducerConstants {
  static let userDefaultsCategoryKey = "currentCategoryKey"
}

private typealias C = CategoriesReducerConstants

func categoriesReducer(action: Action, state: CategoriesState?) -> CategoriesState {
  var currentCategory: Category = .pop

  if let loadedCategory = getCurrentCategoryStateFromUserDefaults() {
    currentCategory = loadedCategory
  }
  var state = state ?? CategoriesState(currentCategory: currentCategory)
  
  switch action {
  case let changeCategoryAction as ChangeCategoryAction:
    let newCategory = state.categories[changeCategoryAction.categoryIndex]
    state.currentCategorySelected = newCategory
    saveCurrentCategoryStateToUserDefaults(category: newCategory)
    
  default: break
  }
  
  return state
}

private func getCurrentCategoryStateFromUserDefaults() -> Category? {
  let userDefaults = UserDefaults.standard
  let rawValue = userDefaults.string(forKey: C.userDefaultsCategoryKey)
  if let rawValue = rawValue {
    return Category(rawValue: rawValue)
  } else {
    return nil
  }
}

private func saveCurrentCategoryStateToUserDefaults(category: Category) {
  let userDefaults = UserDefaults.standard
  userDefaults.set(category.rawValue, forKey: C.userDefaultsCategoryKey)
  userDefaults.synchronize()
}
