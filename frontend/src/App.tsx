import { useEffect, useState } from 'react'
import { API_URL, apiRequest, clearToken, getToken, saveToken } from './api'
import { Avatar, Button, Card, Chip, ErrorMessage, Loader } from './components/ui'
import { UiKitPage } from './UiKitPage'

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
    <main className="page">
      <div className="page-center">
        <section className="hero-panel stack">
          <Chip>Музыка объединяет</Chip>
          <h1>musicmate</h1>
          <p>Сравни музыкальный вкус с другом</p>
          <Button variant="light" onClick={login}>Войти через Spotify</Button>
        </section>
      </div>
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

  return (
    <main className="page">
      <div className="page-center">
        {hasError ? <ErrorMessage>Не удалось войти через Spotify</ErrorMessage> : <Loader text="Выполняется вход..." />}
      </div>
    </main>
  )
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

  if (error) return <main className="page"><div className="page-center"><ErrorMessage>{error}</ErrorMessage></div></main>
  if (!user) return <main className="page"><div className="page-center"><Loader /></div></main>

  return (
    <main className="page">
      <div className="page-center">
        <Card>
          <div className="stack">
            <Chip>Профиль</Chip>
            <div className="profile-row">
              <Avatar src={user.avatar_url} name={user.name} />
              <div>
                <h3>{user.name}</h3>
                {user.email && <p>{user.email}</p>}
              </div>
            </div>
            <Button variant="outline" onClick={logout}>Выйти</Button>
          </div>
        </Card>
      </div>
    </main>
  )
}

function App() {
  if (window.location.pathname === '/ui-kit') return <UiKitPage />
  if (window.location.pathname === '/auth/callback') return <AuthCallbackPage />
  if (window.location.pathname === '/home') return <HomePage />
  return <LoginPage />
}

export default App
