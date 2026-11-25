import type { ScoreResult } from './api'

const SHARE_URL = 'https://playbirdwalk.com'

export function formatChallengeDate(isoDate: string) {
  const [year, month, day] = isoDate.split('-').map(Number)
  return new Intl.DateTimeFormat('en-US', { dateStyle: 'long', timeZone: 'UTC' })
    .format(new Date(Date.UTC(year, month - 1, day)))
}

export function shareText(score: ScoreResult, challengeDate: string) {
  const circles = score.rounds.map((round) => (round.correct ? '🟢' : '🔴')).join('')
  return [
    `My BirdWalk Score (${score.location.name}, ${formatChallengeDate(challengeDate)}):`,
    circles,
    SHARE_URL,
  ].join('\n')
}
