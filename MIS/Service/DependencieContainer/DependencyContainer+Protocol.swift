//
//  DependencyContainerProtocol.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

protocol DependencyContainerProtocol {
    func makeMediaItemViewModel() -> MediaItemViewModel
    func makeMediaItemAddOrEditViewModel(_ mediaItemViewModel: MediaItemViewModel) -> MediaItemAddOrEditViewModel
    func makeSettingsViewModel() -> SettingsViewModel
}
