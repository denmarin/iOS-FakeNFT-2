import Foundation

struct CatalogUpdateOrderNftsRequest: NetworkRequest {
    let ids: [String]

    var endpoint: URL? {
        CatalogRequestFactory.orderURL()
    }

    var httpMethod: HttpMethod {
        .put
    }

    var dto: Dto? {
        CatalogActionsUpdateDTO(field: .nfts, ids: ids)
    }
}
