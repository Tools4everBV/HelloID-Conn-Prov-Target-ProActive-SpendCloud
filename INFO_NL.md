De Spend Cloud Target Connector koppelt Spend Cloud via de Identity & Access Management (IAM)-oplossing HelloID van Tools4ever als doelsysteem aan je bronsystemen. Zo automatiseert de connector het beheer van zowel accounts als toegangsrechten in Spend Cloud, heb je naar dit proces geen omkijken en voorkom je menselijke fouten. In dit artikel lees je meer over de Spend Cloud Target Connector, de mogelijkheden die deze connector biedt en de voordelen. 

## Wat is Spend Cloud

Spend Cloud is software ontwikkeld door Visma | ProActive. Met behulp van de software beheer je het volledige traject van inkoop tot betaling binnen jouw organisatie. Je kunt met de oplossing ook kleinere bedrijfsuitgaven van medewerkers beheren, waarvoor zowel declaratiesoftware als slimme betaalpassen beschikbaar zijn. Spend Cloud centraliseert en automatiseert zo het beheer van uitgaven binnen je organisatie.

## Waarom is Spend Cloud koppeling handig?

Om met Spend Cloud aan de slag te gaan moet voor een medewerker een persoon worden aangemaakt in Spend Cloud. Dankzij de koppeling tussen je bronsysteem en Spend Cloud automatiseert HelloID dit proces. Zo weet je zeker dat een nieuwe medewerker op de eerste werkdag direct met Spend Cloud aan de slag kan en over de juiste autorisaties beschikt. Ook zorgt HelloID dat gebruikers de juiste rollen toegekend krijgen, en trekt deze rol weer in indien bijvoorbeeld het dienstverband afloopt. Prettig is dat HelloID het volledige proces in een logbestand vastlegt, waardoor je altijd aan de geldende compliance-eisen voldoet. 
Met behulp van de Spend Cloud-connector kan je Spend Cloud met diverse bronsystemen integreren. Denk daarbij aan:

*	Visma Raet
*	Active Directory/Entra ID
*	AFAS
*	ADP Workforce
*	SAP SuccessFactors

Verderop in dit artikel lees je meer over deze integraties.

## Hoe HelloID integreert met Spend Cloud

Spend Cloud koppelt als doelsysteem met HelloID. De Spend Cloud Target Connector ondersteunt zowel personen als bijbehorende rollen. De koppeling vindt plaats via een SQLite-database, waarin HelloID alle gebeurtenissen die onderdeel uitmaken van de levenscyclus van een account vastlegt. De informatie uit deze database exporteert HelloID dagelijks naar een CSV-bestand, die Spend Cloud op zijn beurt periodiek importeert. Door het gebruik van de SQLite-database en CSV-export is een on-premises HelloID agent vereist. 

**Personen in Spend Cloud aanmaken en bijwerken**

Dankzij de koppeling maakt HelloID voor nieuwe medewerkers die in dienst treden automatisch een persoon aan in Spend Cloud. Wijzigen de gegevens van een medewerker? Dan wijzigt HelloID deze gegevens ook automatisch in de gerelateerde persoon in Spend Cloud. Op basis van de brondata werkt de IAM-oplossing dit daarnaast bij in de lifecycle in de SQLite-database. Dagelijks vindt een full-dump van de database plaats, waarbij HelloID de gegevens via een CSV-bestand naar Spend Cloud doorzet. 

**Spend Cloud-rollen toekennen of ontnemen**

HelloID bepaalt aan de hand van de brondata de rollen van een persoon. Elk actief contract van een medewerker resulteert daarbij in een aparte rol. De IAM-oplossing kan rollen zowel toekennen als ontnemen. 
De connector werkt via verschillende subacties. Zo wordt in de accountlifecycle van HelloID een SQLite-database gevuld, waarna HelloID deze in een geautomatiseerde taak periodiek samenvoegt en als CSV-bestand exporteert. Dit bestand leest Spend Cloud vervolgens weer in. Dit betekent dat ook aan de kant van Spend Cloud configuratie nodig is. Zo moet Spend Cloud over een import-job beschikken voor het importeren van het CSV-bestand. Ook zien we vaak de inzet van een SFTP-taak voor het automatisch transporteren van het CSV-bestand naar Spend Cloud. Spend Cloud correleert vervolgens aan de hand van het personeelsnummer een bestaand Spend Cloud-persoon met de gegevens uit het CSV-bestand. 
Let op: het gaat om een complexe connector. Zo moet niet alleen HelloID op de juiste manier zijn ingesteld, maar is het ook in Spend Cloud de correcte configuratie nodig. Neem daarom altijd contact met ons op voor de implementatie van de Spend Cloud connector, waarbij wij je graag begeleiden en ondersteunen.

## Gegevensuitwisseling op maat 

Het is mogelijk de informatie die HelloID met Spend Cloud uitwisselt af te stemmen op de specifieke behoeften van jouw organisatie. In een persoon in Spend Cloud zijn een aantal standaardvelden aanwezig: external ID, email, achternaam, voornaam, tussenvoegsel, gebruikersnaam en geslacht. De rollen bevatten daarnaast de gebruikersnaam, organisatorische eenheid en functieprofielcode. Je bepaalt zelf welke van deze velden je wilt gebruiken.

## HelloID voor Spend Cloud helpt je met

* **Versnelde accountaanmaak:** HelloID merkt wijzigingen in je bronsysteem automatisch op, en maakt op basis hiervan een persoon aan in Spend Cloud en kent de juiste autorisaties toe. Zo kan een nieuwe medewerker direct op de eerste werkdag met Spend Cloud aan de slag.

* **Foutloos accountbeheer:** Prettig aan de koppeling tussen je bronsysteem en Spend Cloud is dat HelloID zorgt voor een foutloos proces. Zo volgt de IAM-oplossing automatisch alle vastgelegde procedures en legt daarnaast alle gebruikers- en autorisatie-gerelateerde activiteiten vast in een logbestand. Je weet hierdoor zeker dat je altijd consequent te werk gaat, nooit een stap overslaat en altijd aan de geldende compliance-eisen voldoet. 

* **Verbeterd serviceniveau en sterkere beveiliging:** Doordat personen en autorisaties op het juiste moment beschikbaar zijn beschikken werknemers altijd over de juiste middelen en kunnen zij optimaal hun werk doen. Je verhoogt met de koppeling dan ook je serviceniveau en daarmee de gebruikerstevredenheid. Tegelijkertijd stel je zeker dat personen en autorisaties nooit ongemerkt te lang toegekend blijven. Belangrijk, want zo geef je onverhoopte aanvallers geen onnodige kansen doordat overbodige autorisaties toegekend blijven en weet je zeker dat ongeautoriseerde gebruikers nooit onbedoeld toegang houden tot Spend Cloud. De koppeling versterkt dan ook je beveiliging. 

## Spend Cloud via HelloID koppelen met systemen

Met behulp van HelloID kan je diverse bronsystemen aan Spend Cloud koppelen. Enkele voorbeelden van veelvoorkomende koppelingen zijn:
Visma | Raet - Spend Cloud koppeling: De koppeling tussen de oplossingen van Visma | Raet en Spend Cloud verbetert de samenwerking tussen HR en IT. Zo kan HelloID bij indiensttreding van een nieuwe medewerker automatisch een persoon aanmaken in Spend Cloud en aan deze persoon de juiste rollen koppelen, en indien nodig gegevens bijwerken.
Microsoft Active Directory/Entra ID - Spend Cloud koppeling: Dankzij de Microsoft Active Directory/Entra ID - Spend Cloud koppeling kan HelloID mutaties in Active Directory of Entra ID automatisch verwerken in Spend Cloud. Denk daarbij aan het aanmaken van een nieuw persoon voor nieuwe gebruikers, of juist het bijwerken van personen op basis van wijzigingen in Active Directory of Entra ID. 
HelloID ondersteunt ruim 200 verschillende connectoren, waarmee je de IAM-oplossing van Tools4ever aan nagenoeg alle populaire bron- en doelsystemen kunt koppelen. Wil je meer weten over de mogelijkheden? Bekijk dan het volledige overzicht van connectoren op <a href="https://www.tools4ever.nl/connectoren/">onze website</a>. 
