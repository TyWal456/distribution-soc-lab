SELECT 'events' AS table_name, COUNT(*) AS row_count FROM events
UNION ALL
SELECT 'assets', COUNT(*) FROM assets
UNION ALL
SELECT 'changes', COUNT(*) FROM changes;
