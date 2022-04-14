// Copyright © 2021 Stormbird PTE. LTD.

import UIKit
import WebKit
import Kingfisher

enum WebImageViewImage: Hashable, Equatable {
    case url(WebImageURL)
    case image(UIImage)

    static func == (lhs: WebImageViewImage, rhs: WebImageViewImage) -> Bool {
        switch (lhs, rhs) {
        case (.url(let v1), .url(let v2)):
            return v1 == v2
        case (.image(let v1), .image(let v2)):
            return v1 == v2
        case (_, _):
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .url(let uRL):
            hasher.combine(uRL)
        case .image(let uIImage):
            hasher.combine(uIImage)
        }
    }
}

final class FixedContentModeImageView: UIImageView {
    var fixedContentMode: UIView.ContentMode {
        didSet { self.layoutSubviews() }
    }

    init(fixedContentMode contentMode: UIView.ContentMode) {
        self.fixedContentMode = contentMode
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentMode = fixedContentMode
        layer.masksToBounds = true
        clipsToBounds = true
    }
}

final class WebImageView: UIView {

    private lazy var imageView: FixedContentModeImageView = {
        let imageView = FixedContentModeImageView(fixedContentMode: contentMode)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = Colors.appBackground

        return imageView
    }()

    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isUserInteractionEnabled = false

        return webView
    }()

    override var contentMode: UIView.ContentMode {
        didSet { imageView.fixedContentMode = contentMode }
    }

    init(placeholder: UIImage? = R.image.tokenPlaceholderLarge()) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        clipsToBounds = true

        addSubview(imageView)
        addSubview(webView)

        NSLayoutConstraint.activate([
            webView.anchorsConstraint(to: self),
            imageView.anchorsConstraint(to: self)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(image: UIImage) {
        webView.alpha = 0
        imageView.image = image
    }
    private var pendingLoadWebViewOperation: BlockOperation?

    func setImage(url: WebImageURL?, placeholder: UIImage? = R.image.tokenPlaceholderLarge()) {
        guard let url = url?.url else {
            webView.alpha = 0
            imageView.image = placeholder
            return
        }

        if url.pathExtension == "svg" {
            imageView.image = nil

            //hhh1 temp fix to get build to work
            //if let data = try? ImageCache.default.diskStorage.value(forKey: url.absoluteString), let svgString = data.flatMap({ String(data: $0, encoding: .utf8) }) {
            if let svgString = "" as? String, false {
                webView.alpha = 1
                webView.loadHTMLString(html(svgString: svgString), baseURL: nil)
            } else {
                webView.alpha = 0

                DispatchQueue.global(qos: .utility).async {
                    if let data = try? Data(contentsOf: url), let svgString = String(data: data, encoding: .utf8) {
                        if let op = self.pendingLoadWebViewOperation {
                            op.cancel()
                        }

                        let op = BlockOperation {
                            self.webView.loadHTMLString(self.html(svgString: svgString), baseURL: nil)
                            self.webView.alpha = 1
                            UIView.animate(withDuration: 0.1) { self.webView.alpha = 1 }
                        }
                        self.pendingLoadWebViewOperation = op

                        OperationQueue.main.addOperations([op], waitUntilFinished: false)

                        //hhh1 disabled to fix build
                        //try? ImageCache.default.diskStorage.store(value: data, forKey: url.absoluteString)
                    }
                }
            }
        } else {
            webView.alpha = 0

            imageView.kf.setImage(with: url, placeholder: placeholder, options: [
                .transition(.fade(0.1)),
                .backgroundDecode,
            ])
        }
    }
}

extension WebImageView {

    func html(svgString: String) -> String {
        """
        <!DOCTYPE html>
        <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width,initial-scale=1.0">
                <title></title>
                <style type="text/css">
                    body {
                        height: 100%;
                        width: 100%;
                        position: absolute;
                        margin: 0;
                        padding: 0;
                    }
                    svg {
                        /*height: 100%;*/
                        width: 100%;
                    }
                </style>
            </head>
            <body>
                \(svgString)
            </body>
        </html>
        """
    }
}
