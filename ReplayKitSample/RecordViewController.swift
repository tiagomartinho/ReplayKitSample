import UIKit
import ReplayKit

class RecordViewController: UIViewController {

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let startRecordingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        return button
    }()

    private let stopRecordingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        return button
    }()

    private let recorder = RPScreenRecorder.shared()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        updateUI(recorder.isRecording)
    }

    private func initView() {
        stackView.addArrangedSubview(startRecordingButton)
        stackView.addArrangedSubview(stopRecordingButton)
        view = stackView
    }

    private func updateUI(_ isRecording: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if !self.recorder.isAvailable {
                self.startRecordingButton.isEnabled = false
                self.stopRecordingButton.isEnabled = false
                return
            }
            self.startRecordingButton.isEnabled = !isRecording
            self.stopRecordingButton.isEnabled = isRecording
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
