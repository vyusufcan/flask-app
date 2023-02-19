FROM python:3.8.10-alpine
ARG version

ENV version=$version

COPY  . /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
ENTRYPOINT [ "python" ]
CMD [ "main.py" ]