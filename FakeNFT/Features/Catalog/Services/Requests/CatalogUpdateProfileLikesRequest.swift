import Foundation

struct CatalogUpdateProfileLikesRequest: NetworkRequest {
    let ids: [String]

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }

    var httpMethod: HttpMethod {
        .put
    }

    var dto: Dto? {
        CatalogActionsUpdateDTO(field: .likes, ids: ids)
    }
}
