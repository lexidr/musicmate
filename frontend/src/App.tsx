import { useCallback, useEffect, useState } from 'react'
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

  const loadUser = useCallback(() => {
    apiRequest<User>('/me')
      .then(setUser)
      .catch(() => setError('Не удалось загрузить профиль'))
  }, [])

  useEffect(() => {
    loadUser()
  }, [loadUser])

  const logout = async () => {
    try {
      await apiRequest('/logout', { method: 'POST' })
    } finally {
      clearToken()
      window.location.replace('/')
    }
  }

  if (error) {
    return (
      <main className="page">
        <div className="page-center">
          <ErrorMessage>{error}</ErrorMessage>
          <Button onClick={() => { setError(''); loadUser() }}>Попробовать снова</Button>
        </div>
      </main>
    )
  }

  if (!user) return <main className="page"><div className="page-center"><Loader /></div></main>

  return (
    <div className="home-page">
      <header className="topbar">
        <a className="brand" href="/home"><span>*</span> musicmate</a>
        <Button variant="text" onClick={logout}>Выйти</Button>
      </header>

      <main className="home-content">
        <section className="home-hero">
          <Chip>Ваш профиль</Chip>
          <div className="profile-row">
            <Avatar src={user.avatar_url} name={user.name} />
            <div>
              <p className="eyebrow">Добро пожаловать</p>
              <h1>{user.name}</h1>
            </div>
          </div>
          <p>Создайте музыкальный профиль, чтобы сравнить свой вкус с друзьями.</p>
        </section>

        <section className="home-section">
          <Card>
            <div className="action-card">
              <span className="action-card__number">01</span>
              <div className="stack">
                <h3>Музыкальный профиль</h3>
                <p>Здесь появятся ваши любимые исполнители и треки.</p>
                <span className="coming-soon">Следующий этап</span>
              </div>
            </div>
          </Card>

          <Card dark>
            <div className="action-card">
              <span className="action-card__number">02</span>
              <div className="stack">
                <h3>Сравнить с другом</h3>
                <p>Создание ссылки станет доступно после музыкального профиля.</p>
                <span className="coming-soon coming-soon--dark">Скоро</span>
              </div>
            </div>
          </Card>
        </section>

        <footer className="home-footer">
          <p>{user.email}</p>
        </footer>
      </main>
    </div>
  )
}

function App() {
  if (window.location.pathname === '/ui-kit') return <UiKitPage />
  if (window.location.pathname === '/auth/callback') return <AuthCallbackPage />
  if (window.location.pathname === '/home') return <HomePage />
  return <LoginPage />
}

export default App
