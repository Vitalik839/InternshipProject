//
//  LinkView.swift
//  InternshipProject
//
//  Created by Vitalii Novakovskyi on 17.07.2025.
//

import SwiftUI
import LinkPresentation

struct LinkView: UIViewRepresentable {
    var metadata: LPLinkMetadata

    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(metadata: metadata)
        return linkView
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {
        uiView.metadata = metadata
    }
}
