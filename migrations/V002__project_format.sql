ALTER TABLE project
  ADD COLUMN IF NOT EXISTS format TEXT NOT NULL DEFAULT 'ifc';

CREATE INDEX IF NOT EXISTS idx_project_format ON project(format);
