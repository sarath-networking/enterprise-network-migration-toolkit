# MPLS in Production — Operational Experience from Railwire ICT and KFON

## Based on: Railwire ICT NOC Operations and KFON Infrastructure Deployment

This document covers MPLS as encountered in two real production environments —
the Railwire ICT broadband network running over the RailTel MPLS backbone, and
the KFON Palakkad district deployment. It is written from direct operational
experience coordinating MPLS-based services in live ISP and government
infrastructure environments.

MPLS is well documented at the protocol level. What is less documented is what
it actually means to operate MPLS-dependent services in a live environment where
you do not control the MPLS core — and what happens when something goes wrong
across an organisational boundary.

---

## How MPLS Was Used in the Railwire Environment

Railwire ICT operated its broadband network with connectivity routed over the
RailTel MPLS backbone. RailTel Corporation of India — the railway ministry's
telecoms subsidiary — provided the MPLS infrastructure, and Railwire used it
to deliver services across Kerala.

This meant that Railwire's NOC was operating in a split-responsibility model:

- Railwire owned and operated the edge and access layer — the customer-facing
  infrastructure, the broadband subscriber sessions, the distribution and edge
  PoPs
- RailTel owned and operated the MPLS core — the label switching infrastructure,
  the PE routers, the backbone capacity

When something went wrong in the MPLS layer, Railwire's NOC could see the
symptoms — traffic loss, latency increase, reachability failures — but could
not diagnose or resolve the root cause independently. Resolution required
coordinated troubleshooting across both organisations.

---

## MPLS VPN Services — 145 Bank Locations

One of the significant MPLS-dependent workstreams at Railwire ICT was coordinating
VPN connectivity for 145 State Bank of Travancore and State Bank of India branch
locations across Kerala, running over the RailTel MPLS backbone.

### What This Looked Like Operationally

Each bank branch location was connected via an MPLS L3 VPN — a dedicated virtual
routing and forwarding (VRF) instance that kept bank traffic isolated from other
traffic on the shared MPLS backbone. From the bank's perspective, branch locations
appeared to be on a private network. From Railwire's perspective, each branch
was a CE (Customer Edge) device connecting to a PE (Provider Edge) router in the
RailTel MPLS infrastructure.

**The operational model had three layers:**

- **Branch CE router** — Railwire's responsibility for installation and maintenance
- **PE router** — RailTel's infrastructure, Railwire had visibility but not control
- **Bank's core network** — bank IT team's responsibility, Railwire had no access

When a bank branch lost connectivity, the incident had to be diagnosed across
all three layers simultaneously — with three separate organisations involved,
each with different access levels, different priorities, and different escalation
processes.

### What Made This Challenging

**Fault isolation across organisational boundaries.**
Standard troubleshooting in a single-organisation environment involves checking
each layer in sequence until the fault is found. In a multi-organisation MPLS
environment, you cannot always check the layer you suspect — you have to request
that another organisation checks it and reports back. This adds time to every
incident, particularly out of hours when escalation paths are slower.

**VRF configuration consistency.**
With 145 bank locations, maintaining consistent VRF configuration across all
PE-CE connections required careful documentation and a structured change process.
A misconfigured route target or missing VRF definition on a PE router could
silently break connectivity for a specific branch without affecting any other
location — making it look like a branch-level fault rather than a VPN
configuration issue.

**BGP between CE and PE.**
Bank branch connectivity used BGP between the CE router at each branch and the
PE router in the RailTel infrastructure. BGP session stability between CE and PE
was a key operational metric — a BGP session drop at a bank branch meant the
branch was effectively isolated from its core network. Monitoring BGP session
state across 145 locations and correlating drops with other network events was
a core NOC responsibility.

> *When a BGP session between a bank branch CE and the RailTel PE router dropped
> at 2am, the incident involved Railwire NOC, RailTel network operations, and the
> bank's IT team simultaneously. Having clear escalation contacts and a documented
> troubleshooting process for this specific scenario was what kept resolution times
> manageable.*

---

## MPLS in the KFON Context

In the KFON Palakkad district deployment, MPLS was part of the core and
pre-aggregation layer architecture — used to provide traffic engineering and
service separation across the district backbone.

The KFON deployment used MPLS to support multiple service types over shared
infrastructure — government office connectivity, broadband subscriber traffic,
and management traffic — while keeping each service type appropriately isolated.

**Traffic separation using MPLS VPNs** allowed different categories of government
connectivity to be logically separated on the same physical infrastructure — an
important requirement for a government network carrying both public and restricted
traffic types.

**MPLS traffic engineering** at the core layer provided the ability to control
traffic paths across the district backbone — relevant in a ring topology where
traffic engineering determines which direction around the ring traffic flows
under normal and failover conditions.

---

## Key Components — What They Mean in Practice

**LER (Label Edge Router) — where MPLS meets IP**
The Label Edge Router is where IP packets enter the MPLS domain and are assigned
a label, or where labelled packets leave the MPLS domain and the label is removed.
In the Railwire context, the PE routers at RailTel were the LERs for bank VPN
traffic — where bank branch IP traffic was encapsulated into MPLS VPN tunnels for
transport across the backbone.

**LSR (Label Switch Router) — the core forwarding engine**
Label Switch Routers in the MPLS core forward packets based on labels rather than
IP lookups. From Railwire's perspective, the RailTel MPLS core was a black box of
LSRs — traffic went in at one PE and came out at another PE, with label switching
happening inside infrastructure Railwire did not operate or have visibility into.

**VRF (Virtual Routing and Forwarding) — service isolation**
VRF instances on PE routers provide the logical separation that makes MPLS L3 VPN
services work. Each bank customer had a dedicated VRF on the relevant PE routers,
ensuring that bank traffic was completely isolated from other customers' traffic
on the shared backbone. VRF configuration errors — wrong route targets, missing
import/export policies — were a common source of connectivity faults that required
PE-level access to diagnose.

---

## Operational Issues Encountered in Practice

**Label distribution problems — LDP session instability**
Label Distribution Protocol (LDP) session instability in the MPLS core caused
intermittent traffic loss that was difficult to diagnose from the edge. Symptoms
appeared as packet loss or latency spikes with no obvious cause at the CE or
access layer. Root cause was only identifiable through RailTel's core monitoring.

**BGP session drops at CE-PE boundary**
The most common fault type for bank VPN locations — BGP session between the branch
CE and RailTel PE router dropping. Usually caused by physical connectivity issues
at the branch, CE router configuration changes, or PE router maintenance. Required
coordination across Railwire, RailTel, and bank IT to diagnose and resolve.

**Route leakage between VRFs**
An incorrectly configured route target on a PE router caused routes from one
customer's VRF to be imported into another customer's VRF. This is a serious
fault in a multi-tenant MPLS environment — traffic that should be isolated becomes
visible across VRF boundaries. Caught during routine monitoring before it caused
a security incident, but required immediate escalation to RailTel for PE-level
configuration correction.

**Latency and congestion on backbone segments**
MPLS backbone congestion during peak periods caused latency increases that were
visible at the application layer for bank branch users. Traffic engineering
adjustments in the RailTel core were required to redistribute load across
available backbone capacity.

---

## Lessons Learned from Operating MPLS-Dependent Services

**You cannot troubleshoot what you cannot see.**
Operating services over a third-party MPLS backbone means accepting limited
visibility into the core. Build monitoring at the edge that gives you as much
information as possible about what is happening in the MPLS layer without
requiring core access — CE-PE BGP state, PE reachability, end-to-end latency.

**Escalation processes must be pre-agreed, not improvised.**
When a bank branch loses connectivity at 2am, working out who to call at RailTel
and what information they need is not something to figure out during the incident.
Escalation contacts, information requirements, and expected response times should
be documented and agreed before faults occur.

**VRF configuration changes require a change management process.**
In a multi-tenant MPLS VPN environment, a PE router configuration error can affect
multiple customers simultaneously. Changes to VRF configuration — route targets,
import/export policies, BGP neighbours — should follow a formal change management
process with rollback procedures defined before the change is made.

**Document the CE-PE BGP configuration for every site.**
With 145 bank locations, having a documented record of the BGP configuration at
each CE-PE boundary was essential for fault diagnosis. Sites without documentation
took significantly longer to troubleshoot when BGP sessions dropped.

---

*This document reflects direct operational experience from Railwire ICT NOC
operations and the KFON Palakkad district deployment. MPLS behaviour and
operational challenges described are from live production environments, not
from lab simulations or theoretical analysis.*
