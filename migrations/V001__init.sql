CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS project (
  project_id   UUID PRIMARY KEY,
  name         TEXT NOT NULL,
  description  TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS upload_file (
  file_id      BIGSERIAL PRIMARY KEY,
  project_id   UUID REFERENCES project(project_id) ON DELETE CASCADE,
  file_name    TEXT NOT NULL,
  file_format  TEXT NOT NULL,
  file_path    TEXT NOT NULL,
  file_url     TEXT NOT NULL,
  file_size    BIGINT,
  uploaded_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_upload_file_project_id ON upload_file(project_id);

CREATE TABLE IF NOT EXISTS import_job (
  job_id        UUID PRIMARY KEY,
  project_id    UUID REFERENCES project(project_id) ON DELETE CASCADE,
  file_id       BIGINT REFERENCES upload_file(file_id),
  job_type      TEXT NOT NULL DEFAULT 'import',
  status        TEXT NOT NULL DEFAULT 'PENDING',
  tile_options  JSONB NOT NULL DEFAULT '{}',
  started_at    TIMESTAMPTZ,
  finished_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_import_job_project_id ON import_job(project_id);
CREATE INDEX IF NOT EXISTS idx_import_job_file_id ON import_job(file_id);

CREATE TABLE IF NOT EXISTS tile_job (
  tile_job_id   UUID PRIMARY KEY,
  project_id    UUID REFERENCES project(project_id) ON DELETE CASCADE,
  tile_name     TEXT,
  status        TEXT NOT NULL DEFAULT 'PENDING',
  total_classes INTEGER,
  done_classes  INTEGER NOT NULL DEFAULT 0,
  failed_classes INTEGER NOT NULL DEFAULT 0,
  tile_path     TEXT,
  started_at    TIMESTAMPTZ,
  finished_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tileset (
  tile_job_id  UUID NOT NULL REFERENCES tile_job(tile_job_id) ON DELETE CASCADE,
  ifc_class    TEXT NOT NULL,
  tileset_url  TEXT NOT NULL,
  status       TEXT NOT NULL DEFAULT 'PENDING',
  error        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (tile_job_id, ifc_class)
);

CREATE INDEX IF NOT EXISTS idx_tileset_job
  ON tileset(tile_job_id);


CREATE TABLE IF NOT EXISTS ifc_object (
  ifc_object_id BIGSERIAL PRIMARY KEY,
  job_id        UUID REFERENCES import_job(job_id) ON DELETE CASCADE,
  project_id    UUID NOT NULL REFERENCES project(project_id) ON DELETE CASCADE,
  guid          TEXT NOT NULL,
  ifc_class     TEXT NOT NULL,
  color         TEXT,
  properties    JSONB NOT NULL DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (project_id, guid)
);

CREATE TABLE IF NOT EXISTS ifc_mesh (
  ifc_object_id BIGINT PRIMARY KEY REFERENCES ifc_object(ifc_object_id) ON DELETE CASCADE,
  geom          GEOMETRY(MultiPolygonZ, 5186),
  shaders       JSONB,
  extras        JSONB NOT NULL DEFAULT '{}'
);

CREATE INDEX IF NOT EXISTS ifc_mesh_gix
  ON ifc_mesh
  USING GIST (ST_Centroid(ST_Envelope(geom)));

CREATE OR REPLACE VIEW view_3dtiles AS
SELECT
  o.project_id,
  o.guid,
  o.ifc_class,
  o.color,
  o.job_id,
  o.properties AS props,
  m.shaders,
  ST_Transform(m.geom, 4326) AS geom
FROM ifc_mesh m
JOIN ifc_object o ON o.ifc_object_id = m.ifc_object_id;

create table dem (
  dem_id uuid primary key,
  file_name text not null,                  -- 표시용 파일명
  file_path text not null unique,      -- 내부 상대경로 (예: dem/tif/a.tif)
  file_url text not null,              -- 서빙 URL (예: /assets/dem/tif/a.tif)
  file_size  bigint,
  created_at timestamptz not null default now()
);

create table terrain_job (
  job_id uuid primary key,
  dem_id uuid not null references dem(dem_id) on delete cascade,
  status varchar(16) not null
    check (status in ('PENDING','RUNNING','ZIPPING','DONE','FAILED')),
  task_id text,                       -- celery task id
  err text,
  created_at timestamptz not null default now(),
  started_at timestamptz,
  ended_at timestamptz
);

create table terrain_result (
  job_id uuid primary key references terrain_job(job_id) on delete cascade,
  terrain_dir_path text not null,     -- 내부 상대경로
  terrain_zip_path text not null,     -- 내부 상대경로
  terrain_uri text not null,          -- nginx 서빙 URI
  zip_uri text not null,              -- nginx 서빙 URI
  created_at timestamptz not null default now()
);