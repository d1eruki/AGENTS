---
name: job-application-writer
description: Write concise, personalized cover letters and vacancy responses by matching a specific job posting to the candidate's resume. Use for drafting or improving an application letter; do not invent experience, skills, metrics, or company facts.
---

# Job Application Writer

Create a short application that lets a recruiter quickly see the candidate's relevant value, concrete motivation, and familiarity with the vacancy.

## Required Inputs

Use the vacancy text or URL and the candidate's resume as the factual basis. For Artem Treskov, read the bundled [resume PDF](references/artem-treskov-resume.pdf) as the authoritative candidate source. If the user supplies a newer resume, use it instead. If neither source is available, ask the user to attach the resume or provide its contents; do not reconstruct it from memory or the vacancy.

Use these fixed contact links for Artem Treskov unless the user supplies replacements:

```text
Portfolio: https://d1eruki.github.io/port-heaven/
Telegram: https://t.me/d1eruki
```

## Workflow

1. Extract the role, seniority, core tasks, must-have skills, useful extras, product context, and tone from the vacancy.
2. Extract only supported evidence from the resume: projects, responsibilities, tools, domain experience, outcomes, and work approach.
3. Match the strongest two or three pieces of evidence to the employer's priorities. Prefer outcomes and completed actions over tool lists.
4. When current company information or a vacancy URL is available, inspect reliable public sources for one specific, verifiable motivation point. Never fabricate a product, culture, technology, project, or personal product usage. If research is impossible, ground motivation in the supplied vacancy and say nothing that implies external research.
5. Handle a genuine gap briefly and positively only when it matters: state the actual level of exposure and readiness to learn. Do not apologize or claim rapid mastery as a fact.
6. Draft two or three compact paragraphs in a clear sequence: introduction, relevant evidence, specific motivation, and invitation to continue the conversation. Follow with the contact block. Aim for roughly 20–30 seconds of reading time.
7. Check every factual claim against the resume, vacancy, or verified company source. Verify the candidate and recruiter names, company, role, grammatical gender, spelling, and contact completeness. Remove generic praise, irrelevant experience, unsupported metrics, and duplicated resume content.

Return the finished letter without analysis unless the user asks for variants, rationale, or a fit assessment.

## Writing Standard

- Adapt formality to the employer while staying professional, natural, and restrained.
- Open with the recruiter's name when known; otherwise use `Здравствуйте!`. Use `Привет!` only when the vacancy clearly establishes an informal, first-name tone.
- Introduce the candidate by first name, without repeating the full name or patronymic already present in the resume.
- Identify the vacancy briefly. Mention where it was found when the source is known.
- Write with active verbs such as `проектировал`, `исследовал`, `запускал`, and `работал`.
- Show soft skills through evidence and tone, not a list of adjectives.
- Make motivation specific to the product, audience, task type, mission, process, or technology. Connect that hook to relevant candidate evidence and the contribution it could support.
- In Russian, write the respectful pronoun `вы` with a lowercase letter unless the user requests another convention.
- Close with a calm invitation to discuss the experience. Mention a test assignment only when appropriate; never volunteer extensive unpaid work.
- Preserve the language of the user's request or the vacancy unless the user specifies another language.

Do not use canned openings such as `Доброго времени суток`, `Уважаемый сотрудник HR`, `Пишу, чтобы выразить заинтересованность`, `Буду признателен за рассмотрение кандидатуры`, or `Хочу у вас работать`. Avoid bureaucracy, flattery, pleading, pressure, claims of being the ideal candidate, aggressive confidence, and demands. Delete generic promises such as `смогу внести значительный вклад` when they are not supported by a concrete action or example.

For detailed selection and editing criteria, read [references/writing-guide.md](references/writing-guide.md).
