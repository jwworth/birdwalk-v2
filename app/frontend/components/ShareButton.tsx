import { useEffect, useState } from 'react'

type Status = 'idle' | 'copied' | 'failed'

export default function ShareButton({ text }: { text: string }) {
  const [status, setStatus] = useState<Status>('idle')

  useEffect(() => {
    if (status !== 'copied') return
    const timeout = setTimeout(() => setStatus('idle'), 2000)
    return () => clearTimeout(timeout)
  }, [status])

  async function copy() {
    try {
      await navigator.clipboard.writeText(text)
      setStatus('copied')
    } catch {
      setStatus('failed')
    }
  }

  return (
    <div className="share">
      <button type="button" className="primary" onClick={copy}>
        {status === 'copied' ? 'Copied!' : 'Share Score'}
      </button>
      <p className="visually-hidden" role="status">
        {status === 'copied' ? 'Score copied to clipboard' : ''}
      </p>

      {status === 'failed' && (
        <div className="share-fallback">
          <p className="error" role="alert">Couldn’t copy automatically. Copy your score below:</p>
          <textarea readOnly rows={4} value={text} onFocus={(event) => event.target.select()} autoFocus />
        </div>
      )}
    </div>
  )
}
