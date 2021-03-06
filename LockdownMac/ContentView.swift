//
//  ContentView.swift
//  Lockdown Mac
//
//  Created by Johnny Lin on 12/2/19.
//  Copyright © 2019 Confirmed. All rights reserved.
//

import SwiftUI
import AppKit
import NetworkExtension
import NEKit
import os.log
import PromiseKit
import CocoaLumberjackSwift

let kHasAgreedToFirewallPrivacyPolicy = "kHasAgreedToFirewallPrivacyPolicy"

struct ContentView: View {
    
    @ObservedObject var firewallState = TunnelState()
    @ObservedObject var vpnState = TunnelState()
    
    @State private var showError: Bool = false
    @State private var showMenu: Bool = false
    @State private var showViewLog: Bool = false
    @State private var showBlockList: Bool = false
    @State private var showWhitelist: Bool = false
    @State private var showSetRegion: Bool = false
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    @State private var showingPrivacyPolicyAlert = false
    
    @State private var showEmailLogin: Bool = false
    
    func anyPopoverShowing() -> Bool {
        // swiftUI bug workaround - clicking from 1 popover to another sometimes breaks popovers
        return (
            showError == true ||
            showMenu == true ||
            showViewLog == true ||
            showBlockList == true ||
            showWhitelist == true ||
            showSetRegion == true ||
            showEmailLogin == true
        )
    }
    
    var body: some View {
        
        VStack(spacing: 12) {

            ZStack(alignment: .leading) {
                Button(
                    action: {
                        self.showMenu = true
                }) {
                    Text("􀌇")
                        .font(sfProRoundedSemiBold28)
                        .foregroundColor(Color.confirmedBlue)
                }
                .frame(width: 36, height: 20, alignment: .leading)
                .padding(.top, 12)
                .buttonStyle(BlankButtonStyle())
                .popover(isPresented: self.$showMenu) {
                    MenuView()
                }
                .disabled(anyPopoverShowing())
                .zIndex(100)
                Text("Lockdown")
                .multilineTextAlignment(.center)
                .frame(width: viewWidth, height: 30)
                .font(cFontHeader)
                .padding(.top, 12)
                .popover(isPresented: $showError) {
                    VStack {
                        Text(self.errorTitle)
                            .font(cFontTitle)
                            .frame(minWidth: 0, maxWidth: .infinity)
                        Text(self.errorMessage)
                            .font(cFontRegularSmall)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical, 12)
                        Button(action: {
                            self.showError = false
                        }) {
                            Text("Dismiss")
                                .font(cFontSubtitle2)
                                .frame(height: 40)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(GrayButtonStyle())
                        .cornerRadius(8)
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .padding(14)
                    .frame(width: 340)
                }
                Button(
                    action: {
                        NotificationCenter.default.post(name: .togglePopover, object: nil)
                }) {
                    Text("Hide").font(cFontSmall)
                }
                .frame(width: viewWidth, height: 20, alignment: .trailing)
                .padding(.top, 12)
            }
                
            VStack {
                
                Text("Firewall")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 23, maxHeight: 23, alignment: .leading)
                    .font(cFontHeader2)
                    .foregroundColor(Color(NSColor.labelColor))
                    .padding(.top, 12)
                    .padding(.horizontal, 14)
                Text("Block Trackers & Ads For Free")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 16, maxHeight: 16, alignment: .leading)
                    .font(cFontSubtitle)
                    .foregroundColor(Color(NSColor.lightGray))
                    .padding(.top, 2)
                    .padding(.horizontal, 14)
                Spacer()
                
                LoadingCircle(toggleTapped: {
                    DDLogInfo("toggle Firewall")
                    self.toggleFirewall()
                }, tunnelState: firewallState )
                .frame(width: 100, height: 100)
                .padding(4)
                Text(firewallState.status)
                    .frame(width: 84, height: 18)
                    .font(cFontTiny)
                    .foregroundColor(.white)
                    .background(firewallState.color)
                    .cornerRadius(3)
                Spacer()
                BlockMetricsView()
                HStack(spacing: 0.5) {
                    Button(action: {
                            self.showViewLog = true
                        }) {
                            Text("View Log")
                                .font(cFontTitle)
                                .frame(height: 40)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .buttonStyle(BlueButtonStyle())
                    .popover(isPresented: self.$showViewLog) {
                        BlockLogView()
                    }
                    .disabled(anyPopoverShowing())
                    Button(action: {
                            self.showBlockList = true
                        }) {
                            Text("Block List")
                            .font(cFontTitle)
                            .frame(height: 40)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.horizontal, 0)
                            .padding(.vertical, 5)
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .buttonStyle(BlueButtonStyle())
                    .popover(isPresented: self.$showBlockList) {
                        BlockListsView()
                    }
                    .disabled(anyPopoverShowing())
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            .background(Color.panelBackground)
            .cornerRadius(8)
            
            
            VStack {
                Text("Secure Tunnel VPN")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 23, maxHeight: 23, alignment: .leading)
                    .font(cFontHeader2)
                    .foregroundColor(Color(NSColor.labelColor))
                    .padding(.top, 12)
                    .padding(.horizontal, 14)
                Text("Private Browsing + Hide Location & IP")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 16, maxHeight: 16, alignment: .leading)
                    .font(cFontSubtitle)
                    .foregroundColor(Color(NSColor.lightGray))
                    .padding(.top, 2)
                    .padding(.horizontal, 14)
                Spacer()
                
                LoadingCircle(toggleTapped: {
                    DDLogInfo("toggle VPN")
                    // get creds if we don't have it
                    if getAPICredentials() == nil {
                        self.showEmailLogin = true
                    }
                    else {
                        self.toggleVPN()
                    }
                }, tunnelState: vpnState)
                .frame(width: 100, height: 100)
                .padding(4)
                .popover(isPresented: self.$showEmailLogin) {
                    EmailLoginView(successCallback: {
                        DDLogInfo("dismissed email login view, resuming activating VPN")
                        // if credentials are now set, then resume toggling the VPN
                        if getAPICredentials() != nil {
                            self.toggleVPN()
                        }
                    } )
                }
                Text(vpnState.status)
                    .frame(width: 84, height: 18)
                    .font(cFontTiny)
                    .foregroundColor(.white)
                    .background(vpnState.color)
                    .cornerRadius(3)
                Spacer()
                Text("VIEW AUDIT REPORT")
                    .frame(width: 200, height: 18)
                    .font(cFontSmall)
                    .foregroundColor(Color.lightGray)
                Button(action: {
                    let url = URL(string: "https://openlyoperated.org/report/confirmedvpn")!
                    if NSWorkspace.shared.open(url) {
                        DDLogInfo("audit report opened")
                    }
                }) {
                    Text("June 9th, 2019")
                        .font(cFontSubtitle2)
                        .foregroundColor(Color.confirmedBlue)
                        .frame(width: 150, height: 18)
                        .foregroundColor(.white)
                }
                .buttonStyle(BlankButtonStyle())
                HStack(spacing: 0.5) {
                    Button(action: {
                            self.showWhitelist = true
                        }) {
                            Text("Whitelist")
                                .font(cFontTitle)
                                .frame(height: 40)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 5)
                                .foregroundColor(.white)
                    }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    .buttonStyle(BlueButtonStyle())
                    .popover(isPresented: self.$showWhitelist) {
                        WhitelistView()
                    }
                    .disabled(anyPopoverShowing())
                    Button(action: {
                            self.showSetRegion = true
                        }) {
                            ZStack {
                                Text("Set Region")
                                    .font(cFontTitle)
                                    .frame(height: 30)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding(.horizontal, 0)
                                    .padding(.top, 0)
                                    .padding(.bottom, 12)
                                    .foregroundColor(.white)
                                Text(getSavedVPNRegion().regionDisplayNameShort)
                                    .font(cFontSubtitle)
                                    .frame(height: 10)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding(.horizontal, 0)
                                    .padding(.top, 21)
                                    .foregroundColor(.white)
                            }
                            .frame(height: 50)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .buttonStyle(BlueButtonStyle())
                    .popover(isPresented: self.$showSetRegion) {
                        SetRegionView()
                    }
                    .disabled(anyPopoverShowing())
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            .background(Color.panelBackground)
            .cornerRadius(8)
        }
        .frame(width: viewWidth, height: viewHeight)
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
        .background(Color.mainBackground)
        .onAppear {
            if (defaults.bool(forKey: kHasAgreedToFirewallPrivacyPolicy) == false) {
                self.showingPrivacyPolicyAlert = true
            }
            refreshFirewallStatus()
            refreshVPNStatus()
            self.ensureLoginAndSubscriptionValid()
        }
        .alert(isPresented: $showingPrivacyPolicyAlert) {
            Alert(title: Text("Your Privacy Comes First"), message: Text("Lockdown's Privacy Policy is simple:\n\nEverything Lockdown Firewall does stays on your device, and what you see is what you get — nothing more or less — because that's the way it should be.\n\nFor more details, visit https://lockdownhq.com/privacy\n\nClick 'Agree' to continue."), primaryButton: .default(Text("Agree")) {
                    NotificationCenter.default.post(name: .togglePopoverOn, object: nil)
                    defaults.set(true, forKey: kHasAgreedToFirewallPrivacyPolicy)
                }, secondaryButton: .cancel(Text("Quit")) {
                    NSApplication.shared.terminate(self)
                })
        }
     
    }
    
    func ensureLoginAndSubscriptionValid() {
        DDLogInfo("ensureLoginAndSubscriptionValid")
        if (getUserWantsVPNEnabled() && getAPICredentials() != nil) {
            firstly {
                try Client.signInWithEmail()
            }
            .then { (signin: SignIn) -> Promise<GetKey> in
                try Client.getKey()
            }
            .done { (getKey: GetKey) in
                // nothing to do
            }
            .catch { error in
                // only catch bad subscription errors here
                if let apiError = error as? ApiError {
                    switch apiError.code {
                    case kApiCodeIncorrectLogin:
                        VPNController.shared.setEnabled(false)
                        self.errorTitle = "Incorrect Login"
                        self.errorMessage = "Your saved login credentials are incorrect. Did you change your password recently? Please try signing in again."
                        clearAPICredentials()
                        self.showError = true
                    case kApiCodeNoSubscriptionInReceipt, kApiCodeNoActiveSubscription:
                        VPNController.shared.setEnabled(false)
                        self.errorTitle = "No Active Subscription"
                        self.errorMessage = "Check that you are subscribed to Lockdown Secure Tunnel on your iPhone or iPad and that it's connected with the account: \((getAPICredentials() != nil) ? getAPICredentials()!.email : "")"
                        self.showError = true
                    case kApiCodeMobileSubscriptionOnly:
                        VPNController.shared.setEnabled(false)
                        self.errorTitle = "Upgrade Subscription"
                        self.errorMessage = "Your Secure Tunnel subscription on the account \((getAPICredentials() != nil) ? getAPICredentials()!.email : "") is only valid for iPhone and iPad.\n\nUpgrade to a Pro subscription to enable Mac:\n\n1) Open Settings app\n2) Tap [Your Name]\n3) Tap Subscriptions\n4) Tap Lockdown\n5) Choose a monthly/annual Pro plan\n6) Open Lockdown on iPhone/iPad\n7) Turn the Secure Tunnel Off, Then On\n\nThis process syncs your subscription between Lockdown Mac and iOS. For any questions, email support at team@lockdownhq.com."
                        self.showError = true
                    default:
                        DDLogInfo("nothing to do here")
                    }
                }
            }
        }
    }

    func toggleFirewall() {
        // flip the user preference
        let newFirewallStatus = !getUserWantsFirewallEnabled()
        setUserWantsFirewallEnabled(newFirewallStatus)
        // vpn firewall overrides
        if (getUserWantsVPNEnabled()) {
            FirewallController.shared.setEnabled(false)
            VPNController.shared.restart()
        }
        // otherwise set it to the flipped status
        else {
            FirewallController.shared.setEnabled(newFirewallStatus)
        }
    }
    
    func toggleVPN() {
        // flip the user preference
        let newVPNShouldBeConnectedStatus = !getUserWantsVPNEnabled()
        DDLogInfo("new UserWantsVPNEnabled: \(newVPNShouldBeConnectedStatus)")
        setUserWantsVPNEnabled(newVPNShouldBeConnectedStatus)
        
        if (newVPNShouldBeConnectedStatus == true) {
            DDLogInfo("Toggle VPN: off currently, turning it on")

            // VPN overrides firewall
            if (getUserWantsFirewallEnabled()) {
                FirewallController.shared.setEnabled(false)
            }
            
            // Delay to give time for Firewall to turn off
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                firstly {
                    try Client.signInWithEmail()
                }
                .then { (signin: SignIn) -> Promise<GetKey> in
                    // TODO: don't always do this -- if we already have a key, then only do it once per day max
                    try Client.getKey()
                }
                .done { (getKey: GetKey) in
                    try setVPNCredentials(id: getKey.id, keyBase64: getKey.b64)
                    VPNController.shared.setEnabled(true)
                }
                .catch { error in
                    setUserWantsVPNEnabled(false)

                    let nsError = error as NSError
                    if nsError.domain == NSURLErrorDomain {
                        self.errorTitle = "Network Error"
                        self.errorMessage = "Please check your internet connection. If this persists, please contact team@lockdownhq.com.\n\nError Details\n" + nsError.localizedDescription
                    }
                    else if let apiError = error as? ApiError {
                        switch apiError.code {
                        case kApiCodeNoSubscriptionInReceipt, kApiCodeNoActiveSubscription:
                            self.errorTitle = "No Active Subscription"
                            self.errorMessage = "Check that you are subscribed to Lockdown Secure Tunnel on your iPhone or iPad and that it's connected with the account: \((getAPICredentials() != nil) ? getAPICredentials()!.email : "")"
                        case kApiCodeMobileSubscriptionOnly:
                            self.errorTitle = "Upgrade Subscription"
                            self.errorMessage = "Your Secure Tunnel subscription on the account \((getAPICredentials() != nil) ? getAPICredentials()!.email : "") is only valid for iPhone and iPad.\n\nUpgrade to a Pro subscription to enable Mac:\n\n1) Open Settings app\n2) Tap [Your Name]\n3) Tap Subscriptions\n4) Tap Lockdown\n5) Choose a monthly/annual Pro plan\n6) Open Lockdown on iPhone/iPad\n7) Turn the Secure Tunnel Off, Then On\n\nThis process syncs your subscription between Lockdown Mac and iOS. For any questions, email support at team@lockdownhq.com."
                        default:
                            self.errorTitle = "Unexpected API Error"
                            self.errorMessage = "Message: \(apiError.localizedDescription)\nCode: \(apiError.code)\nIf this persists, please contact team@lockdownhq.com."
                        }
                    }
                    else {
                        self.errorTitle = "Unexpected Error"
                        self.errorMessage = "Message: \(error.localizedDescription)\nIf this persists, please contact team@lockdownhq.com."
                    }
                    
                    self.showError = true
                }
            }
            
        }
        // VPN should not be connected
        else {
            VPNController.shared.setEnabled(false)
            if (getUserWantsFirewallEnabled()) {
                FirewallController.shared.setEnabled(true)
            }
        }
    }

}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
               .environment(\.colorScheme, .light)
            ContentView()
               .environment(\.colorScheme, .dark)
        }
    }
}
#endif

class TunnelState: ObservableObject {
    @Published var status: String = "INITIALIZING"
    @Published var color: Color = Color.gray
    @Published var circleColor: Color = Color.gray
    @Published var isLoading: Bool = false
    
    init() {
    }
    
    init(status: String, color: Color, circleColor: Color, isLoading: Bool) {
        self.status = status
        self.color = color
        self.circleColor = circleColor
        self.isLoading = isLoading
    }
}

func refreshFirewallStatus() {
    var statusToUse = FirewallController.shared.status()
    // if VPN is on and user wants firewall on, sync status to VPN status
    if (getUserWantsVPNEnabled() && getUserWantsFirewallEnabled()) {
        statusToUse = VPNController.shared.status()
    }
    switch (statusToUse) {
        case .invalid:
            contentView?.firewallState.status = "FIREWALL OFF"
            contentView?.firewallState.color = .flatRed
            contentView?.firewallState.circleColor = .lightGray
            contentView?.firewallState.isLoading = false
        case .connecting:
            contentView?.firewallState.status = "ACTIVATING"
            contentView?.firewallState.color = .confirmedBlue
            contentView?.firewallState.circleColor = .confirmedBlue
            contentView?.firewallState.isLoading = true
        case .connected:
            contentView?.firewallState.status = "FIREWALL ON"
            contentView?.firewallState.color = .confirmedBlue
            contentView?.firewallState.circleColor = .confirmedBlue
            contentView?.firewallState.isLoading = false
        case .disconnecting:
            contentView?.firewallState.status = "DEACTIVATING"
            contentView?.firewallState.color = .lightGray
            contentView?.firewallState.circleColor = .lightGray
            contentView?.firewallState.isLoading = true
        case .disconnected:
            contentView?.firewallState.status = "FIREWALL OFF"
            contentView?.firewallState.color = .flatRed
            contentView?.firewallState.circleColor = .lightGray
            contentView?.firewallState.isLoading = false
        case .reasserting:
            contentView?.firewallState.status = "RELOADING"
            contentView?.firewallState.color = .lightGray
            contentView?.firewallState.circleColor = .lightGray
            contentView?.firewallState.isLoading = true
        default:
            contentView?.firewallState.status = "UNKNOWN"
            contentView?.firewallState.color = .lightGray
            contentView?.firewallState.circleColor = .lightGray
            contentView?.firewallState.isLoading = false
    }
}

func refreshVPNStatus() {
    switch (VPNController.shared.status()) {
        case .invalid:
            contentView?.vpnState.status = "TUNNEL OFF"
            contentView?.vpnState.color = .flatRed
            contentView?.vpnState.circleColor = .lightGray
            contentView?.vpnState.isLoading = false
        case .connecting:
            contentView?.vpnState.status = "ACTIVATING"
            contentView?.vpnState.color = .confirmedBlue
            contentView?.vpnState.circleColor = .confirmedBlue
            contentView?.vpnState.isLoading = true
        case .connected:
            contentView?.vpnState.status = "TUNNEL ON"
            contentView?.vpnState.color = .confirmedBlue
            contentView?.vpnState.circleColor = .confirmedBlue
            contentView?.vpnState.isLoading = false
        case .disconnecting:
            contentView?.vpnState.status = "DEACTIVATING"
            contentView?.vpnState.color = .lightGray
            contentView?.vpnState.circleColor = .lightGray
            contentView?.vpnState.isLoading = true
        case .disconnected:
            contentView?.vpnState.status = "TUNNEL OFF"
            contentView?.vpnState.color = .flatRed
            contentView?.vpnState.circleColor = .lightGray
            contentView?.vpnState.isLoading = false
        case .reasserting:
            contentView?.vpnState.status = "RELOADING"
            contentView?.vpnState.color = .lightGray
            contentView?.vpnState.circleColor = .lightGray
            contentView?.vpnState.isLoading = true
        default:
            contentView?.vpnState.status = "UNKNOWN"
            contentView?.vpnState.color = .lightGray
            contentView?.vpnState.circleColor = .lightGray
            contentView?.vpnState.isLoading = false
    }
}
