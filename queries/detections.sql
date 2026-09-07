-- Portable subset shared by SQLite and Athena engine v3.
-- Whole-second UTC epoch fields avoid dialect-specific timestamp arithmetic.
-- This is a batch lab query, not a scheduled production detection.
WITH candidates AS (
    SELECT 'SOC-001' AS rule_id, e.event_id, '' AS related_event_id,
           'PowerShell with an encoded-command flag; inspect content and context' AS reason
    FROM events e
    WHERE e.event_type = 'process'
      AND LOWER(e.process_name) IN ('powershell.exe', 'pwsh.exe')
      AND (LOWER(e.command_line) LIKE '% -encodedcommand %'
           OR LOWER(e.command_line) LIKE '% -enc %')
    UNION ALL
    SELECT 'SOC-002', e.event_id, '',
           'Allowed external transfer of at least 5000000 bytes in one event; validate destination and purpose'
    FROM events e
    WHERE e.event_type = 'network' AND e.dest_zone = 'external'
      AND e.action = 'allowed' AND e.bytes_sent >= 5000000
    UNION ALL
    SELECT 'SOC-003', n.event_id, p.event_id,
           'Restricted OT network attempt within 10 minutes of encoded PowerShell on the same host and user'
    FROM events n JOIN events p
      ON n.host = p.host AND n.username = p.username
     AND n.event_epoch - p.event_epoch BETWEEN 0 AND 600
    WHERE n.event_type = 'network' AND n.dest_zone = 'restricted_ot'
      AND p.event_type = 'process'
      AND LOWER(p.process_name) IN ('powershell.exe', 'pwsh.exe')
      AND (LOWER(p.command_line) LIKE '% -encodedcommand %'
           OR LOWER(p.command_line) LIKE '% -enc %')
), approved_events AS (
    SELECT e.event_id, MIN(ch.change_id) AS change_id
    FROM events e JOIN changes ch
      ON ch.host = e.host AND ch.username = e.username
     AND e.event_epoch BETWEEN ch.start_epoch AND ch.end_epoch
     AND ch.event_type = e.event_type AND ch.process_name = e.process_name
     AND ch.command_line = e.command_line AND ch.dest_ip = e.dest_ip
     AND ch.dest_zone = e.dest_zone AND ch.dest_port = e.dest_port
     AND ch.action = e.action
    GROUP BY e.event_id
), matched AS (
    SELECT c.rule_id, c.event_id, c.related_event_id, c.reason,
           e.event_time, e.host, e.username, e.action,
           CASE WHEN c.related_event_id = '' OR pa.event_id IS NOT NULL
                THEN COALESCE(ea.change_id, '') ELSE '' END AS change_id
    FROM candidates c JOIN events e ON c.event_id = e.event_id
    LEFT JOIN approved_events ea ON ea.event_id = c.event_id
    LEFT JOIN approved_events pa ON pa.event_id = c.related_event_id
)
SELECT m.rule_id, m.event_id, m.related_event_id, m.event_time, m.host, m.username,
       m.action, CASE WHEN m.change_id = '' THEN 'investigate' ELSE 'approved_change' END AS disposition,
       m.change_id, COALESCE(a.criticality, 'unknown') AS criticality,
       COALESCE(a.owner, 'unknown') AS owner,
       COALESCE(a.business_function, 'unknown') AS business_function, m.reason
FROM matched m LEFT JOIN assets a ON m.host = a.host
ORDER BY m.event_time, m.rule_id, m.event_id, m.related_event_id;
