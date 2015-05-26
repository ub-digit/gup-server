class PublicationType < ActiveRecord::Base
  has_many :publications

  #validates_presence_of :label
  validates_presence_of :publication_type_code
  validates_uniqueness_of :publication_type_code, :scope => :content_type

  FORM = {
    "common" =>
      [:pubid,
       :publication_type_id,
       :title,
       :alt_title,
       :author,
       :pubyear,
       :abstract,
       :publanguage,
       :extid,
       :links,
       :url,
       :category_hsv_local,
       :keywords,
       :pub_notes,
       :is_draft,
       :is_deleted,
       :created_by,
       :updated_by],
    "article-ref" =>
      [:sourcetitle,
       :sourcevolume,
       :sourceissue,
       :sourcepages,
       :issn,
       :eissn,
       :project],
    "article" =>
      [:sourcetitle,
       :sourcevolume,
       :sourceissue,
       :sourcepages,
       :issn,
       :eissn,
       :article_number],
    "artistic-work" =>
      [:extent,
       :publisher,
       :place,
       :series,
       :sourcetitle,
       :isbn,
       :artwork_type],
    "book-chapter" =>
      [:sourcetitle,
       :sourcepages,
       :isbn,
       :publisher,
       :place],
    "book-edited" =>
      [#:editor,
       :extent,
       :publisher,
       :place,
       :series,
       :isbn],
    "book" =>
      [:publisher,
       :place,
       :series,
       :isbn],
    "conference-proc" =>
      [:sourcetitle,
       :sourcevolume,
       :sourceissue,
       :sourcepages,
       :issn,
       :eissn,
       :article_number,
       :isbn,
       :project],
    "other" =>
      [:sourcetitle,
       :sourcevolume,
       :sourceissue,
       :sourcepages,
       :issn,
       :eissn,
       :article_number,
       :isbn,
       :extent,
       :publisher,
       :place,
       :series],
  "patent" =>
    [:patent_applicant,
       :patent_application_number,
       :patent_application_date,
       :patent_number,
       :patent_date],
    "text-critical-edition" =>
      [#:editor,
       :extent,
       :publisher,
       :place,
       :isbn],
    "thesis" =>
      [:dissdate,
       :disstime,
       :disslocation,
       :dissopponent,
       :extent,
       :publisher,
       :place,
       :series,
       :isbn]
  }

  def self.get_all_fields
    all_fields = []
    FORM.each_value do |type|
      type.each do |field|
        all_fields << field
      end
    end
    all_fields.uniq
  end

  def active_fields
    (FORM[form_template]+FORM["common"]).uniq
  end

  def permitted_params(params)
    params.require(:publication).permit(active_fields)
  end


  def validate_publication publication
    validate_common publication

    if form_template.eql?('article-ref')
       validate_article_ref publication
    end
  end

  def validate_article_ref publication
    if publication.sourcetitle.blank?
      publication.errors.add(:sourcetitle, 'Needs a sourcetitle')
    end
  end

  def validate_common publication
    if publication.title.blank?
      publication.errors.add(:title, 'Needs a title')
    end

    if publication.pubyear.blank?
      publication.errors.add(:pubyear, 'Needs a publication year')
    elsif !is_number?(publication.pubyear)
      publication.errors.add(:pubyear, 'Publication year must be numerical')
    elsif publication.pubyear.to_i < 1500
      publication.errors.add(:pubyear, 'Publication year must be within reasonable limits')
    end
  end



  def is_number? obj
    obj.to_s == obj.to_i.to_s
  end
end
