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

type ComparisonUser = {
  id: number
  name: string
  avatar_url: string | null
}

type Comparison = {
  invite_token: string
  invite_url: string
  status: 'waiting' | 'completed'
  score: number | null
  creator: ComparisonUser
  guest: ComparisonUser | null
  common_artists: ProfileItem[]
  common_tracks: ProfileItem[]
  is_creator: boolean
  can_join: boolean
}

const PENDING_COMPARISON_KEY = 'musicmate_pending_comparison'

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
    const pendingPath = localStorage.getItem(PENDING_COMPARISON_KEY)
    localStorage.removeItem(PENDING_COMPARISON_KEY)
    window.location.replace(pendingPath || '/home')
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
  const [creatingComparison, setCreatingComparison] = useState(false)

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

  const createComparison = async () => {
    setCreatingComparison(true)
    setError('')

    try {
      const comparison = await apiRequest<Comparison>('/comparisons', { method: 'POST' })
      window.location.href = `/compare/${comparison.invite_token}`
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'Не удалось создать сравнение')
      setCreatingComparison(false)
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
                <p>{profile.status === 'ready' ? 'Создайте ссылку и отправьте её другу.' : 'Создание ссылки станет доступно после музыкального профиля.'}</p>
                <Button variant="light" onClick={createComparison} disabled={profile.status !== 'ready' || creatingComparison}>
                  {creatingComparison ? 'Создаём...' : 'Создать приглашение'}
                </Button>
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
        {items.length === 0 && <p className="empty-list">Совпадений пока нет</p>}
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

function ComparisonPage({ token }: { token: string }) {
  const [comparison, setComparison] = useState<Comparison | null>(null)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(Boolean(getToken()))
  const [joining, setJoining] = useState(false)
  const [copied, setCopied] = useState(false)
  const authorized = Boolean(getToken())

  const loadComparison = useCallback(() => {
    if (!getToken()) return

    apiRequest<Comparison>(`/comparisons/${token}`)
      .then((data) => {
        setError('')
        setComparison(data)
        localStorage.removeItem(PENDING_COMPARISON_KEY)
      })
      .catch((requestError) => {
        setError(requestError instanceof Error ? requestError.message : 'Не удалось загрузить сравнение')
      })
      .finally(() => setLoading(false))
  }, [token])

  useEffect(() => {
    if (!authorized) {
      localStorage.setItem(PENDING_COMPARISON_KEY, `/compare/${token}`)
      return
    }

    loadComparison()
  }, [authorized, loadComparison, token])

  const login = () => {
    localStorage.setItem(PENDING_COMPARISON_KEY, `/compare/${token}`)
    window.location.href = `${API_URL}/auth/spotify`
  }

  const joinComparison = async () => {
    setJoining(true)
    setError('')

    try {
      const data = await apiRequest<Comparison>(`/comparisons/${token}/join`, { method: 'POST' })
      setComparison(data)
    } catch (requestError) {
      setError(requestError instanceof Error ? requestError.message : 'Не удалось присоединиться')
    } finally {
      setJoining(false)
    }
  }

  const copyInvite = async () => {
    if (!comparison) return

    try {
      await navigator.clipboard.writeText(comparison.invite_url)
      setCopied(true)
    } catch {
      setError('Не удалось скопировать ссылку')
    }
  }

  if (!authorized) {
    return (
      <main className="page">
        <div className="page-center">
          <section className="hero-panel stack">
            <Chip>Приглашение</Chip>
            <h1>Сравним музыку</h1>
            <p>Войдите через Spotify, чтобы открыть приглашение друга.</p>
            <Button variant="light" onClick={login}>Войти через Spotify</Button>
          </section>
        </div>
      </main>
    )
  }

  if (loading) return <main className="page"><div className="page-center"><Loader text="Загружаем сравнение..." /></div></main>

  if (error && !comparison) {
    return (
      <main className="page"><div className="page-center">
        <ErrorMessage>{error}</ErrorMessage>
        <Button onClick={loadComparison}>Попробовать снова</Button>
        <Button variant="outline" onClick={() => window.location.href = '/home'}>На главную</Button>
      </div></main>
    )
  }

  if (!comparison) return null

  return (
    <div className="comparison-page">
      <header className="topbar">
        <a className="brand" href="/home"><span>‹</span> Назад</a>
        <span className="topbar__title">Сравнение</span>
      </header>

      {comparison.status === 'waiting' ? (
        <main className="comparison-content">
          <section className="comparison-heading">
            <Chip>{comparison.is_creator ? 'Ждём друга' : 'Приглашение'}</Chip>
            <h1>{comparison.is_creator ? 'Ссылка готова' : `${comparison.creator.name} приглашает вас`}</h1>
            <p>{comparison.is_creator ? 'Отправьте эту ссылку другу. После его входа обновите страницу.' : 'Присоединитесь, чтобы узнать вашу музыкальную совместимость.'}</p>
          </section>

          {error && <ErrorMessage>{error}</ErrorMessage>}

          {comparison.is_creator ? (
            <Card>
              <div className="stack">
                <label className="invite-label" htmlFor="invite-link">Ссылка-приглашение</label>
                <input id="invite-link" className="invite-input" value={comparison.invite_url} readOnly />
                <Button onClick={copyInvite}>{copied ? 'Ссылка скопирована' : 'Скопировать ссылку'}</Button>
                <Button variant="outline" onClick={loadComparison}>Обновить страницу</Button>
              </div>
            </Card>
          ) : (
            <Card>
              <div className="join-card">
                <Avatar src={comparison.creator.avatar_url} name={comparison.creator.name} />
                <div>
                  <span>Сравнение с</span>
                  <h3>{comparison.creator.name}</h3>
                </div>
              </div>
              <Button onClick={joinComparison} disabled={!comparison.can_join || joining}>
                {joining ? 'Сравниваем...' : 'Присоединиться'}
              </Button>
            </Card>
          )}
        </main>
      ) : (
        <ComparisonResult comparison={comparison} />
      )}
    </div>
  )
}

function ComparisonResult({ comparison }: { comparison: Comparison }) {
  return (
    <main className="comparison-result">
      <section className="score-panel">
        <Chip>Результат</Chip>
        <div className="comparison-users">
          <Avatar src={comparison.creator.avatar_url} name={comparison.creator.name} />
          <span>+</span>
          {comparison.guest && <Avatar src={comparison.guest.avatar_url} name={comparison.guest.name} />}
        </div>
        <strong className="score">{comparison.score}%</strong>
        <h1>Музыкальная совместимость</h1>
        <p>{comparison.creator.name} и {comparison.guest?.name}</p>
      </section>

      <ProfileList title="Общие исполнители" items={comparison.common_artists} />
      <ProfileList title="Общие треки" items={comparison.common_tracks} showArtist />

      <div className="comparison-actions">
        <Button onClick={() => window.location.href = '/home'}>На главную</Button>
      </div>
    </main>
  )
}

function App() {
  if (window.location.pathname === '/ui-kit') return <UiKitPage />
  if (window.location.pathname === '/auth/callback') return <AuthCallbackPage />
  if (window.location.pathname === '/home') return <HomePage />
  if (window.location.pathname === '/profile') return <ProfilePage />
  const comparisonMatch = window.location.pathname.match(/^\/compare\/([^/]+)$/)
  if (comparisonMatch) return <ComparisonPage token={comparisonMatch[1]} />
  return <LoginPage />
}

export default App
