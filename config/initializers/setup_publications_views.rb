def setup_publications_views
      ActiveRecord::Base.connection.execute <<-SQL

DROP VIEW IF EXISTS publications_views;
CREATE VIEW publications_views AS
SELECT p.id AS id,
       pv.id AS publication_version_id,
       pv.pubyear AS pubyear,
       pv.title AS title,
       pt.label_sv AS label_sv,
       pt.label_en AS label_en,
       pers.last_name AS first_author_last_name,
       p.updated_at AS updated_at
FROM publications p
INNER JOIN publication_versions pv
  ON pv.id = p.current_version_id
INNER JOIN publication_types pt
  ON pt.id = pv.publication_type_id
LEFT OUTER JOIN people2publications p2p
  ON p2p.publication_version_id = pv.id
  AND p2p.position = 1
LEFT OUTER JOIN people pers
  ON pers.id = p2p.person_id
WHERE p.deleted_at IS NULL
AND p.published_at IS NOT NULL;
SQL
end

# This is necessary because this code is run during db:schema:load but the
# tables needed for the view is not present at this point.
begin
  setup_publications_views
rescue
end



