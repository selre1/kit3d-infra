# kit3d-infra

## Compose 사용법 (compose.yaml)

사전 준비
- Docker Desktop

환경 설정
- `/.env`를 자격정보에 맞게 추가합니다.
- `/migrations/*.sql` 스키마가 존재해야 합니다.

전체 서비스 실행
```bash
docker compose up -d
```

개발환경
```bash
 docker compose --env-file .env.dev -f compose.dev.yml up -d
```

## 이미지 빌드 (서비스별)

```bash
docker compose up -d --pull kit3d-서비스명
```

개발환경
```bash
docker compose --env-file .env.dev -f compose.dev.yml up -d --force-recreate kit3d-서비스명
```

## Flyway 마이그레이션

신규 DB
```bash
docker compose run --rm kit3d-flyway
```

신규 DB 개발환경
```bash
docker compose --env-file .env.dev -f compose.dev.yml run --rm kit3d-flyway
```


기존 DB
```bash
1. docker compose run --rm kit3d-flyway baseline -baselineVersion=1

2. docker compose run --rm kit3d-flyway
```

기존 DB개발환경
```bash
1. docker compose --env-file .env.dev -f compose.dev.yml run --rm kit3d-flyway baseline -baselineVersion=1

2. docker compose --env-file .env.dev -f compose.dev.yml run --rm kit3d-flyway
```