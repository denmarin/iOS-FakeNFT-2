import Foundation

struct NFTGetRequest: NetworkRequest{
    var id: String
    var endpoint: URL? { URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")}
}
