//
//  DependencyContainer.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

final class DependencyContainer: DependencyContainerProtocol {
    // MARK: - Internal

    func makeMediaItemViewModel() -> MediaItemViewModel {
        let repository = MediaItemRepository(persistence: persistence)
        return MediaItemViewModel(repository)
    }

    func makeMediaItemDetailViewModel(_ item: MediaItemDataForm) -> MediaItemDetailViewModel {
        let repository = MediaItemRepository(persistence: persistence)
        return MediaItemDetailViewModel(item, repository)
    }

    // MARK: - Private

    private let persistence = PersistenceController()
}
