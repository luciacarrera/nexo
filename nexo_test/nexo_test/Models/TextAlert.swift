//
//  TextAlert.swift
//  nexo_test
//
//  Created by Lucía on 5/3/22.
//
import SwiftUI
import UIKit

extension UIAlertController {
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: nil, preferredStyle: .alert)
        addTextField {
            $0.placeholder = alert.placeholder
            $0.keyboardType = .numberPad
        }
        addAction(UIAlertAction(title: alert.cancel, style: .cancel) { _ in
            alert.action(nil)
        })
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            alert.action(textField?.text)
        })
    }
}


struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let alert: TextAlert
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
            let hosting = UIHostingController(rootView: content)
            hosting.view.backgroundColor = .clear
            return hosting
    }
    
    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.isPresented = false
                self.alert.action($0)
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}

public struct TextAlert {
    public var title: String
    public var placeholder: String = ""
    public var accept: String = "OK"
    public var cancel: String = "Cancel"
    public var action: (String?) -> ()
    public var keyboardType: UIKeyboardType = .default // Keyboard tzpe of the TextField
}

extension View {
    public func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}

struct ContentView: View {
    @State var showsAlert = false
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("alert") {
                self.showsAlert = true
            }
        }
        .alert(isPresented: $showsAlert, TextAlert(title: "Title", action: {
            print("Callback \($0 ?? "<cancel>")")
        }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
