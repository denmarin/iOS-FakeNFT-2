import Foundation

enum CatalogLocalMockCollections {
    struct Template: Sendable {
        let id: String
        let name: String
        let coverImageName: String
        let description: String
        let authorName: String
        let nftNames: [String]
    }

    static let templates: [Template] = [
        Template(
            id: "peach",
            name: "Peach",
            coverImageName: "cover_peach",
            description: "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей.",
            authorName: "John Doe",
            nftNames: [
                "Archie",
                "Ruby",
                "Nacho",
                "Biscuit",
                "Daisy",
                "Susan",
                "Oreo",
                "Pixi",
                "Zoe",
                "Tater",
                "Art"
            ]
        ),
        Template(
            id: "blue",
            name: "Blue",
            coverImageName: "cover_blue",
            description: "Насыщенная голубая коллекция с сочными цветными акцентами.",
            authorName: "Nora Vale",
            nftNames: [
                "Bonnie",
                "Clover",
                "Loki",
                "Diana",
                "Ollie",
                "Sky"
            ]
        ),
        Template(
            id: "brown",
            name: "Brown",
            coverImageName: "cover_brown",
            description: "Глубокие коричневые оттенки и контрастные персонажи в винтажном стиле.",
            authorName: "Ivy Brooks",
            nftNames: [
                "Rosie",
                "Toast",
                "Bitsy",
                "Stella",
                "Charlie",
                "Iggy",
                "Emma",
                "Zeus"
            ]
        ),
        Template(
            id: "green",
            name: "Green",
            coverImageName: "cover_green",
            description: "Лёгкая зелёная серия с природными тонами и чистой композицией.",
            authorName: "Noah Palmer",
            nftNames: [
                "Lina",
                "Gwen",
                "Melissa",
                "Spring"
            ]
        ),
        Template(
            id: "gray",
            name: "Gray",
            coverImageName: "cover_gray",
            description: "Монохромная коллекция в серой гамме с яркими деталями персонажей.",
            authorName: "Ethan Moss",
            nftNames: [
                "Devin",
                "Lanka",
                "Bethany",
                "Dominique",
                "Grace",
                "Big",
                "Rocky",
                "Kaydan",
                "Chip",
                "Tucker",
                "Zac",
                "Lipton",
                "Flash",
                "Piper",
                "Butter",
                "Larson",
                "Arlena",
                "Josie",
                "Elliot"
            ]
        ),
        Template(
            id: "pink",
            name: "Pink",
            coverImageName: "cover_pink",
            description: "Яркая коллекция с акцентом на розовые оттенки и контрастные формы.",
            authorName: "Lina Cross",
            nftNames: [
                "Ariana",
                "Calder",
                "Cashew",
                "Charity",
                "Flower",
                "Jerry",
                "Lilo",
                "Lucy",
                "Milo",
                "Moose",
                "Oscar",
                "Patton",
                "Salena",
                "Rufus"
            ]
        ),
        Template(
            id: "beige",
            name: "Beige",
            coverImageName: "cover_beige",
            description: "Спокойная бежевая коллекция с мягкими акцентами и тёплой палитрой.",
            authorName: "Martha Lane",
            nftNames: [
                "Simba",
                "April",
                "Biscuit",
                "Bimbo",
                "Corbin",
                "Finn",
                "Melvin",
                "Lark",
                "Lucky",
                "Ralph",
                "Aurora",
                "Buster",
                "Salena",
                "Breena",
                "Cupid",
                "Nala",
                "Gus",
                "Dingo",
                "Ellsa",
                "Penny",
                "Whisper"
            ]
        ),
        Template(
            id: "white",
            name: "White",
            coverImageName: "cover_white",
            description: "Светлая минималистичная коллекция с акцентом на форму и фактуру.",
            authorName: "Olivia Reed",
            nftNames: [
                "Logan",
                "Vulcan",
                "Arielle",
                "Lumpy",
                "Barney",
                "Iron",
                "Paddy"
            ]
        )
    ]

    static func makeCollections() -> [CatalogCollection] {
        templates.map { template in
            CatalogCollection(
                id: template.id,
                name: template.name,
                coverImageName: template.coverImageName,
                nftIDs: template.nftNames.map { nftName in
                    makeNftID(collectionID: template.id, nftName: nftName)
                },
                description: template.description,
                authorName: template.authorName
            )
        }
    }

    static func nftName(from nftID: String, collectionID: String) -> String {
        let expectedPrefix = "\(collectionID)-"
        guard nftID.hasPrefix(expectedPrefix) else {
            return nftID
        }
        let slug = String(nftID.dropFirst(expectedPrefix.count))
        return slug
            .split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    static func makeImageURLs(collectionID: String, nftID: String) -> [URL] {
        let expectedPrefix = "\(collectionID)-"
        guard nftID.hasPrefix(expectedPrefix) else { return [] }
        let nameSlug = String(nftID.dropFirst(expectedPrefix.count))
        let directURLs = makeImageURLs(collectionID: collectionID, nftNameSlug: nameSlug)
        if !directURLs.isEmpty {
            return directURLs
        }

        guard let template = templates.first(where: { $0.id == collectionID }) else { return [] }
        for fallbackName in template.nftNames {
            let fallbackURLs = makeImageURLs(
                collectionID: collectionID,
                nftNameSlug: slugify(fallbackName)
            )
            if !fallbackURLs.isEmpty {
                return fallbackURLs
            }
        }
        return []
    }

    private static func makeNftID(collectionID: String, nftName: String) -> String {
        "\(collectionID)-\(slugify(nftName))"
    }

    private static func makeImageURLs(collectionID: String, nftNameSlug: String) -> [URL] {
        (1...3).compactMap { index in
            let resourceName = "nft_\(collectionID)_\(nftNameSlug)_\(index)"
            return Bundle.main.url(forResource: resourceName, withExtension: "png")
        }
    }

    private static func slugify(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted)
            .joined()
    }
}
