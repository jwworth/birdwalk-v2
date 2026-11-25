import type { ScoreResult } from '../api'
import ShareButton from './ShareButton'

export default function ScoreSummary({ score, shareText }: { score: ScoreResult; shareText: string }) {
  const dotsLabel = score.rounds
    .map((round) => `Bird ${round.position} ${round.correct ? 'correct' : 'incorrect'}`)
    .join(', ')

  return (
    <header className="score-summary">
      <p className="location">{score.location.name}, {score.location.state}</p>
      <p className="score">
        <span className="score-number">{score.correct_count} / {score.round_count}</span> correct
      </p>
      <ol className="result-dots" aria-label={dotsLabel}>
        {score.rounds.map((round) => (
          <li key={round.id} className={round.correct ? 'correct' : 'incorrect'} />
        ))}
      </ol>
      <ShareButton text={shareText} />
    </header>
  )
}
