//
//  ProfileDefaultViewModel.swift
//  Restauranties
//
//  Created by Karim Alweheshy on 11/24/20.
//

import Foundation
import Combine

final class ProfileDefaultViewModel {
    weak var delegate: HomeViewControllerDelegate?
    weak var view: ProfileView?

    private let strategy: ProfileViewModelStrategy
    private let settingsBackendService: SettingsBackendService
    private var user: UserAccount? { didSet { view?.reload() } }

    private var disposables = Set<AnyCancellable>()

    init(
        strategy: ProfileViewModelStrategy,
        settingsBackendService: SettingsBackendService
    ) {
        self.strategy = strategy
        self.settingsBackendService = settingsBackendService
        self.user = settingsBackendService.getMyUser()
    }
}

// MARK: - ProfileViewModel

extension ProfileDefaultViewModel: ProfileViewModel {
    var displayName: String? { user?.username}
    var userEmail: String? { user?.email }
    var isEmailVerified: Bool { user?.isVerified ?? false }
    var userType: String { strategy.userType }
    var isChangeUserRightContainerHidden: Bool { strategy.isChangeUserRightContainerHidden }
    var changeUserRightButtonText: String { strategy.changeUserRightButtonText }

    func refreshedViewModel() {
        settingsBackendService.getCurrentUserRight { [weak delegate] result in
            guard let userRight = try? result.get() else { return }
            switch userRight {
            case .admin: delegate?.didChangeUserPermission(.admin)
            case .restaurantOwner: delegate?.didChangeUserPermission(.restaurantOwner)
            case .rater: delegate?.didChangeUserPermission(.rater)
            case .unknown: fatalError()
            }
        }
    }

    func didTapChangeRightAction(completionHandler: @escaping () -> Void) {
        strategy.changeRightsCallableHTTPS(settingsBackendService)({ result in
            completionHandler()
        }).store(in: &disposables)
    }

    func didTapSignOut() {
        try? settingsBackendService.signOut()
    }
}
