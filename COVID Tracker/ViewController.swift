//
//  ViewController.swift
//  COVID Tracker
//
//  Created by Shivam Maheshwari on 03/06/23.
//

import UIKit

class ViewController: UIViewController {
    
    private var scope: APICaller.DataScope = .national

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "COVID Cases"
        createFilterButton()
        fetchData()
    }
    
    private func fetchData() {
        APICaller.shared.getCovidData(for: scope) { result in
            switch result {
            case .success(let data):
                break
            case .failure(let error):
                dump(error)
            }
        }
    }

    private func createFilterButton() {
        let buttonTitle: String = {
            switch scope {
            case .national:
                return "National"
            case .state(let state):
                return state.name ?? ""
            }
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .done, target: self, action: #selector(didTapFilter))
    }
    
    @objc private func didTapFilter() {
        let vc = FilterViewController()
        vc.completion = { [weak self] state in
            self?.scope = .state(state)
            self?.fetchData()
            self?.createFilterButton()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }

}

