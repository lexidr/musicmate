import type { ButtonHTMLAttributes, ReactNode } from 'react'

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'accent' | 'light' | 'outline' | 'text'
}

export function Button({ variant = 'accent', className = '', ...props }: ButtonProps) {
  return <button className={`button button--${variant} ${className}`} {...props} />
}

export function Card({ children, dark = false }: { children: ReactNode; dark?: boolean }) {
  return <section className={`card ${dark ? 'card--dark' : ''}`}>{children}</section>
}

export function Chip({ children }: { children: ReactNode }) {
  return <span className="chip">{children}</span>
}

export function Avatar({ src, name }: { src?: string | null; name: string }) {
  if (src) return <img className="avatar" src={src} alt={`Аватар ${name}`} />

  return <div className="avatar avatar--fallback">{name.charAt(0).toUpperCase()}</div>
}

export function Loader({ text = 'Загрузка...' }: { text?: string }) {
  return (
    <div className="loader" role="status">
      <span className="loader__circle" />
      <span>{text}</span>
    </div>
  )
}

export function ErrorMessage({ children }: { children: ReactNode }) {
  return <p className="error-message">{children}</p>
}
