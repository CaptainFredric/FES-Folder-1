# DanDeBugger automation — how to push the persona file to repos

This repo contains a local copy of the DanDeBugger prompt instructions and two helper scripts to distribute it to existing repositories.

Files added:
- `docs/DanDeBugger.md` — canonical copy of your VS Code Copilot prompt instructions.
- `scripts/gh_add_dan_prs.sh` — uses GitHub CLI to clone each repo in your account, create a branch, add `docs/DanDeBugger.md`, push and open a PR. Dry-run by default.
- `scripts/copy_dan_local.sh` — walks local git clones under a base directory and copies the file into `.vscode/DanDeBugger.md`. Dry-run by default.

Quick start — prerequisites
- Install GitHub CLI and authenticate: `gh auth login`
- Ensure `git` is installed and you have push permissions for the target repos.
- Make scripts executable: `chmod +x scripts/*.sh`

Using the GH PR script (safe, recommended)
1. Review `docs/DanDeBugger.md` and change it if needed.
2. Dry-run (default):

```bash
./scripts/gh_add_dan_prs.sh ./docs/DanDeBugger.md
```

This will print what it would do without modifying repos.

3. To actually create branches, push and open PRs, run:

```bash
./scripts/gh_add_dan_prs.sh ./docs/DanDeBugger.md --apply
```

Notes:
- The script assumes your GitHub username is `CaptainFredric` and the default branch is `main`. Edit the script if different.
- The script creates PRs so you can review changes before merging. This is safer than direct commits.

Using the local copy script (for local clones)
1. Dry-run example (prints actions):

```bash
./scripts/copy_dan_local.sh /absolute/path/to/docs/DanDeBugger.md /Users/erendiracisneros/Documents/GitHub
```

2. To actually apply changes, answer prompts and type `apply` when requested.

Recommendations
- Test both scripts on 1–3 non-critical repos first.
- Prefer the GH PR approach for remote repos (auditable, reviewable).
- Use a template repository for new repos so they include the file by default.

Template repository (create once, use forever)
1. Prepare the `template-repo/` folder in this workspace (already provided). It contains `docs/DanDeBugger.md`, `CONTRIBUTING.md`, and a minimal `.gitignore`.
2. Create a new GitHub repository named e.g. `dan-de-bugger-template` and push the `template-repo/` contents to it:

```bash
# from the workspace root
cd template-repo
git init
git add .
git commit -m "chore: initial template with DanDeBugger instructions"
git branch -M main
git remote add origin https://github.com/CaptainFredric/dan-de-bugger-template.git
git push -u origin main
```

3. On the GitHub repo page: Settings -> Template repository -> enable "Template repository". Now when you create a new repository, choose "Use this template" and it will include the persona file and scaffolding.

4. Optional: pair this template with the `scripts/gh_add_dan_prs.sh` script to propose the file to existing repos (PRs) so older repos also gain the file.


If you want, I can:
- Run a dry-run here (I cannot run gh auth on your behalf). I can run local-only operations within this workspace.
- Create a GitHub repository template for you (I can prepare files; you'll need to create/enable the template on GitHub).

Added automation
- The template repo included in `template-repo/` now contains a GitHub Action (`.github/workflows/add-dan-if-missing.yml`) which will open a PR adding `docs/DanDeBugger.md` if it is missing. The action copies the content from `.github/dan/DanDeBugger.md` and uses `peter-evans/create-pull-request` to open a PR.
- A small helper script to create new repos from the template is included: `scripts/create_from_template.sh`.

Create a new repository from the template via the script:

```bash
./scripts/create_from_template.sh new-project-name --public --description "Project created from DanDeBugger template"
```

Notes:
- The script uses `gh repo create --template`. Ensure `gh` is installed and you are authenticated (`gh auth login`).
- By default it creates a public repo; pass `--private` to create a private repo.

