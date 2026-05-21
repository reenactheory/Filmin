import SwiftUI

/// "전체 필름 한 눈에 보기" — Instagram-shareable grid view of every
/// photo in the roll. Reached from the detail view's bottom button.
struct FilmRollGalleryView: View {
    let roll: FilmRoll
    let rollNumber: Int

    @Environment(\.dismiss) private var dismiss
    @State private var showSavedAlert = false

    private let photosPerRow = 5
    /// FilmStrip asset aspect (W:H).
    private let tileAspect: CGFloat = 1451.0 / 1179.0

    var body: some View {
        VStack(spacing: 0) {
            header

            stripGrid
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea()
        .alert("이미지 저장됨", isPresented: $showSavedAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("사진 라이브러리에 저장되었습니다. 인스타그램 스토리에서 불러올 수 있어요.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 16) {
            closeButton

            titleBlock

            tagChips
                .padding(.horizontal, 24)
        }
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60) // clear the Dynamic Island / status bar area
    }

    private var titleBlock: some View {
        VStack(spacing: 4) {
            (
                Text("나의 ").foregroundStyle(.secondary)
                + Text("\(rollNumber)번째").foregroundStyle(.primary)
                + Text(" 롤").foregroundStyle(.secondary)
            )
            .font(.pretendard(.bold, size: 20))

            Text(roll.fullName)
                .font(.pretendard(.bold, size: 20))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }

    private var tagChips: some View {
        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8, alignment: .center) {
            if let developedAt = roll.developedAt {
                TagChip(text: "#\(formatDateShort(developedAt))", fontSize: 12)
            }
            TagChip(text: "#\(roll.camera)", fontSize: 12)
            if let iso = roll.iso {
                TagChip(text: "#ISO\(iso)", fontSize: 12)
            }
        }
    }

    // MARK: - Grid

    @ViewBuilder
    private var stripGrid: some View {
        if roll.format == "120" {
            mediumGrid(includesSaveButton: true, cellPadding: 5)
        } else {
            standardStripGrid
        }
    }

    private var standardStripGrid: some View {
        let totalPhotos = roll.photoCount
        let rowCount = Int(ceil(Double(totalPhotos) / Double(photosPerRow)))

        return VStack(spacing: 10) {
            ForEach(0..<rowCount, id: \.self) { rowIdx in
                stripRow(
                    rowIdx: rowIdx,
                    totalPhotos: totalPhotos,
                    includesSaveButton: true
                )
            }
        }
    }

    // MARK: - Medium (120) Grid

    /// 120 layout: photos sit on a black "contact sheet" — but only the
    /// cells that actually contain a photo wear black. Save-button and
    /// empty cells stay transparent so the surrounding canvas (white)
    /// shows through, matching how 35mm's per-tile FilmStrip only paints
    /// where there's film.
    ///
    /// Every cell is a Color.clear-based fixed-size container with
    /// `maxWidth: .infinity`. Because every cell has the same (zero)
    /// intrinsic content, HStack divides width perfectly equally — the
    /// last row's photo lines up with the photos above it.
    private func mediumGrid(includesSaveButton: Bool, cellPadding: CGFloat) -> some View {
        let mediumPerRow = 3
        let totalPhotos = roll.photoCount
        let rowCount = Int(ceil(Double(totalPhotos) / Double(mediumPerRow)))
        let lastIdx = totalPhotos - 1
        let lastRowFull = includesSaveButton && totalPhotos % mediumPerRow == 0
        // Negative spacing equal to cellPadding collapses adjacent rows/
        // columns so the visible black gap between photos is `cellPadding`
        // (only the upper/left cell's padding shows), not doubled.
        let collapse = -cellPadding

        return VStack(spacing: collapse) {
            ForEach(0..<rowCount, id: \.self) { rowIdx in
                let baseIdx = rowIdx * mediumPerRow
                let rowContainsLast = baseIdx <= lastIdx && lastIdx < baseIdx + mediumPerRow

                HStack(spacing: collapse) {
                    ForEach(0..<mediumPerRow, id: \.self) { colIdx in
                        let photoIdx = baseIdx + colIdx
                        let isPhoto = photoIdx < totalPhotos
                        let isSaveSlot = rowContainsLast
                            && includesSaveButton
                            && photoIdx == totalPhotos
                        mediumCell(
                            photoIdx: isPhoto ? photoIdx : nil,
                            isSaveButton: isSaveSlot,
                            cellPadding: cellPadding
                        )
                    }
                }
            }
            if lastRowFull {
                HStack(spacing: collapse) {
                    mediumCell(photoIdx: nil, isSaveButton: true, cellPadding: cellPadding)
                    mediumCell(photoIdx: nil, isSaveButton: false, cellPadding: cellPadding)
                    mediumCell(photoIdx: nil, isSaveButton: false, cellPadding: cellPadding)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    /// One cell in the medium grid. Always a perfect square (so every
    /// row is the exact same height — the black borders between photos
    /// match up cleanly). Black background only when it holds a photo.
    @ViewBuilder
    private func mediumCell(photoIdx: Int?, isSaveButton: Bool, cellPadding: CGFloat) -> some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(photoIdx != nil ? Color.black : Color.clear)
            .overlay {
                if let photoIdx {
                    mediumPhotoImage(for: photoIdx)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(cellPadding)
                } else if isSaveButton {
                    HStack {
                        saveButton
                            .padding(.leading, 14)
                        Spacer()
                    }
                }
            }
    }

    /// Plain medium photo image. Uses `.fill` + `.clipped()` so that every
    /// photo fills its (square) cell uniformly — keeping the black borders
    /// between photos a consistent thickness across all rows even when the
    /// source images have slightly different aspect ratios.
    @ViewBuilder
    private func mediumPhotoImage(for index: Int) -> some View {
        let name = index < roll.photos.count ? roll.photos[index] : ""
        if !name.isEmpty, let uiImage = RollPhotoStore.image(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            Rectangle()
                .fill(Color(.systemGray3))
        }
    }

    /// One grid row: up to 5 photo tiles. The very last photo in the
    /// roll uses the wider FilmStripEnd image instead of FilmStrip and,
    /// if `includesSaveButton`, gets the download button placed
    /// immediately after it (in the same row).
    private func stripRow(rowIdx: Int, totalPhotos: Int, includesSaveButton: Bool) -> some View {
        let baseIdx = rowIdx * photosPerRow
        let lastIdx = totalPhotos - 1
        let rowContainsLast = baseIdx <= lastIdx && lastIdx < baseIdx + photosPerRow

        return GeometryReader { geo in
            let unitW = geo.size.width / CGFloat(photosPerRow)
            let endTileWidth = unitW * (1699.0 / 1179.0) / tileAspect
            let tileHeight = unitW / tileAspect

            HStack(spacing: 0) {
                ForEach(0..<photosPerRow, id: \.self) { colIdx in
                    let photoIdx = baseIdx + colIdx
                    let isLast = photoIdx == lastIdx

                    if photoIdx < totalPhotos {
                        photoTile(photoIdx: photoIdx, isLast: isLast)
                            .frame(
                                width: isLast ? endTileWidth : unitW,
                                height: tileHeight
                            )
                    } else if !(rowContainsLast && includesSaveButton) {
                        // Empty slot (only used when last photo isn't here,
                        // since we'll put the save button into the gap
                        // when it is).
                        Color.clear
                            .frame(width: unitW, height: tileHeight)
                    }
                }

                if rowContainsLast && includesSaveButton {
                    Spacer().frame(width: 16)
                    saveButton
                    Spacer(minLength: 0)
                }
            }
        }
        .aspectRatio(CGFloat(photosPerRow) * tileAspect, contentMode: .fit)
    }

    private func photoTile(photoIdx: Int, isLast: Bool) -> some View {
        // For regular tile (FilmStrip): the photo window is centered
        // and spans ~92% × 76% of the tile.
        // For the end tile (FilmStripEnd): the frame portion is on
        // the LEFT (1451/1699 ≈ 85.4% of the asset width). The photo
        // sits inside that left portion only, leaving the dark tail
        // on the right untouched.
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let frameWidth = isLast ? w * (1451.0 / 1699.0) : w
            // +2pt on each side (4 total) compared to the prior 92% window.
            let photoW = frameWidth * 0.92 + 4
            let photoH = h * 0.76

            ZStack {
                photoPlaceholder(for: photoIdx)
                    .frame(width: photoW, height: photoH)
                    .clipped()
                    .position(x: frameWidth / 2, y: h / 2)

                Image(isLast ? "FilmStripEnd" : "FilmStrip")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: h)
            }
        }
    }

    @ViewBuilder
    private func photoPlaceholder(for index: Int) -> some View {
        let name = index < roll.photos.count ? roll.photos[index] : ""
        if !name.isEmpty, let uiImage = RollPhotoStore.image(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // Gradient fallback when real photo data isn't bundled yet.
            let palettes: [[Color]] = [
                [Color(red: 0.62, green: 0.74, blue: 0.86),
                 Color(red: 0.40, green: 0.52, blue: 0.62)],
                [Color(red: 0.55, green: 0.65, blue: 0.55),
                 Color(red: 0.30, green: 0.40, blue: 0.30)],
                [Color(red: 0.82, green: 0.66, blue: 0.50),
                 Color(red: 0.58, green: 0.42, blue: 0.30)],
                [Color(red: 0.45, green: 0.50, blue: 0.58),
                 Color(red: 0.25, green: 0.30, blue: 0.36)]
            ]
            let palette = palettes[index % palettes.count]
            LinearGradient(colors: palette, startPoint: .top, endPoint: .bottom)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveToPhotos()
        } label: {
            Image(systemName: "arrow.down.to.line")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.black)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 4)
        }
    }

    private func formatDateShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyMMdd"
        return f.string(from: date)
    }

    // MARK: - Export / Save

    /// Rendered to Photos when the download button is tapped. Sized
    /// exactly to Instagram Story format (1080×1920). Title and tag
    /// chips run at scaled-up font sizes so they read at full canvas
    /// resolution, not at on-screen size.
    private var exportContent: some View {
        return VStack(spacing: 32) {
            // Title — scaled ~2.5× from on-screen size
            VStack(spacing: 8) {
                (
                    Text("나의 ").foregroundStyle(.secondary)
                    + Text("\(rollNumber)번째").foregroundStyle(.primary)
                    + Text(" 롤").foregroundStyle(.secondary)
                )
                .font(.pretendard(.bold, size: 50))

                Text(roll.fullName)
                    .font(.pretendard(.bold, size: 50))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 100)

            // Tag chips — scaled ~2.7× from 12pt on-screen
            FlowLayout(horizontalSpacing: 20, verticalSpacing: 20, alignment: .center) {
                if let developedAt = roll.developedAt {
                    TagChip(text: "#\(formatDateShort(developedAt))", fontSize: 32)
                }
                TagChip(text: "#\(roll.camera)", fontSize: 32)
                if let iso = roll.iso {
                    TagChip(text: "#ISO\(iso)", fontSize: 32)
                }
            }
            .padding(.horizontal, 48)

            // Photo grid — different for 120 (medium) vs 35mm
            Group {
                if roll.format == "120" {
                    mediumGrid(includesSaveButton: false, cellPadding: 15)
                } else {
                    let totalPhotos = roll.photoCount
                    let rowCount = Int(ceil(Double(totalPhotos) / Double(photosPerRow)))
                    VStack(spacing: 24) {
                        ForEach(0..<rowCount, id: \.self) { rowIdx in
                            stripRow(
                                rowIdx: rowIdx,
                                totalPhotos: totalPhotos,
                                includesSaveButton: false
                            )
                        }
                    }
                }
            }
            .padding(.top, 16)

            Spacer(minLength: 0)
        }
        .frame(width: 1080, height: 1920)
        .background(Color.white)
    }

    @MainActor
    private func saveToPhotos() {
        // Output is laid out at 1080×1920 pt; scale 1 means the saved
        // file is exactly 1080×1920 px — Instagram Story format.
        let renderer = ImageRenderer(content: exportContent)
        renderer.scale = 1

        guard let uiImage = renderer.uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        showSavedAlert = true
    }
}

#Preview {
    FilmRollGalleryView(roll: FilmRoll.samples[1], rollNumber: 3)
}
