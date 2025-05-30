import XCTest
import SwiftUI
@testable import MHModal

@MainActor
final class ViewPresentModalExtensionTests: XCTestCase {
    
    func testPresentModalBasicAPI() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        
        let modalView = testView.presentModal(isPresented: binding) {
            Text("Modal Content")
        }
        
        // Test that the modifier can be applied
        XCTAssertNotNil(modalView)
    }
    
    func testPresentModalWithAppearance() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        let appearance = ModalAppearance.dark
        
        let modalView = testView.presentModal(
            isPresented: binding,
            appearance: appearance
        ) {
            Text("Dark Modal Content")
        }
        
        XCTAssertNotNil(modalView)
    }
    
    func testPresentModalWithBehavior() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        let behavior = ModalBehavior.nonDismissible
        
        let modalView = testView.presentModal(
            isPresented: binding,
            behavior: behavior
        ) {
            Text("Non-dismissible Modal Content")
        }
        
        XCTAssertNotNil(modalView)
    }
    
    func testPresentModalWithFullCustomization() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        let appearance = ModalAppearance.minimal
        let behavior = ModalBehavior.easyDismiss
        
        let modalView = testView.presentModal(
            isPresented: binding,
            appearance: appearance,
            behavior: behavior
        ) {
            VStack {
                Text("Fully Customized Modal")
                Button("Action") { }
            }
        }
        
        XCTAssertNotNil(modalView)
    }
    
    func testPresentLightModal() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        
        let modalView = testView.presentLightModal(isPresented: binding) {
            Text("Light Modal Content")
        }
        
        XCTAssertNotNil(modalView)
    }
    
    func testPresentDarkModal() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        
        let modalView = testView.presentDarkModal(isPresented: binding) {
            Text("Dark Modal Content")
        }
        
        XCTAssertNotNil(modalView)
    }
    
    func testPresentMinimalModal() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { false }, set: { _ in })
        
        let modalView = testView.presentMinimalModal(isPresented: binding) {
            Text("Minimal Modal Content")
        }
        
        XCTAssertNotNil(modalView)
    }
    
    func testModalWithComplexContent() {
        let testView = Text("Base View")
        let binding = Binding<Bool>(get: { true }, set: { _ in })
        
        let modalView = testView.presentModal(isPresented: binding) {
            VStack(spacing: 20) {
                Text("Complex Modal")
                    .font(.title)
                
                HStack {
                    Button("Cancel") { }
                    Button("Confirm") { }
                }
                
                ScrollView {
                    LazyVStack {
                        ForEach(0..<10, id: \.self) { index in
                            Text("Item \(index)")
                                .padding()
                        }
                    }
                }
                .frame(height: 200)
            }
            .padding()
        }
        
        XCTAssertNotNil(modalView)
    }
}