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

type MusicProfile = {
  status: 'empty' | 'ready' | 'failed'
  artists_count: number
  tracks_count: number
  artists: ProfileItem[]
  tracks: ProfileItem[]
}

type ProfileItem = {
  name: string
  artist_name: string | null
  spotify_url: string | null
  image_url: string | null
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
  const [profile, setProfile] = useState<MusicProfile | null>(null)
  const [error, setError] = useState('')
  const [syncing, setSyncing] = useState(false)

  const loadUser = useCallback(() => {
    Promise.all([
      apiRequest<User>('/me'),
      apiRequest<MusicProfile>('/music-profile'),
    ])
      .then(([userData, profileData]) => {
        setUser(userData)
        setProfile(profileData)
      })
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

  const syncProfile = async () => {
    setSyncing(true)
    setError('')

    try {
      const data = await apiRequest<MusicProfile>('/music-profile/sync', { method: 'POST' })
      setProfile(data)
    } catch {
      setError('Не удалось получить данные из Spotify')
    } finally {
      setSyncing(false)
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

  if (!user || !profile) return <main className="page"><div className="page-center"><Loader /></div></main>

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
                {profile.status === 'ready' ? (
                  <p>Ваши любимые исполнители и треки уже загружены.</p>
                ) : (
                  <p>Получим любимых исполнителей и треки из Spotify.</p>
                )}
                <Button onClick={syncProfile} disabled={syncing}>
                  {syncing ? 'Загружаем...' : profile.status === 'ready' ? 'Обновить профиль' : 'Создать профиль'}
                </Button>
                {profile.status === 'ready' && (
                  <Button variant="outline" onClick={() => window.location.href = '/profile'}>
                    Открыть профиль
                  </Button>
                )}
              </div>
            </div>
          </Card>

          <Card dark>
            <div className="action-card">
              <span className="action-card__number">02</span>
              <div className="stack">
                <h3>Сравнить с другом</h3>
                <p>Создание ссылки станет доступно после музыкального профиля.</p>
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

function ProfilePage() {
  const [profile, setProfile] = useState<MusicProfile | null>(null)
  const [error, setError] = useState('')

  useEffect(() => {
    apiRequest<MusicProfile>('/music-profile')
      .then(setProfile)
      .catch(() => setError('Не удалось загрузить музыкальный профиль'))
  }, [])

  if (error) {
    return <main className="page"><div className="page-center"><ErrorMessage>{error}</ErrorMessage></div></main>
  }

  if (!profile) return <main className="page"><div className="page-center"><Loader /></div></main>

  return (
    <div className="profile-page">
      <header className="topbar">
        <a className="brand" href="/home"><span>‹</span> Назад</a>
        <span className="topbar__title">Мой профиль</span>
      </header>

      <main className="profile-content">
        <section className="profile-heading">
          <Chip>Spotify</Chip>
          <h1>Моя музыка</h1>
          <p>Исполнители и треки, которые вы слушаете чаще всего.</p>
        </section>

        <ProfileList title="Любимые исполнители" items={profile.artists.slice(0, 15)} />
        <ProfileList title="Любимые треки" items={profile.tracks.slice(0, 15)} showArtist />
      </main>
    </div>
  )
}

function ProfileList({ title, items, showArtist = false }: { title: string; items: ProfileItem[]; showArtist?: boolean }) {
  return (
    <section className="profile-section">
      <div className="section-title">
        <h2>{title}</h2>
        <span>{items.length}</span>
      </div>

      <div className="music-list">
        {items.map((item, index) => (
          <a
            className="music-item"
            href={item.spotify_url || undefined}
            target={item.spotify_url ? '_blank' : undefined}
            rel="noreferrer"
            key={`${item.name}-${index}`}
          >
            <span className="music-item__number">{index + 1}</span>
            <span className="music-item__image">
              <span>{item.name.charAt(0).toUpperCase()}</span>
              {item.image_url && (
                <img
                  src={item.image_url}
                  alt=""
                  referrerPolicy="no-referrer"
                  onError={(event) => { event.currentTarget.style.display = 'none' }}
                />
              )}
            </span>
            <span className="music-item__text">
              <strong>{item.name}</strong>
              {showArtist && item.artist_name && <small>{item.artist_name}</small>}
            </span>
            <span className="music-item__arrow">›</span>
          </a>
        ))}
      </div>
    </section>
  )
}

function App() {
  if (window.location.pathname === '/ui-kit') return <UiKitPage />
  if (window.location.pathname === '/auth/callback') return <AuthCallbackPage />
  if (window.location.pathname === '/home') return <HomePage />
  if (window.location.pathname === '/profile') return <ProfilePage />
  return <LoginPage />
}

export default App
