//
//  MorphingModal.swift
//  MHModal
//
//  Created by Michael Harrigan on 5/30/25.
//

import SwiftUI

/// A modern modal that automatically morphs to fit its content.
///
/// `MorphingModal` is the core view component that provides smooth, automatic
/// resizing behavior based on content changes. It works with `ModalCoordinator`
/// to provide a clean, performant modal experience.
public struct MorphingModal<Content: View>: View {
    
    // MARK: - Properties
    
    let coordinator: ModalCoordinator
    let content: Content
    
    // MARK: - Initialization
    
    /// Creates a new morphing modal
    /// - Parameters:
    ///   - coordinator: The modal coordinator managing state
    ///   - content: The content to display inside the modal
    public init(
        coordinator: ModalCoordinator,
        @ViewBuilder content: () -> Content
    ) {
        self.coordinator = coordinator
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if coordinator.isPresented {
                // Background overlay
                overlayView
                
                // Modal content - always anchored to bottom, keyboard-aware
                modalContentView
            }
        }
        .background(ScreenSizeDetector(coordinator: coordinator))
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Overlay
    
    private var overlayView: some View {
        coordinator.appearance.overlayColor
            .opacity(overlayOpacity)
            .ignoresSafeArea()
            .onTapGesture {
                if coordinator.behavior.tapToDismiss {
                    coordinator.dismiss()
                }
            }
            .transition(.opacity.animation(coordinator.presentAnimation))
    }
    
    /// Calculated overlay opacity based on drag state
    private var overlayOpacity: Double {
        let baseOpacity = 0.4
        let dragProgress = min(coordinator.dragOffset / 300.0, 1.0)
        return baseOpacity * (1.0 - dragProgress)
    }
    
    // MARK: - Modal Content
    
    private var modalContentView: some View {
        VStack(spacing: 0) {
            // Drag indicator
            if coordinator.appearance.showDragIndicator {
                dragIndicator
            }
            
            // Content container
            contentContainer
        }
        .frame(height: coordinator.modalHeight)
        .frame(maxWidth: .infinity)
        .background(coordinator.appearance.background)
        .clipShape(
            RoundedRectangle(
                cornerRadius: coordinator.appearance.cornerRadius,
                style: .continuous
            )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -2)
        .padding(.horizontal, coordinator.appearance.horizontalPadding)
        .padding(.bottom, coordinator.appearance.bottomPadding)
        .offset(y: coordinator.dragOffset)
        .gesture(dragGesture)
        .transition(modalTransition)
        .animation(coordinator.dragAnimation, value: coordinator.dragOffset)
        .animation(coordinator.morphAnimation, value: coordinator.modalHeight)
    }
    
    // MARK: - Drag Indicator
    
    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(coordinator.appearance.dragIndicatorColor)
            .frame(width: 36, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 20)
    }
    
    // MARK: - Content Container
    
    private var contentContainer: some View {
        Group {
            if coordinator.shouldScroll {
                ScrollView {
                    contentWithSizeDetection
                        .padding(.bottom, coordinator.bottomPadding)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            } else {
                contentWithSizeDetection
                    .padding(.bottom, coordinator.bottomPadding)
            }
        }
    }
    
    /// Content with size detection attached
    private var contentWithSizeDetection: some View {
        content
            .background(SizeDetector(coordinator: coordinator))
    }
    
    // MARK: - Gestures
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if coordinator.behavior.enableDragToDismiss {
                    let translation = value.translation.height
                    // Apply resistance to upward drags, allow downward drags
                    let offset = translation < 0 ? 
                        -sqrt(abs(translation)) * 4 : 
                        translation * 0.7
                    
                    coordinator.updateDragOffset(offset)
                }
            }
            .onEnded { value in
                if coordinator.behavior.enableDragToDismiss {
                    let velocity = value.predictedEndLocation.y - value.location.y
                    coordinator.handleDragEnd(
                        translation: value.translation.height,
                        velocity: velocity
                    )
                }
            }
    }
    
    // MARK: - Transitions
    
    private var modalTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .opacity)
                .animation(coordinator.presentAnimation),
            removal: .move(edge: .bottom)
                .combined(with: .opacity)
                .animation(coordinator.presentAnimation)
        )
    }
}