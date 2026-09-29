export const API_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:3000/api/v1'
const TOKEN_KEY = 'musicmate_token'

export function getToken() {
  return localStorage.getItem(TOKEN_KEY)
}

export function saveToken(token: string) {
  localStorage.setItem(TOKEN_KEY, token)
}

export function clearToken() {
  localStorage.removeItem(TOKEN_KEY)
}

export async function apiRequest<T>(path: string, options: RequestInit = {}) {
  const token = getToken()
  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      ...options.headers,
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  })

  if (response.status === 401) {
    clearToken()
    window.location.replace('/')
    throw new Error('Unauthorized')
  }

  const body = await response.json()
  if (!response.ok) throw new Error(body.error?.message || 'Request failed')

  return body.data as T
}
