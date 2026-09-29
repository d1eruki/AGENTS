# Agent Guidance And Skills Repository

Хранилище глобальных инструкций и специализированных skills для AI-агентов. Глобальная инструкция задаёт обязательный workflow и маршрутизацию, а skills содержат подробные процедуры для конкретных задач.

## Назначение

Весь репозиторий подключается как `~/.codex/agent-guidance`, а [`instructions/global.md`](./instructions/global.md) — как `~/.codex/AGENTS.md`. Глобальная инструкция действует во всех проектах, а тематические роутеры загружают только релевантные skills, чтобы подробные инструкции не занимали контекст каждой задачи.

Папки skills подключаются в `~/.agents/skills` симлинками. Синхронизатор также поддерживает глобальные ссылки и удаляет прежние ссылки этого репозитория из `~/.codex/skills`. После клонирования репозитория или добавления, удаления, переименования либо перемещения skill необходимо выполнить:

```sh
./scripts/sync-skills.sh
./scripts/sync-skills.sh --check
```

## Skills

| Skill                                                                     | Описание                                                                                                               |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| [`design-macos-apps`](./design-macos-apps/SKILL.md)                       | Проектирует, реализует и проверяет нативные интерфейсы macOS по Apple Human Interface Guidelines.                      |
| [`figma-design-system-refactor`](./figma-design-system-refactor/SKILL.md) | Аудирует, рефакторит и внедряет дизайн-системы в существующих Figma-файлах.                                            |
| [`figma-layout-structure`](./figma-layout-structure/SKILL.md)             | Собирает блоки и страницы в Figma на сетке из переменных: блок во всю ширину, контейнер по центру, фоны навылет.        |
| [`figma-wireframes-generator`](./figma-wireframes-generator/SKILL.md)     | Генерирует desktop low-fidelity wireframes для landing pages и связанных страниц в текущем Figma-файле.                |
| [`frontend-engineering`](./frontend-engineering/SKILL.md)                 | Применяет общие подходы к реализации и диагностике frontend-интерфейсов и подключает доступные технологические skills. |
| [`frontend-maintenance`](./frontend-maintenance/SKILL.md)                 | Аудирует и безопасно обновляет runtime, зависимости и frontend-tooling как совместимую систему.                        |
| [`frontend-verification`](./frontend-verification/SKILL.md)               | Проектирует долговечные frontend-тесты и выбирает пропорциональную проверку изменений.                                 |
| [`job-application-writer`](./job-application-writer/SKILL.md)             | Создаёт краткие персонализированные отклики на вакансии на основе резюме и требований работодателя.                    |
| [`tailwind-engineering`](./tailwind-engineering/SKILL.md)                 | Реализует и диагностирует Tailwind CSS через utilities, tokens, variants и обоснованные расширения.                    |
| [`timeweb-deployment`](./timeweb-deployment/SKILL.md)                    | Пошагово разворачивает сайты на обычном Timeweb через GitHub Actions и безопасно переносит DNS, почту и HTTPS.          |
| [`vue-engineering`](./vue-engineering/SKILL.md)                           | Реализует и диагностирует Vue-компоненты, реактивность, composables и владение состоянием.                             |

## Формат Skill

Рекомендации:

- `SKILL.md` содержит frontmatter с `name` и `description`, затем полную инструкцию для агента.
- `description` должен четко описывать, когда skill нужно использовать и когда не нужно.
- `agents/` хранит runtime-specific метаданные, если они нужны.
- `references/` хранит справочные материалы, которые агент должен читать только при необходимости.
- Skill должен быть самодостаточным: агенту должно хватать содержимого директории, чтобы выполнить задачу.
- Обязательные правила, применимые к каждой задаче, хранятся в глобальной инструкции, а не дублируются в skills.
