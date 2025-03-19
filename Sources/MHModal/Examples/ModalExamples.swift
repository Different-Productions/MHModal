//
//  ModalExamples.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/8/25.
//

import SwiftUI

/// Preview and example implementation of the ModalView component
public struct ModalPreview: View {
  @State private var showModal = false
  @State private var showSection1 = false
  @State private var showSection2 = false
  
  public init() { }
  
  public var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "rectangle.portrait")
        .font(.system(size: 60))
        .foregroundColor(.blue)
        .padding()
      
      Text("MHModal Preview")
        .font(.title2.bold())
      
      Text("A modal that automatically sizes to fit its content")
        .multilineTextAlignment(.center)
      
      Button("Show Modal") {
        showModal = true
      }
      .buttonStyle(.borderedProminent)
      .padding(.top)
    }
    .padding()
    .mhModal(isPresented: $showModal) {
      modalContent
    }
  }
  
  private var modalContent: some View {
    VStack(spacing: 20) {
      Text("Dynamic Content")
        .font(.title2.bold())
      
      Text("Toggle sections to see the modal resize")
        .font(.subheadline)
        .foregroundColor(.secondary)
      
      Button {
        withAnimation {
          showSection1.toggle()
        }
      } label: {
        HStack {
          Text("First Section")
          Spacer()
          Image(systemName: showSection1 ? "chevron.up" : "chevron.down")
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
      }
      .buttonStyle(.plain)
      
      if showSection1 {
        contentSection("This content makes the modal grow automatically")
        
        Button {
          withAnimation {
            showSection2.toggle()
          }
        } label: {
          HStack {
            Text("Nested Section")
            Spacer()
            Image(systemName: showSection2 ? "chevron.up" : "chevron.down")
          }
          .padding()
          .background(Color.blue.opacity(0.1))
          .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.top)
        
        if showSection2 {
          contentSection("Even more content grows the modal further")
          contentSection("Multiple sections stack vertically")
          contentSection("When sections are closed, the modal shrinks back")
        }
      }
      
      Spacer()
      
      Button("Close") {
        showModal = false
      }
      .buttonStyle(.borderedProminent)
      .frame(maxWidth: .infinity)
    }
    .padding()
  }
  
  private func contentSection(_ text: String) -> some View {
    VStack {
      Text(text)
        .padding()
      
      Image(systemName: "arrow.up.and.down")
        .font(.system(size: 30))
        .foregroundColor(.blue)
        .padding()
    }
    .frame(maxWidth: .infinity)
    .background(Color.gray.opacity(0.1))
    .cornerRadius(8)
  }
}

// MARK: - Previews
struct ExamplesPreview: View {
  @State private var selectedExample = 0
  
  var body: some View {
    VStack {
      Picker("Example", selection: $selectedExample) {
        Text("Dynamic Content").tag(0)
        Text("Keyboard Support").tag(1)
      }
      .pickerStyle(.segmented)
      .padding()
      
      if selectedExample == 0 {
        ModalPreview()
      } else {
        KeyboardExample()
      }
    }
  }
}

struct ModalExamplesPreview: PreviewProvider {
  static var previews: some View {
    ExamplesPreview()
  }
}
