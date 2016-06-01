# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def setup_department_sequence
  ActiveRecord::Base.connection.execute("SELECT SETVAL('departments_id_seq', 10000)")
rescue ActiveRecord::StatementInvalid
  # Sequence already exists, do nothing
end

Source.where(
    name: 'xkonto'
).first_or_create

Source.where(
    name: 'orcid'
).first_or_create

Source.where(
    name: 'cid'
).first_or_create

