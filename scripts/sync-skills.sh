#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd "${script_dir}/.." && pwd -P)"
skill_home="${AGENT_SKILLS_HOME:-${HOME}/.agents/skills}"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
guidance_link="${codex_home}/agent-guidance"
global_agents_link="${codex_home}/AGENTS.md"
global_agents_source="${repo_root}/instructions/global.md"
legacy_skill_home="${codex_home}/skills"
mode="${1:-sync}"

if [[ "${mode}" != "sync" && "${mode}" != "--check" ]]; then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi

desired_names="$(mktemp)"
trap 'rm -f "${desired_names}"' EXIT

find "${repo_root}" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -print \
  | while IFS= read -r skill_file; do basename "$(dirname "${skill_file}")"; done \
  | LC_ALL=C sort -u > "${desired_names}"

if [[ "${mode}" == "sync" ]]; then
  mkdir -p "${skill_home}"
  mkdir -p "${codex_home}"
elif [[ ! -d "${skill_home}" ]]; then
  echo "Missing skill directory: ${skill_home}" >&2
  exit 1
fi

drift=0

ensure_link() {
  local source_path="$1"
  local link_path="$2"

  if [[ -L "${link_path}" ]]; then
    if [[ -e "${link_path}" && "${link_path}" -ef "${source_path}" ]]; then
      return
    fi

    existing_target="$(readlink "${link_path}")"
    if [[ "${existing_target}" != "${repo_root}" && "${existing_target}" != "${repo_root}/"* ]]; then
      echo "Conflict: ${link_path} points outside this repository (${existing_target})" >&2
      exit 1
    fi

    if [[ "${mode}" == "--check" ]]; then
      echo "Outdated link: ${link_path}" >&2
      drift=1
    else
      ln -sfn "${source_path}" "${link_path}"
      echo "Updated ${link_path}"
    fi
  elif [[ -e "${link_path}" ]]; then
    echo "Conflict: ${link_path} exists and is not a managed symlink" >&2
    exit 1
  elif [[ "${mode}" == "--check" ]]; then
    echo "Missing link: ${link_path}" >&2
    drift=1
  else
    ln -s "${source_path}" "${link_path}"
    echo "Created ${link_path}"
  fi
}

if [[ -z "${AGENT_SKILLS_HOME:-}" ]]; then
  ensure_link "${repo_root}" "${guidance_link}"
  ensure_link "${global_agents_source}" "${global_agents_link}"
fi

while IFS= read -r skill_name; do
  [[ -n "${skill_name}" ]] || continue

  source_dir="${repo_root}/${skill_name}"
  link_path="${skill_home}/${skill_name}"

  if [[ -L "${link_path}" ]]; then
    if [[ -e "${link_path}" && "${link_path}" -ef "${source_dir}" ]]; then
      continue
    fi

    existing_target="$(readlink "${link_path}")"
    if [[ "${existing_target}" != "${repo_root}/"* ]]; then
      echo "Conflict: ${link_path} points outside this repository (${existing_target})" >&2
      exit 1
    fi

    if [[ "${mode}" == "--check" ]]; then
      echo "Outdated link: ${link_path}" >&2
      drift=1
    else
      ln -sfn "${source_dir}" "${link_path}"
      echo "Updated ${link_path}"
    fi
  elif [[ -e "${link_path}" ]]; then
    echo "Conflict: ${link_path} exists and is not a managed symlink" >&2
    exit 1
  elif [[ "${mode}" == "--check" ]]; then
    echo "Missing link: ${link_path}" >&2
    drift=1
  else
    ln -s "${source_dir}" "${link_path}"
    echo "Created ${link_path}"
  fi
done < "${desired_names}"

while IFS= read -r link_path; do
  existing_target="$(readlink "${link_path}")"
  [[ "${existing_target}" == "${repo_root}/"* ]] || continue

  skill_name="$(basename "${link_path}")"
  if grep -Fqx "${skill_name}" "${desired_names}"; then
    continue
  fi

  if [[ "${mode}" == "--check" ]]; then
    echo "Stale link: ${link_path}" >&2
    drift=1
  else
    rm "${link_path}"
    echo "Removed ${link_path}"
  fi
done < <(find "${skill_home}" -mindepth 1 -maxdepth 1 -type l -print)

if [[ -z "${AGENT_SKILLS_HOME:-}" && -d "${legacy_skill_home}" ]]; then
  while IFS= read -r link_path; do
    existing_target="$(readlink "${link_path}")"
    [[ "${existing_target}" == "${repo_root}/"* ]] || continue

    if [[ "${mode}" == "--check" ]]; then
      echo "Legacy link: ${link_path}" >&2
      drift=1
    else
      rm "${link_path}"
      echo "Removed legacy link ${link_path}"
    fi
  done < <(find "${legacy_skill_home}" -mindepth 1 -maxdepth 1 -type l -print)
fi

if [[ "${drift}" -ne 0 ]]; then
  exit 1
fi

if [[ "${mode}" == "sync" ]]; then
  "${BASH_SOURCE[0]}" --check
else
  echo "Skill links are synchronized."
fi
