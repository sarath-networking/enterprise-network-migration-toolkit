# Network Migration Checklist — MikroTik to Juniper Platform
## Based on: Railwire ICT — 11,000+ Broadband User Migration

This checklist covers the three critical phases of a live ISP network migration.
It reflects the actual sequence followed during the Railwire ICT infrastructure
transition — a phased cutover of 11,000+ active broadband subscribers from
MikroTik-based edge devices to Juniper platforms in a live production environment.

---

## Pre-Migration

### Hardware and Platform Readiness
- [ ] Juniper device staged and validated in isolated segment before production use
- [ ] JunOS version confirmed — matches tested baseline, no unexpected upgrades pending
- [ ] Physical connectivity verified — all uplinks, trunk ports, and management interfaces confirmed
- [ ] MikroTik hardware confirmed stable — no pre-existing faults before migration window

### Configuration Readiness
- [ ] Full configuration backup taken from every MikroTik device in scope — stored with date stamp
- [ ] Juniper configs pre-loaded and reviewed — PPPoE profiles, VLAN assignments, routing entries
- [ ] RADIUS/AAA authentication tested from Juniper to authentication server — confirmed working
- [ ] Routing table on Juniper validated — all expected prefixes present before any traffic moved
- [ ] OSPF adjacencies stable on Juniper side — no flapping before cutover begins

> **Key lesson from Railwire:** OSPF neighbour instability between the MikroTik edge
> and new Juniper platform appeared in early phases. Validating adjacency stability
> before cutting live traffic saved significant recovery time.

### Subscriber and Traffic Readiness
- [ ] Active PPPoE session count per device recorded — baseline for comparison during migration
- [ ] Subscriber segments mapped — know exactly which users sit behind each device
- [ ] Peak usage hours confirmed — migration window scheduled outside peak period
- [ ] High-risk subscribers identified — business accounts, banking links, SLA-bound services

### Rollback Readiness
- [ ] Rollback configs pre-staged — ready to push without editing under pressure
- [ ] Rollback procedure rehearsed by the team — not just documented
- [ ] Rollback decision thresholds agreed — specific metrics that trigger immediate rollback
- [ ] Rollback engineer assigned — separate person from migration lead

---

## During Migration

### First 5 Minutes After Cutover
- [ ] PPPoE session count monitored — compare to pre-migration baseline immediately
- [ ] OSPF adjacency status confirmed on Juniper uplink — should be stable within 60 seconds
- [ ] Routing table checked — verify no prefixes dropped during cutover
- [ ] Management access to Juniper confirmed — device responding to SSH/console

### Ongoing Monitoring During Window
- [ ] Packet loss on upstream links — checked every 2 minutes, alert threshold >2% sustained
- [ ] Interface utilisation on Juniper uplinks — confirm traffic is flowing as expected
- [ ] VLAN segmentation validated — test endpoints in each VLAN confirming connectivity
- [ ] DNS resolution tested from subscriber-side test endpoints — checked continuously
- [ ] CPU and memory on Juniper — confirm no unexpected resource spikes under live load
- [ ] SolarWinds (or monitoring tool) alerts actively watched — dedicated monitor assigned

### Validation Before Declaring Phase Complete
- [ ] Test subscriber list validated — PPPoE up, correct IP assigned, routing functional
- [ ] Redundancy paths tested — failover link confirmed active and passing traffic
- [ ] No unusual error rates on interfaces — CRC errors, input errors checked
- [ ] Soak period completed — minimum observation time passed with stable metrics

> **Critical:** Do not move to the next migration phase until the current phase
> has been stable for the agreed soak period. Rushing phases was the most common
> cause of compounding issues during large-scale ISP migrations.

---

## Post-Migration

### Immediate Validation (Within 30 Minutes)
- [ ] Full subscriber count confirmed — session count matches expected number
- [ ] Application connectivity validated — web browsing, DNS, core services tested
- [ ] DNS functionality confirmed from multiple test points
- [ ] VPN services tested — any site-to-site or remote access VPNs verified
- [ ] Firewall policies reviewed — confirm ACLs and security rules carried over correctly

### Infrastructure Confirmation
- [ ] Routing table reviewed — confirm clean, no unexpected routes or missing prefixes
- [ ] VLAN assignments confirmed across all segments
- [ ] Redundancy links verified — secondary paths active and healthy
- [ ] Monitoring alerts reviewed — no outstanding unacknowledged alerts

### Documentation and Handover
- [ ] Migration log completed — timeline, phases, issues encountered, resolutions
- [ ] Network diagrams updated — reflect new Juniper topology
- [ ] Any deviations from plan documented — what changed and why
- [ ] Support team briefed — aware of new platform, known differences from MikroTik
- [ ] Incident tickets raised for any issues encountered — even minor ones

### Post-Migration Review (Within 48 Hours)
- [ ] Performance comparison completed — before and after metrics documented
- [ ] Any issues identified during migration reviewed for root cause
- [ ] Lessons learned documented — what to carry forward to next phase or project
- [ ] Stakeholders notified — migration complete, outcome summary provided

---

## Metrics to Track Throughout

| Metric | Pre-Migration Baseline | Target During Migration | Alert Threshold |
|---|---|---|---|
| PPPoE active sessions | Record per device | Within 5% of baseline | Drop >5% in 2 mins |
| Packet loss upstream | <0.1% | <0.5% | >2% sustained 3 mins |
| OSPF adjacencies | All stable | All stable | Any adjacency down |
| DNS resolution time | Record baseline | Within 20% of baseline | Any failure |
| Interface error rate | Record baseline | No increase | Any CRC/input errors |

---

*This checklist was developed from direct operational experience on the Railwire ICT
MikroTik-to-Juniper migration. The phased approach, monitoring thresholds, and
validation steps reflect real decisions made during a live production migration
involving 11,000+ broadband subscribers.*
