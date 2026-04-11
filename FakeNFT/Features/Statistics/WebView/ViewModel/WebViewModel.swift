//
//  WebViewModel.swift
//  FakeNFT
//
//  Created by Timofei Kirichenko on 12.04.2026.

import Foundation

protocol WebViewModelProtocol {
    var url: URL { get }
    func close()
}

@MainActor
final class WebViewModel: @preconcurrency WebViewModelProtocol {
    
    let url: URL

    var onClose: (() -> Void)?
    
    init(url: URL) {
        self.url = url
    }
    
    func close() {
        onClose?()
    }
}
