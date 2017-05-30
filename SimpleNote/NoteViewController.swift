//
//  NoteViewController.swift
//  SimpleNote
//
//  Created by sodas on 5/7/17.
//  Copyright © 2017 sodastsai. All rights reserved.
//

import UIKit

protocol NoteViewControllerDelegate: AnyObject {
    func noteViewController(_ noteViewController: NoteViewController, didCloseNote note: PureTextNote)
}

class NoteViewController: UIViewController {

    weak var delegate: NoteViewControllerDelegate?
    var aStreamReader: StreamReader?

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    var titleLabel: UILabel! {
        return self.navigationItem.titleView as! UILabel
    }

    var note: PureTextNote? {
        didSet {
            guard self.isViewLoaded else { return }
            self.updateUIElements()
        }
    }
    
    func setPage() {
        aStreamReader = StreamReader(path: self.note!.fileURL.path)
    }
    @IBAction func nextpage(_ sender: UIButton) {
        var tempstr = ""
        while self.lineNumber(label: self.contentLabel, text: tempstr)<27{
            if let line = aStreamReader!.nextLine(){
                tempstr = tempstr + line
                tempstr = tempstr + "\n"
                print("read a line")
            }
            else{
                break
            }
        }
        self.contentTextView.text = tempstr
        print("test3")
    }
    func loadNextPage(){
        var tempstr = ""
        while self.lineNumber(label: self.contentLabel, text: tempstr)<27{
            if let line = aStreamReader!.nextLine(){
                tempstr = tempstr + line
                tempstr = tempstr + "\n"
                print(self.lineNumber(label: self.contentLabel, text: tempstr))
            }
            else{
                break
            }
        }
        self.contentTextView.text = tempstr
        print("test3")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.updateUIElements()
        contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        contentLabel.numberOfLines = 0
        self.setPage()
        self.loadNextPage()
    }

    func updateUIElements() {
        self.titleLabel.text = self.note?.title
        self.contentTextView.text = self.note?.content
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.note?.content = self.contentTextView.text ?? ""
        if self.note != nil {
            self.delegate?.noteViewController(self, didCloseNote: self.note!)
        }
    }
    func lineNumber(label: UILabel, text: String) -> Int {
        let oneLineRect  =  "a".boundingRect(with: label.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
        let boundingRect = text.boundingRect(with: label.bounds.size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
        return Int(boundingRect.height / oneLineRect.height)
    }

    // MARK: - Gesture Regcognizer

    @IBAction func titleDidDoubleClicked(_ sender: UITapGestureRecognizer) {
        let titlePrompt = UIAlertController(title: "New Note Title",
                                            message: nil,
                                            preferredStyle: .alert)
        titlePrompt.addTextField { (titleTextField) in
            titleTextField.autocapitalizationType = .words
            titleTextField.text = self.note?.title
        }

        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned titlePrompt] _ in
            let newTitle = titlePrompt.textFields!.first!.text!
            print("New title is '\(newTitle)'")
        }
        titlePrompt.addAction(okAction)
        titlePrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(titlePrompt, animated: true)
    }

}
