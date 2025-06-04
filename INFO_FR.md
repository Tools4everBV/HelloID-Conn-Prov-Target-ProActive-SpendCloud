Le connecteur cible Spend Cloud relie Spend Cloud, via la solution de gestion des identités et des accès (GIA) HelloID de Tools4ever, en tant que système cible à vos systèmes sources. Ce connecteur automatise ainsi la gestion des comptes et des droits d'accès dans Spend Cloud, éliminant toute intervention manuelle et réduisant les risques d'erreurs humaines. Cet article vous en dit plus sur le connecteur cible Spend Cloud, les fonctionnalités qu'il offre et ses avantages. 

## Qu’est-ce que Spend Cloud ?

Spend Cloud est un logiciel développé par Visma | ProActive. Grâce à cette solution, vous gérez l'ensemble du processus d'achat jusqu'au paiement au sein de votre organisation. Spend Cloud vous permet également de gérer les petites dépenses des collaborateurs grâce à un logiciel de gestion des notes de frais et à des cartes de paiement intelligentes. Cette solution centralise et automatise ainsi la gestion des dépenses au sein de votre organisation.

## Pourquoi est-il pratique de connecter Spend Cloud ?

Pour commencer à utiliser Spend Cloud, il est nécessaire de créer un compte utilisateur pour chaque collaborateur dans le système. Grâce à la connexion entre votre système source et Spend Cloud, HelloID automatise ce processus. Vous êtes ainsi assuré qu’un nouvel employé pourra utiliser Spend Cloud dès son premier jour de travail et disposera des autorisations appropriées.
HelloID attribue également les rôles nécessaires aux utilisateurs et les révoque automatiquement, par exemple, à la fin d’un contrat de travail. Un autre avantage est qu'HelloID consigne l’intégralité du processus dans un journal de bord, garantissant ainsi le respect des exigences de conformité en vigueur.
Grâce au connecteur Spend Cloud, il est possible d’intégrer Spend Cloud avec divers systèmes sources, notamment :

*	Active Directory/Entra ID
*	AFAS
*	ADP Workforce
*	SAP SuccessFactors

Vous trouverez plus d'informations sur ces intégrations dans la suite de cet article.

## Comment HelloID s'intègre avec Spend Cloud

Spend Cloud est connecté à HelloID en tant que système cible. Le connecteur cible Spend Cloud prend en charge la gestion des personnes ainsi que des rôles associés. La connexion s’effectue via une base de données SQLite, dans laquelle HelloID enregistre tous les événements liés au cycle de vie d’un compte. Les informations issues de cette base de données sont exportées quotidiennement par HelloID sous la forme d’un fichier CSV, que Spend Cloud importe périodiquement. En raison de l’utilisation de la base de données SQLite et de l’exportation CSV, l’installation d’un agent HelloID est requise.

**Création et mise à jour des utilisateurs dans Spend Cloud**

Grâce à cette intégration, HelloID crée automatiquement un utilisateur dans Spend Cloud pour chaque nouvel employé rejoignant l’entreprise. Si les informations d’un employé sont modifiées, HelloID met également à jour ces informations dans Spend Cloud. L’outil de GIA actualise en même temps ces données dans le cycle de vie enregistré dans la base de données SQLite. Chaque jour, une exportation complète de la base de données est réalisée, et HelloID transfère les données sous forme de fichier CSV vers Spend Cloud. 

**Attribution des rôles dans Spend Cloud**

HelloID attribue les rôles d’un utilisateur sur la base des données sources. Chaque contrat actif d’un employé génère un rôle distinct. La solution de GIA permet d’attribuer ces rôles automatiquement.

Le connecteur fonctionne via plusieurs sous-actions. Par exemple, HelloID remplit une base de données SQLite dans le cadre du cycle de vie des comptes, puis regroupe périodiquement ces données et les exporte sous forme de fichier CSV à l’aide d’une tâche automatisée. Ce fichier est ensuite lu par Spend Cloud. Cependant, cela nécessite une configuration spécifique dans Spend Cloud, comme la mise en place d’une tâche d’importation pour traiter les fichiers CSV. Il est également courant d’utiliser une tâche SFTP pour transférer automatiquement les fichiers CSV vers Spend Cloud. Spend Cloud corrèle ensuite les données en utilisant les numéros de personnel (matricule) afin de faire correspondre les utilisateurs existants dans Spend Cloud avec les informations issues des fichiers CSV.

Note importante : Il s’agit d’un connecteur complexe. Il faut bien effectuer la configuration non seulement dans HelloID, mais également dans Spend Cloud. Nous recommandons donc toujours de nous contacter pour la mise en œuvre du connecteur Spend Cloud. Nous serons ravis de vous accompagner et de vous apporter notre soutien.

## Échange de données personnalisé

Il est possible d’adapter les informations échangées entre HelloID et Spend Cloud aux besoins spécifiques de votre organisation. Dans un utilisateur de Spend Cloud, plusieurs champs standard sont disponibles : externalid, email, nom de famille, prénom, préfixe, nom d’utilisateur et genre. Les rôles comprennent également les informations suivantes : nom d’utilisateur, unité organisationnelle et code de profil et fonction. Vous pouvez décider quels champs vous souhaitez utiliser selon vos besoins.

## Avantages d’HelloID pour Spend Cloud

**Création accélérée des comptes :** HelloID détecte automatiquement les modifications dans votre système source et crée un utilisateur dans Spend Cloud tout en attribuant les autorisations nécessaires. Ainsi, un nouvel employé peut commencer à utiliser Spend Cloud dès son premier jour de travail.

**Gestion des comptes sans erreurs :** Grâce à la connexion entre votre système source et Spend Cloud, HelloID garantit un processus fluide et sans erreur. La solution de GIA suit automatiquement toutes les procédures définies et enregistre toutes les activités liées aux utilisateurs et aux autorisations dans un fichier journal. Cela vous assure de travailler de manière cohérente, sans oublier aucune étape, et de toujours respecter les exigences de conformité en vigueur.

**Amélioration du niveau de service et renforcement de la sécurité :** En fournissant les accès et les autorisations au bon moment, les employés disposent toujours des ressources nécessaires pour travailler efficacement. Cette connexion améliore votre niveau de service et la satisfaction des utilisateurs. Parallèlement, vous garantissez que les autorisations ne restent jamais actives plus longtemps que nécessaire, réduisant ainsi les risques de failles potentielles. Cela empêche également les utilisateurs non autorisés d'accéder accidentellement à Spend Cloud. Cette intégration renforce considérablement la sécurité. 

## Connecter Spend Cloud à d'autres systèmes via HelloID

Avec HelloID, vous pouvez connecter divers systèmes sources à Spend Cloud. Voici quelques exemples de connexions fréquentes :

**Connexion ADP - Spend Cloud :** L’intégration des solutions ADP et Spend Cloud améliore la collaboration entre les départements RH et IT. Par exemple, HelloID peut automatiquement créer un utilisateur dans Spend Cloud lors de l’embauche d’un nouvel employé et lui attribuer les rôles appropriés, tout en mettant à jour les données si nécessaire.

**Connexion Microsoft Active Directory/Entra ID - Spend Cloud :** Grâce à l’intégration entre Microsoft Active Directory/Entra ID et Spend Cloud, HelloID peut traiter automatiquement les modifications effectuées dans Active Directory ou Entra ID. Par exemple, la création d’un nouvel utilisateur dans Spend Cloud pour un nouvel employé ou la mise à jour des données existantes en fonction des changements dans Active Directory ou Entra ID. 

HelloID prend en charge plus de 200 connecteurs différents, ce qui permet de connecter la solution de GIA de Tools4ever à quasiment tous les systèmes sources et cibles populaires. Vous souhaitez en savoir plus sur les possibilités ? Consultez la liste complète des connecteurs sur notre <a href="https://www.tools4ever.fr/connecteurs/">site internet</a>.
