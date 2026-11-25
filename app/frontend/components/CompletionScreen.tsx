import type { Location } from '../api'

type Props = {
  location: Location
  status: 'submitting' | 'error' | 'complete'
  error?: string
  onRetry?: () => void
}

export default function CompletionScreen({ location, status, error, onRetry }: Props) {
  return (
    <section className="screen completion">
      <p className="location">{location.name}, {location.state}</p>

      {status === 'submitting' && <h1>Tallying your sightings…</h1>}

      {status === 'error' && (
        <>
          <h1>We couldn’t score your walk</h1>
          <p className="error" role="alert">{error}</p>
          <p>Your answers are still here, so you won’t need to replay the walk.</p>
          <button type="button" className="primary" onClick={onRetry}>Try again</button>
        </>
      )}

      {status === 'complete' && (
        <>
          <h1>Walk complete</h1>
          <p className="lede">Your answers have been scored. Thanks for birding with us!</p>
        </>
      )}
    </section>
  )
}
