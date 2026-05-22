# Rollback Plan — MikroTik to Juniper Migration
## Based on: Railwire ICT NOC — Live Production Environment

This rollback procedure was developed for a live broadband network migration involving
11,000+ active subscribers. It reflects the actual decision-making framework and
escalation criteria used during the Railwire ICT infrastructure transition.

---

## Why Rollback Planning Is Different at This Scale

In a lab or small environment, rollback means reverting a config and moving on.
In a live ISP environment with 11,000+ subscribers, rollback is an operational event
with real user impact. Every minute of extended outage during a failed rollback
translates directly into SLA breaches, support call surges, and business impact.

This plan exists because rollback was rehearsed before it was ever needed —
not written up afterwards.

---

## Rollback Triggers — When to Initiate Immediately

Do not wait for management approval if any of the following occur:

| Condition | Threshold | Action |
|---|---|---|
| PPPoE session count drops unexpectedly | >5% of segment within 2 minutes | Initiate rollback |
| OSPF neighbour lost on Juniper uplink | Any adjacency down >60 seconds | Initiate rollback |
| Packet loss on upstream link | >2% sustained for 3 minutes | Initiate rollback |
| DNS resolution failures from test endpoints | Any failure in consecutive checks | Initiate rollback |
| Routing table missing expected prefixes | Any critical prefix absent | Initiate rollback |
| No response from Juniper management interface | >90 seconds | Initiate rollback |

> **The decision to rollback must be made quickly and without hesitation.**
> During the Railwire migration, having pre-agreed thresholds meant the team
> did not spend time debating whether to roll back — the criteria made the
> decision automatically.

---

## Roles During Rollback

| Role | Responsibility |
|---|---|
| Migration Lead | Calls the rollback decision, coordinates the team |
| Rollback Engineer | Executes config restoration — dedicated to this task only |
| Monitoring Engineer | Watches metrics throughout, calls out threshold breaches |
| NOC Coordinator | Manages support ticket queue, briefs support team |
| Stakeholder Contact | Notifies management and enterprise customers |

> One critical lesson: the person executing rollback must not be the same person
> who was leading the migration. Under pressure, cognitive load matters.
> Separate responsibilities before the window opens.

---

## Rollback Procedure — Step by Step

### Phase 1: Decision and Notification (0–2 minutes)

1. Migration lead confirms rollback trigger threshold has been met
2. Announce rollback on team call — "Initiating rollback, [timestamp]"
3. NOC coordinator alerts support team to expect increased contact volume
4. Stakeholder contact sends initial notification if enterprise customers are affected

### Phase 2: Traffic Restoration (2–8 minutes)

5. Rollback engineer pushes pre-staged MikroTik configuration to affected device
6. Verify MikroTik is responding to management access before proceeding
7. Restore original upstream routing path — confirm OSPF adjacency re-established
8. Monitor PPPoE session count — should begin recovering within 2–3 minutes
9. Monitoring engineer calls out session recovery rate in real time

### Phase 3: Validation (8–15 minutes)

10. Test subscriber list — validate PPPoE sessions up, IP assignments correct
11. Confirm DNS resolution from test endpoints
12. Check routing table — all expected prefixes present
13. Validate VLAN assignments match pre-migration baseline
14. Confirm no unusual error rates or latency spikes on upstream links
15. Soak period — observe for minimum 10 minutes before declaring rollback successful

### Phase 4: Post-Rollback Actions (15–30 minutes)

16. Migration lead formally declares rollback complete with timestamp
17. Full incident log documented — timeline, trigger, actions taken, outcome
18. Stakeholder notification — rollback complete, services restored, next steps TBD
19. Root cause analysis scheduled — before any further migration phases proceed
20. Pre-migration checklist reviewed — identify what was missed or underestimated

---

## Configuration Restoration Details

**MikroTik config restoration:**
- Configs stored in dated backup folder: `/backups/YYYY-MM-DD/[device-name].rsc`
- Restore via: `import file=[backup-file]` from MikroTik terminal
- Verify with: `ip address print` and `ip route print` immediately after import

**Routing path restoration:**
- Original OSPF adjacencies should re-establish automatically within 30–90 seconds
- If not re-establishing: check interface states, verify OSPF area configuration
- Manually verify routing table matches pre-migration snapshot

**VLAN restoration:**
- Verify bridge and VLAN interface assignments match backup
- Check any trunk ports between devices for correct VLAN membership

---

## What We Learned About Rollback

**Rehearse it, don't just document it.**
The rollback procedure was walked through by the team before the first live migration
phase. Each person knew their role without referring to the document. Under real
pressure, that preparation was what kept the execution clean.

**Pre-staged configs are non-negotiable.**
Editing a config under pressure during a live outage introduces new errors.
Every rollback config was prepared, reviewed, and staged before the window opened.

**Speed matters more than perfection during rollback.**
The goal during rollback is to restore service, not to understand why it failed.
Root cause analysis happens after services are restored, not during.

> *In practice we ran a full rehearsal two days before the first live phase with the NOC team in Kochi — that preparation was what kept execution clean when a real trigger occurred in phase 3.*

---

*Developed from direct operational experience during the Railwire ICT MikroTik-to-Juniper
migration. Written to reflect real decisions made in a live production environment,
not as a theoretical exercise.*
