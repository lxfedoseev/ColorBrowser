/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class DocumentBrowserViewController: UIDocumentBrowserViewController {
  
  var transitionController: UIDocumentBrowserTransitionController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    allowsDocumentCreation = true
    customizeBrowser()
  }
  
  func presentDocument(_ document: ColorDocument) {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
    documentViewController.document = document
    
    // 1
    documentViewController.transitioningDelegate = self
    // 2
    transitionController = transitionController(
      forDocumentURL: document.fileURL)
    
    present(documentViewController, animated: true, completion: nil)
  }
  
  func customizeBrowser() {
    // 1
    view.tintColor = UIColor(named: "MarineBlue")
    // 2
    browserUserInterfaceStyle = .light
    // 3
    let action = UIDocumentBrowserAction(
      identifier: "com.razeware.action",
      localizedTitle: "Lighter Color",
      availability: .menu) { urls in
        let colorDocument = ColorDocument(fileURL: urls[0])
        colorDocument.open { success in
          if success {
            // 4
            colorDocument.color =
              colorDocument.color!.lighterColor(by: 60)
            self.presentDocument(colorDocument)
          }
        } }
    // 5
    action.supportedContentTypes =
      ["com.razeware.colorExtension"]
    // 6
    customActions = [action]
    // 7
    let aboutButton = UIBarButtonItem(
      title: "About",
      style: .plain,
      target: self,
      action: #selector(openAbout))
    // 8
    additionalTrailingNavigationBarButtonItems = [aboutButton]
  }
  @objc func openAbout() {
    showAlert(title: "About", text: "ColorBrowser 1.0.0\n By Ray Wenderlich")
  }
  
}

extension DocumentBrowserViewController:
UIDocumentBrowserViewControllerDelegate {
  func documentBrowser(_ controller:
    UIDocumentBrowserViewController,
                       didRequestDocumentCreationWithHandler importHandler:
    @escaping (URL?, UIDocumentBrowserViewController.ImportMode)
    -> Void) {
    // 1
    let url = Bundle.main.url(forResource: "Untitled",withExtension: "color")
      // 2
      importHandler(url, .copy)
  }
  
  // 1
  func documentBrowser(_ controller: UIDocumentBrowserViewController,
                       didImportDocumentAt sourceURL: URL,
                       toDestinationURL destinationURL: URL) {
    // 2
    presentDocument(ColorDocument(fileURL: destinationURL))
    
  }
  // 3
  func documentBrowser(_ controller: UIDocumentBrowserViewController,
                       failedToImportDocumentAt documentURL: URL,
                       error: Error?) {
    showAlert(title: "Failed", text: "Failed to import")
  }
  // 4
  func documentBrowser(_ controller: UIDocumentBrowserViewController,
                       didPickDocumentURLs documentURLs: [URL]) {
    presentDocument(ColorDocument(fileURL: documentURLs[0]))
  }
  
  func documentBrowser(_ controller:
    UIDocumentBrowserViewController,
                       applicationActivitiesForDocumentURLs
    documentURLs: [URL]) -> [UIActivity] {
    let colorDocument = ColorDocument(fileURL: documentURLs[0])
    return [CopyStringActivity(colorDocument: colorDocument)]
  }
  
}

extension DocumentBrowserViewController:
UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented:
    UIViewController, presenting: UIViewController,
                      source: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {
      return transitionController
  }
  
}


