import type { Challenge, Round } from '../api'
import BirdPhoto from './BirdPhoto'

type Props = {
  challenge: Challenge
  round: Round
  answeredCount: number
  onAnswer: (roundId: number, birdId: number) => void
}

export default function GameScreen({ challenge, round, answeredCount, onAnswer }: Props) {
  const total = challenge.rounds.length

  return (
    <section className="screen game">
      <header className="game-header">
        <p className="location">
          {challenge.location.name}, {challenge.location.state}
        </p>
        <p className="progress-label">Bird {answeredCount + 1} of {total}</p>
        <ol className="progress" aria-hidden="true">
          {challenge.rounds.map((r, index) => (
            <li key={r.id} className={index < answeredCount ? 'done' : index === answeredCount ? 'current' : ''} />
          ))}
        </ol>
      </header>

      <BirdPhoto key={round.id} photo={round.photo} alt={`Bird ${answeredCount + 1} of ${total} to identify`} />

      <h2 className="prompt">Which bird is this?</h2>
      <div className="choices">
        {round.choices.map((choice) => (
          <button key={`${round.id}-${choice.id}`} type="button" onClick={() => onAnswer(round.id, choice.id)}>
            {choice.common_name}
          </button>
        ))}
      </div>
    </section>
  )
}
