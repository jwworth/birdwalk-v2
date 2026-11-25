type Props = {
  loading: boolean
  error?: string
  onPlay: () => void
}

export default function HomeScreen({ loading, error, onPlay }: Props) {
  return (
    <section className="screen home">
      <h1>BirdWalk</h1>
      <p className="lede">
        Take a walk through one of America’s great parks. Five birds were spotted along the trail —
        can you name them all?
      </p>

      <button type="button" className="primary" onClick={onPlay} disabled={loading}>
        {loading ? 'Heading to the trailhead…' : 'Play'}
      </button>

      {error && <p className="error" role="alert">{error}</p>}
    </section>
  )
}
