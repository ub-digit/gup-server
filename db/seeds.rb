# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def setup_extra_db
  ActiveRecord::Base.connection.execute("CREATE SEQUENCE publications_pubid_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1000 CACHE 1;")
rescue ActiveRecord::StatementInvalid
  # Sequence already exists, do nothing
end


def create_department(id:, school_id:, parent_id:, grandparent_id:, name_sv:, name_en:, start_year:, end_year:)
  department = Department.new(id: id, name_sv: name_sv.strip, name_en: name_en.strip, start_year: start_year, end_year: end_year, faculty_id: school_id)
  department.save
end

setup_extra_db

Source.where(
    name: 'xkonto'
).first_or_create

Source.where(
    name: 'orcid'
).first_or_create

Source.where(
    name: 'Chalmers-ID'
).first_or_create

create_department(id: 666, school_id: nil, parent_id: nil, grandparent_id: nil, name_sv: "Extern institution", name_en: "Extern", start_year: 1900, end_year: nil)
create_department(id: 6666, school_id: nil, parent_id: nil, grandparent_id: nil, name_sv: "Institutionen för löjliga gångarter", name_en: "Department of Silly Walks", start_year: 1900, end_year: nil)
