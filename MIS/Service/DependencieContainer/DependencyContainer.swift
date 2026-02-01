//
//  DependencyContainer.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

final class DependencyContainer: DependencyContainerProtocol {
    // MARK: - Lifecycle

    init(persistence: PersistenceControllerProtocol = PersistenceController()) {
        self.persistence = persistence
        let repository = MediaItemRepository(persistence: persistence)
        sharedMediaDataStore = SharedMediaDataStore(repository)
    }

    // MARK: - Internal

    func makeMediaItemViewModel() -> MediaItemViewModel {
        let repository = MediaItemRepository(persistence: persistence)
        return MediaItemViewModel(repository, sharedDataStore: sharedMediaDataStore)
    }

    func makeMediaItemAddOrEditViewModel(_ mediaItemViewModel: MediaItemViewModel) -> MediaItemAddOrEditViewModel {
        let repository = MediaItemRepository(persistence: persistence)
        return MediaItemAddOrEditViewModel(repository, mediaItemViewModel)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        let repository = SettingsRepository()
        return SettingsViewModel(repository)
    }

    // MARK: - Private

    private let persistence: PersistenceControllerProtocol
    private let sharedMediaDataStore: SharedMediaDataStore
}
