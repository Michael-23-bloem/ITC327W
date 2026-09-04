# ITC327W
...
# Décor & Events Booking Platform

A cross-platform booking and portfolio management system for a décor/events business, allowing customers to browse past work, get instant cost estimates, and submit booking inquiries — while giving the owner a single dashboard to manage inquiries, pricing, and portfolio content.

---

## Table of Contents
- [About the Project](#about-the-project)
- [Group Members](#group-members)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Functional Requirements](#functional-requirements)
- [Non-Functional Requirements](#non-functional-requirements)
- [System & Integration Requirements](#system--integration-requirements) 
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [License](#license)

---

## About the Project

**Course/Module:** [Work Integrated Learning]
**Institution:** [Central University of Technology]
**Submission Date:** [04 SEPTEMBER 2026]

Customers currently have to message the owner directly (e.g. via WhatsApp) to see past work, get pricing, and book events. This platform replaces that with a self-service portfolio browser, an instant cost estimator, and a direct booking/inquiry flow — with a dedicated dashboard for the owner to manage everything in one place instead of scattered personal messages.

---

## Group Members

| Name | GitHub Username | Role |
|------|------------------|------|
| Mchaisa M | Michael-23-bloem |  |
 | Motlhakane M | ValiantAlias |  |
 | Ramotete KJ | Kat-7-coder |  |
 | Khiba SP | SonopoKhiba |  |
 | Modisana MD | Robert-67 |  |
 | Semela K | WANO-10 |  |
 | Phahlane LG | Galalentsang_Phahlane |  |
 | Khunyeli P | PabloSamurai |  |
 | Gumede N | NomveloG |  |
 | Makara K | Michael-23-bloem |  |
 

---

## Features

- Browse a categorised portfolio of past completed events
- Get an automatic cost estimate by selecting a service/package and guest count
- View what's included in a selected package (items, tier, accessories)
- Submit a booking/inquiry request directly through the platform
- Owner dashboard to view and respond to incoming inquiries
- Owner tools to upload new portfolio items (images, descriptions, pricing)
- Basic analytics on inquiries, estimates, conversions, and drop-offs
- Role-based access — customers can view/estimate only; only the owner/partners can edit business data

---

## Tech Stack

**Mobile app:** Flutter
**Web app:** ASP.NET
**Backend / Database / Auth:** Supabase (shared instance across both apps)
**Integration:** Flutter connects via the Supabase client SDK; ASP.NET connects via REST/PostgREST

---

## Functional Requirements

| ID  | Requirement                                                                         | Priority    |
|-----|-------------------------------------------------------------------------------------|-------------|
| FR1 | Customers can browse a categorised portfolio of past completed events               | Must Have   |
| FR2 | Customers select a service/package + guest count to get an automatic cost estimate  | Should Have |
| FR3 | Customers can view what's included in a selected package (items, tier, accessories) | Must Have   |
| FR4 | Customers can submit a booking/inquiry request directly through the platform        | Must Have   |
| FR5 | The owner can log in and view/respond to incoming inquiries via a dashboard         | Must Have   |
| FR6 | The owner can upload new portfolio items (images, descriptions, pricing)            | Must Have   |
| FR7 | The system records basic funnel data (inquiries, estimates, conversions, drop-offs) | Must Have   |
| FR8 | Only owner/business partners can edit business data; customers view/estimate-only   | Must Have   |

---

## Non-Functional Requirements

| ID   | Requirement                                                               | Priority    |
|------|---------------------------------------------------------------------------|-------------|
| NFR1 | Estimator must be usable with no prior instruction, in a few simple steps | Should Have |
| NFR2 | Portfolio pages and estimates load/generate in under 3 seconds            | Could Have  |
| NFR3 | Only authenticated owner/business-partner accounts access the dashboard   | Must Have   |
| NFR4 | System remains consistently available; downtime risks losing customers    | Must Have   |
| NFR5 | System behaves consistently across the Flutter app and ASP.NET web app    | Must Have   |
| NFR6 | Design supports responding to inquiries within 24 hours                   | Should Have |

---

## System & Integration Requirements

| ID  | Requirement                                                                                 | Priority   |
|-----|---------------------------------------------------------------------------------------------|------------|
| SR1 | Flutter mobile app + ASP.NET web app, both backed by one shared Supabase instance           | Must Have  |
| SR2 | Two user roles: public/customer (view + self-service) and owner/admin (full access)         | Must Have  |
| SR3 | All portfolio, pricing, and inquiry data stored centrally in Supabase for both apps         | Must Have  |
| IR1 | Flutter app connects to Supabase Auth and Database via the client SDK                       | Should Have|
| IR2 | ASP.NET web app connects to the same Supabase backend via REST/PostgREST                    | Must Have  |
| IR3 | Inquiries from either app sync to the shared database, appearing instantly in the dashboard | Must Have  |

---

## Project Structure

 project-root/
├── mobile-app/        # Flutter customer app
├── web-app/           # ASP.NET web app (customer + owner dashboard)
├── docs/              # SRS, schema, and design documentation
├── tests/             # Test files
├── .env.example       # Example environment variables (no real secrets)
├── .gitignore
└── README.md

 

---

## Documentation

- [Software Requirements Specification](Documents/GROUP K SRS.pdf)
  

---

## License

[ MIT License ]
