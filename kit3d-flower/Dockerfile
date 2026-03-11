FROM mher/flower:2.0.1

ENV TZ=Asia/Seoul

CMD ["sh", "-c", "celery --broker=${CELERY_BROKER_URL} flower --address=0.0.0.0 --port=5555 --persistent=True --basic_auth=${FLOWER_BASIC_AUTH}"]