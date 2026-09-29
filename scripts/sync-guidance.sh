#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd "${script_dir}/.." && pwd -P)"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
skill_home="${AGENT_SKILLS_HOME:-${HOME}/.agents/skills}"
legacy_skill_home="${codex_home}/skills"
guidance_link="${codex_home}/agent-guidance"
global_agents_link="${codex_home}/AGENTS.md"
global_agents_source="${repo_root}/global.md"
mode="${1:-sync}"

former_skill_names=(
  design-macos-apps
  figma-design-system-refactor
  figma-layout-structure
  figma-wireframes-generator
  frontend-engineering
  frontend-maintenance
  frontend-verification
  job-application-writer
  tailwind-engineering
  timeweb-deployment
  vue-engineering
)

if [[ "${mode}" != "sync" && "${mode}" != "--check" ]]; then
  echo "Использование: $0 [--check]" >&2
  exit 2
fi

if [[ "${mode}" == "sync" ]]; then
  mkdir -p "${codex_home}"
elif [[ ! -d "${codex_home}" ]]; then
  echo "Каталог Codex не найден: ${codex_home}" >&2
  exit 1
fi

drift=0

ensure_link() {
  local source_path="$1"
  local link_path="$2"
  local existing_target

  if [[ -L "${link_path}" ]]; then
    if [[ -e "${link_path}" && "${link_path}" -ef "${source_path}" ]]; then
      return
    fi

    existing_target="$(readlink "${link_path}")"
    if [[ "${existing_target}" != "${repo_root}" && "${existing_target}" != "${repo_root}/"* ]]; then
      echo "Конфликт: ${link_path} указывает за пределы этого репозитория (${existing_target})" >&2
      exit 1
    fi

    if [[ "${mode}" == "--check" ]]; then
      echo "Устаревшая ссылка: ${link_path}" >&2
      drift=1
    else
      ln -sfn "${source_path}" "${link_path}"
      echo "Обновлена ссылка ${link_path}"
    fi
  elif [[ -e "${link_path}" ]]; then
    echo "Конфликт: ${link_path} существует, но это не управляемый симлинк" >&2
    exit 1
  elif [[ "${mode}" == "--check" ]]; then
    echo "Отсутствует ссылка: ${link_path}" >&2
    drift=1
  else
    ln -s "${source_path}" "${link_path}"
    echo "Создана ссылка ${link_path}"
  fi
}

remove_former_links() {
  local directory="$1"
  local name link_path existing_target
  [[ -d "${directory}" ]] || return

  for name in "${former_skill_names[@]}"; do
    link_path="${directory}/${name}"
    [[ -L "${link_path}" ]] || continue
    existing_target="$(readlink "${link_path}")"
    [[ "${existing_target}" == "${repo_root}/${name}" ]] || continue

    if [[ "${mode}" == "--check" ]]; then
      echo "Устаревшая ссылка: ${link_path}" >&2
      drift=1
    else
      rm "${link_path}"
      echo "Удалена ссылка ${link_path}"
    fi
  done
}

ensure_link "${repo_root}" "${guidance_link}"
ensure_link "${global_agents_source}" "${global_agents_link}"
remove_former_links "${skill_home}"
remove_former_links "${legacy_skill_home}"

if [[ "${drift}" -ne 0 ]]; then
  exit 1
fi

if [[ "${mode}" == "sync" ]]; then
  "${BASH_SOURCE[0]}" --check
else
  echo "Глобальные ссылки синхронизированы."
fi
