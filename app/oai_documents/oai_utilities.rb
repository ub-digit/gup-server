class OaiDocuments
  class Utilities

    def get_uri_identifier id
      APP_CONFIG['public_base_url'] + APP_CONFIG['publication_path'] + id.to_s
    end

    def is_monography? publication_type
      monographs.include?(publication_type)
    end

    def get_language_code language
      code = language_mapping[language.downcase.strip.to_sym]
      code.nil? ? 'und' : code
    end
    
    def monographs
      ['publication_book',
       'publication_edited-book',
       'publication_report',
       'publication_doctoral-thesis',
       'publication_licenciate-thesis']
    end

    def language_mapping
      {en: 'eng', eng: 'eng',
       sv: 'swe', swe: 'swe',
       ar: 'ara', ara: 'ara',
       bs: 'bos', bos: 'bos',
       bg: 'bul', bul: 'bul',
       zh: 'chi', chi: 'chi',
       hr: 'hrv', hrv: 'hrv',
       cs: 'cze', cze: 'cze',
       da: 'dan', dan: 'dan',
       nl: 'dut', dut: 'dut',
       fi: 'fin', fin: 'fin',
       fr: 'fre', fre: 'fre',
       de: 'ger', ger: 'ger',
       el: 'gre', gre: 'gre',
       he: 'heb', heb: 'heb',
       hu: 'hun', hun: 'hun',
       is: 'ice', ice: 'ice',
       it: 'ita', ita: 'ita',
       ja: 'jpn', jpn: 'jpn',
       ko: 'kor', kor: 'kor',
       la: 'lat', lat: 'lat',
       lv: 'lav', lav: 'lav',
       no: 'nor', nor: 'nor',
       pl: 'pol', pol: 'pol',
       pt: 'por', por: 'por',
       ro: 'rum', rum: 'rum',
       ru: 'rus', rus: 'rus',
       sr: 'srp', srp: 'srp',
       sk: 'slo', slo: 'slo',
       sl: 'slv', slv: 'slv',
       es: 'spa', spa: 'spa',
       tr: 'tur', tur: 'tur',
       uk: 'ukr', ukr: 'ukr'}
    end    
  end
end