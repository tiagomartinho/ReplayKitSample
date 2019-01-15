import UIKit
import ReplayKit

class RecordViewController: UIViewController {

    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        return button
    }()

    private let recorder = RPScreenRecorder.shared()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        updateUI(recorder.isRecording)
    }

    private func initView() {
        view = recordButton
    }

    private func updateUI(_ isRecording: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if !self.recorder.isAvailable {
                self.recordButton.isEnabled = false
                return
            }
            if isRecording {
                self.recordButton.setTitle("Stop", for: .normal)
                self.recordButton.removeTarget(self, action: #selector(self.startRecording), for: .touchUpInside)
                self.recordButton.addTarget(self, action: #selector(self.stopRecording), for: .touchUpInside)
            } else {
                self.recordButton.setTitle("Start", for: .normal)
                self.recordButton.removeTarget(self, action: #selector(self.stopRecording), for: .touchUpInside)
                self.recordButton.addTarget(self, action: #selector(self.startRecording), for: .touchUpInside)
            }
        }
    }

    @IBAction func startRecording(_ sender: AnyObject) {
        recorder.startRecording(withMicrophoneEnabled: true) { [unowned self] error in
            if let error = error {
                NSLog("Failed start recording: \(error.localizedDescription)")
                return
            }
            NSLog("Start recording")
            self.updateUI(true)
        }
    }

    @IBAction func stopRecording(_ sender: AnyObject) {
        recorder.stopRecording(handler: { [unowned self] (previewViewController, error) in
            self.updateUI(false)

            if let error = error {
                NSLog("Failed stop recording: \(error.localizedDescription)")
                return
            }

            NSLog("Stop recording")
            previewViewController?.previewControllerDelegate = self

            DispatchQueue.main.async { [unowned self] in
                previewViewController?.popoverPresentationController?.sourceView = self.view
                self.present(previewViewController!, animated: true, completion: nil)
            }
        })
    }
}

extension RecordViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        DispatchQueue.main.async { [unowned previewController] in
            previewController.dismiss(animated: true, completion: nil)
        }
    }
}
