import UIKit
import AVFoundation
import Vision
import VisionLab

final class ViewController: UIViewController {
  /// Text view to display results of classification
  private lazy var textView: UITextView = self.makeTextView()
  /// Array of vision requests
  private var requests = [VNRequest]()
  /// Service used to capture video output from the camera
  private lazy var videoCaptureService: VideoCaptureService = .init()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    view.layer.addSublayer(videoCaptureService.previewLayer)
    view.addSubview(textView)
    setupConstraints()

    videoCaptureService.delegate = self
    videoCaptureService.startCapturing()
    setupVision()
  }

  // MARK: - Subviews

  private func makeTextView() -> UITextView {
    let textView = UITextView()
    textView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    textView.font = .systemFont(ofSize: 18)
    textView.textColor = .white
    textView.textAlignment = .center
    textView.isSelectable = false
    textView.isScrollEnabled = false
    textView.text = "Point 📷 at objects around you"
    return textView
  }

  // MARK: - Layout

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    videoCaptureService.previewLayer.frame = view.layer.bounds
  }

  private func setupConstraints() {
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
  }
}

// MARK: - Vision

private extension ViewController {
  /// Create CoreML model and classification request
  func setupVision() {
    do {
      let model = try VNCoreMLModel(for: Inceptionv3().model)
      let classificationRequest = VNCoreMLRequest(model: model, completionHandler: handleClassifications)
      classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
      requests = [classificationRequest]
    } catch {
      assertionFailure("can't load Vision ML model: \(error)")
    }
  }

  /// Handle results of the classification request
  func handleClassifications(request: VNRequest, error: Error?) {
    var text = "No results"
    if let observations = request.results as? [VNClassificationObservation] {
      text = observations.prefix(upTo: 3)
        .filter({ $0.confidence > 0.1 })
        .map({ "\($0.identifier): \($0.confidence.roundTo(places: 3) * 100.0)%" })
        .joined(separator: "\n")
    }

    DispatchQueue.main.async {
      self.textView.text = text
      self.textView.sizeToFit()
      self.textView.frame.size.width = self.view.bounds.width
    }
  }
}

// MARK: - VideoCaptureManagerDelegate

extension ViewController: VideoCaptureServiceDelegate {
  func videoCaptureService(_ service: VideoCaptureService,
                           didOutput sampleBuffer: CMSampleBuffer,
                           pixelBuffer: CVPixelBuffer) {
    var requestOptions = [VNImageOption: Any]()
    let attachment = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil)
    if let cameraIntrinsicData = attachment {
      requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
    }

    do {
      let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: requestOptions)
      try imageRequestHandler.perform(requests)
    } catch {
      print(error)
    }
  }

  func videoCaptureService(_ service: VideoCaptureService, didFailWithError error: Error) {
    print(error)
  }
}
