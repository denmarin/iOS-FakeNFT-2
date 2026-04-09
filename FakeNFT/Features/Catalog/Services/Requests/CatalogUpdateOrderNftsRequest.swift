import Foundation

struct CatalogUpdateOrderNftsRequest: NetworkRequest {
    let ids: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var httpMethod: HttpMethod {
        .put
    }

    var dto: Dto? {
        CatalogActionsUpdateDTO(field: .nfts, ids: ids)
    }
}
