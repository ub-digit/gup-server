FactoryGirl.define do

  sequence :endnote_record_id do |n|
    n
  end

  sequence :endnote_record_checksum do |n|
    n
  end

  factory :endnote_record do
    id {generate :endnote_record_id}
    checksum {generate :endnote_record_checksum}
    username 'test_key_user'

    trait :article do
      title "the title"
      alt_title "the alt_title"
      abstract "the abstract"
      keywords "the keywords"
      pubyear "1999"
      language "sv"
      issn "1234-1234"
      sourcetitle "the sourcetitle"
      sourcevolume "1"
      sourceissue "1"
      sourcepages "10-16"
      publisher "the publisher"
      place "the place"
      #extent ""
      doi '11.1111/111-1-1111-1111-1'
      doi_url 'https://doi.org/11.1111/111-1-1111-1111-1'
      xml = "<xml></xml>"
    end

    trait :xml_record do
      title "Treg-cell depletion promotes chemokine production and accumulation of CXCR3(+) conventional T cells in intestinal tumors"
      xml <<-EOT
        <record>
        <database name="My EndNote Library.enl" path="C:\\Users\\xramma\\Desktop\\My EndNote Library.enl">My EndNote Library.enl</database>
        <source-app name="EndNote" version="17.3">EndNote</source-app>
        <rec-number>307</rec-number>
        <foreign-keys>
        <key app="EN" db-id="0d0aexxslp95ejepaxd52t5ezfwervxze0de">307</key>
        </foreign-keys>
        <ref-type name="Journal Article">17</ref-type>
        <contributors>
        <authors>
        <author>
        <style face="normal" font="default" size="100%">Akeus, P.</style>
        </author>
        <author>
        <style face="normal" font="default" size="100%">Langenes, V.</style>
        </author>
        <author>
        <style face="normal" font="default" size="100%">Kristensen, J.</style>
        </author>
        <author>
        <style face="normal" font="default" size="100%">von Mentzer, A.</style>
        </author>
        <author>
        <style face="normal" font="default" size="100%">Sparwasser, T.</style>
        </author>
        <author>
        <style face="normal" font="default" size="100%">Raghavan, S.</style>
        </author>
        <author>
        <style face="normal" font="default" size="100%">Quiding-Jarbrink, M.</style>
        </author>
        </authors>
        </contributors>
        <auth-address>
        <style face="normal" font="default" size="100%">
        [Akeus, Paulina; Langenes, Veronica; Kristensen, Jonas; von Mentzer, Astrid; Raghavan, Sukanya; [Sparwasser, Tim] TWINCORE, Inst Infect Immunol, Ctr Expt & Clin Infect Res, Hannover, Germany.
        paulina.akeus@gu.se
        </style>
        </auth-address>
        <titles>
        <title>
        <style face="normal" font="default" size="100%">
        Treg-cell depletion promotes chemokine production and accumulation of CXCR3(+) conventional T cells in intestinal tumors
        </style>
        </title>
        <secondary-title>
        <style face="normal" font="default" size="100%">European Journal of Immunology</style>
        </secondary-title>
        </titles>
        <periodical>
        <full-title>
        <style face="normal" font="default" size="100%">European Journal of Immunology</style>
        </full-title>
        </periodical>
        <pages>
        <style face="normal" font="default" size="100%">1654-1666</style>
        </pages>
        <volume>
        <style face="normal" font="default" size="100%">45</style>
        </volume>
        <number>
        <style face="normal" font="default" size="100%">6</style>
        </number>
        <keywords>
        <keyword>
        <style face="normal" font="default" size="100%">Colorectal cancer, CXCL9, CXCL10, Treg cell</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">COLORECTAL-CANCER PATIENTS</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">IMMUNITY</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">POLYPOSIS</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">SURVIVAL</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">MOUSE</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">TUMORIGENESIS</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">INFILTRATION</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">INSTABILITY</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">PROGRESSION</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">RECRUITMENT</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">Immunology</style>
        </keyword>
        <keyword>
        <style face="normal" font="default" size="100%">ATES OF AMERICA, V108, P17135</style>
        </keyword>
        </keywords>
        <dates>
        <year>
        <style face="normal" font="default" size="100%">2015</style>
        </year>
        <pub-dates>
        <date>
        <style face="normal" font="default" size="100%">Jun</style>
        </date>
        </pub-dates>
        </dates>
        <isbn>
        <style face="normal" font="default" size="100%">0014-2980</style>
        </isbn>
        <accession-num>
        <style face="normal" font="default" size="100%">WOS:000355836500010</style>
        </accession-num>
        <abstract>
        <style face="normal" font="default" size="100%">
        Colorectal cancer (CRC) is one of the most prevalent tumor types worldwide and tumor-infiltrating T cells are crucial for anti-tumor immunity. We previously demonstrated that Treg cells from CRC patients inhibit transendothelial migration of conventional T cells. However, it remains unclear if local Treg cells affect lymphocyte migration into colonic tumors. By breeding APC(Min/+) mice with depletion of regulatory T cells mice, expressing the diphtheria toxin receptor under the control of the FoxP3 promoter, we were able to selectively deplete Treg cells in tumor-bearing mice, and investigate the impact of these cells on the infiltration of conventional T cells into intestinal tumors. Short-term Treg-cell depletion led to a substantial increase in the frequencies of T cells in the tumors, attributed by both increased infiltration and proliferation of T cells in the Treg-cell-depleted tumors. We also demonstrate a selective increase of the chemokines CXCL9 and CXCL10 in Treg-cell-depleted tumors, which were accompanied by accumulation of CXCR3(+) T cells, and increased IFN- mRNA expression. In conclusion, Treg-cell depletion increases the accumulation of conventional T cells in intestinal tumors, and targeting Treg cells could be a possible anti-tumor immunotherapy, which not only affects T-cell effector functions, but also their recruitment to tumors.
        </style>
        </abstract>
        <notes>
        <style face="normal" font="default" size="100%">
        ISI Document Delivery No.: CJ9QE
        Times Cited: 0
        Cited Reference Count: 50
        Cited References:
         Menon AG, 2004, LABORATORY INVESTIGATION, V84, P493
        Akeus, Paulina Langenes, Veronica Kristensen, Jonas von Mentzer, Astrid Sparwasser, Tim Raghavan, Sukanya Quiding-Jarbrink, Marianne
        Swedish Science Council; Swedish Cancer Foundation; Sahlgrenska University Hospital; Ruth and Richard Julin foundation; Assar Gabrielssons foundation; Olle Engkvist's foundation; Hvitfeldska foundation
        The study was supported by grants from the Swedish Science Council, the Swedish Cancer Foundation, the Sahlgrenska University Hospital, the Ruth and Richard Julin foundation, Assar Gabrielssons foundation, Olle Engkvist's foundation, and Hvitfeldska foundation.
        0
        WILEY-BLACKWELL
        HOBOKEN
        </style>
        </notes>
        <work-type>
        <style face="normal" font="default" size="100%">Article</style>
        </work-type>
        <urls>
        <related-urls>
        <url>
        <style face="normal" font="default" size="100%"><Go to ISI>://WOS:000355836500010</style>
        </url>
        </related-urls>
        </urls>
        <electronic-resource-num>
        <style face="normal" font="default" size="100%">
        10.1002/eji.201445058
        Etrich wf, 1993, cell, v75, p631
        </style>
        </electronic-resource-num>
        <language>
        <style face="normal" font="default" size="100%">English</style>
        </language>
        </record>
      EOT
    end

    factory :endnote_article_record, traits: [:article]

    factory :endnote_xml_record, traits: [:xml_record]
  end
end
