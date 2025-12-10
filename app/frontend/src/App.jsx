import React, { useState } from 'react'

const API = import.meta.env.VITE_API_URL || ''

export default function App() {
  const [file, setFile] = useState(null)
  const [feed, setFeed] = useState([])
  const [message, setMessage] = useState('')

  async function loadFeed() {
    const res = await fetch(`${API}/feed`)
    const data = await res.json()
    setFeed(data.videos || [])
  }

  async function presign() {
    if (!file) return
    const res = await fetch(`${API}/videos/presign`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ filename: file.name })
    })
    const data = await res.json()
    const put = await fetch(data.url, { method: 'PUT', body: file })
    if (put.ok) {
      setMessage('Uploaded! Confirming...')
      await fetch(`${API}/videos/confirm`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ video_id: data.video_id })
      })
      setMessage('Queued for processing ✅')
      loadFeed()
    } else {
      setMessage('Upload failed')
    }
  }

  return (
    <div style={{fontFamily:'Inter, system-ui', maxWidth: 900, margin: '40px auto'}}>
      <h1>StreamSphere</h1>
      <p>Upload a short video and view the feed.</p>

      <div style={{border:'1px solid #ddd', padding:16, borderRadius:8, marginBottom:24}}>
        <input type="file" accept="video/*" onChange={e => setFile(e.target.files?.[0])} />
        <button onClick={presign} disabled={!file} style={{marginLeft:12}}>Upload</button>
        <div style={{marginTop:8, color:'#555'}}>{message}</div>
      </div>

      <button onClick={loadFeed}>Load Feed</button>
      <ul>
        {feed.map(v => <li key={v.id}>{v.title || v.id}</li>)}
      </ul>
    </div>
  )
}
