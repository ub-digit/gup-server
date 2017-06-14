# Note: all external auhors are excluded from this view
def setup_report_views
      ActiveRecord::Base.connection.execute <<-SQL
DROP VIEW IF EXISTS report_views;
CREATE VIEW report_views AS
SELECT p.id AS publication_id,
       pv.id AS publication_version_id,
       pv.pubyear AS year,
       pv.publication_type_id AS publication_type_id,
       CASE pv.ref_value WHEN 'ISREF' THEN 'ISREF' ELSE 'OTHER' END AS ref_value,
       d.faculty_id AS faculty_id,
       d.id AS department_id,
       p2p.person_id AS person_id,
       persid.value AS xaccount
FROM publications p
INNER JOIN publication_versions pv
  ON pv.id = p.current_version_id
INNER JOIN people2publications p2p
  ON p2p.publication_version_id = pv.id
INNER JOIN departments2people2publications d2p2p
  ON d2p2p.people2publication_id = p2p.id
INNER JOIN departments d
  ON d.id = d2p2p.department_id
INNER JOIN people pers
  ON p2p.person_id = pers.id
LEFT OUTER JOIN identifiers persid
  ON pers.id = persid.person_id
FULL OUTER JOIN sources s
  ON persid.source_id = s.id
  AND s.name = 'xkonto'
WHERE p.deleted_at IS NULL
  AND p.published_at IS NOT NULL
  AND d.is_internal IS true
SQL
end

# This is necessary because this code is run during db:schema:load, but the
# tables needed for the view is not present at this point.
begin
  setup_report_views
rescue
end
