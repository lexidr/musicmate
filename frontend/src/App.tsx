import { useEffect, useState } from 'react'
import { API_URL, apiRequest, clearToken, getToken, saveToken } from './api'

type User = {
  id: number
  name: string
  email: string | null
  avatar_url: string | null
}

function LoginPage() {
  useEffect(() => {
    if (getToken()) window.location.replace('/home')
  }, [])

  const login = () => {
    window.location.href = `${API_URL}/auth/spotify`
  }

  return (
    <main>
      <h1>musicmate</h1>
      <p>Сравни музыкальный вкус с другом</p>
      <button onClick={login}>Войти через Spotify</button>
    </main>
  )
}

function AuthCallbackPage() {
  const params = new URLSearchParams(window.location.search)
  const token = params.get('token')
  const hasError = Boolean(params.get('error') || !token)

  useEffect(() => {
    if (hasError || !token) return

    saveToken(token)
    window.location.replace('/home')
  }, [hasError, token])

  return <main><p>{hasError ? 'Не удалось войти через Spotify' : 'Выполняется вход...'}</p></main>
}

function HomePage() {
  const [user, setUser] = useState<User | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    apiRequest<User>('/me')
      .then(setUser)
      .catch(() => setError('Не удалось загрузить профиль'))
  }, [])

  const logout = async () => {
    try {
      await apiRequest('/logout', { method: 'POST' })
    } finally {
      clearToken()
      window.location.replace('/')
    }
  }

  if (error) return <main><p>{error}</p></main>
  if (!user) return <main><p>Загрузка...</p></main>

  return (
    <main>
      {user.avatar_url && <img className="avatar" src={user.avatar_url} alt="" />}
      <h1>{user.name}</h1>
      {user.email && <p>{user.email}</p>}
      <button className="secondary" onClick={logout}>Выйти</button>
    </main>
  )
}

function App() {
  if (window.location.pathname === '/auth/callback') return <AuthCallbackPage />
  if (window.location.pathname === '/home') return <HomePage />
  return <LoginPage />
}

export default App
