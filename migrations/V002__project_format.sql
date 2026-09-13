ALTER TABLE project
  ADD COLUMN IF NOT EXISTS format TEXT NOT NULL DEFAULT 'unknown';

CREATE INDEX IF NOT EXISTS idx_project_format ON project(format);
