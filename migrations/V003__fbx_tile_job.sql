CREATE TABLE IF NOT EXISTS fbx_tile_job (
  fbx_job_id   UUID PRIMARY KEY,
  project_id   UUID NOT NULL REFERENCES project(project_id) ON DELETE CASCADE,
  tile_name    TEXT,
  task_id      TEXT,
  status       TEXT NOT NULL DEFAULT 'PENDING',
  options      JSONB NOT NULL DEFAULT '{}',
  input_dir    TEXT,
  tileset_url  TEXT,
  output_dir   TEXT,
  error        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at   TIMESTAMPTZ,
  finished_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_fbx_tile_job_project_id ON fbx_tile_job(project_id);

