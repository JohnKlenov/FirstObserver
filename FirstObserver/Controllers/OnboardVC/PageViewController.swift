//
//  PageViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//

import UIKit


protocol PageViewControllerDelegate: AnyObject {
    func nextPage(_ index:Int)
}

class PageViewController: UIPageViewController {
    
    let presentScreenContents = ["Как правило дорогой товар не нуждается в гарантиях качества, но как найти качественный товар по средней и низкой цене?", "Observer исследует бренды среднего ценового сегмента и рекомендует товары с потенциалом качества!", "Observer это навигатор по торговым центрам в твоем кармане!"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let contentPageVC = showViewControllerAtIndex(0) {
            
            contentPageVC.pageVC = self
            setViewControllers([contentPageVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func showViewControllerAtIndex(_ index: Int) -> ContentPageViewController? {
        
        guard index >= 0 && index < presentScreenContents.count else {
            
            // save true for UserDefaults if index < presentScreenContents.count
            
            HomeViewController.userDefaults.set(true, forKey: "appAlreadeSeen")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
            
            return nil
        }
        
        guard let contentPageViewController = storyboard?.instantiateViewController(withIdentifier: "ContentPageViewController") as? ContentPageViewController else { return nil }
        contentPageViewController.presenText = presentScreenContents[index]
        contentPageViewController.numberOfPages = presentScreenContents.count
        contentPageViewController.currentPage = index
        
        return contentPageViewController
    }
    
    deinit {
        print("PageViewController is dead!")
    }
}




extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var pageNumber = (viewController as! ContentPageViewController).currentPage
        guard pageNumber > 0 else { return nil }
        pageNumber -= 1
        return showViewControllerAtIndex(pageNumber)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var pageNumber = (viewController as! ContentPageViewController).currentPage
        pageNumber += 1
        return showViewControllerAtIndex(pageNumber)
    }

}

extension PageViewController: PageViewControllerDelegate {
    
    func nextPage(_ index: Int) {
        if let nextPageVC = showViewControllerAtIndex(index) {
            nextPageVC.pageVC = self
            setViewControllers([nextPageVC], direction: .forward, animated: true, completion: nil)
        }
    }

}

