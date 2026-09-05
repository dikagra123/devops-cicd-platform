
# 🚀 DevOps CI/CD Platform

### Blue-Green Deployment Pipeline with Jenkins, Docker & Terraform

An end-to-end CI/CD pipeline that automatically takes code from a Git
push all the way to a **zero-downtime production deployment** — with
automated testing, container security scanning, infrastructure as
code, and **automatic rollback** if anything goes wrong.

---

## 📌 What This Project Does

Every time code is pushed, the pipeline automatically:

1. ✅ Pulls the latest code
2. ✅ Installs dependencies and runs automated tests
3. ✅ Builds a Docker image
4. ✅ Scans the image for security vulnerabilities
5. ✅ Provisions infrastructure using Terraform
6. ✅ Deploys to a safe, idle environment (Blue or Green)
7. ✅ Runs a health check before allowing live traffic
8. ✅ Switches production traffic to the new version
9. ✅ Automatically rolls back if anything fails

No manual steps. No downtime. No broken deployments reaching users.

---

## 🏗️ Architecture

```
                         GITLAB
                           │
                     Push / Merge Request
                           │
                           ▼
                        JENKINS
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
      BUILD              TEST             SECURITY
                                             SCAN
        └──────────────────┼──────────────────┘
                           │
                           ▼
                     DOCKER IMAGE
                           │
                           ▼
                   TERRAFORM PLAN
                           │
                           ▼
                    NEW ENVIRONMENT
                     (idle color)
                           │
                           ▼
                      HEALTH CHECK
                           │
                           ▼
                   NGINX TRAFFIC SWITCH
                           │
                  ┌────────┴────────┐
                  ▼                 ▼
                BLUE              GREEN
              inactive           ACTIVE
                  │                 │
                  └────────┬────────┘
                           │
                      FAILURE?
                           │
                           ▼
                   AUTOMATIC ROLLBACK
```

---

## 🧰 Tech Stack

| Tool | What It's Used For |
|------|---------------------|
| **Jenkins** | Runs and coordinates the entire pipeline |
| **Docker** | Packages the app into containers |
| **Terraform** | Creates and manages infrastructure automatically |
| **Trivy** | Scans containers for security vulnerabilities |
| **Nginx** | Switches live traffic between Blue and Green |
| **Node.js / Express** | The sample application being deployed |
| **GitLab** | Stores the code and triggers the pipeline |

---

## 💡 What Makes This Special: Blue-Green Deployment

Instead of updating one live server (risky — if it breaks, users see
it immediately), this project keeps **two identical environments**:

- 🔵 **Blue** — one version of the app
- 🟢 **Green** — another version of the app

At any time, only **one** of them receives real traffic. When a new
version is deployed:

1. It's deployed to the **idle** environment first (not live yet)
2. It's health-checked to confirm it's actually working
3. Only then does traffic switch over to it
4. If anything looks wrong, traffic instantly switches back

**Result:** Users never see a broken deployment, and every release can
be reversed in seconds.

---

## 📂 Project Structure

```
devops-cicd-platform/
│
├── app/                 → Node.js application + automated tests
├── nginx/               → Nginx config for traffic switching
├── terraform/           → Infrastructure-as-code (Blue/Green setup)
│   └── scripts/         → Switch scripts (switch-blue / switch-green)
├── Dockerfile           → Builds the application container
└── Jenkinsfile          → The full CI/CD pipeline definition
```

---

## ▶️ Running It Locally

**You'll need:** Docker Desktop, Terraform, Trivy, and Node.js installed.

```bash
# 1. Install dependencies and run tests
cd app
npm install
npm test

# 2. Build the Docker image
docker build -t devops-app:local .

# 3. Scan the image for vulnerabilities
trivy image --severity HIGH,CRITICAL devops-app:local

# 4. Provision the infrastructure
cd ../terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Once running, the app is available at:

- 🔵 Blue → `http://localhost:3001`
- 🟢 Green → `http://localhost:3002`
- 🌐 Live traffic (via Nginx) → `http://localhost:8080`

---

## 🎓 What I Learned Building This

Writing the pipeline steps was the easy part. The real learning came
from debugging real-world environment issues, including:

- Fixing broken **PATH** configuration on Windows so Docker, Terraform
  and Trivy could actually be found by Jenkins
- Understanding why **Jenkins service accounts** behave differently
  from a normal user login
- Diagnosing a **corrupted Terraform provider cache** after a failed
  download
- Resolving **container name conflicts** between Terraform's state and
  Docker's real running containers
- Building a test runner that **shows real errors** instead of hiding
  them behind a generic failure message

This is the kind of practical troubleshooting that tutorials rarely
cover — but makes up most of real-world DevOps work.

---

