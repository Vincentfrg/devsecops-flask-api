# 🔐 DevSecOps Flask API

Projet réalisé dans le cadre du cours **5DVSCOPS – 2025/2026** (Laurent FREREBEAU)  
**ESTIAM — Master Web Development & Mobile E5S2**  
Étudiant : **Vincent FERRAG**

---

## 📋 Présentation

Pipeline DevSecOps complet intégrant des outils de sécurité open-source dans un workflow GitHub Actions, appliqué à une API REST Flask conteneurisée.

**Objectifs :**
- Comprendre le rôle de la sécurité dans un pipeline CI/CD
- Intégrer des outils de scan statique et d'image (Trivy)
- Mettre en place des politiques de sécurité codifiées (Conftest / Rego)
- Identifier et documenter les vulnérabilités

---

## 🗂️ Structure du projet

```
devsecops-flask-api/
├── app.py                        # API Flask (Python 3.11)
├── requirements.txt              # Dépendances Python
├── Dockerfile                    # Image Docker python:3.11-slim
├── .yamllint.yml                 # Config linting YAML
├── k8s/
│   └── deployment.yaml           # Manifest Kubernetes
├── policy/
│   └── deny_root.rego            # Règle Conftest anti-root
└── .github/
    └── workflows/
        └── ci.yml                # Pipeline GitHub Actions (5 jobs)
```

---

## ⚙️ Pipeline CI/CD — GitHub Actions

Le pipeline se déclenche automatiquement à chaque **push** ou **pull request** sur `main`.

```
Lint YAML Files (4s)
       │
       ▼
Build Docker Image (13s)
       │
       ├──▶ Trivy Scan Dépendances (23s)
       │
       └──▶ Trivy Scan Image Docker (26s)

Lint YAML Files
       │
       └──▶ Conftest Politique Kubernetes (6s)
```

| Job | Outil | Rôle |
|-----|-------|------|
| Lint YAML Files | yamllint 1.38.0 | Validation des fichiers YAML |
| Build Docker Image | Docker | Build de l'image flask-api:latest |
| Trivy Scan Dépendances | Trivy FS | Scan du fichier requirements.txt |
| Trivy Scan Image Docker | Trivy Image | Scan de l'image Docker |
| Conftest Politique Kubernetes | Conftest / Rego | Vérification sécurité K8s |

---

## 🛠️ Outillage utilisé

| Domaine | Outil |
|---------|-------|
| CI/CD | GitHub Actions |
| Scan de vulnérabilités | Trivy (Aqua Security) |
| Analyse des dépendances | Trivy FS |
| Linting YAML | yamllint |
| Docker image scan | Trivy container scan |
| Politique de sécurité | Rego / Conftest (OPA) |
| Application test | Flask (Python 3.11) |

---

## 🔍 Vulnérabilités détectées

Trivy a détecté **94 vulnérabilités** sur les dépendances Python :

| Bibliothèque | CVE | Sévérité | Version fixée |
|---|---|---|---|
| Flask 2.1.0 | CVE-2023-30861 | **HIGH** | 2.3.2 |
| Werkzeug 2.1.0 | CVE-2023-25577 | **HIGH** | 2.2.3 |
| Jinja2 3.0.3 | CVE-2024-22195 | MEDIUM | 3.1.3 |
| Jinja2 3.0.3 | CVE-2024-56201 | MEDIUM | 3.1.5 |
| Werkzeug 2.1.0 | CVE-2024-49766 | MEDIUM | 3.0.6 |
| Werkzeug 2.1.0 | CVE-2025-27788 | MEDIUM | 3.1.4 |

> ⚠️ Les versions anciennes sont utilisées **intentionnellement** pour démontrer la détection de CVE par Trivy.

---

## 🛡️ Règle de sécurité Conftest

La règle `policy/deny_root.rego` refuse tout déploiement Kubernetes dont le conteneur s'exécute en tant que **root** :

```rego
package main

deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.runAsNonRoot == true
  msg := sprintf(
    "REFUSE : le conteneur '%v' tourne en root. Ajoutez securityContext.runAsNonRoot: true",
    [container.name]
  )
}
```

Résultat dans les logs :
```
FAIL - k8s/deployment.yaml - main - REFUSE : le conteneur 'flask-api' tourne en root.
1 test, 0 passed, 0 warnings, 1 failure, 0 exceptions
```

---

## 🚀 Lancer l'API localement

```bash
# Créer et activer l'environnement virtuel Python 3.11
python3.11 -m venv venv
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Lancer l'API
python app.py
# → http://localhost:5001/
# → http://localhost:5001/health
```

---

## 📄 Rapport

Le rapport synthétique complet (vulnérabilités, recommandations, réflexion sécurité) est disponible dans le rendu Teams.
