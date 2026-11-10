# Brief: "Ashton Haynes Gov" agent (v2)

> **In one screen:** a Claude agent that finds small government web contracts, qualifies them, writes the full bid,
> and, once Ashton approves, submits by email, does the work, and invoices. It works on its own up to the approval
> gate. Ashton signs, certifies and accepts. It runs from his phone on his Claude membership, at no or near-zero cost.
>
> **Main target:** accessibility audits and remediation for small Virginia localities and school divisions, which face
> a federal WCAG 2.1 AA deadline (see §3). Federal micro-purchases are a secondary target, reached by *being findable*,
> not by scanning.

Items marked **verify** change over time. The agent must check them against the official source named before relying
on them, and must never hardcode them.

---

## 1. Owner facts
| | |
|---|---|
| Business | Ashton Haynes Web Design (sole proprietor), Manassas Park, VA |
| Credentials | B.A.S. Information Management, Security & Network Assurance (IT forensics), Palm Beach State College |
| Contact | (910) 757-8917 · haynesashton03@gmail.com · https://ashton-haynes-web-design.netlify.app |
| Privacy | Home address stays off anything public (see decision D1, because SAM.gov conflicts with this) |
| Budget | Claude membership only (no API billing). Free or near-free tools. |

## 2. Services offered
1. Website builds and redesigns (static or CMS; USWDS styling when the buyer is federal)
2. Accessibility audits and remediation: Section 508 / WCAG 2.1 AA (and 2.2 where asked), with VPAT/ACR write-ups
3. Website maintenance retainers
4. Small website security assessments, **only under signed rules of engagement** (see §7)

## 3. Where the money is (ranked)
| # | Target | Why | How the agent finds it |
|---|---|---|---|
| 1 | **VA localities and schools with populations under 50k** (Manassas Park, Manassas, towns, special districts, small school divisions) | The DOJ ADA Title II web rule (2024) requires WCAG 2.1 AA. The deadline for small entities is about **April 2027**. **Verify** the current status and any extension at ada.gov. | Locality bid pages and eVA, plus **approved outreach** (§5 step 4b) |
| 2 | Larger VA localities (Prince William, Fairfax, Loudoun…) | The large-entity deadline (April 2026) has passed, so they need remediation and ongoing maintenance | Locality bid pages, eVA |
| 3 | VA state agencies | Small purchases often favor **SWaM micro-business** vendors. **Verify** the rules in the DGS APSPM. | eVA / Virginia Business Opportunities |
| 4 | Subcontracting to federal primes | Lets him build past performance without being prime | SBA SubNet, prime supplier portals, SAM.gov "sources sought" |
| 5 | Federal set-asides of $25k and up | These are publicly posted on SAM.gov | SAM.gov API scan |
| 6 | Federal micro-purchases (≈ **$15k**, **verify** the FAR 2.101 threshold on acquisition.gov) | **Usually not posted.** They're bought by purchase card from vendors the buyer already knows. | Be findable: SBA small-business search profile, capability statement sent to agency small-business (OSDBU) offices |

**Skip for now:** security clearances, FedRAMP, CMMC level 2+, required on-site staff, bid or performance bonds,
handling CUI, and anything over the minimum-size or travel limits (decision D4).

## 4. Who does what
| Agent alone | Needs Ashton's one-step OK | Never (agent) |
|---|---|---|
| Scan, score, dedupe, qualify | Submit a bid (`submit bid <id>`) | Sign or certify anything for him |
| Draft bid packages, forms, Q&A questions | Send a question to a contracting officer | Log into SAM.gov, eVA, IPP or PIEE as him |
| Pricing research, capability statement | First version of each outreach email template | Accept an award or sign a contract |
| Calendar reminders, phone summaries | Start active security testing (needs signed ROE too) | Probe a site without written permission |
| Build and test deliverables on staging | Deliver to the client; send an invoice | Put non-public agency data or CUI into Claude unless the contract allows it |
| Track payments, learn from outcomes | Spend money (insurance, fees) | Pay anyone who charges to "register" him |

This table becomes `BID_POLICY.md`, and the code enforces it, not just the prompts.

## 5. Pipeline
Every opportunity is one record in `data/gov.json`, with this state flow:

```
found → qualified ─→ drafted → awaiting_approval → submitted | portal_checklist → won | lost | no_award
      ↘ skipped(reason)                                                           won → delivering → invoiced → paid
```

**Record fields:** `id, source, url, agency, title, naics[], psc, set_aside, est_value, qa_deadline, due_date,
submit_method (email|portal), fit_score, fit_rationale, red_flags[], requirements[], package_path, package_sha256,
approved_at, submitted_at, gmail_thread_ids[], award_amount, award_notes, invoice_ids[], paid_at, lessons`.

### Steps
1. **Scan** (Mon/Wed/Fri). Sources:
   - SAM.gov (API)
   - eVA / VBO
   - Bid pages for Prince William County, Manassas, Manassas Park, Fairfax, Loudoun and Fauquier counties, and their
     school divisions (keep the list in `gov/sources.json`)
   - SBA SubNet

   Filter to open, small-business-sized, web/accessibility/web-security work. Dedupe by source id and URL.
2. **Score** with an explicit rubric. A score of 60 or more is needed to draft.

   | Criterion | Weight |
   |---|---|
   | Scope match | 30 |
   | Size fits (no bond, value within range) | 15 |
   | Set-aside he qualifies for | 15 |
   | Remote OK | 15 |
   | Time to deadline ≥ 7 days | 10 |
   | Light insurance/forms burden | 10 |
   | Local preference | 5 |

3. **Qualify** each scored opportunity:
   - Build a requirements checklist.
   - Capture the deadlines (Q&A and due date) and the set-aside type.
   - List the required forms and insurance.
   - Check the red flags: on-site work, clearance, FedRAMP, CMMC, bond, CUI, **AI-use restrictions or disclosure
     rules**, required hosting, and liquidated damages.

   Anything out of reach becomes `skipped` with a one-line reason.
4. **Bid package** in `gov/bids/<id>/`:
   - Technical approach
   - Timeline
   - Price with assumptions (benchmarked against USAspending.gov awards and GSA CALC+ rates)
   - Compliance matrix (each requirement mapped to the page that answers it)
   - Pre-filled forms
   - Questions for the contracting officer
   - `CERTIFICATIONS.md`, which lists in plain English every certification Ashton would be making

   **4b. Outreach**: for target #1, the agent sends an approved-template email offering a free one-page accessibility
   snapshot. It is CAN-SPAM-compliant, uses passive checks only, and is capped at a few per week.
5. **Approval**: the phone summary shows the price, the deadline, the certifications and the package hash.
   `submit bid <id>` approves **that hash**. Any later edit sends it back to `awaiting_approval`.
6. **Submit**:
   - **Email bids**: the code writes the outbox, the chat session sends it from Gmail, and the thread id is recorded.
   - **Portal bids**: the agent gives a 2-minute checklist with every field pre-written. If the bid is still
     unsubmitted 24h before the deadline, the agent sends an escalation alert.
7. **Deliver** (on a win, after Ashton accepts):
   - Build or remediate the site.
   - Run the automated accessibility checks (axe/Pa11y) **plus** a manual checklist (keyboard, screen reader spot
     checks, color contrast, forms, PDFs).
   - Run security checks within the written scope only.
   - Produce the report, VPAT/ACR, and handoff docs.

   Federal production sites go to the **agency's hosting**. Netlify/GitHub Pages are staging only.
8. **Invoice** per the contract terms:
   - **Federal**: via the Invoice Processing Platform (IPP), or PIEE/WAWF for DoD. Ashton registers for these himself.
     Payment arrives by EFT to his SAM bank account.
   - **Local**: emailed invoice plus a W-9.

   The agent tracks the net-30 clock and Prompt Payment Act interest, and alerts when money lands. 30% goes to the tax
   set-aside (`money.ts`).
9. **Learn**: for each won or lost bid, record the winning price and vendor from USAspending.gov or the locality's
   award notice in `data/lessons.md`. The Friday review updates the scoring weights and pricing.

### Calendar and alerts
- Q&A deadline −2 days and due date −3 days
- Contract milestones
- Invoice due dates
- SAM.gov annual renewal −60 days
- Insurance renewal

## 6. Ashton's one-time setup (the agent drafts every form; real registration is free)
| Order | Step | Notes |
|---|---|---|
| 1 | **EIN** at IRS.gov | Free, 10 minutes. Keeps his SSN off W-9s and forms. |
| 2 | **Decide the business address** (D1) | SAM.gov needs a physical address and shows it publicly |
| 3 | **SAM.gov** registration via Login.gov → UEI (+ CAGE) | Allow 2–4+ weeks. Bank account for EFT. NAICS 541511/541512/541519, plus PSC codes such as DA01 or other IT/web codes; **verify** all codes on census.gov/naics and the PSC manual. Create a **SAM.gov API key** (account settings) for the scanner. |
| 4 | **SWaM micro-business** certification (Virginia SBSD) | Free. Do it early, because it's a big help with VA small purchases. |
| 5 | **eVA** vendor registration | **Verify** the current fees on eva.virginia.gov |
| 6 | **SBA small-business search profile** (DSBS/SBS) | This is how federal buyers find vendors for micro-purchases |
| 7 | **HUBZone check** on the SBA map | Free certification if his location qualifies |
| 8 | Get **insurance quotes** for general liability ($1M is common) + professional/cyber | Only buy once a contract needs it |
| 9 | Register for **IPP**/**PIEE** | Only when a federal award needs it |

**Credentials for the agent:** the SAM.gov API key goes into the cloud environment's credential store (it is never
pasted in chat or committed). An API key is not a login, so this does not break the "never log in as him" rule.

## 7. Guardrails
- **18 U.S.C. 1001**: false statements to the government are a crime. The agent never certifies, signs or accepts.
  `CERTIFICATIONS.md` makes it clear what he's certifying.
- **No invented past performance.** The capability statement says "UEI/CAGE: pending" until they're issued.
- **Security testing:** active testing only with signed rules of engagement (scope, URLs/IPs, dates, emergency
  contact). Everything else is passive (`sitecheck.ts`). This follows CFAA and the Virginia Computer Crimes Act.
- **Data:** no agency non-public data or CUI goes into Claude unless the contract permits it. Follow any AI clause in
  the contract.
- **Email:** CAN-SPAM (identification, opt-out, honest subject lines). No purchased lists.
- **Gifts and contact rules:** no contact with evaluators outside the official Q&A channel once a solicitation is open.
- `LEGAL.md` from Dedication is extended with these rules.

## 8. Reuse from Dedication (repo `haynesashton03-eng/Dedication`, branch `ccr-f8f79c57-8yshv3`)
| Need | Reuse |
|---|---|
| Run Claude (Opus) on the membership, no API key | `src/agent.ts` (`runAgent()` → `claude -p`, structured JSON output, timeouts, tool allow and block lists) |
| Cloud network setup | `scripts/launch.mjs` (proxy + CA for Node fetch) |
| Gmail send and read | `RUNBOOK.md` outbox pattern: the code writes the outbox, the chat session sends with the Gmail connector and records thread ids |
| Scheduled runs with Gmail | Scheduled tasks bound to the chat session (no new-session mode) |
| Build and publish sites | `src/build.ts`, `src/prompts.ts` (developer + reviewer prompts), `src/deploy.ts` (Netlify), `src/hosting.ts` (GitHub Pages) |
| Netlify credit protection | `creditGuard()` in `src/deploy.ts` (blocks above 85%) |
| Passive site checks | `src/sitecheck.ts` |
| Learning loop | `src/learn.ts` + `data/lessons.md` + Friday review (RUNBOOK step 7) |
| Money | `src/money.ts` (30% tax set-aside), `src/contract.ts` |
| To-dos and reminders | `OWNER_TODO.md`, Monday reminders, Google Calendar |
| Legal | `LEGAL.md` (CAN-SPAM, CFAA, FTC fake reviews) |

## 9. New pieces
| File | Purpose |
|---|---|
| `src/gov.ts` | Commands: `scan`, `qualify <id>`, `bid <id>`, `submit <id>` (approved hash + email only), `invoice <id>`, `capability`, `status` |
| `src/gov-sources.ts` | One adapter per source (SAM API, eVA/VBO, each locality page), all returning the same record shape |
| `gov/sources.json` | Source list with URLs and check frequency |
| `gov/REGISTRATION.md` | The step-by-step guide for §6 |
| `gov/capability-template.html` | Generates the capability statement PDF (via Playwright) |
| `gov/templates/` | Technical approach, compliance matrix, VPAT/ACR, ROE, invoice, outreach email |
| `GOV_RUNBOOK.md` | What each scheduled run does, and the commands the chat session runs |
| `BID_POLICY.md` | The §4 table |

**Network hosts to allow:**
- api.sam.gov, sam.gov
- eva.virginia.gov, mvendor.cgieva.com
- api.usaspending.gov
- each locality's domain in `gov/sources.json`

**Membership budget:** usage limits are shared with Ashton's own Claude use, so each run qualifies at most about 10
new opportunities, caches fetched pages for 48h, and uses web search only for sources with no feed or API.

**Where the code lives:** decision D2. It's a separate private repo (e.g. `haynesashton03-eng/gov-agent`), with the
Claude GitHub app given access **and Dedication and samples kept selected**.

## 10. Phases (each one ends with a "done when")
| Phase | Scope | Done when |
|---|---|---|
| 0 | Registrations (§6) + capability statement | UEI issued, SWaM application filed, capability PDF approved |
| 1 | `scan` + `qualify` only | 2 weeks of runs, and Ashton agrees at least 70% of the "qualified" picks were worth a look |
| 2 | `bid` packages | Three packages drafted that Ashton would submit with minor edits |
| 3 | `submit` (email) + portal checklists + calendar alerts | First real bid submitted, with no deadline missed |
| 4 | Delivery + `invoice` | First contract delivered, invoiced and paid |
| 5 | Learning loop + outreach | Pricing uses award data, and lessons get updated weekly |

## 11. Open decisions for Ashton
- **D1 Business address** for SAM.gov and eVA: the home address (public) or a legitimate business address such as a
  virtual office or coworking space (check that SAM.gov accepts it).
- **D2 Repo:** create `gov-agent`, or build in this `never` repo?
- **D3 Insurance budget** per year, and whether to buy before or after the first award.
- **D4 Limits:** smallest contract worth bidding (e.g. $1,500), largest he'll take on alone, and travel radius for any
  kickoff meeting.
- **D5 Outreach:** OK to email small localities offering a free accessibility snapshot? Up to how many per week?

## 12. Honest expectations
- Registration takes 2–4 weeks (SAM.gov sometimes longer). The first award likely comes 2–6 months after that, and
  payment is net-30 after acceptance.
- With no past performance, the first wins are small: local accessibility audits, subcontracts and micro-purchases.
  Each win makes the next easier, so log every one.
- The agent does most of the work. Ashton's approval on bids and contracts is required by law, and it also protects
  him.
