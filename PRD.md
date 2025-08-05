# SlateHub Product Requirements Document (PRD)

## Version History
- **Version**: 4.0
- **Date**: July 11, 2025
- **Author**: Chris Bruce
- **Status**: Draft
- **Notes**: Updated to include QR code generation for profiles and jobs, enabling easy sharing in posters, flyers, or other materials. QR codes will link to public profiles or job postings. Further iterations can refine terms or add details.

## 1. Introduction
### 1.1 Overview
SlateHub is an open-source SaaS platform designed as a collaborative hub for the TV, film, documentary, commercial, social media, and content production industry. It combines elements of LinkedIn (networking and profiles) and GitHub (collaboration and project management) to connect filmmakers, content creators, brands, producers, crew, talent, influencers, and agencies.

The platform is built in two phases:
- **Phase 1**: A free, ad-free talent/crew/job directory with semantic search, AI-assisted profile creation, and no costs for job postings, networking, or profiles (only a one-time verification fee for third-party identity costs).
- **Phase 2**: Paid production management tools with AI virtual assistants for end-to-end workflows (development, pre-production, production, post-production, marketing, and distribution).

Core technical foundation:
- **Database**: SurrealDB (multi-model DB supporting graph relationships, key-value, and vector embeddings for semantic search).
- **Backend**: Rust with Axum for REST API.
- **Frontend**: SvelteKit (client-side rendering only, no SSR for performance).
- **Graph/Vector Leverage**: Use SurrealDB's graph capabilities for relationships (e.g., people-orgs-projects); vector embeddings for semantic search and AI features (via fastembed for efficient, local embeddings).
- **File Storage**: Self-hosted S3-compatible solution like MinIO for media uploads (images/videos), integrated with SurrealDB for metadata.

The platform emphasizes inclusivity, respecting distinctions between filmmakers and content creators while appealing to both, and ensuring legitimacy for feature film studios without excluding influencers. All features prioritize a personal, affirmational tone: extra encouraging for less experienced users (e.g., "You're taking a great first step—keep building!") and more assertive for experienced ones (e.g., "Leverage your expertise to dominate this opportunity.").

### 1.2 Goals and Objectives
- Democratize access to networking and opportunities with no costs or ads for core features (profiles, jobs, networking).
- Enhance discovery via top-tier semantic search (natural language queries for jobs/talent/collabs, accessible without an account).
- Foster collaboration through projects, organizations, and delegated access.
- Monetize solely via identity verification fees (TBD pricing) and Phase 2 premium tools.
- Ensure data privacy, verification, and scalability.
- Launch MVP in 45 days (focus on core Phase 1 features).
- Provide multilingual support from launch, inferring language from browser settings with easy overrides; translate all content (including user-generated) to feel native.
- *Suggested Goal*: Integrate automated search alerts and email reports for job/talent matches.

### 1.3 Scope
- **In Scope**: Profiles (with role experience levels), organizations, projects, jobs/casting, verification, AI auto-fill (via link parsing/scraping without OAuth where possible), semantic search (publicly accessible), delegations, media uploads/embeds (with MinIO), social links, multilingual translation, tone-adapted messaging, automated email reports, QR code generation for profiles and jobs.
- **Out of Scope**: Full payment processing (handle externally); advanced AI generation (defer to Phase 2); mobile app (web-first); initial communication channels beyond email (e.g., SMS/WhatsApp—plan for future).
- *Suggested Addition*: Basic in-app messaging/notifications with affirmational tone.

### 1.4 Assumptions and Risks
- **Assumptions**: Browser language detection reliable for multilingual inference; social data extractable via links without OAuth (use scraping/AI parsing); SurrealDB's vector support with fastembed sufficient for semantic search (embeddings via open-source models like Sentence Transformers).
- **Risks**: Translation accuracy for user-generated content (mitigate with AI services like DeepL API); tight 45-day launch (prioritize MVP: profiles, search, verification); legal compliance for worldwide verification (select providers accordingly).
- **Dependencies**: Third-party identity verification APIs; translation APIs (e.g., DeepL or Google Translate); AI models for auto-fill and search; MinIO setup for self-hosted storage.

### 1.5 Recommended Third-Party Identity Verification Providers
Based on market research for the least expensive options with worldwide support (195+ countries, pay-per-use models to minimize costs), here are top recommendations. Pricing is TBD and should be verified directly (as of 2025, estimates from public sources; focus on per-successful-verification to align with monetization). Providers selected for affordability, global coverage, and ease of integration.

1. **iDenfy**: Cost-effective (pay only per successful verification, ~$0.50–$1.50/verify; saves up to 75% on failed attempts). Worldwide coverage (195+ countries), AI-powered with human oversight, compliant with KYC/AML/GDPR. Ideal for startups/SMBs; flexible API integration.
2. **Veriff**: Affordable per-verification (~$1–$2), global support (195+ countries), fast biometric/document checks. Strong on fraud prevention; scalable for high-volume. Free trials available; hybrid AI/human model.
3. **Onfido (by Entrust)**: Competitive pricing (~$1–$3/verify), extensive global coverage (195+ countries, 2,500+ document types). AI-driven with passive fraud detection; compliant with SOC 2/ISO. Good for regulated industries; modular SDKs for integration.

*Notes*: Avoid enterprise-heavy options like Trulioo or Persona if cost is primary (higher tiers). Check for volume discounts; integrate via API without OAuth if possible. For worldwide, ensure support for diverse documents/languages.

## 2. User Personas
(Adapted from previous; unchanged for now, but messaging tone tailored per experience level inferred from profile roles.)

1. **Producer (Elena Vasquez)**: Independent freelance producer seeking efficient team assembly.
2. **Studio/Agency Executive (Marcus Blackwell)**: Oversees talent acquisition at major studios.
3. **Influencer/Content Creator (Jordan Kim)**: Builds viral content and seeks collaborations.
4. **Brand Marketer (Sophia Patel)**: Manages campaigns and scouts creators.
5. **Actor/Talent (Liam Harper)**: Applies for roles and builds visibility.
6. **Crew Member (Nadia Ruiz)**: Freelance specialist looking for gigs.
7. **Director/Filmmaker (Theo Langston)**: Crafts narratives and assembles teams.
8. **Agent (Rebecca Stein)**: Manages client profiles and applies on their behalf.

## 3. Functional Requirements
### 3.1 User Profiles (Person Nodes)
- Users create a "Person" profile as the core entity in SurrealDB (graph for relationships).
- Profile includes: Name, bio, skills, experience, credits, contact info (multiple emails), location, availability.
- Roles and Experience: Users add one or more roles (e.g., Director, Actor, Cinematographer). For each role, specify duration (e.g., years/months) and self-selected experience level using positive, non-judging terms: Student (exploring the craft), Beginner (building foundations), Portfolio Building (gaining momentum), Expert (leading with mastery). This data influences messaging tone (encouraging for lower levels, assertive for higher).
- Dual-purpose: Job application template and public portfolio (optional visibility; custom URL like slatehub.com/username).
- Delegation: Grant access to others (e.g., agents) for editing/applying. Graph: Person -> DelegatesTo -> Person/Org.
- Verification Levels (monetized via third-party fee at Level 3):
  - Level 1: Email (2 photos, 1 video embed limit).
  - Level 2: Phone/SMS (4 photos, 1 video embed).
  - Level 3: Third-party ID (20 photos, unlimited embeds; fee TBD).
- Media: Upload images/videos to self-hosted MinIO (with limits enforced); embed videos (YouTube/Vimeo—no storage cost).
- Social Integrations: Add links (LinkedIn, X, IMDb, etc.); optional connect for data extraction (no third-party OAuth unless essential—prefer scraping/AI parsing). SlateHub acts as OAuth provider for external apps.
- AI Auto-Fill: Paste links; AI parses/extracts data (e.g., credits/bio) without OAuth. Use fastembed for efficient embeddings in SurrealDB.
- Messaging Tone: Adapt based on role experience levels (e.g., combined duration/level score): Encouraging for Student/Beginner, assertive for Expert.
- Multilingual: Infer language from browser; easy switcher on every page. Translate all UI/user content via API (e.g., DeepL) to user's language.
- QR Code Generation: Users can generate downloadable QR codes linking to their public profile (e.g., via a button on the profile page). Use Rust QR code library (e.g., qrcode crate) in backend to create SVG/PNG images dynamically, stored temporarily or generated on-the-fly.
- *Suggested Feature*: Profile analytics (views/matches) with encouraging feedback.

### 3.2 Organizations (Org Nodes)
- Create public Orgs (production companies, etc.); profiles with media (stored in MinIO).
- Membership: Add members with roles (Admin/Member). Graph: Org -> HasMember -> Person (with Role).
- Delegation at Org level.

### 3.3 Projects and Opportunities
- Create Projects under Person/Org: Title, description, etc.
- Add casting/jobs; apply via profile.
- Graph: Project -> OwnedBy -> Person/Org; Person -> AppliesTo -> Job.
- QR Code Generation: For job postings or casting calls within projects, generate QR codes linking to the job details page (e.g., for use in posters or flyers). Dynamically generated via backend, downloadable as image.

### 3.4 AI and Search Features
- **Semantic Search (Priority)**: Natural language queries (e.g., "experienced DP for indie horror") across profiles/jobs/orgs/projects. Use SurrealDB vectors with fastembed for embeddings (multi-lingual support via translated queries). Publicly accessible without account; results in user's inferred language.
- Automated Searches: Users set alerts; email reports on matches (translated, with affirmational tone).
- AI Virtual Assistant: Phase 1 basic (auto-fill); Phase 2 expansion.
- *Suggested Feature*: Recommendations via graph traversal + vectors.

### 3.5 Additional Features
- Notifications: Email-first; future: SMS, WhatsApp, Signal, Discord (no Slack).
- Privacy: Granular controls.
- No Ads/Costs: Enforce for core features.

## 4. Non-Functional Requirements
- **Performance**: Semantic searches <2s; scale for 10k+ users.
- **Security**: No OAuth login; username/password with MFA. GDPR/CCPA compliant.
- **Scalability**: SurrealDB for all data models; MinIO for storage.
- **Usability**: Client-side SvelteKit; multilingual UI.
- **Accessibility**: WCAG 2.1.
- **Tech Stack**: Rust/Axum (API), SurrealDB (DB), SvelteKit (frontend, no SSR), fastembed (embeddings), MinIO (storage).

## 5. Roadmap and Phases
- **45-Day MVP Launch (Phase 1 Core)**: Profiles, verification, semantic search, basic projects/jobs, multilingual, AI auto-fill. Prioritize search excellence.
- **Phase 1 Full**: Orgs, delegations, automated emails, QR code generation.
- **Phase 2**: Premium tools, advanced comms.
- **Milestones**: Prototype in 2 weeks; beta in 30 days; launch in 45.

## 6. Open Questions for Clarification
- Specific translation API preference (DeepL vs. Google)?
- Details on scraping social links (legal/compliance)?
- Exact media storage quotas enforcement in MinIO?
- Any must-have for 45-day MVP beyond listed?
