# Network Migration Best Practices
## Lessons from a Live ISP Migration — 11,000+ Broadband Users

These practices are drawn from direct operational experience on the Railwire ICT
infrastructure migration — transitioning 11,000+ active broadband subscribers from
MikroTik-based edge devices to Juniper platforms in a live production environment
where zero significant downtime was acceptable.

---

## 1. Planning — Map Before You Touch Anything

The most valuable work happens before the first change is made.

**Subscriber and dependency mapping is non-negotiable.**
In an ISP environment, a single aggregation device can serve hundreds of active
PPPoE sessions. Before any migration activity, map every subscriber segment to its
upstream device. Without this map, you cannot calculate blast radius if a phase fails.

**Phase sizing matters more than speed.**
Breaking the migration into small, contained phases — each with defined boundaries
and go/no-go criteria — is what keeps a large-scale migration manageable. The temptation
is to move quickly once preparation is done. In practice, every hour spent on
pre-migration validation saved multiple hours of potential incident response.

**Define scope with precision.**
"Migrate the network" is not a scope. The scope must specify which devices, which
subscriber segments, which phases, and which maintenance windows — before any
work begins.

> *In the Railwire migration, starting with the smallest, lowest-risk segment first
> validated the process under real conditions before scaling to larger segments.
> That first phase revealed the OSPF adjacency issue that we then pre-validated
> in every subsequent phase.*

---

## 2. Communication — Structure It Before the Window Opens

Communication failures cause more migration incidents than technical failures.

**Single point of coordination.**
One person owns the migration call. Everyone else reports to that person.
Multiple people making decisions simultaneously under pressure leads to
conflicting actions and compounding problems.

**Role assignment before the window.**
Every team member must know their specific responsibility before the migration
starts — migration lead, rollback engineer, monitoring engineer, NOC coordinator,
stakeholder contact. These roles must not overlap during execution.

**Escalation contacts confirmed in advance.**
Vendor support numbers, senior engineer contacts, and management on standby —
all confirmed before the window opens, not looked up during an incident.

**Structured updates during the window.**
Regular status updates at fixed intervals — even when nothing is wrong — keep
all stakeholders informed and reduce unnecessary interruptions to the technical team.

---

## 3. Validation — Build It Specifically for the Migration

Standard monitoring is not sufficient during a large-scale migration.

**Pre-migration baselines are essential.**
Record PPPoE session counts, interface error rates, routing table state, and
latency metrics before any changes. Without a baseline, you cannot tell whether
something has degraded during migration.

**Migration-specific monitoring.**
During the Railwire cutover windows, standard monitoring was supplemented with:
- Real-time PPPoE session count tracking per device
- OSPF adjacency state monitoring with second-level alerting
- Upstream packet loss checked every 2 minutes
- DNS resolution tests from subscriber-side endpoints running continuously

**Validation test list prepared in advance.**
A specific list of subscriber accounts and services to test immediately after
each phase cutover — not a general "check connectivity" instruction, but named
accounts, specific IPs, specific services.

**Soak period before declaring success.**
A minimum observation period after cutover before moving to the next phase.
Metrics must remain stable throughout — not just pass a single check.

---

## 4. Risk Reduction — Rollback Is Not a Last Resort

Rollback readiness is part of migration readiness, not a backup plan.

**Pre-staged configurations.**
Every rollback config prepared, reviewed, and staged before the window opens.
Editing configurations under pressure during a live outage introduces new errors.
The rollback must be executable without any real-time decision-making.

**Pre-agreed rollback triggers.**
Specific metrics that automatically trigger rollback — no discussion required.
During the Railwire migration: PPPoE session drop >5% within 2 minutes,
OSPF adjacency down >60 seconds, packet loss >2% sustained for 3 minutes.

**Rollback rehearsal.**
The rollback procedure must be walked through by the team before the first
live phase. Each person knows their role without referring to the document.
Under real pressure, that preparation is what keeps execution clean.

**Speed over perfection during rollback.**
The goal is to restore service, not to understand why it failed.
Root cause analysis happens after services are restored, not during.

---

## 5. Post-Migration — Close the Loop Properly

**Immediate validation within 30 minutes.**
Full subscriber count confirmed, application connectivity tested, DNS validated,
routing table reviewed, monitoring alerts cleared.

**Performance comparison documented.**
Before and after metrics compared and recorded — not just to confirm success,
but to demonstrate the value of the migration to stakeholders.

**Lessons learned documented within 48 hours.**
While the detail is still fresh. What changed from the plan, what issues occurred,
what would be done differently. This feeds directly into the next phase or project.

**Infrastructure documentation updated.**
Network diagrams, device inventory, and configuration records updated to reflect
the new topology before the team moves on to other work.

---

## Summary — What Actually Matters

| Factor | Common Mistake | What Works |
|---|---|---|
| Planning | Define scope loosely | Map every subscriber segment before touching anything |
| Phasing | Migrate everything at once | Small contained phases with go/no-go criteria |
| Monitoring | Use standard monitoring | Build migration-specific monitoring for the window |
| Rollback | Document it and hope | Rehearse it with the team before the first phase |
| Communication | Ad-hoc during the window | Assigned roles and single coordinator before it opens |
| Validation | Check connectivity generally | Named test accounts, specific services, soak period |

---

*Written from direct operational experience on the Railwire ICT MikroTik-to-Juniper
migration involving 11,000+ live broadband subscribers. These practices reflect
real decisions made under production conditions, not theoretical recommendations.*
