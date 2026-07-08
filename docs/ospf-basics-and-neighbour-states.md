# OSPF Neighbour States — Operational Experience from a Live ISP Migration

## Based on: Railwire ICT — MikroTik to Juniper Migration

This document covers OSPF neighbour state behaviour as encountered during the
Railwire ICT infrastructure migration — a live production environment involving
11,000+ broadband subscribers migrated from MikroTik-based systems to Juniper
platforms. It is written from operational experience, not as a protocol reference.

The OSPF neighbour state machine is well documented in RFC 2328. What is less
documented is how it behaves when two different vendor implementations form an
adjacency under production conditions — and what happens when that adjacency
is unstable during a live migration window.

---

## What OSPF Neighbour States Actually Tell You in Production

The standard neighbour states — Down, Init, 2-Way, ExStart, Exchange, Loading,
Full — are useful for understanding where in the adjacency formation process a
problem has occurred. In a live environment, the state you care most about is
Full, and anything that prevents reaching or maintaining Full state is an
operational incident.

### The States That Matter Most Under Pressure

**2-Way** — Routers have seen each other's Hello packets. On a broadcast segment
this is where DR/BDR election happens. In the Railwire migration, seeing a
neighbour stuck in 2-Way when it should have progressed to Full indicated that
DR/BDR election was not completing as expected across the MikroTik-Juniper
boundary.

**ExStart / Exchange** — Database synchronisation is in progress. Neighbours
stuck at ExStart almost always indicate an MTU mismatch. This was one of the
first issues encountered when Juniper devices were introduced into the Railwire
network — Juniper's default MTU handling differs from MikroTik, and mismatched
MTU values caused adjacencies to stall at ExStart before ever reaching Full state.

**Loading** — LSA requests are outstanding. A neighbour that sits in Loading
for an extended period indicates that LSA exchange is not completing. In the
Railwire migration, brief Loading states were acceptable during adjacency
formation, but persistent Loading indicated a database synchronisation problem
that required investigation.

**Full** — The only state where OSPF is working as intended. In a live ISP
environment with 11,000+ subscribers depending on routing stability, anything
that knocks a neighbour out of Full state is an incident — regardless of how
quickly it recovers.

---

## The OSPF Problem Encountered During the Railwire Migration

During phase 1 of the MikroTik to Juniper migration, OSPF adjacencies between
the MikroTik edge devices and the newly introduced Juniper infrastructure were
unstable. Neighbours were forming and then flapping — dropping from Full back
to lower states and re-establishing repeatedly.

### What Was Observed

- OSPF neighbour relationships cycling between Full and lower states
- Routing table instability affecting traffic forwarding before any subscribers
  had been migrated
- SolarWinds alerts firing on OSPF neighbour state changes across multiple
  devices simultaneously

### Root Cause

The instability came down to Hello and Dead interval timer behaviour across
vendor implementations. OSPF requires that Hello and Dead intervals match
between neighbours — this is protocol-mandated. However, the way each vendor
implements the default values, and how they handle timer negotiation, varies.

MikroTik's OSPF implementation had specific default timer behaviour that was
stable in an all-MikroTik environment. When Juniper devices were introduced
with their own default timer configuration, the adjacency between the two
platforms was not stable even though both sides were technically RFC-compliant.

Additionally, the way each platform handled the DR/BDR election on shared
segments created contention that contributed to the flapping behaviour.

### What Was Changed

**Timer alignment** — Hello and Dead interval values were explicitly configured
on both platforms to match, rather than relying on each vendor's defaults.
This removed the timer mismatch that was contributing to adjacency instability.

**MTU configuration** — Juniper's default MTU handling was explicitly configured
to match the MTU values in use across the existing MikroTik infrastructure,
resolving the ExStart stalling issue that appeared on some segments.

**DR/BDR election management** — OSPF priority values were explicitly set on
Juniper interfaces to control DR/BDR election outcomes on shared segments,
preventing the contention that was occurring with default priority values.

**Pre-migration validation added to checklist** — From phase 2 onwards,
OSPF adjacency stability between the MikroTik and Juniper sides was validated
for a defined observation period before any live traffic was cut over. The
adjacency had to be stable in Full state for a minimum observation window
before migration of subscriber traffic could proceed.

> *This single change — added to the pre-migration checklist after phase 1 —
> prevented the same OSPF instability from appearing in any subsequent migration
> phase. The phase 1 incident cost approximately 40 minutes of additional
> investigation and delay to the migration window.*

---

## DR and BDR Behaviour in a Mixed-Vendor Environment

On broadcast segments (such as Ethernet), OSPF elects a Designated Router (DR)
and Backup Designated Router (BDR) to reduce the volume of LSA flooding. All
routers on the segment form Full adjacency with the DR and BDR rather than
with every other router on the segment.

In a mixed-vendor environment, DR/BDR election requires explicit attention.
Default OSPF priority values vary between vendors, and if priority is not
explicitly configured, the election outcome may not be what is intended.

In the Railwire migration, allowing default priority values to determine DR/BDR
election in a mixed MikroTik/Juniper environment contributed to instability.
Explicitly setting priority values to control which device became DR and which
became BDR resolved this aspect of the problem.

**Key lesson:** Never rely on default OSPF priority values in a mixed-vendor
environment. Explicitly configure priority on every interface where DR/BDR
election occurs.

---

## OSPF Areas in the Railwire Context

The Railwire network used OSPF Area 0 (backbone area) for core and distribution
layer routing. The single-area design was appropriate for the network scale and
simplified the routing architecture during a period when the network was undergoing
significant change.

During the migration, maintaining a stable Area 0 routing table was the primary
concern. Any instability in OSPF adjacencies at the core or distribution layer
had immediate impact on traffic forwarding across the entire network — not just
in the segment being migrated.

This is why OSPF adjacency stability was treated as a migration gate condition
rather than something to monitor and resolve reactively.

---

## Practical Troubleshooting Lessons from Production

These are troubleshooting checks that matter in a live ISP environment, in
priority order based on what was actually encountered:

**1. Timer mismatch — check first in mixed-vendor environments**
Hello and Dead interval mismatches prevent adjacency from reaching Full state.
In a mixed-vendor environment, never assume defaults will match. Check explicitly.

**2. MTU mismatch — causes ExStart stalling**
If a neighbour is stuck at ExStart, MTU mismatch is the most likely cause.
Check interface MTU on both sides and ensure they match, or configure
ip ospf mtu-ignore if MTU matching is not possible.

**3. Area mismatch — obvious but worth checking**
Neighbours in different OSPF areas will not form adjacency. Confirm area
configuration matches on both sides of every adjacency.

**4. Authentication mismatch — silent failure**
OSPF authentication mismatches cause adjacency failure without clear error
messages. If authentication is configured, verify keys and authentication
type match exactly.

**5. Interface status — confirm both physical and protocol status**
An interface that is administratively up but has a protocol issue will not
form OSPF adjacency. Confirm both physical connectivity and protocol status.

**6. Neighbour flapping — look at logs, not just current state**
A neighbour that appears to be in Full state may have been flapping. Review
OSPF logs for neighbour state change events over the relevant time period,
not just the current snapshot.

---

*This document reflects direct operational experience from the Railwire ICT
MikroTik-to-Juniper migration. OSPF behaviour described is from a live
production ISP environment involving 11,000+ broadband subscribers, not
from a lab or theoretical analysis.*
