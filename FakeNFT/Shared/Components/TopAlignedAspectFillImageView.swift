import UIKit

final class TopAlignedAspectFillImageView: UIImageView {
    override var image: UIImage? {
        didSet { updateContentsRect() }
    }

    override var bounds: CGRect {
        didSet {
            guard oldValue.size != bounds.size else { return }
            updateContentsRect()
        }
    }

    override var contentMode: UIView.ContentMode {
        didSet { updateContentsRect() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateContentsRect()
    }

    private func updateContentsRect() {
        guard contentMode == .scaleAspectFill,
              let image,
              bounds.width > 0,
              bounds.height > 0 else {
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            return
        }

        let viewAspect = bounds.width / bounds.height
        let imageAspect = image.size.width / image.size.height

        if imageAspect > viewAspect {
            let visibleWidth = viewAspect / imageAspect
            let xOrigin = (1 - visibleWidth) / 2
            layer.contentsRect = CGRect(x: xOrigin, y: 0, width: visibleWidth, height: 1)
            return
        }

        if imageAspect < viewAspect {
            let visibleHeight = imageAspect / viewAspect
            layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: visibleHeight)
            return
        }

        layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
}
