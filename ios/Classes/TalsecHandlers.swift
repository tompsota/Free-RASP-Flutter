import TalsecRuntime

/// Extension with submits events to plugin
extension SecurityThreatCenter: SecurityThreatHandler, SecurityThreatNotifier {
    
    public func threatDetected(_ securityThreat: TalsecRuntime.SecurityThreat) {
        SwiftFreeraspPlugin.instance.submitEvent(securityThreat)
    }
    
    public func initialChecksDone() {
        SwiftFreeraspPlugin.instance.initialchecksDone = true
        SwiftFreeraspPlugin.instance.initialChecksDoneResult?(true)
        SwiftFreeraspPlugin.instance.submitEvent("checksCompleted")
    }
}

/// An extension to unify callback names with Flutter ones.
extension SecurityThreat {
    var callbackIdentifier: String {
        switch self {
        case .signature:
            return "appIntegrity"
        case .jailbreak:
            return "privilegedAccess"
        case .debugger:
            return "debug"
        case .runtimeManipulation:
            return "hooks"
        case .passcode:
            return "passcode"
        case .passcodeChange:
            return "passcodeChange"
        case .simulator:
            return "simulator"
        case .missingSecureEnclave:
            return "secureHardwareNotAvailable"
        case .deviceChange:
            return "deviceBinding"
        case .deviceID:
            return "deviceId"
        case .unofficialStore:
            return "unofficialStore"
        @unknown default:
            return "unknown"
        }
    }
}
