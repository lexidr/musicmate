import { Avatar, Button, Card, Chip, ErrorMessage, Loader } from './components/ui'

export function UiKitPage() {
  return (
    <main className="page">
      <section className="ui-kit-section">
        <Chip>UI Kit</Chip>
        <h1>musicmate</h1>
        <p>Базовые компоненты интерфейса.</p>
      </section>

      <section className="ui-kit-section ui-kit-section--dark">
        <h2>Кнопки</h2>
        <Button variant="light">Основное действие</Button>
        <Button variant="outline">Вторичное действие</Button>
        <Button variant="text">Текстовая ссылка →</Button>
      </section>

      <section className="ui-kit-section">
        <h2>Компоненты</h2>
        <Card>
          <div className="stack">
            <Chip>Совместимость</Chip>
            <h3>Музыкальный профиль</h3>
            <p>Исполнители и треки из Spotify.</p>
          </div>
        </Card>
        <Card dark>
          <div className="stack">
            <h3>Тёмная карточка</h3>
            <p>Для контрастных блоков интерфейса.</p>
          </div>
        </Card>
        <Avatar name="Анна" />
        <Loader />
        <ErrorMessage>Что-то пошло не так</ErrorMessage>
      </section>
    </main>
  )
}
