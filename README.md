---
title: Deepcoder Ollama
emoji: 🦙
colorFrom: blue
colorTo: gray
sdk: docker
app_port: 7860
pinned: false
---

# 🦙 DeepCoder 1.5B — serveur Ollama auto-hébergé

Serveur **Ollama** contenant le modèle **`deepcoder:1.5b`**, prêt à être déployé
comme **Hugging Face Space** (SDK Docker) ou en local avec **Docker Compose**.

> **DeepCoder** est un modèle de code entièrement open source, avec une version
> **1.5B** (et une version 14B). Voir la fiche officielle :
> [ollama.com/library/deepcoder](https://ollama.com/library/deepcoder)

## Caractéristiques du modèle

| Propriété | Valeur |
|---|---|
| Tag Ollama | `deepcoder:1.5b` |
| Taille du fichier | **1,1 GB** |
| Fenêtre de contexte | **128K** tokens |
| Variante haute précision | `deepcoder:1.5b-preview-q8_0` (1,9 GB) |
| Variante pleine précision | `deepcoder:1.5b-preview-fp16` (3,6 GB) |

## Contenu du dépôt

| Fichier | Rôle |
|---|---|
| `Dockerfile` | Image Docker : installe Ollama + embarque le modèle au build |
| `start.sh` | Entrypoint : démarre l'API, attend qu'elle réponde, pull de secours |
| `docker-compose.yml` | Déploiement local en une commande |
| `client_example.py` | Exemples d'appels (curl / Python / client officiel) |
| `.dockerignore` | Build plus rapide et image plus propre |

---

## 🚀 Déploiement n°1 — Hugging Face Space (recommandé)

C'est la cible prévue par le `README.md` (front-matter `sdk: docker`).

1. Sur [huggingface.co/new-space](https://huggingface.co/new-space) :
   - **Space name** : `deepcoder-ollama`
   - **SDK** : `Docker`
   - **Docker template** : `Blank`
   - **Visibility** : `Public` ou `Private`
2. Une fois le Space créé : onglet **Files** → **Add file** → `Upload files`,
   ou bien reliez ce dépôt GitHub via **Settings → Repository sync**.
3. Le build télécharge le modèle (~1,1 GB) : comptez **5 à 10 minutes**.
4. Quand le statut passe au vert 🟢, votre API est disponible à :
   `https://<utilisateur>-<nom-du-space>.hf.space`

> ⚠️ Sur le plan gratuit, un Space Docker s'endort après une période
> d'inactivité. Au réveil, pas de re-téléchargement : le modèle est
> **embarqué dans l'image**.

---

## 🖥️ Déploiement n°2 — Local avec Docker Compose

```bash
git clone https://github.com/hounmetinjeremy-cmyk/deepcoder-ollama.git
cd deepcoder-ollama
docker compose up -d --build
```

L'API écoute alors sur **http://localhost:11434**.

```bash
# Vérifier que ça tourne
docker compose logs -f ollama

# Tester
curl http://localhost:11434/api/tags
```

Pour arrêter : `docker compose down`
Pour tout supprimer (y compris les modèles) : `docker compose down -v`

---

## 🐍 Déploiement n°3 — Sans Docker (Ollama natif)

```bash
# 1. Installer Ollama (https://ollama.com/download)
# 2. Télécharger le modèle
ollama pull deepcoder:1.5b

# 3. Lancer
ollama run deepcoder:1.5b
```

---

## 📡 Utilisation de l'API

### Lister les modèles

```bash
curl http://localhost:11434/api/tags
```

### Génération simple

```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepcoder:1.5b",
    "prompt": "Écris une fonction Python qui inverse une chaîne",
    "stream": false
  }'
```

### Conversation (chat)

```bash
curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepcoder:1.5b",
    "messages": [
      {"role": "user", "content": "Explique-moi les décorateurs Python"}
    ],
    "stream": false
  }'
```

### En Python

```python
import requests

r = requests.post(
    "http://localhost:11434/api/generate",
    json={"model": "deepcoder:1.5b",
          "prompt": "Écris un tri à bulles en Python",
          "stream": False},
    timeout=300,
)
print(r.json()["response"])
```

D'autres exemples prêts à l'emploi (génération, chat multi-tours, client
officiel `ollama`) sont dans **`client_example.py`** :

```bash
pip install requests
python client_example.py
```

---

## 🔌 Connexion depuis LibreChat

Dans `librechat.yaml`, ajoutez Ollama comme fournisseur personnalisé :

```yaml
version: 1.2.8
endpoints:
  custom:
    - name: "DeepCoder (auto-hébergé)"
      apiKey: "ollama"
      baseURL: "https://<votre-space>.hf.space/v1"
      models:
        default: ["deepcoder:1.5b"]
        fetch: false
      titleConvo: true
      modelDisplayLabel: "DeepCoder 1.5B"
```

> `apiKey` peut être n'importe quelle valeur : Ollama ne vérifie pas la clé
> par défaut. **Ajoutez une authentification si votre Space est public.**

---

## 🔒 Sécurité

Par défaut, Ollama **n'a aucune authentification**. Si votre Space est public,
n'importe qui peut consommer votre API. Trois options :

1. Passer le Space en **privé** (Settings → Change visibility).
2. Placer un **reverse-proxy avec jeton Bearer** devant Ollama (comme le fait
   déjà votre projet `chap-libre-mcp-toolkit` sur Render).
3. Ajouter la variable `OLLAMA_ORIGINS` pour restreindre les origines CORS.

---

## 🛠️ Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| Build qui échoue à `ollama pull` | Coupure réseau pendant le build | Relancez le build (Factory reboot sur HF) |
| 503 / « Space is sleeping » | Space inactif | Attendez le réveil, ou passez au plan payant |
| `Connection refused` en local | Conteneur pas démarré | `docker compose logs ollama` |
| Réponses très lentes | Pas de GPU | Utilisez `deepcoder:1.5b` (déjà le plus léger) |
| Code incohérent | Température trop élevée | Réglez `temperature` entre 0.1 et 0.2 |
| `Killed` pendant le build | Limite mémoire du builder | Réduisez le contexte ou utilisez un build local |

---

## 📄 Licence

Le code de ce dépôt est fourni tel quel. Le modèle **DeepCoder** est distribué
sous sa propre licence — consultez la fiche du modèle sur
[ollama.com/library/deepcoder](https://ollama.com/library/deepcoder) avant tout
usage commercial.
