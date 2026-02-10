# Daily Git Workflow Guide

**Stack:** Bitbucket + Fork + dbt/Snowflake

---

## 🎯 Purpose

Keep your code updated, avoid conflicts, and follow enterprise-safe workflow daily.

---

## 🧠 Mental Model

### Repository Structure
- **Upstream** = Company's original repository
- **Origin** = Your fork (personal Bitbucket copy)
- **Local** = Your machine

### Flow Pattern
```
Upstream → Origin → Local
```

### Branch Strategy
- `main` = Stable production code
- `feature/*` = Your development work

---

## ⚙️ One-Time Setup

> Perform once per repository

### Step 1: Fork Repository
Fork the repository in Bitbucket UI

### Step 2: Clone to Local Machine
```bash
git clone <your-fork-url>
cd <repo>
```

### Step 3: Add Upstream Reference
```bash
git remote add upstream <original-repo-url>
```

### Step 4: Verify Configuration
```bash
git remote -v
```

**Expected output:**
- `origin` → your fork
- `upstream` → original repo

---

## 🌅 Daily Morning Routine

⏱️ **Takes 30 seconds** — Sync your local & fork with company changes

```bash
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

---

## 🚀 Starting New Work

Create a fresh branch from updated `main`:

```bash
git checkout -b feature/<short-description>
```

### Branch Naming Examples
- `feature/nav_model`
- `feature/customer_segmentation`
- `bugfix/returns_calc`
- `bugfix/null_handling`

### Best Practice
**One task → One branch → One PR**

Finish same day if possible to minimize conflicts.

---

## 💻 During Development

### Making Changes
```bash
git add .
git commit -m "Clear description of changes"
git push origin feature/<name>
```

### Commit Message Guidelines
- Be descriptive and clear
- Use present tense (e.g., "Add customer model" not "Added customer model")
- Reference ticket numbers if applicable

---

## 🔄 Multi-Day Development

> Only if your work spans multiple days

Keep your feature branch updated with latest `main`:

```bash
git checkout feature/<name>
git merge main
git push origin feature/<name>
```

> **📌 Team Policy:** Use `merge`, not `rebase`, for updating branches (unless explicitly asked)

---

## 📤 Creating Pull Request

### Step 1: Navigate to Bitbucket UI
Create PR from your fork

### Step 2: Configure PR
- **Source:** `feature/<name>`
- **Target:** `main`

### Step 3: Complete PR Description
Include:
- **What changed:** Summary of modifications
- **Why:** Business reason or ticket reference
- **dbt test status:** Confirmation all tests pass

### Step 4: Request Review
Assign reviewer who will approve & merge

---

## 🧹 Post-Merge Cleanup

After your PR is merged, clean up local branch:

```bash
git branch -d feature/<name>
```

---

## ✅ Pre-PR Checklist

Before submitting your pull request, ensure:

- [ ] `dbt run` successful
- [ ] `dbt test` passed
- [ ] Branch updated with latest `main` (if multi-day work)
- [ ] PR description complete and clear
- [ ] No merge conflicts

---

## ⚠️ Golden Rules

1. **Never push directly to `main`**
2. **Always branch from updated `main`**
3. **Small PRs = faster review, fewer conflicts**
4. **Test before submitting PR**
5. **Merge over rebase** (standard team practice)

---

## 📋 Daily Workflow Summary

```
1. Update main
2. Create branch
3. Work & commit
4. Test (dbt run + dbt test)
5. Create PR
6. Get approval & merge
7. Cleanup branch
8. Repeat
```

---

## 🆘 Quick Reference Commands

| Action | Command |
|--------|---------|
| Update main | `git checkout main && git fetch upstream && git merge upstream/main && git push origin main` |
| New branch | `git checkout -b feature/<name>` |
| Save work | `git add . && git commit -m "message" && git push origin feature/<name>` |
| Update feature branch | `git checkout feature/<name> && git merge main` |
| Delete branch | `git branch -d feature/<name>` |

---

**Last Updated:** February 2026
