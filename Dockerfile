FROM ollama/ollama:latest

ENV OLLAMA_HOST=0.0.0.0:10000
ENV OLLAMA_KEEP_ALIVE=-1

# Télécharge le modèle pendant le build : il est embarqué dans l'image
RUN ollama serve & sleep 5 && ollama pull deepcoder:1.5b

EXPOSE 10000
ENTRYPOINT ["ollama", "serve"]
