//
//  StatisticsViewController.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 26.03.2026.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .white
//        table.dataSource = self
//        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.register(StatisticUserCell.self, forCellReuseIdentifier: StatisticUserCell.reuseIdentifier)
        
        return table
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        
        
        return label
    }()
    
    
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
