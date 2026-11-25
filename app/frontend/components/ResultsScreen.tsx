import { useState } from 'react'
import type { ScoreResult } from '../api'
import { shareText } from '../share'
import BirdPhoto from './BirdPhoto'
import RoundResult from './RoundResult'
import ScoreSummary from './ScoreSummary'

export default function ResultsScreen({ score, challengeDate }: { score: ScoreResult; challengeDate: string }) {
  const [index, setIndex] = useState(0)
  const round = score.rounds[index]
  const total = score.rounds.length

  return (
    <section className="screen results">
      <ScoreSummary score={score} shareText={shareText(score, challengeDate)} />

      <div className="result-body">
        <div className="result-media">
          <BirdPhoto key={round.id} photo={round.photo} alt={round.correct_bird.common_name} />

          <nav className="result-nav" aria-label="Bird results">
            <button
              type="button"
              aria-label="Previous bird"
              disabled={index === 0}
              onClick={() => setIndex(index - 1)}
            >
              ‹ Previous
            </button>
            <p aria-live="polite">Bird {index + 1} of {total}</p>
            <button
              type="button"
              aria-label="Next bird"
              disabled={index === total - 1}
              onClick={() => setIndex(index + 1)}
            >
              Next ›
            </button>
          </nav>
        </div>

        <RoundResult round={round} />
      </div>
    </section>
  )
}
