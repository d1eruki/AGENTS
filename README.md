# Agent Skills Repository

Хранилище skills для AI-агентов. Репозиторий содержит переиспользуемые инструкции, workflow, справочные материалы и метаданные, которые расширяют поведение агентов под конкретные задачи.

## Назначение

Skills помогают агентам работать предсказуемо: задают область применения, ограничения, последовательность действий, требования к инструментам и формат результата. Каждый skill хранится в отдельной директории и может включать основной `SKILL.md`, настройки для разных агентских runtime, ссылки на справочные материалы и вспомогательные файлы.

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
| [`repository-workflow`](./repository-workflow/SKILL.md)                   | Задаёт проверку репозитория, согласование scope, краткую коммуникацию и поддержку инструкций.                          |
| [`tailwind-engineering`](./tailwind-engineering/SKILL.md)                 | Реализует и диагностирует Tailwind CSS через utilities, tokens, variants и обоснованные расширения.                    |
| [`timeweb-deployment`](./timeweb-deployment/SKILL.md)                 | Пошагово разворачивает сайты на обычном Timeweb через GitHub Actions и безопасно переносит DNS, почту и HTTPS.          |
| [`vue-engineering`](./vue-engineering/SKILL.md)                           | Реализует и диагностирует Vue-компоненты, реактивность, composables и владение состоянием.                             |

## Формат Skill

Рекомендации:

- `SKILL.md` содержит frontmatter с `name` и `description`, затем полную инструкцию для агента.
- `description` должен четко описывать, когда skill нужно использовать и когда не нужно.
- `agents/` хранит runtime-specific метаданные, если они нужны.
- `references/` хранит справочные материалы, которые агент должен читать только при необходимости.
- Skill должен быть самодостаточным: агенту должно хватать содержимого директории, чтобы выполнить задачу.
