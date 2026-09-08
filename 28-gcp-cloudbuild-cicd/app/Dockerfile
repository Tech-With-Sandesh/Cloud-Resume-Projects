FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
RUN useradd -m appuser && chown -R appuser /app
USER appuser
EXPOSE 8080
ENV PORT=8080
CMD ["python", "-m", "gunicorn", "--bind", "0.0.0.0:8080", "--threads", "4", "main:app"]
