//
//  ContentPageViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//



import UIKit

class ContentPageViewController: UIViewController {
    
    
    @IBOutlet weak var onboardingLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var getStartedButton: UIButton!
    
    weak var pageVC:PageViewControllerDelegate?
    var presenText = ""
    var currentPage = 0
    var numberOfPages = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 10
        getStartedButton.layer.cornerRadius = 10
        
        getStartedButton.isHidden = true
        hiddenNextButton()
        onboardingLabel.text = presenText
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage
        
    }
    

    @IBAction func goHomeVC(_ sender: Any) {
        currentPage += 1
        pageVC?.nextPage(currentPage)
    }
    
    
    @IBAction func nextPageVC(_ sender: Any) {
        currentPage += 1
        pageVC?.nextPage(currentPage)
    }
    
    func hiddenNextButton() {
        if currentPage == 2 {
            nextButton.isHidden = true
            getStartedButton.isHidden = false
        }
    }
    
    deinit {
        print("ContentPageViewController dead!")
    }
    
}
