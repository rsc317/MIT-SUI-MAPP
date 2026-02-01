//
//  ColoredSegmentedPicker.swift
//  MIS
//
//  Created by Emircan Duman on 01.02.26.
//
import SwiftUI

// MARK: - ColoredSegmentedPicker -

struct ColoredSegmentedPicker: View {
    enum FilterType: Hashable, CaseIterable {
        case all
        case local
        case remote
    }

    struct SegmentItem {
        // MARK: - Lifecycle
        init(type: FilterType, title: String? = nil, icon: String? = nil, color: Color) {
            self.type = type
            self.title = title
            self.icon = icon
            self.color = color
        }
        // MARK: - Internal

        let type: FilterType
        let title: String?
        let icon: String?
        var uiColor: UIColor  {
            UIColor(color)
        }
        let color: Color
    }

    @Binding var selection: FilterType
    var showAllOption: Bool = true

    var body: some View {
        CustomSegmentedControl(
            selection: $selection,
            segments: segments
        )
    }
    
    private var segments: [SegmentItem] {
        var items: [SegmentItem] = []
        
        if showAllOption {
            items.append(SegmentItem(type: .all, title: "Alle", color: .cyan.opacity(0.8)))
        }
        
        items.append(contentsOf: [
            SegmentItem(type: .local, title: "Lokal", icon: "internaldrive", color: .green.opacity(0.8)),
            SegmentItem(type: .remote, title: "Server", icon: "cloud", color: .blue.opacity(0.8))
        ])
        
        return items
    }
}

// MARK: - CustomSegmentedControl -

struct CustomSegmentedControl: UIViewRepresentable {
    class Coordinator: NSObject {
        // MARK: - Lifecycle

        init(_ parent: CustomSegmentedControl) {
            self.parent = parent
        }

        // MARK: - Internal

        var parent: CustomSegmentedControl

        @objc func valueChanged(_ sender: UISegmentedControl) {
            // Konvertiere den Segment-Index zurück zum entsprechenden FilterType
            let selectedIndex = sender.selectedSegmentIndex
            if selectedIndex < parent.segments.count {
                parent.selection = parent.segments[selectedIndex].type
            }
        }
    }

    @Binding var selection: ColoredSegmentedPicker.FilterType

    let segments: [ColoredSegmentedPicker.SegmentItem]

    func makeUIView(context: Context) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl()

        for (index, segment) in segments.enumerated() {
            if let icon = segment.icon, let title = segment.title {
                // Kombiniertes Bild mit Icon und Text
                let image = createCombinedImage(icon: icon, text: title, isSelected: false)
                segmentedControl.insertSegment(with: image, at: index, animated: false)
            } else if let title = segment.title {
                segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
            } else if let icon = segment.icon {
                let normalImage = UIImage(systemName: icon)?
                    .withTintColor(.label, renderingMode: .alwaysOriginal)
                segmentedControl.insertSegment(with: normalImage, at: index, animated: false)
            }
        }

        let selectedIndex = segments.firstIndex(where: { $0.type == selection }) ?? 0
        segmentedControl.selectedSegmentIndex = selectedIndex
        segmentedControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )

        segmentedControl.selectedSegmentTintColor = segments[selectedIndex].uiColor
        
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        updateSegmentImages(segmentedControl, selectedIndex: selectedIndex)

        return segmentedControl
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        let selectedIndex = segments.firstIndex(where: { $0.type == selection }) ?? 0
        uiView.selectedSegmentIndex = selectedIndex

        if selectedIndex < segments.count {
            uiView.selectedSegmentTintColor = segments[selectedIndex].uiColor
        }
        
        updateSegmentImages(uiView, selectedIndex: selectedIndex)
    }
    
    private func updateSegmentImages(_ segmentedControl: UISegmentedControl, selectedIndex: Int) {
        for (index, segment) in segments.enumerated() {
            let isSelected = index == selectedIndex
            
            if let icon = segment.icon, let title = segment.title {
                // Kombiniertes Bild mit Icon und Text
                let image = createCombinedImage(icon: icon, text: title, isSelected: isSelected)
                segmentedControl.setImage(image, forSegmentAt: index)
            } else if let icon = segment.icon {
                // Nur Icon
                let image = UIImage(systemName: icon)?
                    .withTintColor(isSelected ? .white : .label, renderingMode: .alwaysOriginal)
                segmentedControl.setImage(image, forSegmentAt: index)
            }
        }
    }
    
    private func createCombinedImage(icon: String, text: String, isSelected: Bool) -> UIImage? {
        let iconImage = UIImage(systemName: icon)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
        
        let textColor: UIColor = isSelected ? .white : .label
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: textColor
        ]
        
        let textSize = (text as NSString).size(withAttributes: attributes)
        let iconSize = iconImage?.size ?? .zero
        
        let spacing: CGFloat = 4
        let totalWidth = iconSize.width + spacing + textSize.width
        let totalHeight = max(iconSize.height, textSize.height)
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalWidth, height: totalHeight))
        
        return renderer.image { context in
            // Icon zeichnen
            if let iconImage = iconImage {
                let iconY = (totalHeight - iconSize.height) / 2
                iconImage
                    .withTintColor(textColor, renderingMode: .alwaysOriginal)
                    .draw(at: CGPoint(x: 0, y: iconY))
            }
            
            // Text zeichnen
            let textY = (totalHeight - textSize.height) / 2
            (text as NSString).draw(
                at: CGPoint(x: iconSize.width + spacing, y: textY),
                withAttributes: attributes
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
