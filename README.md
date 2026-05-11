# kit3d-infra

## Compose 사용법 (compose.yaml)

사전 준비
- Docker Desktop

환경 설정
- [`.env.example`](.env.example)을 참고하여 `.env` 파일을 생성합니다.
- `/migrations/*.sql` 스키마가 존재해야 합니다.

### 환경변수 설정

| 변수명 | 설명 | 예시 |
|---|---|---|
| `PLATFORM` | Docker 빌드 플랫폼 | `linux/amd64` |
| `REGISTRY` | 컨테이너 레지스트리 주소 | `ghcr.io/<username>` |
| `FRONT_TAG` / `BACK_TAG` / `ENGIN_TAG` / `TERRAIN_TAG` | 각 서비스 이미지 태그 | `latest` |
| `POSTGRES_DB` | PostgreSQL 데이터베이스명 | `tile_worker` |
| `POSTGRES_USER` | PostgreSQL 사용자명 | `postgres` |
| `POSTGRES_PASSWORD` | PostgreSQL 비밀번호 | *(직접 설정)* |
| `RABBITMQ_USER` | RabbitMQ 사용자명 | *(직접 설정)* |
| `RABBITMQ_PASS` | RabbitMQ 비밀번호 | *(직접 설정)* |
| `FLOWER_BASIC_AUTH` | Flower 인증 (형식: `user:password`) | *(직접 설정)* |
| `PGADMIN_EMAIL` | pgAdmin 로그인 이메일 | *(직접 설정)* |
| `PGADMIN_PASSWORD` | pgAdmin 비밀번호 | *(직접 설정)* |
| `BACK_WORKERS` | 백엔드 워커 수 | `4` |

```bash
cp .env.example .env
# .env 파일을 열어 각 값을 환경에 맞게 수정합니다.
```

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
docker compose up -d --force-recreate kit3d-서비스명
```

개발환경
```bash
docker compose --env-file .env.dev -f compose.dev.yml up -d --pull kit3d-서비스명
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