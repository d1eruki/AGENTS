# Репозиторий инструкций для агентов

Глобальная инструкция задаёт обязательный порядок работы и направляет к тематическим маршрутизаторам. Те открывают только нужные для задачи инструкции и справочные материалы.

## Подключение

Весь репозиторий подключается как `~/.codex/agent-guidance`, а [`global.md`](./global.md) — как `~/.codex/AGENTS.md`. Codex загружает глобальную инструкцию в каждой задаче. Остальные файлы читаются по переходам из неё и тематических маршрутизаторов, а не автоматически по именам.

После клонирования репозитория или смены пути запусти синхронизатор. Он поддерживает две глобальные ссылки и удаляет только устаревшие ссылки на прежние 11 скиллов этой репы из `~/.agents/skills` и `~/.codex/skills`; чужие ссылки и обычные файлы не трогает.

```sh
./scripts/sync-guidance.sh
./scripts/sync-guidance.sh --check
```

## Иерархия

```text
.
├── global.md
├── frontend/
│   ├── index.md
│   └── references/
│       ├── engineering.md
│       ├── maintenance.md
│       ├── verification.md
│       ├── tailwind.md
│       └── vue.md
├── figma/
│   ├── index.md
│   └── references/
│       ├── design-system.md
│       ├── design-system-discovery.md
│       ├── design-system-rollout.md
│       ├── design-system-components.md
│       ├── design-system-foundations.md
│       ├── design-system-quality.md
│       ├── layout-structure.md
│       ├── layout-api.md
│       ├── wireframes.md
│       ├── wireframes-style.md
│       ├── wireframes-grid.md
│       ├── wireframes-sizing.md
│       ├── wireframes-text.md
│       └── wireframes-components.md
├── macos/
│   ├── index.md
│   └── references/
├── timeweb/
│   ├── index.md
│   └── references/
└── job-application/
    ├── index.md
    └── references/
```

Каждый тематический каталог содержит один `index.md` — точку входа с переходами по задачам. Отдельные инструкции и материалы лежат в `references/` и читаются только при необходимости; вложенные каталоги ради одного `index.md` не нужны. Например, рядом с инструкцией по откликам хранится исходное резюме PDF.

## Каталог инструкций

| Инструкция | Назначение |
| --- | --- |
| [`global.md`](./global.md) | Общие правила, план перед правками, маршрутизация и поддержание документации. |
| [`frontend/index.md`](./frontend/index.md) | Выбор ветки по задаче и стеку фронтенда. |
| [`frontend/references/engineering.md`](./frontend/references/engineering.md) | Сквозная архитектура и диагностика интерфейса. |
| [`frontend/references/maintenance.md`](./frontend/references/maintenance.md) | Совместимое обновление среды, зависимостей и инструментов. |
| [`frontend/references/verification.md`](./frontend/references/verification.md) | Устойчивые тесты и соразмерная проверка изменений. |
| [`frontend/references/tailwind.md`](./frontend/references/tailwind.md) | Оформление с Tailwind CSS, токенами и вариантами. |
| [`frontend/references/vue.md`](./frontend/references/vue.md) | Компоненты Vue, реактивность и владение состоянием. |
| [`figma/index.md`](./figma/index.md) | Выбор ветки по виду работы в Figma. |
| [`figma/references/design-system.md`](./figma/references/design-system.md) | Аудит, рефакторинг и внедрение дизайн-системы; переходы к подробным справочникам. |
| [`figma/references/layout-structure.md`](./figma/references/layout-structure.md) | Страницы Figma на сетке с переменными; API-нюансы в соседнем справочнике. |
| [`figma/references/wireframes.md`](./figma/references/wireframes.md) | Десктопные низкодетализированные вайрфреймы лендингов; переходы к подробным справочникам. |
| [`macos/index.md`](./macos/index.md) | Проектирование и проверка нативных интерфейсов macOS. |
| [`timeweb/index.md`](./timeweb/index.md) | Развёртывание на Timeweb, DNS, почта и HTTPS. |
| [`job-application/index.md`](./job-application/index.md) | Персонализированные отклики на вакансии по резюме. |
