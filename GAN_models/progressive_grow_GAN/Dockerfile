FROM python:3.10

WORKDIR /app
COPY server server
COPY requirements-for-server.txt requirements.txt
COPY model/server_process.py model/server_process.py

RUN pip install --no-cache-dir -r requirements-for-server.txt

EXPOSE 8000

CMD ["uvicorn", "server.server:app", "--host", "0.0.0.0", "--port", "8000"]