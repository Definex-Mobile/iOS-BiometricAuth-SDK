import Foundation
import MachO

/// Internal detector for runtime security risks.
@available(iOS 11.0, macOS 10.13.2, *)
internal final class SecurityRiskDetector {
    
    // MARK: - Internal Methods
    
    /// Assesses all security risks and returns the result.
    func assessAllRisks() -> SecurityRiskResult {
        var detectedRisks: Set<SecurityRisk> = []
        
        if isJailbroken() {
            detectedRisks.insert(.jailbreak)
        }
        
        if isSimulator() {
            detectedRisks.insert(.simulator)
        }
        
        if isDebuggerAttached() {
            detectedRisks.insert(.debugger)
        }
        
        if isHookingDetected() {
            detectedRisks.insert(.hooking)
        }
        
        return SecurityRiskResult(detectedRisks: detectedRisks)
    }
    
    // MARK: - Private Detection Methods
    
    private func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // Check for common jailbreak files
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // Check if we can write to system directories (should fail on non-jailbroken)
        let testPath = "/private/jailbreak_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // Expected behavior on non-jailbroken device
        }
        
        return false
        #endif
    }
    
    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        
        if result != 0 {
            return false
        }
        
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    private func isHookingDetected() -> Bool {
        // Check for suspicious loaded dylibs (Frida, Cycript, etc.)
        let suspiciousDylibs = [
            "frida",
            "cycript",
            "substrate",
            "substitute"
        ]
        
        for i in 0..<_dyld_image_count() {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName).lowercased()
                
                for suspicious in suspiciousDylibs {
                    if name.contains(suspicious) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}

