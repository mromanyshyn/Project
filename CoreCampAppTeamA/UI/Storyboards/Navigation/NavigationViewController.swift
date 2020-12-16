//
//  NavigationViewController.swift
//  CoreCampAppTeamB
//
//  Created by Max on 10/11/2020.
//
import UIKit

class NavigationViewController: UIViewController {
    
    //  MARK: -IBOutlets and varibiables
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var navigationCollection: UICollectionView!
    @IBOutlet weak var avengaButton: UIButton!
    @IBOutlet var contentView: UIView!
    
   static var viewControllers = [
        UIStoryboard(name: "Randomizer", bundle: nil).instantiateViewController(withIdentifier: "Random"),
        UIStoryboard(name: "FortuneWheel", bundle: nil).instantiateViewController(withIdentifier: "Wheel"),
        UIStoryboard(name: "Recruiters", bundle: nil).instantiateViewController(withIdentifier: "Recruit"),
        UIStoryboard(name: "Speakers", bundle: nil).instantiateViewController(withIdentifier: "Speaker"),
        UIStoryboard(name:"Settings", bundle:
                        nil).instantiateViewController(withIdentifier:"Settings")]
    
    let pageNames = ["Randomiser", "FortuneWheel", "Recruiters", "Speakers","Settings"]
    let hues = [UIColor(named: "randomizer_hue"),
                  UIColor(named: "fortunewheel_hue"),
                  UIColor(named: "recruiters_hue"),
                  UIColor(named: "speakers_hue"),
                  UIColor(named: "settings_hue")]
    var currentViewControllerIndex = 0
    let navigationPageViewController = UIStoryboard(name: "NavigationScreen", bundle: nil).instantiateViewController(identifier: "navpagevc") as? NavigationPageViewController

    // MARK: -Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationPageView()
        setupProperties()
        setupNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let selectedIndexPath = IndexPath(row: currentViewControllerIndex, section: 0)
        navigationCollection.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredVertically)
    }
    
    func setupNavigation(){
        navigationCollection.delegate = self
        navigationCollection.dataSource = self
    }
    
    func setupProperties(){
        avengaButton.imageView?.contentMode = .scaleAspectFit
        headerView.layoutSubviews()
    }
    
    //MARK: - Navigation Config
    
    func configureNavigationPageView(){
        guard let navigationPageViewController = navigationPageViewController else { return }
        
        navigationPageViewController.delegate = self
        navigationPageViewController.dataSource = self
        
        addChild(navigationPageViewController)
        navigationPageViewController.didMove(toParent: self)
        
        navigationPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(navigationPageViewController.view)
        
        NSLayoutConstraint.activate([
            navigationPageViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            navigationPageViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            navigationPageViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            navigationPageViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        navigationPageViewController.setViewControllers([NavigationViewController.viewControllers[currentViewControllerIndex]], direction: .forward, animated: true)
    }
    
    //MARK: - Button Actions
    
    @IBAction func avengeButtonFunc(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

    //MARK: - UIPageView Delegate & DataSource

extension NavigationViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var currentIndex = NavigationViewController.viewControllers.firstIndex(of: viewController) else { return nil }
        currentViewControllerIndex = currentIndex
        if currentIndex <= 0  {
            return nil
        }
        currentIndex -= 1
        return NavigationViewController.viewControllers[currentIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var currentIndex = NavigationViewController.viewControllers.firstIndex(of: viewController) else { return nil }
        currentViewControllerIndex = currentIndex
        if currentIndex >= NavigationViewController.viewControllers.count-1 {
            return nil
        }
        currentIndex += 1
        return NavigationViewController.viewControllers[currentIndex]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return NavigationViewController.viewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        currentViewControllerIndex = NavigationViewController.viewControllers.firstIndex(of: pendingViewControllers[0]) ?? 0
        let selectedIndexPath = IndexPath(row: currentViewControllerIndex, section: 0)
        navigationCollection.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .centeredVertically)
    }
}

    //MARK: - UICollectionView Delegate & DataSource
extension NavigationViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NavigationViewController.viewControllers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "NavigationCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as!  NavigationCell
        cell.screenNameLabel.text = pageNames[indexPath.row]
        cell.selectedColor = hues[indexPath.row]
        cell.screenNameLabel.font = UIFont(name: "TTHoves-Regular", size: 18)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentViewControllerIndex > indexPath.row{
            navigationPageViewController?.setViewControllers([NavigationViewController.viewControllers[indexPath.row]], direction: .reverse, animated: true)
        }else{
            navigationPageViewController?.setViewControllers([NavigationViewController.viewControllers[indexPath.row]], direction: .forward, animated: true)
        }
        currentViewControllerIndex = indexPath.row
    }
}
