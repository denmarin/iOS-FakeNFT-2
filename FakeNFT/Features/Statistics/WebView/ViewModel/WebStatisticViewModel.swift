//
//  WebViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.

import Foundation

protocol WebStatisticViewModelProtocol {
    var url: URL { get }
    func close()
}

@MainActor
final class WebStatisticViewModel: @preconcurrency WebStatisticViewModelProtocol {
    
    let url: URL

    var onClose: (() -> Void)?
    
    init(url: URL) {
        self.url = url
    }
    
    func close() {
        onClose?()
    }
}
