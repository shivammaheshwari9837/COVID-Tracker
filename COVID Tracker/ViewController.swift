//
//  ViewController.swift
//  COVID Tracker
//
//  Created by Shivam Maheshwari on 03/06/23.
//

import UIKit
import Charts

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource {
    
    private var scope: APICaller.DataScope = .national
    
    private var dayData: [DayData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.createGraph()
            }
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "COVID Cases"
        createFilterButton()
        configureTable()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.frame = view.bounds
    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchData() {
        APICaller.shared.getCovidData(for: scope) { [weak self] result in
            switch result {
            case .success(let dayData):
                self?.dayData = dayData
            case .failure(let error):
                dump(error)
            }
        }
    }
    
    private func createGraph() {
        let headerView = UIView(frame: .init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        
        let set = dayData.prefix(20)
        var entries: [BarChartDataEntry] = []
        for index in 0..<set.count {
            let data = set[index]
            entries.append(.init(x: Double(index), y: Double(data.count ?? 0)))
        }
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.joyful()
        let chartData = BarChartData.init(arrayLiteral: dataSet)
        
        let barChartView = BarChartView.init(frame: .init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        barChartView.data = chartData
        
        headerView.addSubview(barChartView)
        tableView.tableHeaderView = headerView
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = self.dayData[indexPath.row]
        cell.textLabel?.text = createText(with: data)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayData.count
    }
    
    private func createText(with data: DayData) -> String? {
        guard let count = data.count else {
            return nil
        }
        let dateString = DateFormatter.prettyFormatter.string(from: data.date ?? Date())
        return "\(dateString): \(count)"
    }
}

