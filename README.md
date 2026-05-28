# jihan-agent-source

Claude Code 와 OpenCode 에 배포할 역할 agent 와 doc skill 의 단일 원본. OSST (One Source Single Truth) 원칙에 따라 `source/` 아래 파일만 직접 수정하고, 각 런타임 배포물은 sync 스크립트로 생성한다.

마켓플레이스 이름과 단일 플러그인 이름 모두 `jihan-agents`.

## 구조

```text
jihan-agent-source/
├── source/                              # OSST 원본
│   ├── agents/
│   │   ├── notion-writer.md
│   │   ├── verifier-on-sandbox.md
│   │   ├── notion-doc-verifier.md
│   │   ├── notion-verifier-gui.md
│   │   ├── notion-verifier-concept.md
│   │   └── doc-librarian.md
│   ├── skills/
│   │   ├── general-doc-rules/SKILL.md
│   │   ├── method-doc-rules/SKILL.md
│   │   ├── doc-cluster/SKILL.md         # 이하 6개 = doc-librarian 이 조립하는 atomic skill
│   │   ├── doc-summarize/SKILL.md
│   │   ├── doc-index/SKILL.md
│   │   ├── doc-file/SKILL.md
│   │   ├── doc-scaffold/SKILL.md
│   │   └── doc-tier/SKILL.md
│   ├── hooks/
│   │   └── librarian-hooks.json         # doc-librarian SessionStart 스캔 (Claude Code 전용)
│   └── scripts/
│       └── librarian-scan.sh            # 도구 중립 스캔 (doc-scan, hook 이 호출)
├── plugins/
│   └── jihan-agents/                    # Claude Code 통합 플러그인 (6 agents + 8 skills + librarian hook)
├── distributions/
│   ├── opencode-plugin/                 # OpenCode 배포물
│   ├── gemini-extension/                # Gemini CLI 익스텐션 (agents → user-invokable skills 로 변환)
│   └── codex-plugin/                    # Codex CLI 플러그인 (agents → 최소 frontmatter skills 로 변환)
├── .claude-plugin/
│   └── marketplace.json
└── scripts/
    ├── install-all.sh
    └── sync-distributions.sh
```

## 수록 항목

| 이름                          | 유형    | 설명                                                                          |
| --------------------------- | ----- | --------------------------------------------------------------------------- |
| `general-doc-rules`         | skill | 문서 작성 공통 규칙                                                                 |
| `method-doc-rules`          | skill | 단계별 방법 문서 작성 규칙                                                             |
| `notion-writer`             | agent | Notion 페이지 작성, 수정 전담                                                        |
| `verifier-on-sandbox`       | agent | 문서 안의 셸 명령을 일회용 Ubuntu Docker 컨테이너에서 실행하고 pass/fail 보고                       |
| `notion-doc-verifier`       | agent | Notion how-to 문서 종합 검증 오케스트레이터. 블록을 CLI/GUI/concept lane 으로 분기하고 인라인 코멘트로 피드백 |
| `notion-verifier-gui`       | agent | GUI lane. 문서가 참조하는 공개 URL 가용성과 UI 라벨을 ghostdesk + WebFetch 로 확인              |
| `notion-verifier-concept`   | agent | Concept lane. 죽은 링크, 누락 단계, 모호한 지시, 출처와의 사실 불일치 검토                          |
| `doc-librarian`             | agent | 쌓인 markdown 을 주제별로 묶어 목차(INDEX)+챕터 요약 오버레이로 정리하는 **orchestrator**. 아래 atomic skill 들을 순서대로 조립. 원문은 안 건드림 |
| `doc-cluster`               | skill | 흩어진 md 를 내용 읽고 주제별로 그룹 (taxonomy 산출, 파일 안 씀)                            |
| `doc-summarize`             | skill | 한 주제의 문서들을 시놉시스 `_chapters/<topic>.md` 로 요약                              |
| `doc-index`                 | skill | taxonomy 로 Tier-0 목차 `INDEX.md` 생성/갱신 (기계적)                              |
| `doc-file`                  | skill | unfiled 문서 1개를 기존 taxonomy 에 편입 (분류 안정성 유지)                             |
| `doc-scaffold`              | skill | corpus 성격 보고 레퍼런스 폴더골격 (project → history/todo/WIP/handoffs)            |
| `doc-tier`                  | skill | catalog 가 임계 초과 시 챕터를 상위 parts 로 묶는 재귀 단계                              |

### doc-librarian 구조 (OMC 식 조립)

`doc-librarian` 은 monolith 가 아니라 **orchestrator agent + atomic skill** 구성이다. 측정(`librarian-scan.sh`) → 그룹(`doc-cluster` 또는 `doc-file`) → 요약(`doc-summarize`) → 목차(`doc-index`) → 골격(`doc-scaffold`) → 재귀(`doc-tier`) 순으로 필요한 단계만 돈다. 각 skill 은 단일책임이라 단독 호출도 가능하다.

`.agent/librarian.json` 에 관리 대상 폴더(`managed_roots`)와 임계값(`chapter_threshold_bytes` 기본 8192, `chapter_min_docs` 기본 3)을 선언한다. Claude Code 에서는 SessionStart 스캔 hook 이 임계 초과나 INDEX 보다 새로운 문서를 감지해 정리 시점을 알려준다 — config 가 없으면 hook 은 no-op. 수동 호출(`docs 정리해줘`)은 config 없이도 동작하며, 대상은 지정 폴더 → config → `docs/` 순으로 해결한다. hook 은 Claude Code 전용이고 다른 도구에서는 수동 호출만 된다.

```json
{
  "managed_roots": ["docs"],
  "chapter_threshold_bytes": 8192,
  "chapter_min_docs": 3
}
```

## Claude Code 설치

```bash
claude plugin marketplace add https://github.com/2JIHAN/jihan-agent-source
claude plugin install jihan-agents@jihan-agents
```

설치 확인.

```bash
claude plugin list
```

## OpenCode 설치

OpenCode 전역 config 에 skills 와 agent 를 설치한다.

```bash
git clone https://github.com/2JIHAN/jihan-agent-source ~/jihan-agent-source
~/jihan-agent-source/distributions/opencode-plugin/install-global.sh
```

OpenCode 는 다음 경로에서 자동 발견한다.

```text
~/.config/opencode/skills/<name>/SKILL.md
~/.config/opencode/agents/<name>.md
```

## Gemini CLI 설치

원본 agent 가 Gemini 의 SKILL.md 포맷 (`user-invokable: true|false` 포함) 으로 변환되어 `distributions/gemini-extension/` 에 들어있다.

```bash
git clone https://github.com/2JIHAN/jihan-agent-source ~/jihan-agent-source
gemini extensions install ~/jihan-agent-source/distributions/gemini-extension
```

개발 중 source 변경을 실시간으로 반영하려면 `install` 대신 `link` 사용.

```bash
gemini extensions link ~/jihan-agent-source/distributions/gemini-extension
```

확인.

```bash
gemini extensions list
```

Claude Code 의 sub-agent 위임은 Gemini 에서는 SKILL activation 으로 매핑된다. 도구 이름 차이 (`Bash` → `run_shell_command`, `WebFetch` → `web_fetch` 등) 는 익스텐션의 `GEMINI.md` 안 매핑 표를 참고. Notion MCP, ghostdesk MCP 등 외부 의존은 `~/.gemini/settings.json` 의 `mcpServers` 에 동일하게 등록 필요.

## Codex CLI 설치

원본 agent 가 Codex 의 SKILL.md 포맷 (frontmatter `name`, `description`) 으로 변환되어 `distributions/codex-plugin/` 에 들어있다. `.codex-plugin/plugin.json` manifest 포함.

```bash
git clone https://github.com/2JIHAN/jihan-agent-source ~/jihan-agent-source
```

로컬 plugin 폴더를 Codex 가 찾을 수 있는 위치에 복사 또는 심볼릭 링크.

```bash
ln -s ~/jihan-agent-source/distributions/codex-plugin ~/.codex/plugins/jihan-agents
```

설치 확인은 `codex` 실행 후 사용 가능한 skill 목록에 7개 (`notion-writer`, `verifier-on-sandbox`, `notion-doc-verifier`, `notion-verifier-gui`, `notion-verifier-concept`, `general-doc-rules`, `method-doc-rules`) 가 노출되는지로 판단. 정식 plugin 설치 명령은 Codex 버전에 따라 달라지므로 변동 시 README 갱신 예정.

Gemini 와 동일하게 sub-agent 위임은 skill activation 으로 처리되고, MCP 도구는 Codex 의 MCP 설정에 동일한 서버를 등록해야 한다.

## 업데이트 흐름

1. `source/` 아래 원본만 수정.
   ```bash
   $EDITOR source/skills/method-doc-rules/SKILL.md
   ```
2. 배포물 동기화.
   ```bash
   scripts/sync-distributions.sh
   ```
3. 필요한 런타임에 반영.
   ```bash
   distributions/opencode-plugin/install-global.sh
   claude plugin marketplace update jihan-agents
   claude plugin install jihan-agents@jihan-agents
   # Gemini 는 link 로 설치했다면 자동 반영, install 로 설치했다면 다시 install
   ```
4. 변경 사항 커밋 후 푸시.
   ```bash
   git add -A
   git commit -m "..."
   git push
   ```

## 새 역할 추가

1. `source/agents/<new-role>.md` 작성. frontmatter 의 `name`, `description`, `model` 채우기.
2. `scripts/sync-distributions.sh` 의 `AGENTS=()` 배열 끝에 새 이름 한 줄 추가.
3. `scripts/sync-distributions.sh` 실행. `plugins/jihan-agents/agents/` 와 OpenCode 배포물에 자동 복사.
4. 커밋, 푸시. 사용자는 `claude plugin marketplace update jihan-agents` 한 번이면 반영.

## 규칙 변경 원칙

룰에 대한 피드백을 받으면 로컬 메모리, `CLAUDE.md`, 개별 프로젝트 메모리에 저장하지 않고 `source/` 아래 원본을 수정한 뒤 `scripts/sync-distributions.sh` 로 배포물을 갱신한다. 단일 원본을 유지하기 위함.
