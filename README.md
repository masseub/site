# OpStream Site Web

Ce dépôt contient le site statique bilingue d'OpStream.

## Récupérer les fichiers

### Option 1 : Télécharger une archive ZIP depuis GitHub
1. Ouvrez la page du dépôt GitHub.
2. Cliquez sur le bouton **Code** puis sur **Download ZIP**.
3. Décompressez l'archive sur votre ordinateur.
4. Uploadez le dossier décompressé vers votre hébergeur (FTP, SFTP, etc.) ou servez-le directement.

### Option 2 : Cloner le dépôt
1. Assurez-vous d'avoir [Git](https://git-scm.com) installé.
2. Exécutez la commande :
   ```bash
   git clone https://github.com/votre-compte/opstream-site.git
   ```
3. Le site est maintenant disponible dans le dossier `opstream-site`.
4. Transférez les fichiers vers votre hébergement.

## Préparer une archive ZIP manuellement
Si vous travaillez localement et souhaitez créer une archive à transférer :

```bash
zip -r opstream-site.zip *
```

Cette commande génère `opstream-site.zip` avec l'ensemble des fichiers du site. Vous pouvez ensuite envoyer cette archive sur votre hébergeur et la décompresser côté serveur.

## Structure du site
- `index.html` : page d'accueil
- `pourquoi-nous.html` : page "Pourquoi nous ?"
- `produits-services.html` : page Produits & Services
- `contact.html` : page de contact
- `assets/` : ressources (CSS, JavaScript, images)

> ℹ️  Les fichiers binaires (PNG, JPG, etc.) ne sont pas suivis dans le dépôt. Déposez-les dans `assets/images/` au moment du déploiement ou hébergez-les séparément, puis mettez à jour les chemins dans le code si nécessaire.

## Hébergement
Copiez l'intégralité des fichiers sur votre serveur web. Le site est statique et peut être servi par n'importe quel hébergeur supportant des fichiers HTML/CSS/JS.
