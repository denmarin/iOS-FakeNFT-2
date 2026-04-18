//
//  WebViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.

import Foundation

@MainActor
protocol WebStatisticViewModelProtocol {
    var url: URL { get }
    func close()
}

final class WebStatisticViewModel: WebStatisticViewModelProtocol {
    
    let url: URL

    var onClose: (() -> Void)?
    
    init(url: URL) {
        self.url = url
    }
    
    func close() {
        onClose?()
    }
}
