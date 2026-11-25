import { useRef, useState } from 'react'
import { fetchChallenge, submitScore, type Answer, type Challenge, type ScoreResult } from './api'
import GameScreen from './components/GameScreen'
import HomeScreen from './components/HomeScreen'
import ResultsScreen from './components/ResultsScreen'
import ScoringScreen from './components/ScoringScreen'

type GameState =
  | { screen: 'home'; status: 'idle' | 'loading' | 'error'; error?: string }
  | { screen: 'playing'; challenge: Challenge; answers: Answer[] }
  | { screen: 'scoring'; challenge: Challenge; answers: Answer[]; status: 'submitting' | 'error'; error?: string }
  | { screen: 'complete'; challenge: Challenge; answers: Answer[]; score: ScoreResult }

type Props = {
  challengeId?: string
  challengeDate: string
}

export default function App({ challengeId, challengeDate }: Props) {
  const [state, setState] = useState<GameState>({ screen: 'home', status: 'idle' })
  // Clicks can arrive before React re-renders, so state alone can't prevent a second submission.
  const scoring = useRef(false)

  async function play() {
    if (!challengeId) return

    setState({ screen: 'home', status: 'loading' })
    try {
      const challenge = await fetchChallenge(challengeId)
      setState({ screen: 'playing', challenge, answers: [] })
    } catch (error) {
      setState({ screen: 'home', status: 'error', error: messageFor(error) })
    }
  }

  async function score(challenge: Challenge, answers: Answer[]) {
    if (scoring.current) return
    scoring.current = true

    setState({ screen: 'scoring', challenge, answers, status: 'submitting' })
    try {
      const result = await submitScore(challenge.id, answers)
      setState({ screen: 'complete', challenge, answers, score: result })
    } catch (error) {
      scoring.current = false
      setState({ screen: 'scoring', challenge, answers, status: 'error', error: messageFor(error) })
    }
  }

  function answer(roundId: number, birdId: number) {
    if (state.screen !== 'playing') return

    const { challenge, answers } = state
    if (challenge.rounds[answers.length]?.id !== roundId) return

    const nextAnswers = [...answers, { round_id: roundId, bird_id: birdId }]
    if (nextAnswers.length === challenge.rounds.length) {
      score(challenge, nextAnswers)
    } else {
      setState({ screen: 'playing', challenge, answers: nextAnswers })
    }
  }

  return <main>{renderScreen()}</main>

  function renderScreen() {
    switch (state.screen) {
      case 'home':
        return (
          <HomeScreen
            available={Boolean(challengeId)}
            loading={state.status === 'loading'}
            error={state.error}
            onPlay={play}
          />
        )
      case 'playing':
        return (
          <GameScreen
            challenge={state.challenge}
            round={state.challenge.rounds[state.answers.length]}
            answeredCount={state.answers.length}
            onAnswer={answer}
          />
        )
      case 'scoring':
        return (
          <ScoringScreen
            location={state.challenge.location}
            status={state.status}
            error={state.error}
            onRetry={() => score(state.challenge, state.answers)}
          />
        )
      case 'complete':
        return <ResultsScreen score={state.score} challengeDate={challengeDate} />
    }
  }
}

function messageFor(error: unknown) {
  return error instanceof Error ? error.message : 'Something went wrong. Please try again.'
}
