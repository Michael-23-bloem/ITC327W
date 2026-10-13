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
- [Phase 2 Links](#Phase-2-links)
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
 | Makara K | MAKARA KARABO |  |
 

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

- [Software Requirements Specification](Documents/GROUP-K-SRS.pdf)
  

---


## Phase 2 Links

| Name | Links | Documents |
|------|-------|-----------|
| System Architecture Design | [System Architecture Design](https://lucid.app/lucidchart/44240553-e1a3-49a9-8e37-b2206e969dba/edit?viewport_loc=-1322%2C-1177%2C2712%2C3659%2C0_0&invitationId=inv_c65493ad-0815-4808-a067-4fa283bc9b11) | N/A |
| Flutter Mobile App Wireframes | [Flutter Mobile App Wireframes](https://www.figma.com/design/jVTwOe6OxguXIdolAzv0w7/Untitled?node-id=0-1&p=f&t=FKmfgJu8kIgzpnUa-0) | [Mobile App WireFrames](Documents)|
| ERD | [AkeaEvents ERD](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=ERD.drawio&dark=0#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%22gWOokk-qHZj6GwECZU_W%22%3E7V1rk9q4Ev01fITyi9fHMI%2Bd7J08dibZ7H6acrAGfGNsrjHzyK%2B%2FMrYMBtnTMJYlm65KVQZhG1Af9VG3jlod82Lx8kdoL%2BefAod4HUNzXjrmZccw9KE%2Bov%2FFLa9pi671k5ZZ6DpJm7ZtuHd%2Fk%2FRC1rp2HbJK25KmKAi8yF3mG6eB75NplGuzwzB4zl%2F2GHhOrmFpz0jua8QN91PbIweX%2FXCdaJ60jvo7V98QdzaPst%2BXvrOw2cVpw2puO8HzTpN51TEvwiCIkr8WLxfEi3sv3y%2FXBe9mXywkfgS5Yf63sZ6MA9e%2F%2BfL9h9%2B%2Fvrj%2F%2FrFr9A8fkz55Fb2yTqBffRn%2FGdk%2F46bJKrLDKLWVqdEG2vuR7fokpA365rXn2cuVu7n8cnPF3PWcW%2Fs1WEfsQezV5NF9Ic5dYqr4bmq1W%2FqwVXrrI334ffpl4rdtz5359O8p%2FcbxJ05CsqLf5dZeRekV82jhbb%2FJeuGzxyVPX%2FsOcdKHe%2FZP4k3s6a%2FZpv0i8IL4R%2FiBH%2F%2FQpCeebG%2Bd9sT3Ff3EpJGEEXnZ6bG01%2F8gwYJE4Su9ZL4DDEM3kvuetyjSRyk00sd09cE4aUhHS3ecDh87RfEse3j2eXcU9bY%2Fo72T%2F0BTO%2Fi8cX%2Fv47Tcp421%2FIfZHu1e347IJO6Z1S646B87v3TbtIHcMfAbHMKvFKdFoLyLR9ZkHoTu7xiKXmrdXaBuXj%2B7C8%2F26ZC1nb2mSbDxURvAuZ63B4RDQDthsPxmhzMSpQ1L%2BpWjTdf1J%2FQf7cwLrdfv9Ol3vaCv9e1r%2Bi%2B%2BPIwuAn8VhXTgxM8gFL%2FPJMbwJAqWDJ7kkT0%2FTG0b%2F%2F0ziKJgUQWgTwIzB1sZll%2Fzl%2FCQm0PR0ZAZQiEzKIQMvTdybW87dDYeLOYPe2tgDgq4dslssW%2Bkfb8V0F5%2B9DYUMHcdh1AfNnmeuxG5X9rT%2BKJnyqF57%2FUu0379T1XGLTPm8W5o%2F2l1%2BJlRU0DDyC25drKi0HD92W1y52APVX0JqIoZ0LcXpDLH0c%2BTYLVYy54uBmzE%2BTCZOX%2F9Dn75n5e%2B9eRdf7vpgh0UclqVnFY5hQ0qoDAuQDjOqAxISGBnRWBcKIwbAhnl6etqYbseclchJ3GAhuR1BHlpqgZk%2B9F9ZQEZ%2B%2By3ITOW7JyI47LnyaCzcyQzPmI4uUs1EfMmndWNoWs3XEUPGH%2BVwstADmsnh%2BmGMBIzgZhh4EISO3cSs5qCGOVILF6pQw4rRxc4YY0cViWHVU9Z%2B%2BCpjrKgoTrD0nlRFjKUBQ3MpQNEOYa6pIZ5CB4ffrohNSCyVEG2WYciDFlKcZYaVcBSfIhwcj2lWEKWai1L8e3OydaoCRDlWOou8DCEKp7%2BcDxPq6St75vhkGkQfg0DZz2NTsJQptAuEbSO%2BkfoWd8VDFnQnK%2F1BgTOdSaiTGKwNiGpBU35MmyhDuesZit8LECzvtJBo7wSJyWfB9rfOIcpQhFnew7SWhuWMqsQl%2FKRAN1SYxXnZFoccONK5iEQoIJ16YhRLgL%2FjIuYZXiBLmIiezWMvYSJSS3ooqYle80K2UsN9truxFcdMcqx1yVZTUN3GbmBjyRWiC%2BoWBlJrGEkJk5N2odmo%2FvFmEEWOysWgyajpSNGORb7GrpTDMI2j79xBqOr7nP3njzdP%2Fyp3ZrrGXg3OtKX4hKdKoSkXIRwovQyJJ0XV50VNXHNzonIlYSHcsR0Qc0yC9IBeu7cxJ%2FMgFdTkZzUJqcq9KN8iEBXQBmWkJ5aS098u0PXO6UDRDmC%2BriwZ%2BRhHWI9lELQ6LxtnqgizWJvymKPgecGJyEIJiE1ckxjDERJSHUTSjUZKHA6kvd4yuQDaxOR6iaUfjJ4oYwUJy26CU3LyYeN%2BkJSRkIoJe0Up2egy5hIborH2lUoR7kI4SxaliHpvALtnRJcZ0ljXCRwFi2VRIxykTfufYDMkaDyUaSspklvhOlHdXBVHF161RPU3igSjIEL5cjHjHJMhjsgyqGFYVdbOUycfFQHVzPQSxbGkcTOi8SgClL5mFGOxHAjBCDYh2p1kMkUTyCKU5LyDhMtgdJ5kdZZcRTX7JylUiXhoRw%2FoZL07ekP0lNrAy1h4lIdXF8nw9d5cRYGWhwkgBU%2F0jGjHJGh4hRwOBZvmlROWZ2jFaebFkmK0wNUfAkdetMpiDCsEvpgjxkaOToRV4TU1KGqrszIOAnJezAuPkRNLISpQk0dunSdQabJqtADg6HSc8fA4GNapEOhDqUn3%2FmjEKYMGGyhCWnlVFrR6qQVYaU9TQO6mpxBpsHh6oG9zlN4WWBfozFIEBGEHmDj%2ByrucpSilAEBfMQpsogCLCLuvHYDfnKp2T4WQQ7JrAtNfsvHQS0csjn0z12t1gSDkWIsDDDHVR2NNEiUaA7AOa2B7ERGZbSBLGEOwPkr6WavjyWi4OGSeO7TicsW58EU4MrJyBQymELcweTg8sem9Gq2yBQVjndwgkG62Wthim8BdVUPSyxPXD6%2FQJZQmSWEae%2FMAZglBrLdBbJEheMdzBLSzV4LS%2FxN%2FDXyQyEKLA0XvxXmh6yEY%2FUngWngg3cYRJAfms8PlgadFsg3ey38cB%2FZ0XqFBFHo9g3eAQXlTNBpgV76Y0QWJ6Eic%2BElmuk%2B0yKK10ybYH5nhkZ%2Bz7ullmimTXAiwJTt%2BFEzLdalm%2BDUgHQoyNRMUwZA4XQpOsC5BuQWBSRv4oTTvFMcyiHT%2FFgShdNc%2B4JFb9KRUEt4idtv3oYMdMM3sogKLCJOOA0%2BtCGDDLJIS1kErIWUjoRaWATrmUNAA1ZSIo8owCMCpdTggtMZZtpEJEgjGQ7gKU%2FZOKiFRv5a237kRljnrgQy4NQokkirRNXg%2Bs4ZRNrEGRh87NgXnMyUjoR6gg97%2BisuK4fBRxkU0oiVODOy0zV82USwDqek7GkcqV38YLbORf30PJgFvu1dbVv3Kgdur7kNNpiKbftfEkWvKfnY6yjIW568uNE%2FO3%2F%2FGz%2Bq109fXb4w9xO%2FYMREf1v4%2Bs%2FmQk3rs4bkTm00ZA3bmzevcnd%2FJaFL%2B3%2BjDEkanQ9huMHs1R0dFd%2BCT7b%2Fmrxx7Xo5It1euLB958tmCG3e2L8w%2FdF6%2BgG7L5OujhhxvkH4h2APiWdH7lPe7AIIalwhwjiTlwYATB%2FkAaab%2BrsB9puEAQxhyZVFGAuDX%2BRH6oT0Q5AdgBCKusQVSEMd86XV%2BDXOmk8DYKfpHRF%2BDYa3FJmCnJpVQOB1oYsz1TrUFtLZRpS3KG8KkwzBvekUZ4Z1oA2M5zPu1PY%2BpG8s6ESJA7zDeZFnV7fzbJCfEbFeYPpAtuVTgAl4h0o0ygR0Wqr9rCynsWcIXRvlLaFr4kYDqDKxoqb46E%2B9tSNqPGTbmjIziLMCZxWyMVa4I49xzQSNUqAYQ1gMpFtDiHNNnFXAxljiItG7CzLDcN8tMTcuwAog%2Fb%2BiVhA%2BHoajft4QI2GOaQRyTG3aiLEZQ9Poyv%2Ff2g1PY3jIboz9CvaGOHIZgYUNo%2BJqP2e9vNCS3RgjsFhhJPtMZNyNITZ1zAR1DYCClN0YqfvH9YdSEIEXrZBYFBA%2FiduKMQYL8Meyj8%2FCdWyxLgGsq5eOBKxhrwiLgBX4yCIKsIi4rRhjcJw6ll2VFllErEsAB6rSkYAb%2BpRgEUsDSymRRdpUwt7SoEFoBpHmswZShKVBQ075Zq%2BFIj6R1cqeYZxRggNwaIoM0aZdFpYGDTAziCBDtIEhoOGkfLPXwhB3ZLWkLgApohgITFZUjfCYE5vWITxmIuI9AXG2T6JQPnwgUP8C1QuftgfiFIl00qNvK9j7x2iMUwBrPW3ITsUrBDH96fbrzgUpEW8%2F7GvcsH2opWm9vGyKbbS5ht9BW8bl91hWBfekhz1tR1XyY%2Fm3m2O9xwQF7DPNUY8lHln%2FJMMkvVfEkOXE%2FY1RionWr%2BbNOxQ2w9KbLKm%2Fi11CzEjC9Hr7hjAGoirvWqzbq9mwJXVHoHYELWx3zryb9N6%2FK6uanX%2FJ%2BuhxDNbVqP9ls9nKKKxLKatn5BDcTc%2BFKuIWzi2WYfSGpTeNzJ713lveIlfdHPaG77zDGOXuyPNkZcTG5r%2F5cCOephwO6HJfsDd8b%2B2fxMsPuSN8aSyl3Ql98nmIONWwUWOleDd4%2FnYS%2B9qLkFCn63SO2kVTPnkba2Z%2BOtItO8eiCLf5rAQ7Vps9IXh8XBExExk2cWokh95TJyeIPLvZNZnavcTBvY89YVsD26R2T%2BssnGS7Uw4dMFhFeAHGA68I9IulR2ed322HzN3ibWkshwzK3FuaA%2Bbtq1QUClJk7lhmBwIi8EICEosCAkVhMneLtyu1HDLNX0jEEp%2BH1h2AQ3DpOKhlZfEzCtxL4QI%2B9BL5QwH%2BECZwt8CnY1vSj0lG%2FhDpEKBaZfk4qIU%2FLslqGrrLyA0qK13SRhoBC52RRhSgEYGS9wE40zmQvckSeUSkRwAnOqXjoKYTa9zqiiM2mkGI82Eyc%2F76HfzyPy9968m7%2FnbTxTCk7fp3rtk5QUcZPJpPFWfFDFxTcuILJU1eCyt8XMQrHOvQQ2Yonh%2Bk62TVCN85R1SoXnH7SLH8MVWzASW49%2Bu4V1VoO1nUBAqpKtMLDofDXr5y7qBcxXd4gzGsQ2I3LAG58pKremu9msI0V6wOZiONIL7U654dDKuCmrv8uQBoI0WbtG9xbaaHD%2BtoTu%2Bmxj85%2FZhlekp0cF19MK7LkJw8YanFMcxruAyOb11OkrAULyiCa2cwqHOyhGoCQYoELk8AqIQrAwhHTYnMouoCVBU6OL51OXrIUrw0P6V47mX6%2BOblyCHVxAGWelWCP3hbF5E%2FVOWPKnRwfBhw0m6leGkTfyB7MONy8n5qoqCmA69Xq%2BcgxOijGAdpHHvsGhWUYeosbZEtS%2F3LPA3kUNi%2BZnZ2lqn0nqa%2FXeAieuNQ2O0Z1icedZ105O5iFL%2FHNT6OKz%2F1lQ%2BeJh%2BwuJOiEFUrqDvY26eti0pPG00%2BYPHGfhJmgWHeArpuvd8C%2Bo0zGF11n7v35On%2B4U%2Ft1lzPsrIYlSz26%2BZh1lB9TxoLIvc8aeZaj%2FGkR9QFgpYa2q2fYnYq0wL0jyknVD3kcKW9aNyPrfxhnpUstfONwJlxN8YIwlfax%2F18JalT%2FC99GQZBtDvvpd01%2FxQ4ccWlq%2F8D%3C%2Fdiagram%3E%3C%2Fmxfile%3E)| [ERD](Documents) |
| ASP.NET Sequence Diagram | [ ASP.NET Sequence Diagram](https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=ASP.NET%20Sequence%20Diagram%20for%20(Request%20Quotation)%20Use%20Case.drawio&dark=0#R%3Cmxfile%3E%3Cdiagram%20name%3D%22Page-1%22%20id%3D%22RNcW7AbYlC4a8QO17n5t%22%3E7V3rl6I2G%2F9rPKf9oCeE%2B0cvs21Pd7fTdXrZTz2MROVdJBZwLv3r3wSIQIKCSBidddqdkYCPmPyea57nYaBONy8%2Fhc52%2FQm7yB9A4L4M1NkAQh0YOvlDR17TEQgtmI6sQs9Nx0A%2BMPf%2BQ%2BmgwkZ3nouibCwdijH2Y29bHlzgIECLuDTmhCF%2BLl%2B2xL5bGtg6K1S6DTowXzg%2BEi77y3PjdTpq6YWrf0beas0%2BWQHZmY3DLs4GorXj4ufCkHo3UKchxnH6avMyRT6dvfK8fDhwdn9jIQriJm%2F4FsbA%2FqA9uJ9h9PDn%2FNfwYf0yrKCSDUXxK5uDGL2Qc5N1vPHJgEJePq%2B9GM23zoJe8UyWnoxFcYi%2FoSn2cUgGAxyQc5Ol5%2FvckON7q4AcLsgnIjI%2BeUJh7JEZH2cnNp7r0o%2BehHgXuIjePqCkcBBn%2B…) | [ASP.NET Sequence Diagram](Documents) |
## License

[ MIT License ]
