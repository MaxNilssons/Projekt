# Projekt
Skolprojekt 
Inlämning projektuppgift Auktioner
Plananalysera en auktionsverksamhet och skapa en datatjänst

Om uppgiften

Ni har fått till uppgift att analysera och planera en datatjänst för en auktionsverksamhet. Datatjänsten ska bestå av en relevant databas, samt en uppsättning Views som besvarar specifika frågor, motsvarande databehov för auktionsverksamheten.


Genomförande

Tillsammans i grupp:

Skapa / upptäck / välj en specifik auktionsverksamhet, med viss komplexitet (lärare måste godkänna och kan ge råd om er idé). Ni kan själva utforma den, inspireras av, eller välja som utgångspunkt, en av idéerna nedan. Vi vill att ni skapar ett specifikt varumärke som tydligt nischar sig.

Lite enklare idéer

Auktionera ut konsulter till tidsbegränsade uppdrag.
Auktionera ut delägande i semesterbostäder.
Auktionera ut elscootertimmar ur en begränsad pott.

Lite mer komplicerade idéer

Auktionera ut scenkonstnärer och artister till evenemang (som en omvänd typ av auktioner)
Lägg bud i grupp för att kunna göra ett inköp av varuparti.
Auktionera ut lån (bostadslån, billån, osäkra lån) som en omvänd auktion: Lägg bud på ränta som är lägre än föregående bud. Auktionen kan t ex ta slut vid en hemlig tidpunkt, eller när räntan passerat en viss nivå. Brainstorma fram en bra modell för den här typen av budgiving.
Auktionera ut färskvaror till restauranger och storkök, fundera över hur budgivningen ska kunna fungera då värdet är som högst när färskvaran är som nyast, men att vissa varor kanske inte säljs inom den tiden; hur ska de då auktioneras ut när värdet sjunker?
Genomför en DDD-analys genom att undersöka auktionstjänster och verksamhetsområde (för er idé) för att upptäcka och dokumentera terminologi och funktionalitet. Planera domäner/subdomäner och contexts genom att analysera och bryta ner er idé, och tillämpa vad ni lärt er om auktionstjänster och verksamhetsområde.

Skriv berättelser om användning av tjänsten. Alltså, beskriv hur olika typer av användare gör olika saker med tjänsten.

Planera en databastruktur. Skissa både Entititer (tabeller), Relationer (kopplingar), och Modeller (kolumner/egenskaper) med namn och datatyper. Namnge dem utifrån er DDD-analys.

Individuellt

Skapa databasen - ni kan hjälpa varandra, men var och en ska skapa sin egen databas. Ni har möjlighet att individuellt skapa en databas som motsvarar skallkraven nedan, eller en mer utvecklad databas.

Lägg in exempeldata i databasen. Tänk på att exempeldatan ska stämma överens med er verksamhetsidé och era berättelser.

Skriv queries (databasfrågor) för varje berättelse. Om det är SELECT-queries, spara dem som Views. Namnge era Views så att är tydligt vad de är till för och tänk på att använda de begrepp / den terminologin ni upptäckt under er DDD-analys. Ni har möjlighet att individuellt skriva queries som motsvarar skallkraven nedan, eller mer utvecklade queries.

Tänk på: Vi använder bara Views för att läsa data. Vi skriver (insertar/updaterar/deletar) inte via Views.

Ni får alltså arbeta tillsammans för att hitta lösningar och utveckla förståelse, men ni ska skapa databas och skriva queries själva.

Ett tips: Om du har skapat en View där två (eller flera) tabeller kopplas ihop, kan du använda den som en tabell i nya queries i sin tur, och skapa nya Views av dem…

Samla alla queries under kommentarer i ett text-dokument med namnet queries.sql.

Exempel på queries.sql:

# 11. Som köpare vill jag kunna se alla auktioner som säljer en "gul boll": 

SELECT * FROM ongoing_auctions WHERE name = 'gul boll';

# 12. Som säljare vill jag kunna se alla mina avslutade auktioner:

SELECT * FROM ended_auctions WHERE seller = 'Ben';

Skallkrav

(dessa måste mötas)

Utöver säljare och köpare i auktionerna, behöver också datatjänst för admininstratörer eller motsvarande hanteras.
Tjänsten måste ge tillräcklig information om varje auktionstyp och auktionsobjekt så att köpare tydligt kan förstå vad de budar på.
Varje auktionsobjekt måste kunna ha flera bilder eller filer. (Bilder och filer kan med fördel sparas som länkar i typen text).
Användare måste kunna registrera sig och logga in.
Användare måste kunna se listor (mer kortfattad info) såväl som enskilda auktioner (med detaljerad info)
Listor måste kunna ordnas baserat på tid (nya auktioner / auktioner som snart går ut)
Listor måste kunna filtreras (pågående, avslutade)
Användare måste kunna se budhistorik per auktion, såväl som aktuellt bud
Användare måste kunna se egna bud och egna auktioner
Användare måste kunna se vem som vunnit en auktion
Administratörer måste kunna se användare som listor och detaljerat

Tips på ytterligare funktionalitet

Utgångspris på auktionsobjekt.
Dolt reservationspris på auktionsobjekt. (Om bud ej uppnått reservationspris när auktionen avslutas så säljs objektet inte).
Listor organiserade på status (pågående, avslutade, sålda, ej sålda).
Söka på auktioner i ett sökfält.
Söka på auktioner inom en kategori.
Ge/se betyg vid köp/försäljning.
Skicka meddelande mellan säljare och budgivare/köpare.
Adminstratörer måste kunna stoppa auktioner och användare
Tidsplanerade auktioner (senarelagd starttid)

Inlämning


Vad ska ni leverera?

Era berättelser om hur man använder era auktioner
DDD-planering
E/R modell på datastrukturer
Databas som täcker era berättelser (minimum skallkrav eller mostvarande)
SQL-queries som besvarar berättelser (minimum skallkrav eller mostvarande)
Uppgiften lämnas in individuellt, på learnpoint, enligt listan ovan.
Lägg filerna i en mapp med ditt förnamn och efternamn. Packa filerna i ett arkiv (zip, tar, etc), och ladda upp.


Bedömning

Bedömningen görs utifrån kursplanen.

För ett godkänt betyg ska ovanstående moment genomföras på ett grundläggande, men heltäckande sätt (du ska vara närvarande, aktiv, delaktig och produktiv i planeringsarbetet), du ska på egen hand skapa databas och queries motsvarande skallkraven ovan.

För ett väl godkänt betyg ska arbetet ske på ett fördjupat sätt, vilket kan ske genom ett tydligt kommunikativt / proaktivt / analytiskt arbetssätt i gruppmomenten, samt genom att i din egen databas och med dina egna queries, implementera funktionalitet på ett heltäckande och fördjupat sätt, vilket kan ske genom tydlighet och kvalitet i genomförandet och/eller genom att ha tillämpat mer avancerade/komplexa lösningar.
