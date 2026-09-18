FROM ollama/ollama:latest

# Hugging Face Spaces exécute le conteneur avec l'utilisateur 1000
RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user \
    OLLAMA_HOST=0.0.0.0:7860 \
    OLLAMA_MODELS=/home/user/models \
    OLLAMA_KEEP_ALIVE=-1

# Télécharge le modèle pendant le build : il est embarqué dans l'image
RUN ollama serve & sleep 10 && ollama pull deepcoder:1.5b

EXPOSE 7860
ENTRYPOINT ["ollama", "serve"]
