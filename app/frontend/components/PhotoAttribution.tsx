import type { Photo } from '../api'

export default function PhotoAttribution({ photo }: { photo: Photo }) {
  return (
    <p className="attribution">
      Photo by {photo.creator}
      {' · '}
      <a href={photo.license_url} target="_blank" rel="noopener noreferrer">{photo.license_name}</a>
      {' · '}
      <a href={photo.source_url} target="_blank" rel="noopener noreferrer">Source</a>
      {photo.attribution_notes && <span className="attribution-notes">{photo.attribution_notes}</span>}
    </p>
  )
}
