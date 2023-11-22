//
//  BiometryService.swift
//  freerasp
//
//  Created by Tomas Psota on 22.11.2023.
//

import Foundation
import LocalAuthentication

class BiometryService {

    private static var notEnrolledErrors: [LAError.Code] {
        [LAError.biometryNotEnrolled]
    }
    private static var notAvailableErrors: [LAError.Code] {
        [LAError.biometryNotAvailable]
    }

    static func hasBiometry() -> String {
        let laContext = LAContext()
        var error: NSError?
        let _ = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if (errorHasOneOfCodes(errorOpt: error, invalidCodes: notAvailableErrors)) {
            return "NOT_AVAILABLE"
        }
        if (errorHasOneOfCodes(errorOpt: error, invalidCodes: notEnrolledErrors)) {
            return "NONE_ENROLLED"
        }
        return "ACTIVE"
    }

    private static func errorHasOneOfCodes(errorOpt: NSError?, invalidCodes: [LAError.Code]) -> Bool {
        guard let error = errorOpt else {
            return false
        }

        for invalidError in invalidCodes where error.code == invalidError.rawValue {
            return true
        }

        return false
    }
}
