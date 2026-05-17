# Pre-Migration Checklist — MikroTik to Juniper Platform Migration
## Based on: Railwire ICT NOC — 11,000+ Broadband User Migration

This checklist reflects the actual pre-migration validation process used during the
large-scale infrastructure transition from MikroTik-based edge devices to Juniper
platforms across the Railwire broadband network. It is written from direct operational
experience, not as a generic template.

---

## 1. Subscriber Inventory and Dependency Mapping

- [ ] Export full subscriber list from MikroTik — IP assignments, PPPoE sessions, VLAN bindings
- [ ] Map each subscriber segment to its upstream aggregation device
- [ ] Identify shared infrastructure — any device serving both migrating and non-migrating segments
- [ ] Flag high-risk subscribers — business accounts, SLA-bound services, CCTV or banking links
- [ ] Confirm total active session count per device before migration window opens

> **Railwire context:** With 11,000+ live broadband users, a single aggregation device
> could serve hundreds of active PPPoE sessions. Migrating without this map meant
> no clear picture of blast radius if a phase failed.

---

## 2. Juniper Platform Pre-Validation

- [ ] Verify JunOS version matches tested configuration baseline
- [ ] Confirm Juniper device has been staged and tested in lab or isolated segment first
- [ ] Validate routing table — confirm all expected prefixes are present before cutover
- [ ] Check OSPF neighbour relationships are stable on Juniper side pre-migration
- [ ] Verify VLAN configurations on Juniper match the MikroTik source exactly
- [ ] Confirm PPPoE service profiles are correctly replicated on Juniper
- [ ] Test authentication — RADIUS connectivity from Juniper to AAA server confirmed

> **Key lesson:** OSPF neighbour flapping between the MikroTik edge and new Juniper
> platform was the first issue hit in early phases. Pre-validating adjacency stability
> before cutting live traffic was critical.

---

## 3. Configuration Backup and Rollback Preparation

- [ ] Export running config from every MikroTik device in scope — stored in dated folder
- [ ] Verify backup files are accessible from a second location (not just the device itself)
- [ ] Pre-stage rollback configs — ready to push without editing under pressure
- [ ] Confirm rollback can be executed within the agreed recovery time window
- [ ] Assign one team member specifically responsible for rollback execution — not the migration lead

> **Rollback must be rehearsed, not just documented.** During the Railwire migration,
> rollback procedures were actively tested before the first live phase. Knowing exactly
> how to revert without referring to documentation under pressure was essential.

---

## 4. Monitoring Setup — Migration-Specific

Standard monitoring is not sufficient during a migration of this scale. The following
must be in place specifically for the migration window:

- [ ] SolarWinds (or equivalent) alerting configured for all devices in scope
- [ ] Interface state monitoring active on both MikroTik and Juniper sides during cutover
- [ ] OSPF adjacency monitoring — alert on any neighbour state change within seconds
- [ ] PPPoE session count tracking — baseline captured, alerts set for unexpected drop
- [ ] Real-time traffic flow monitoring on upstream links during cutover
- [ ] DNS resolution validation from test endpoints — checked every 2 minutes during window
- [ ] Dedicated NOC resource assigned to monitoring only — not involved in migration execution

> **Monitoring gaps are a bigger risk than known faults.** Issues that are hardest to
> resolve are the ones not being monitored for. Build visibility into areas assumed to
> be stable, not just the parts being changed.

---

## 5. Communication and Escalation Plan

- [ ] Migration schedule confirmed with NOC lead, field teams, and management
- [ ] Escalation contacts confirmed — vendor support, senior engineer, management on standby
- [ ] Single point of coordination identified — one person owns the migration call
- [ ] Field team briefed — aware of phase timings and their specific responsibilities
- [ ] Support team informed — prepared for increased call volume during window
- [ ] Stakeholder notification sent — internal teams and any affected enterprise customers

---

## 6. Phase Definition and Go/No-Go Criteria

- [ ] Migration broken into phases — never migrate entire user base in one window
- [ ] Each phase limited to a defined subscriber segment with clear boundaries
- [ ] Go/No-Go criteria defined per phase — specific metrics that must pass before proceeding
- [ ] Maximum acceptable downtime per phase agreed and documented
- [ ] Phase completion sign-off process confirmed — who approves moving to next phase

> **Phase sizing matters.** Starting with the smallest, lowest-risk segment first
> gives the team confidence, validates the process under real conditions, and
> limits blast radius if something unexpected occurs.

---

## 7. Post-Migration Validation Plan

- [ ] Test subscriber list prepared — specific accounts to validate immediately after cutover
- [ ] Validation steps defined: PPPoE session up, IP correct, routing functional, DNS resolving
- [ ] Soak period defined — minimum time to observe before declaring phase successful
- [ ] Metrics to confirm success: session count stable, no unusual error rates, latency normal

---

*This checklist was developed from direct experience on the Railwire ICT MikroTik-to-Juniper
migration project. It reflects real operational decisions made during a live production
migration involving 11,000+ broadband subscribers.*
