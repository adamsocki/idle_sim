# MARKETING GROWTH PLAN — idle_01

Summary
-------
This document is a growth-hacker style marketing plan for the `idle_01` project (working title). It converts repository signals (iOS app, terminal UI, `Liquid Consciousness` aesthetic, recent terminal/dashboard work) into a prioritized, measurable plan to attract early users, build community, and validate product-market fit.

Quick repo-derived insights
--------------------------
- Platform: iOS (files like `idle_01App.swift`, Xcode project present). Recent commits show active UI work and TestFlight-ready features.
- Product features: a city simulation with an emphasis on aesthetics and narrative — plus an embedded terminal UI and dashboard experiences (see `ui/terminal/*`).
- Tone & design: deliberate, poetic UI copy and 'Liquid Consciousness' visual language — useful for creative positioning.
- Dev maturity: working prototype with UI components, simulator integration, and command parsing. Commits are frequent and iterative (Sep 29 -> Oct 13, 2025), indicating active development.

Positioning
-----------
- Elevator pitch: "idle_01 is a meditative city-consciousness simulator — part ambient idle game, part poetically-designed dashboard, with a hacker-friendly terminal for power players and creators." 
- Primary audience: players who enjoy ambient/idle games, art-game audiences, indie game enthusiasts, designers/creatives who appreciate aesthetic UI, and developer/tooling communities attracted to terminal-style interfaces.
- Value props to highlight:
  - Slow-play, emergent systems that reward observation and experimentation.
  - Unique visual and narrative design (Liquid Consciousness style).
  - A terminal interface that enables playful discovery and power-user experiments.

North Star & primary metrics
---------------------------
- North Star: engaged users who return weekly and invite others (Activated, Retained users).
- Primary KPIs (quantitative):
  1. Email list signups / landing page conversion rate
  2. TestFlight installs (or App Store downloads)
  3. Day-1/Day-7 retention
  4. Weekly active users (WAU) and command usage frequency
  5. Social engagement & community growth (followers, mentions, subreddit threads)

Growth strategy overview (high level)
------------------------------------
1. Build a simple conversion funnel: landing page -> email capture -> TestFlight (or waitlist) -> engaged demo users.
2. Use short-form content and developer storytelling to build an audience: demo GIFs, 60s video, and behind-the-scenes posts.
3. Run repeatable experiments (A/B test hero messages, CTA wording, demo thumbnails) and prioritize based on cost-to-run and expected impact.
4. Launch to communities where the product fits (IndieGame, IdleGame, art/game communities, Product Hunt, GitHub dev audience).

Priority experiments (first 6 weeks)
----------------------------------
Each experiment: hypothesis — metric — duration

1) Landing page + email capture
   - Hypothesis: A visually aligned landing page will convert >5% of visitors to email signups when targeted correctly.
   - Metric: conversion rate (visitors -> emails), baseline visits.
   - Duration: 1 week to build, 4 weeks to iterate.
   - Tasks: hero GIF, 2 messaging variants (art vs. terminal), signup form (Mailchimp/ConvertKit/Plausible + simple backend), UTM tags.

2) 60s demo video + short clips
   - Hypothesis: Short, polished demos will drive referral traffic and social follows.
   - Metric: click-through rate from socials -> landing page, view completion.
   - Duration: 1 week creation, ongoing posting.
   - Channels: Twitter/X, Mastodon, Threads, TikTok (60s), Instagram Reels.

3) GitHub release + developer blog post
   - Hypothesis: Developer-focused release will attract contributors, press, and technical users.
   - Metric: repo stars, forks, issue engagement, demo downloads.
   - Duration: 1 week to prepare, link in outreach.

4) Product Hunt launch (MVP-ready)
   - Hypothesis: Product Hunt spike will create a sustainable stream of signups if the launch includes a strong narrative and assets.
   - Metric: number of upvotes, signup conversion, referral traffic.
   - Duration: plan 2 weeks before launch; launch day and immediate 1 week follow-up.

5) Community seeding: Reddit, r/IdleGames, r/IndieDev, r/ExperimentalGames
   - Hypothesis: Niche community posts that surface design process or a curious demo will generate high-quality traffic.
   - Metric: traffic quality (time-on-site), signups, comments.
   - Duration: ongoing, post cadence weekly.

Experiment prioritization matrix
--------------------------------
- Priority A (fast, high ROI): landing page + email capture, 60s demo video, GitHub release + README, social pinned thread.
- Priority B (moderate effort): Product Hunt prep, community seeding, short-form content series.
- Priority C (longer-term): referral program, paid ads experiments, influencer co-creation.

12-week roadmap (detailed)
-------------------------
Weeks 0–2 (Prep & foundation)
  - Create landing page (2 variants): art-forward hero vs. terminal-forward hero.
  - Add email capture, analytics (UTMs, Google Analytics / Plausible), event tracking (PostHog / Firebase / Mixpanel).
  - Produce a 60s demo video + 3 short clips (15s/30s) and GIFs for social.
  - Prepare GitHub release: polished README, demo GIF, CONTRIBUTING, short dev post about the terminal UI and design choices.

Weeks 3–6 (Community seeding & small launches)
  - Soft launch to dev communities (GitHub release, Hacker News 'Show HN' possible), IndieGame/Idle communities.
  - Start posting short clips 3x/week on socials, rotating messaging tests.
  - Collect feedback from early testers (via short survey after signup).
  - Run simple A/B tests on landing page headlines and CTA language.

Weeks 7–9 (Product Hunt & press)
  - Finalize Product Hunt assets (images, tagline, maker comment thread) and schedule launch.
  - Outreach to niche press and newsletter curators (Indie Game Dev, iOS game newsletters, design journals).
  - Publish a long-form 'making-of' dev/design blog post.

Weeks 10–12 (Scale & measurement)
  - Analyze conversion funnel; double down on highest-performing channels.
  - Identify top-performing content pieces and repurpose for paid experiments.
  - Plan next product milestones (referral, premium features, more command modules).

Messaging frameworks and examples
--------------------------------
- Core: "A meditative city simulator that rewards curiosity — an artful idle experience with a terminal that invites playful mastery." 
- Developer/Power-user angle: "Explore and script the city's consciousness through the terminal — built for players who like to tinker." 
- Short socials:
  - Twitter/X: "A new kind of idle — cities that dream. Tap to watch the city breathe. Join the waitlist → [link]"
  - GitHub release tagline: "idle_01 — City consciousness simulator with terminal-driven exploration. Playful, slow, and poetic."

Assets to prepare (priority order)
---------------------------------
1. Landing page hero GIF (5–8s) + static hero image
2. 60s demo video + three short clips (15s, 30s, 60s)
3. Press kit: screenshots, short description, founder bio, key features list
4. Product Hunt images and thumbnail
5. GitHub README with demo GIF, quickstart, and contributing notes

Measurement & tooling
---------------------
- Analytics: Plausible or Google Analytics for traffic; PostHog or Firebase for event-level tracking (command usage, session length, retention cohorts).
- Attribution: Use UTM parameters for all links and a short tracker (Bitly / Rebrandly) for outreach.
- Experimentation: Simple A/B tests via two landing page variants and track conversion by UTMs.
- Dashboard: a Notion or Google Sheet running weekly metrics, or a lightweight dashboard using Google Data Studio / Metabase.

Outreach templates (short)
-------------------------
Product Hunt blurb (example):
"idle_01 is a slow, meditative city consciousness simulator — equal parts idle game and poetic dashboard. Explore emergent behaviors, poke the city with terminal commands, and watch its moods shift. We’re launching on Product Hunt — join the waitlist or try the TestFlight demo!"

Press/Newsletter outreach email (subject + body):
Subject: "Explore a city that thinks — idle_01 demo & press kit"

Body (short):
Hi [Name],

I built idle_01, a meditative city simulator that blends an ambient idle experience with a terminal UI for playful exploration. We’re opening a small round of TestFlight invites and would love to offer an exclusive preview for your readers. I can send a demo video and press kit. Would you be interested?

— [Your name & short bio]

Community seeding post (Reddit / Indie dev)
Title: "I made an ambient city simulator with a hacker-friendly terminal — looking for feedback"
Body: Short description + GIF + link to landing page and signups. Ask for playtesting feedback and UX thoughts.

Risk, edge-cases & mitigations
------------------------------
- Risk: Low initial traffic — mitigate by focusing on niche communities and developer audiences first.
- Risk: Poor retention — mitigate by instrumenting event tracking early to identify where users drop off and by designing small onboarding tasks that hook users.
- Risk: Feature expectation mismatch (terminal might seem too 'hard') — mitigate by producing a low-friction demo and clear messaging that the terminal is optional and exploratory.

Next steps (concrete)
---------------------
1. Finalize landing page copy and produce hero GIF (1 week).
2. Hook up email capture + analytics + simple event tracking (1–2 days).
3. Create demo video and 3 short clips (3–5 days).
4. Prepare GitHub release + README improvements (2–3 days).
5. Seed communities and schedule Product Hunt (after Week 4).

Checklist (for the repo)
-----------------------
- [ ] Add demo GIF(s) and screenshots to README
- [ ] Add CONTRIBUTING and short project intro for non-dev users
- [ ] Create `marketing/` folder with assets and copy variants
- [ ] Add a `press-kit/` folder with images and short bios
- [ ] Setup simple landing page (Netlify / Vercel / GitHub Pages) with email capture

Appendix: Suggested experiment matrix (examples)
----------------------------------------------
- A/B test headline: "Cities that dream" vs "Control the city's mood with a terminal" — metric: signup CTR.
- Social post timing: post short clip at 9am/12pm/6pm (local TZ) — metric: visits per post.
- Community post framing: "Design/dev making-of" vs "Play demo" — metric: upvotes & signups.

Credits
-------
Built from repository signals and a growth-hacker playbook. For help executing any item above (landing page, analytics wiring, PR outreach, or content creation), tell me which one to start and I will execute the next steps.
