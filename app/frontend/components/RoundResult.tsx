import type { RoundResult as RoundResultData } from '../api'

export default function RoundResult({ round }: { round: RoundResultData }) {
  const bird = round.correct_bird

  return (
    <div className="round-result">
      <p className={`verdict ${round.correct ? 'correct' : 'incorrect'}`}>
        <span aria-hidden="true">{round.correct ? '✓' : '✗'}</span> {round.correct ? 'Correct' : 'Incorrect'}
      </p>
      <h2 className="bird-name">{bird.common_name}</h2>
      <p className="scientific-name"><i>{bird.scientific_name}</i></p>
      {!round.correct && (
        <p className="your-answer">You answered: {round.selected_bird.common_name}</p>
      )}
      {bird.fact && <p className="fact">{bird.fact}</p>}
    </div>
  )
}
