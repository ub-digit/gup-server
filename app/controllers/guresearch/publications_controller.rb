class Guresearch::PublicationsController < ApplicationController

  def search
    svepid =        params[:svepid] || ''
    userid =        params[:userid] || ''
    departmentid =  params[:departmentid] || ''
    lyear =         params[:lyear] || '1900'
    hyear =         params[:hyear] || '9999'
    spost =         params[:spost] || '0'
    npost =         params[:npost] || '0'

    q = []
    if svepid.present? 
      q.push('svepid:' + svepid)
    end
    if userid.present? 
      q.push("person_extid:" + userid)
    end
    if departmentid.present? 
      q.push('departmentid:' + departmentid)
    end
    q.push("pubyear:[" + lyear + " TO " + hyear + "]")
    
    sort = "pubyear desc"

    @response = solr.paginate spost.to_i, npost.to_i, 'select', :params => {:q => q, :wt=> 'xml', :sort => sort}
#    @document = Nokogiri::XML "<xmlpage>" + response + "</xmlpage>"

    render xml: @response
  end

  def solr
    @@rsolr ||= RSolr.connect(url: APP_CONFIG['gu_reasearch_index_url'])
  end


end