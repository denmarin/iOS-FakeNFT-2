import Foundation

struct CatalogUpdateProfileLikesRequest: NetworkRequest {
    let ids: [String]

    var endpoint: URL? {
        CatalogRequestFactory.profileURL()
    }

    var httpMethod: HttpMethod {
        .put
    }

    var dto: Dto? {
        CatalogActionsUpdateDTO(field: .likes, ids: ids)
    }
}
