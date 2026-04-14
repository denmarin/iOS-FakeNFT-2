import Foundation

struct OrderUpdateRequest: NetworkRequest {
    let nfts: [String]
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var httpMethod: HttpMethod { .put }
    
    var dto: Encodable? {
        nfts.map { "nfts=\($0)" }.joined(separator: "&")
    }
}
