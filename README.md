# EcoChallenge_RS2

Seminarski rad iz predmeta **Razvoj softvera 2** na Fakultetu informacijskih tehnologija u Mostaru

## 📖 O projektu

EcoChallenge je platforma koja omogućava korisnicima da učestvuju u ekološkim izazovima i doprinose očuvanju životne sredine. Korisnici mogu da se prijave na različite izazove, šalju dokaze o ispunjenim zadacima, a administratori mogu da upravljaju zahtevima i odobravaju ili odbijaju poslate dokaze. Aplikacija takođe omogućava donacije kroz Stripe integraciju.

## 🚀 Upute za pokretanje

### Backend setup

1. Otvoriti `EcoChallenge_RS2` repozitorij
2. Otvoriti folder `EcoChallengeBackend` unutar pomenutog repozitorija
3. Locirati `env.zip` arhivu u `EcoChallengeBackend` folderu
4. Iz te arhive uraditi extract `.env` file-a u isti folder (`EcoChallenge_RS2/EcoChallengeBackend`) koristeći šifru: **fit**
5. Unutar `EcoChallengeBackend` foldera, locirati `EcoChallenge.WebAPI` folder
6. U `EcoChallenge.WebAPI` folderu locirati drugi `env.zip`
7. Extract drugi `env.zip` u `EcoChallenge.WebAPI` folder koristeći šifru: **fit**
8. Vratiti se u `EcoChallengeBackend` folder, otvoriti terminal i pokrenuti komandu:
   ```bash
   docker compose up --build
   ```
   Te sačekati da se sve uspešno build-a

### Frontend aplikacije

1. **Vratiti se u EcoChallenge_RS2 folder i locirati `fit-build-25-08-24.zip` arhivu**
2. **Iz te arhive uraditi extract, gdje biste trebali dobiti dva foldera: `Release` i `flutter-apk`**
3. **Otvoriti `Release` folder i iz njega otvoriti `ecochallenge_desktop.exe`**
4. **Otvoriti `flutter-apk` folder**
5. **File `app-release.apk` prenijeti na emulator i sačekati da se instalira** *(Deinstalirati aplikaciju sa emulatora ukoliko je prije bila instalirana!)*
6. **Nakon instaliranja obe aplikacije, na iste se možete prijaviti koristeći kredencijale ispod**

## 🔐 Kredencijali za prijavu

### Administrator
- **Korisničko ime:** `dekstop`
- **Lozinka:** `test`

### Korisnik
- **Korisničko ime:** `mobile`
- **Lozinka:** `test`

> **Napomena:** Administrator se može prijaviti i kao obični korisnik

## 💳 Stripe kredencijali za donacije

Donacije su omogućene u mobilnoj aplikaciji kroz Stripe integraciju.  
Za testiranje donacija koristi se Stripe test okruženje sa sledećim kartičnim podacima:

### Test kartica
- **Broj kartice:** `4242 4242 4242 4242`
- **Datum isteka:** bilo koji datum u budućnosti (npr. `12/34`)
- **CVC:** bilo koji trocifreni broj (npr. `123`)
- **ZIP / Poštanski broj:** bilo koji važeći (npr. `10000`)


## 🔧 Mikroservis funkcionalnosti

Aplikacija koristi **RabbitMQ** mikroservis za automatsko slanje email obaveštenja u sledećim slučajevima:

- **Reset lozinke** - šalje se reset kod
- **Odobravanje/odbijanje zahteva** - obaveštenje o statusu zahteva
- **Odobravanje/odbijanje dokaza (proof)** - obaveštenje o statusu poslatог dokaza

## 🛠️ Tehnologije

- **Backend:** ASP.NET Core
- **Frontend:** Flutter (desktop i mobilna aplikacija)
- **Baza podataka:** SQL Server
- **Message Broker:** RabbitMQ
- **Plaćanje:** Stripe
- **Containerization:** Docker

---

*Developed as part of Software Development 2 course at Faculty of Information Technology, Mostar*