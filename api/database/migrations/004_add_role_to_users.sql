USE ipiggconect;

SET @role_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND column_name = 'role'
);

SET @alter_sql := IF(
  @role_exists = 0,
  'ALTER TABLE users ADD COLUMN role ENUM(''Membro'', ''Administrador'') NOT NULL DEFAULT ''Membro'' AFTER phone;',
  'SELECT 1;'
);

PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE users
SET role = 'Membro'
WHERE role IS NULL;
