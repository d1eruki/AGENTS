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
│   ├── engineering/index.md
│   ├── maintenance/index.md
│   ├── verification/index.md
│   ├── tailwind/index.md
│   └── vue/index.md
├── figma/
│   ├── index.md
│   ├── design-system-refactor/index.md
│   ├── layout-structure/index.md
│   └── wireframes/index.md
├── macos/index.md
├── timeweb/index.md
└── job-application/index.md
```

Тематические каталоги могут содержать `references/` — справочные файлы, которые инструкция открывает только при необходимости. Например, рядом с инструкцией по откликам хранится исходное резюме PDF.

## Каталог инструкций

| Инструкция | Назначение |
| --- | --- |
| [`global.md`](./global.md) | Общие правила, план перед правками, маршрутизация и поддержание документации. |
| [`frontend/index.md`](./frontend/index.md) | Выбор ветки по задаче и стеку фронтенда. |
| [`frontend/engineering/index.md`](./frontend/engineering/index.md) | Сквозная архитектура и диагностика интерфейса. |
| [`frontend/maintenance/index.md`](./frontend/maintenance/index.md) | Совместимое обновление среды, зависимостей и инструментов. |
| [`frontend/verification/index.md`](./frontend/verification/index.md) | Устойчивые тесты и соразмерная проверка изменений. |
| [`frontend/tailwind/index.md`](./frontend/tailwind/index.md) | Оформление с Tailwind CSS, токенами и вариантами. |
| [`frontend/vue/index.md`](./frontend/vue/index.md) | Компоненты Vue, реактивность и владение состоянием. |
| [`figma/index.md`](./figma/index.md) | Выбор ветки по виду работы в Figma. |
| [`figma/design-system-refactor/index.md`](./figma/design-system-refactor/index.md) | Аудит, рефакторинг и внедрение дизайн-системы. |
| [`figma/layout-structure/index.md`](./figma/layout-structure/index.md) | Страницы Figma на сетке с переменными. |
| [`figma/wireframes/index.md`](./figma/wireframes/index.md) | Десктопные низкодетализированные вайрфреймы лендингов. |
| [`macos/index.md`](./macos/index.md) | Проектирование и проверка нативных интерфейсов macOS. |
| [`timeweb/index.md`](./timeweb/index.md) | Развёртывание на Timeweb, DNS, почта и HTTPS. |
| [`job-application/index.md`](./job-application/index.md) | Персонализированные отклики на вакансии по резюме. |
