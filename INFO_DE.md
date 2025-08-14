Der Spend Cloud Target Connector verbindet Spend Cloud über die Identity & Access Management (IAM)-Lösung HelloID von Tools4ever als Zielsystem mit Ihren Quellsystemen. Auf diese Weise automatisiert der Connector die Verwaltung von sowohl Konten als auch Zugriffsrechten in Spend Cloud, sodass Sie sich nicht mehr um diesen Prozess kümmern müssen und menschliche Fehler vermieden werden. In diesem Artikel erfahren Sie mehr über den Spend Cloud Target Connector, die Möglichkeiten, die dieser Connector bietet, und die Vorteile.

## Was ist Spend Cloud

Spend Cloud ist eine Software, die von Visma | ProActive entwickelt wurde. Mit Hilfe der Software verwalten Sie den gesamten Prozess von Einkauf bis Zahlung innerhalb Ihrer Organisation. Sie können mit der Lösung auch kleinere Unternehmensausgaben von Mitarbeitern verwalten, wofür sowohl Abrechnungssoftware als auch intelligente Zahlungskarten zur Verfügung stehen. Spend Cloud zentralisiert und automatisiert somit das Ausgabenmanagement innerhalb Ihrer Organisation.

## Warum ist die Spend Cloud Verknüpfung nützlich?

Um mit Spend Cloud zu starten, muss für einen Mitarbeiter eine Person in Spend Cloud erstellt werden. Dank der Verbindung zwischen Ihrem Quellsystem und Spend Cloud automatisiert HelloID diesen Prozess. So können Sie sicher sein, dass ein neuer Mitarbeiter am ersten Arbeitstag direkt mit Spend Cloud arbeiten kann und über die richtigen Autorisierungen verfügt. HelloID sorgt auch dafür, dass Benutzer die richtigen Rollen zugewiesen bekommen, und zieht diese Rolle wieder zurück, wenn beispielsweise das Beschäftigungsverhältnis endet. Angenehm ist, dass HelloID den gesamten Prozess in einer Protokolldatei aufzeichnet, wodurch Sie immer die geltenden Compliance-Anforderungen erfüllen. Mit Hilfe des Spend Cloud-Connectors können Sie Spend Cloud mit verschiedenen Quellsystemen integrieren. Denken Sie an:

* Visma Raet
* Active Directory/Entra ID
* AFAS
* ADP Workforce
* SAP SuccessFactors

Weiter unten in diesem Artikel erfahren Sie mehr über diese Integrationen.

## Wie HelloID mit Spend Cloud integriert

Spend Cloud wird als Zielsystem mit HelloID gekoppelt. Der Spend Cloud Target Connector unterstützt sowohl Personen als auch die zugehörigen Rollen. Die Verbindung erfolgt über eine SQLite-Datenbank, in der HelloID alle Ereignisse, die Teil des Lebenszyklus eines Kontos sind, erfasst. Die Informationen aus dieser Datenbank exportiert HelloID täglich in eine CSV-Datei, die Spend Cloud wiederum periodisch importiert. Durch die Verwendung der SQLite-Datenbank und des CSV-Exports ist ein On-Premises HelloID Agent erforderlich.

**Personen in Spend Cloud erstellen und aktualisieren**

Dank der Verbindung erstellt HelloID für neue Mitarbeiter, die in das Unternehmen eintreten, automatisch eine Person in Spend Cloud. Ändern sich die Daten eines Mitarbeiters? Dann ändert HelloID diese Daten auch automatisch in der zugehörigen Person in Spend Cloud. Auf Basis der Quelldaten aktualisiert die IAM-Lösung dies darüber hinaus im Lebenszyklus in der SQLite-Datenbank. Täglich erfolgt ein vollständiger Dump der Datenbank, wobei HelloID die Daten über eine CSV-Datei an Spend Cloud weiterleitet.

**Spent Cloud-Rollen zuweisen**

HelloID bestimmt anhand der Quelldaten die Rollen einer Person. Jedes aktive Arbeitsverhältnis eines Mitarbeiters resultiert dabei in einer separaten Rolle. Die IAM-Lösung kann Rollen sowohl zuweisen. Der Connector arbeitet über verschiedene Unteraktionen. So wird in der Kontolebenszyklus von HelloID eine SQLite-Datenbank gefüllt, woraufhin HelloID diese in einer automatisierten Aufgabe periodisch zusammenführt und als CSV-Datei exportiert. Diese Datei wird anschließend wieder von Spend Cloud importiert. Dies bedeutet, dass auch auf der Seite von Spend Cloud eine Konfiguration erforderlich ist. So muss Spend Cloud über einen Import-Job für den Import der CSV-Datei verfügen. Häufig sehen wir auch den Einsatz einer SFTP-Aufgabe für den automatischen Transport der CSV-Datei zu Spend Cloud. Spend Cloud korreliert dann anhand der Personalnummer eine bestehende Spend Cloud-Person mit den Daten aus der CSV-Datei. Beachten Sie: Es handelt sich um einen komplexen Connector. So muss nicht nur HelloID richtig eingerichtet sein, sondern auch in Spend Cloud ist die korrekte Konfiguration erforderlich. Nehmen Sie daher immer Kontakt mit uns auf für die Implementierung des Spend Cloud-Connectors, bei der wir Sie gerne begleiten und unterstützen.

## Maßgeschneiderter Datenaustausch 

Es ist möglich, die Informationen, die HelloID mit Spend Cloud austauscht, auf die spezifischen Bedürfnisse Ihrer Organisation abzustimmen. In einer Person in Spend Cloud sind einige Standardfelder vorhanden: externe ID, E-Mail, Nachname, Vorname, Zwischenname, Benutzername und Geschlecht. Die Rollen enthalten zudem den Benutzernamen, die organisatorische Einheit und die Jobprofilcode. Sie bestimmen selbst, welche dieser Felder Sie verwenden möchten.

## HelloID für Spend Cloud hilft Ihnen bei

* **Beschleunigter Kontenerstellung:** HelloID erkennt Änderungen in Ihrem Quellsystem automatisch und erstellt basierend darauf eine Person in Spend Cloud und weist die richtigen Autorisierungen zu. So kann ein neuer Mitarbeiter direkt am ersten Arbeitstag mit Spend Cloud arbeiten.

* **Fehlerfreies Kontenmanagement:** Es ist vorteilhaft, dass die Verbindung zwischen Ihrem Quellsystem und Spend Cloud dafür sorgt, dass HelloID einen fehlerfreien Prozess gewährleistet. So folgt die IAM-Lösung automatisch allen festgelegten Verfahren und zeichnet zudem alle benutzer- und autorisierungsbezogenen Aktivitäten in einer Protokolldatei auf. Dadurch können Sie sicher sein, dass Sie immer konsequent arbeiten, keinen Schritt auslassen und stets die geltenden Compliance-Anforderungen erfüllen.

* **Verbessertem Servicelevel und stärkerer Sicherheit:** Da Personen und Autorisierungen zum richtigen Zeitpunkt verfügbar sind, haben Mitarbeiter immer die richtigen Werkzeuge und können optimal arbeiten. Die Verbindung erhöht somit Ihr Servicelevel und die Benutzerzufriedenheit. Gleichzeitig stellen Sie sicher, dass Personen und Autorisierungen nie unbemerkt zu lange zugewiesen bleiben. Wichtig, denn so geben Sie ungewollten Angreifern keine unnötigen Möglichkeiten, indem überflüssige Autorisierungen verbleiben, und gewährleisten, dass unberechtigte Benutzer nie unabsichtlich Zugang zu Spend Cloud behalten. Die Verbindung stärkt somit Ihre Sicherheit.

## Spend Cloud über HelloID mit Systemen verbinden

Mit Hilfe von HelloID können Sie verschiedene Quellsysteme an Spend Cloud koppeln. Einige Beispiele für häufige Verknüpfungen sind:

Visma | Raet - Spend Cloud-Verknüpfung: Die Verbindung zwischen den Lösungen von Visma | Raet und Spend Cloud verbessert die Zusammenarbeit zwischen HR und IT. So kann HelloID bei der Anstellung eines neuen Mitarbeiters automatisch eine Person in Spend Cloud erstellen und dieser Person die richtigen Rollen zuweisen sowie gegebenenfalls Daten aktualisieren.

Microsoft Active Directory/Entra ID - Spend Cloud-Verknüpfung: Dank der Microsoft Active Directory/Entra ID - Spend Cloud-Verknüpfung kann HelloID Änderungen in Active Directory oder Entra ID automatisch in Spend Cloud verarbeiten. Denken Sie dabei an die Erstellung einer neuen Person für neue Benutzer oder das Aktualisieren von Personen basierend auf Änderungen in Active Directory oder Entra ID.

HelloID unterstützt mehr als 200 verschiedene Connectoren, mit denen Sie die IAM-Lösung von Tools4ever an nahezu alle gängigen Quell- und Zielsysteme koppeln können. Möchten Sie mehr über die Möglichkeiten erfahren? Sehen Sie sich das vollständige Übersicht von Connectoren auf [unsere Website](https://www.tools4ever.nl/connectoren/) an.