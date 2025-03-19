//
//  KeyboardExample.swift
//  MHModal
//
//  Created by Michael Harrigan on 3/19/25.
//

import SwiftUI

/// Example view demonstrating keyboard interaction with MHModal
public struct KeyboardExample: View {
  @State private var showModal = false
  @State private var textInput = ""
  @State private var emailInput = ""
  
  public init() {}
  
  public var body: some View {
    VStack(spacing: 20) {
      Text("Keyboard Modal Demo")
        .font(.title)
        .padding()
      
      Button("Show Keyboard Modal") {
        showModal = true
      }
      .buttonStyle(.borderedProminent)
      .padding()
    }
    .mhModal(isPresented: $showModal) {
      VStack(spacing: 16) {
        Text("Keyboard Modal Demo")
          .font(.headline)
          .padding(.top)
        
        Text("The modal will automatically move up when the keyboard appears")
          .font(.caption)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
        
        TextField("Enter your name", text: $textInput)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.horizontal)
        
        TextField("Enter your email", text: $emailInput)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding(.horizontal)
          .keyboardType(.emailAddress)
        
        Text("Comments:")
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)
          .font(.caption)
          .foregroundColor(.secondary)
        
        TextEditor(text: $textInput)
          .frame(height: 100)
          .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
          .padding(.horizontal)
        
        Spacer()
        
        HStack {
          Button("Cancel") {
            showModal = false
          }
          .buttonStyle(.bordered)
          
          Spacer()
          
          Button("Submit") {
            showModal = false
          }
          .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.bottom)
      }
      .padding()
    }
  }
}

public struct KeyboardExamplePreview: PreviewProvider {
  public static var previews: some View {
    KeyboardExample()
  }
}
