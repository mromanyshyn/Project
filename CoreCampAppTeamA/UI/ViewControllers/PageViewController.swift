//
//  PageViewController.swift
//  CoreCampAppTeamA
//
//  Created by Max on 31.10.2020.
//

import UIKit

class PageViewController: UIPageViewController {
    
    weak var mDelegate: PageViewControllerDelegate?
    
    private let scrollView = UIScrollView()
    
    func updateView(segment: String) {
    }
    
    var currentIndex:Int {
        get {
            return orderedViewControllers.firstIndex(of: self.viewControllers!.first!)!
        }
        set {
            guard newValue >= 0,
                  newValue < orderedViewControllers.count else {
                return
            }
            let vc = orderedViewControllers[newValue]
            let direction:UIPageViewController.NavigationDirection = newValue > currentIndex ? .forward : .reverse
            self.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        }
    }
    
    private func hpvc() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = HomeScreenViewController()
        controller = storyboard.instantiateViewController(withIdentifier: "HomeScreenViewController") as! HomeScreenViewController
        controller.pageViewController = self
        return  controller
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            hpvc(),
            self.newViewController(name: "Random", storyboard: "Randomizer"),
            self.newViewController(name: "Wheel", storyboard: "FortuneWheel"),
            self.newViewController(name: "Recruit", storyboard: "Recruiters"),
            self.newViewController(name: "Speaker", storyboard: "Speakers")]
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        mDelegate?.pageViewController(PageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    /**
     Scrolls to the next view controller.
     */
    
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
           let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
           let currentIndex = orderedViewControllers.firstIndex(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }

    private func newViewController(name: String, storyboard: String) -> UIViewController {
        return UIStoryboard(name: storyboard, bundle: nil) .
            instantiateViewController(withIdentifier: "\(name)")
        
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'mDelegate' of the new index.
                            self.notifymDelegateOfNewIndex()
                           })
    }

    /**
     Notifies '_mDelegate' that the current page index was updated.
     */
    private func notifymDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: firstViewController) {
            mDelegate?.pageViewController(PageViewController: self, didUpdatePageCount: index)
        }
    }
    
}
// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
    }
}
protocol PageViewControllerDelegate: class {
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func pageViewController(PageViewController: PageViewController,
                            didUpdatePageCount count: Int)
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageViewController(PageViewController: PageViewController,
                            didUpdatePageIndex index: Int)
}
