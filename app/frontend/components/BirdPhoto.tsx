import type { Photo } from '../api'
import PhotoAttribution from './PhotoAttribution'

export default function BirdPhoto({ photo, alt }: { photo: Photo; alt: string }) {
  return (
    <figure className="bird-photo">
      <img src={photo.url} alt={alt} />
      <figcaption>
        <PhotoAttribution photo={photo} />
      </figcaption>
    </figure>
  )
}
