//
//  MessageComposerView.swift
//  Friends
//
//  Created by Runwei Pei on 26/11/25.
//
// Licensed under the Polyform Noncommercial License 1.0.0
// Copyright (c) 2025 PEI RUNWEI

import SwiftUI
import MessageUI

struct MessageComposerView: UIViewControllerRepresentable {
    let phoneNumber: String
    let message: String
    @Binding var result: MessageComposeResult?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = [phoneNumber]
        controller.body = message
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(result: $result, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        @Binding var result: MessageComposeResult?
        let dismiss: DismissAction
        
        init(result: Binding<MessageComposeResult?>, dismiss: DismissAction) {
            self._result = result
            self.dismiss = dismiss
        }
        
        func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MessageComposeResult
        ) {
            self.result = result
            dismiss()
        }
    }
}
