import Foundation

enum MockData {
    static let nfts: [Nft] = [
        Nft(
            id: "1",
            images: [URL(string: "local://April")!],
            name: "April",
            price: 1.78,
            rating: 3,
            authorId: "1",
            description: "",
            website: URL(string: "https://yandex.ru")!
        ),
        Nft(
            id: "2",
            images: [URL(string: "local://Greena")!],
            name: "Greena",
            price: 1.78,
            rating: 4,
            authorId: "2",
            description: "",
            website: URL(string: "https://yandex.ru")!
        ),
        Nft(
            id: "3",
            images: [URL(string: "local://Spring")!],
            name: "Spring",
            price: 1.78,
            rating: 5,
            authorId: "3",
            description: "",
            website: URL(string: "https://yandex.ru")!
        )
    ]
}
