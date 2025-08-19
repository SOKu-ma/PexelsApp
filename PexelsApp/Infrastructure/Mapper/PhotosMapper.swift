import Foundation

struct PhotosMapper {
    func fromList(_ dto: PhotoDTO) -> Photo {
        Photo(
            id: dto.id,
            width: dto.width,
            height: dto.height,
            aspectRatio: CGFloat(dto.width) / CGFloat(dto.height),
            photographerName: dto.photographer,
            photographerURL: dto.photographerURL,
            avgColorHex: dto.avgColorHex,
            urls: Photo.URLs(
                original: dto.src.original,
                large: dto.src.large,
                large2x: dto.src.large2x,
                medium: dto.src.medium,
                small: dto.src.small,
                portrait: dto.src.portrait,
                landscape: dto.src.landscape,
                tiny: dto.src.tiny
            ),
            alt: dto.alt,
            liked: dto.liked
        )
    }

    func fromDetail(_ dto: PhotoDTO) -> Photo {
        Photo(
            id: dto.id,
            width: dto.width,
            height: dto.height,
            aspectRatio: CGFloat(dto.width) / CGFloat(dto.height),
            photographerName: dto.photographer,
            photographerURL: dto.photographerURL,
            avgColorHex: dto.avgColorHex,
            urls: Photo.URLs(
                original: dto.src.original,
                large: dto.src.large,
                large2x: dto.src.large2x,
                medium: dto.src.medium,
                small: dto.src.small,
                portrait: dto.src.portrait,
                landscape: dto.src.landscape,
                tiny: dto.src.tiny
            ),
            alt: dto.alt,
            liked: dto.liked
        )
    }
}
