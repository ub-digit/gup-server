# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def setup_extra_db
  ActiveRecord::Base.connection.execute("DROP SEQUENCE publications_pubid_seq;")
  ActiveRecord::Base.connection.execute("CREATE SEQUENCE publications_pubid_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1000 CACHE 1;")
end

def create_publication_type(label, code, content_type, template, id = nil)
  pt=PublicationType.new(id: id, publication_type_code: code, 
                         content_type: content_type, form_template: template, label: label)
  pt.save(:validate=>false)
end

setup_extra_db

create_publication_type('none', '- Välj -', '- Välj -', 'none', 0)
create_publication_type('article-ref' , 'article', 'ref', 'article-ref')
create_publication_type('article-ovr' , 'article', 'ovr', 'article-ref')
create_publication_type('article-for' , 'article', 'for', 'article-ref')
create_publication_type('article-pop' , 'article', 'pop', 'article')
create_publication_type('article-rec' , 'article', 'rec', 'article')
create_publication_type('book-ref' , 'book', 'ref', 'book')
create_publication_type('book-nap' , 'book', 'nap', 'book')
create_publication_type('book-edited-ref' , 'book, edited', 'ref', 'book-edited')
create_publication_type('book-edited-nap' , 'book, edited', 'nap', 'book-edited')
create_publication_type('textbook-nap' , 'textbook', 'nap', 'book')
create_publication_type('report-nap' , 'report', 'nap', 'book')
create_publication_type('book-chapter-ref' , 'book chapter', 'ref', 'book-chapter')
create_publication_type('book-chapter-nap' , 'book chapter', 'nap', 'book-chapter')
create_publication_type('conference-proceeding-ref' , 'conference proceeding', 'ref', 'conference-proc')
create_publication_type('conference-proceeding-abs' , 'conference proceeding', 'abs', 'conference-proc')
create_publication_type('conference-proceeding-pos' , 'conference proceeding', 'pos', 'conference-proc')
create_publication_type('conference-proceeding-nap' , 'conference proceeding', 'nap', 'conference-proc')
create_publication_type('artistic-work-ref' , 'artistic work', 'ref', 'artistic-work')
create_publication_type('artistic-work-nap' , 'artistic work', 'nap', 'artistic-work')
create_publication_type('text-critical-edition-nap' , 'text critical edition', 'nap', 'text-critical-edition')
create_publication_type('doctoral-thesis-nap' , 'doctoral thesis', 'nap', 'thesis')
create_publication_type('licentiate-thesis-nap' , 'licentiate thesis', 'nap', 'thesis')
create_publication_type('patent-nap' , 'patent', 'nap', 'patent')
create_publication_type('other-nap' , 'other', 'nap', 'other')

Source.where(
    name: 'xkonto'
).first_or_create

Source.where(
    name: 'orcid'
).first_or_create