# System Architecture Overview

## Purpose

This document describes the high-level architecture of the Executive Compliance & Operations Automation Hub. It is the single source of truth for "how does this system work?".

## Audience

- New engineers joining the project
- Interviewers evaluating architectural thinking
- Future you, 6 months from now, wondering "why did I do this?"

## Business Context

The platform supports an **Executive Director of Compliance & Licensing** in the Oil & Gas industry. This executive is responsible for:

- Ensuring regulatory compliance (EPA, OSHA, state-specific)
- Managing operating licenses and renewals
- Coordinating inspections
- Responding to regulatory inquiries
- Communicating with stakeholders (regulators, executives, operators)

The Executive Assistant (EA) supports this role. Today, this work is done with email, spreadsheets, and manual follow-ups. We are automating it.

## High-Level Architecture (5 Layers)

### Layer 1 — Executive User Interface

**What:** How the user interacts with the system.
**Components:**
- n8n Web UI (workflow management & monitoring)
- Custom executive dashboard (KPIs, alerts, tasks)
- Email notifications
- Calendar invitations

**Why:** Executives don't log into terminals. They need a clean visual interface.

### Layer 2 — Automation Layer (n8n)

**What:** The brain. Where workflows live.
**Components:**
- ~15 production workflows covering email, calendar, AI, documents
- Sub-workflows for reusable logic
- Error handling & retry logic

**Why:** n8n provides visual, low-code automation perfect for business workflows. Self-hostable = data sovereignty (critical for compliance data).

### Layer 3 — Integration Layer

**What:** How n8n talks to the outside world.
**Components:**
- Google Workspace (Gmail, Calendar, Drive, Sheets)
- AWS S3 (document storage)
- AI APIs (Claude, OpenAI)
- SMTP/IMAP (email in/out)
- HTTP webhooks (custom integrations)

**Why:** No system is an island. This layer handles all I/O.

### Layer 4 — Infrastructure Layer (AWS)

**What:** Where the system runs.
**Components:**
- **EC2** — Virtual server running Docker containers
- **S3** — Object storage for documents
- **IAM** — Identity & access management (least privilege)
- **VPC + Security Groups** — Network isolation
- **Secrets Manager** — Encrypted credentials storage
- **CloudWatch** — Logs, metrics, alarms
- **Route53** — DNS management
- **Elastic IP** — Static public IP

**Why:** AWS is the industry leader, and certifications (SAA, SAP) require this knowledge.

### Layer 5 — Infrastructure as Code Layer

**What:** How we build and deploy.
**Components:**
- **Terraform** — Provisions AWS resources
- **Docker** — Containerizes n8n and helpers
- **Docker Compose** — Local multi-container orchestration
- **GitHub Actions** — CI/CD pipeline
- **Git** — Version control

**Why:** Manual clicks don't scale. IaC = reproducibility, auditability, disaster recovery.

## Data Flow Example: Inspection Email Arrives

```
1. Email arrives in IMAP inbox
   ↓
2. n8n IMAP trigger fires workflow
   ↓
3. "Read Email" node extracts subject, body, attachments
   ↓
4. "HTTP Request" node sends body to Claude API for summarization
   ↓
5. "Google Sheets" node logs the inspection in tracking sheet
   ↓
6. "AWS S3" node uploads PDF attachment
   ↓
7. "Gmail Send" node emails summary to Executive
   ↓
8. "CloudWatch" log records execution status
```

## Non-Functional Requirements

| Concern | Decision |
|---------|----------|
| Availability | 99.0% (single EC2 acceptable for v1.0; HA later) |
| Security | HTTPS, IAM least privilege, secrets encrypted |
| Observability | CloudWatch logs, n8n execution history |
| Scalability | Vertical (larger EC2) initially; horizontal later |
| Recoverability | Terraform state in S3 + DynamoDB lock; daily S3 snapshots |
| Cost | <$50/month for v1.0 dev environment |

## Design Principles

1. **Automate everything automatable** — If a human does it twice, automate it.
2. **Document as you build** — Documentation is not a phase; it's a habit.
3. **Secure by default** — No public S3 buckets, no hardcoded secrets, no HTTP-only.
4. **Test before you ship** — Workflows get test data; code gets unit tests.
5. **Boring is good** — Use proven tools. n8n, Terraform, Docker — battle-tested.

## Future Considerations (v2.0+)

- Multi-tenant support (multiple EAs)
- Mobile app for executive alerts
- Slack integration
- Power BI executive dashboard
- Disaster recovery region (us-west-2 failover)
- SOC 2 compliance posture

## Version History

- **v0.1** — Initial architecture documented
