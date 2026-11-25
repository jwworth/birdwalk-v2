export type Location = {
  name: string
  state: string
}

export type Photo = {
  url: string
  source_url: string
  creator: string
  license_name: string
  license_url: string
  attribution_notes: string | null
}

export type Choice = {
  id: number
  common_name: string
}

export type Round = {
  id: number
  position: number
  photo: Photo
  choices: Choice[]
}

export type Challenge = {
  id: number
  location: Location
  rounds: Round[]
}

export type Answer = {
  round_id: number
  bird_id: number
}

export type RoundResult = {
  id: number
  position: number
  correct: boolean
  selected_bird: Choice
  correct_bird: Choice & { scientific_name: string; fact: string | null }
  photo: Photo
}

export type ScoreResult = {
  id: number
  location: Location
  correct_count: number
  round_count: number
  rounds: RoundResult[]
}

export function fetchChallenge(challengeId: string): Promise<Challenge> {
  return request(`/api/challenges/${challengeId}`)
}

export function submitScore(challengeId: number, answers: Answer[]): Promise<ScoreResult> {
  return request(`/api/challenges/${challengeId}/score`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ answers }),
  })
}

async function request<T>(url: string, init?: RequestInit): Promise<T> {
  let response: Response
  try {
    response = await fetch(url, { ...init, headers: { Accept: 'application/json', ...init?.headers } })
  } catch {
    throw new Error('We couldn’t reach BirdWalk. Check your connection and try again.')
  }

  const body = await response.json().catch(() => null)
  if (!response.ok) {
    const details = body?.errors?.join(' ') ?? body?.error
    throw new Error(details ? `Something went wrong: ${details}` : 'Something went wrong. Please try again.')
  }
  return body as T
}
