import Foundation

struct OrderUpdateRequest: NetworkRequest {
    let nfts: [String]
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var httpMethod: HttpMethod { .put }
    
    var dto: Dto? {
        OrderUpdateDto(nfts: nfts)
    }
}

private struct OrderUpdateDto: Dto {
    let nfts: [String]

    func asDictionary() -> [String: String] {
        ["nfts": nfts.isEmpty ? "null" : nfts.joined(separator: ",")]
    }
}
