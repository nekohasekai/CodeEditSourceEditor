//
//  FindPanelViewModel+Emphasis.swift
//  CodeEditSourceEditor
//
//  Created by Khan Winter on 4/18/25.
//

import CodeEditTextView

extension FindPanelViewModel {
    func addMatchEmphases(flashCurrent: Bool) {
        guard let target = target, let emphasisManager = target.textView.emphasisManager else {
            return
        }

        // Clear existing emphases
        emphasisManager.removeEmphases(for: EmphasisGroup.find)

        // Create emphasis with the nearest match as active
        let emphases = findMatches.enumerated().map { index, range in
            Emphasis(
                range: range,
                style: .standard,
                flash: flashCurrent && index == currentFindMatchIndex,
                inactive: index != currentFindMatchIndex,
                selectInDocument: index == currentFindMatchIndex
            )
        }

        // Add all emphases
        emphasisManager.addEmphases(emphases, for: EmphasisGroup.find)

        // EmphasisManager.handleSelections calls textView.scrollSelectionToVisible(),
        // which relies on TextSelection.boundingRect — only populated when the selection
        // is drawn. Off-screen matches keep boundingRect == .zero, making that scroll a
        // no-op. scrollToRange(_:) derives the rect from the layout manager and works.
        if let currentFindMatchIndex {
            target.textView.scrollToRange(findMatches[currentFindMatchIndex])
        }
    }

    func flashCurrentMatch() {
        guard let target = target,
              let emphasisManager = target.textView.emphasisManager,
              let currentFindMatchIndex else {
            return
        }

        let currentMatch = findMatches[currentFindMatchIndex]

        // Clear existing emphases
        emphasisManager.removeEmphases(for: EmphasisGroup.find)

        // Create emphasis with the nearest match as active
        let emphasis = (
            Emphasis(
                range: currentMatch,
                style: .standard,
                flash: true,
                inactive: false,
                selectInDocument: true
            )
        )

        // Add the emphasis
        emphasisManager.addEmphases([emphasis], for: EmphasisGroup.find)

        // See addMatchEmphases for why this explicit scroll is required.
        target.textView.scrollToRange(currentMatch)
    }

    func clearMatchEmphases() {
        target?.textView.emphasisManager?.removeEmphases(for: EmphasisGroup.find)
    }
}
