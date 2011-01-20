#=============================================================================
#
# Copyright 2007 Adam Wisniewski <adamw@tbcn.ca>
# Contributions by Andrew Turner, High Earth Orbit
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#
#=============================================================================

module Geonames
  class WebService
    def self.get_element_child_text(element, child)
      unless element.elements[child].nil?
        element.elements[child][0].to_s
      end
    end

    def self.get_element_child_float(element, child)
      if !element.elements[child].nil?
        element.elements[child][0].to_s.to_f
      end
    end

    def self.get_element_child_int(element, child)
      if !element.elements[child].nil?
        element.elements[child][0].to_s.to_i
      end
    end

    def self.element_to_postal_code(element)
      postal_code = PostalCode.new

      postal_code.admin_code_1    = get_element_child_text element, 'adminCode1'
      postal_code.admin_code_2    = get_element_child_text element, 'adminCode2'
      postal_code.admin_name_1    = get_element_child_text element, 'adminName1'
      postal_code.admin_name_2    = get_element_child_text element, 'adminName2'
      postal_code.country_code    = get_element_child_text element, 'countryCode'
      postal_code.distance        = get_element_child_float element, 'distance'
      postal_code.longitude       = get_element_child_float element, 'lat'
      postal_code.latitude        = get_element_child_float element, 'lng'
      postal_code.place_name      = get_element_child_text element, 'name'
      postal_code.postal_code     = get_element_child_text element, 'postalcode'

      postal_code
    end

    def self.element_to_wikipedia_article(element)
      article = WikipediaArticle.new

      article.language              = get_element_child_text element, 'lang'
      article.title                 = get_element_child_text element, 'title'
      article.summary               = get_element_child_text element, 'summary'
      article.wikipedia_url         = get_element_child_text element, 'wikipediaUrl'
      article.feature               = get_element_child_text element, 'feature'
      article.population            = get_element_child_text element, 'population'
      article.elevation             = get_element_child_text element, 'elevation'
      article.latitude              = get_element_child_float element, 'lat'
      article.longitude             = get_element_child_float element, 'lng'
      article.thumbnail_img         = get_element_child_text element, 'thumbnailImg'
      article.distance              = get_element_child_float element, 'distance'

      article
    end

    def self.element_to_toponym(element)
      toponym = Toponym.new

      toponym.name                = get_element_child_text element, 'name'
      toponym.alternate_names     = get_element_child_text element, 'alternateNames'
      toponym.latitude            = get_element_child_float element, 'lat'
      toponym.longitude           = get_element_child_float element, 'lng'
      toponym.geoname_id          = get_element_child_text element, 'geonameId'
      toponym.country_code        = get_element_child_text element, 'countryCode'
      toponym.country_name        = get_element_child_text element, 'countryName'
      toponym.feature_class       = get_element_child_text element, 'fcl'
      toponym.feature_code        = get_element_child_text element, 'fcode'
      toponym.feature_class_name  = get_element_child_text element, 'fclName'
      toponym.feature_code_name   = get_element_child_text element, 'fCodeName'
      toponym.population          = get_element_child_int element, 'population'
      toponym.elevation           = get_element_child_text element, 'elevation'
      toponym.distance            = get_element_child_float element, 'distance'

      toponym
    end

    def self.element_to_intersection(element)
      intersection = Intersection.new

      intersection.street_1        = get_element_child_text element, 'street1'
      intersection.street_2        = get_element_child_text element, 'street2'
      intersection.admin_code_1    = get_element_child_text element, 'adminCode1'
      intersection.admin_code_1    = get_element_child_text element, 'adminCode1'
      intersection.admin_code_2    = get_element_child_text element, 'adminCode2'
      intersection.admin_name_1    = get_element_child_text element, 'adminName1'
      intersection.admin_name_2    = get_element_child_text element, 'adminName2'
      intersection.country_code    = get_element_child_text element, 'countryCode'
      intersection.distance        = get_element_child_float element, 'distance'
      intersection.longitude       = get_element_child_float element, 'lat'
      intersection.latitude        = get_element_child_float element, 'lng'
      intersection.place_name      = get_element_child_text element, 'name'
      intersection.postal_code     = get_element_child_text element, 'postalcode'

      intersection
    end

    def self.postal_code_search(postal_code, place_name, country_code)
      postal_code_sc = PostalCodeSearchCriteria.new
      postal_code_sc.postal_code = postal_code
      postal_code_sc.place_name = place_name
      postal_code_sc.coutry_code = country_code

      postal_code_search postal_code_sc
    end

    def self.postal_code_search(search_criteria)
      # postal codes to reutrn
      postal_codes = Array.new

      url = Geonames::GEONAMES_SERVER + "/postalCodeSearch?a=a"
      url += search_criteria.to_query_params_string

      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/code") do |element|
        postal_codes << element_to_postal_code( element )
      end

      postal_codes
    end

    def self.find_nearby_postal_codes( search_criteria )
      # postal codes to reutrn
      postal_codes = Array.new

      url = Geonames::GEONAMES_SERVER + "/findNearbyPostalCodes?a=a"
      url += search_criteria.to_query_params_string
      uri = URI.parse(url)

      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/code") do |element|
        postal_codes << element_to_postal_code( element )
      end

      postal_codes
    end

    def self.find_nearby_place_name(lat, long)
      places = Array.new

      url = Geonames::GEONAMES_SERVER + "/findNearbyPlaceName?a=a"
      url += "&lat=" + lat.to_s
      url += "&lng=" + long.to_s

      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/geoname") do |element|
        places << element_to_toponym( element )
      end

      places
    end

    def self.find_nearest_intersection(lat, long)
      url = Geonames::GEONAMES_SERVER + "/findNearestIntersection?a=a"
      url += "&lat=" + lat.to_s
      url += "&lng=" + long.to_s

      res = fetch_results(url)

      intersection = []
      REXML::Document.new(res.body).elements.each("geonames/intersection") do |element|
        intersection = element_to_intersection( element )
      end

      intersection
    end

    def self.timezone(lat, long)
      timezone = Timezone.new

      url = Geonames::GEONAMES_SERVER + "/timezone?a=a"
      url += "&lat=" + lat.to_s
      url += "&lng=" + long.to_s
      
      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/timezone") do |element|
        timezone.timezone_id    = get_element_child_text( element, 'timezoneId' )
        timezone.gmt_offset     = get_element_child_float( element, 'gmtOffset' )
        timezone.dst_offset     = get_element_child_float( element, 'dstOffset' )
      end

      timezone
    end

    def self.findNearbyWikipedia(hashes)
      # here for backwards compatibility
      find_nearby_wikipedia( hashes )
    end
    
    def self.find_nearby_wikipedia(hashes)
      articles = Array.new

      lat = hashes[:lat]
      long = hashes[:long]
      lang = hashes[:lang]
      radius = hashes[:radius]
      max_rows = hashes[:max_rows]
      country = hashes[:country]
      postalcode = hashes[:postalcode]
      q = hashes[:q]

      url = Geonames::GEONAMES_SERVER + "/findNearbyWikipedia?a=a"

      if !lat.nil? && !long.nil?
        url += "&lat=" + lat.to_s
        url += "&lng=" + long.to_s
        url += "&radius=" + radius.to_s unless radius.nil?
        url += "&max_rows=" + max_rows.to_s unless max_rows.nil?

      elsif !q.nil?
        url += "&q=" + q
        url += "&radius=" + radius.to_s unless radius.nil?
        url += "&max_rows=" + max_rows.to_s unless max_rows.nil?
      end

      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/entry") do |element|
        articles << element_to_wikipedia_article( element )
      end

      articles
    end

    def self.findBoundingBoxWikipedia(hashes)
      # here for backwards compatibility
      find_bounding_box_wikipedia( hashes )
    end
    
    def self.find_bounding_box_wikipedia(hashes)
      articles = Array.new

      north = hashes[:north]
      east = hashes[:east]
      south = hashes[:south]
      west = hashes[:west]
      lang = hashes[:lang]
      radius = hashes[:radius]
      max_rows = hashes[:max_rows]
      country = hashes[:country]
      postalcode = hashes[:postalcode]
      q = hashes[:q]

      url = Geonames::GEONAMES_SERVER + "/wikipediaBoundingBox?a=a"

      url += "&north=" + north.to_s
      url += "&east=" + east.to_s
      url += "&south=" + south.to_s
      url += "&west=" + west.to_s
      url += "&radius=" + radius.to_s unless radius.nil?
      url += "&max_rows=" + max_rows.to_s unless max_rows.nil?

      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/entry") do |element|
        articles << element_to_wikipedia_article( element )
      end

      articles
    end

    def self.country_subdivision(lat, long)
      country_subdivision = CountrySubdivision.new

      url = Geonames::GEONAMES_SERVER + "/countrySubdivision?a=a"
      url += "&lat=" + lat.to_s
      url += "&lng=" + long.to_s

      res = fetch_results(url)

      REXML::Document.new(res.body).elements.each("geonames/countrySubdivision") do |element|
        country_subdivision.country_code    = get_element_child_text(element, 'countryCode')
        country_subdivision.country_name    = get_element_child_text(element, 'countryName')
        country_subdivision.admin_code_1    = get_element_child_text(element, 'adminCode1')
        country_subdivision.admin_name_1    = get_element_child_text(element, 'adminName1')
      end

      country_subdivision
    end

    def self.country_code ( lat, long )
      url = Geonames::GEONAMES_SERVER + "/countrycode?a=a"
      url += "&lat=" + lat.to_s
      url += "&lng=" + long.to_s

      fetch_results(url).body.strip
    end

    def self.search(search_criteria)
      toponym_sr = ToponymSearchResult.new

      url = Geonames::GEONAMES_SERVER + "/search?a=a"
      url += "&q=" + CGI::escape(search_criteria.q) unless search_criteria.q.nil?
      url += "&name_equals=" + CGI::escape(search_criteria.name_equals) unless search_criteria.name_equals.nil?
      url += "&name_startsWith=" + CGI::escape(search_criteria.name_starts_with) unless search_criteria.name_starts_with.nil?
      url += "&name=" + CGI::escape(search_criteria.name) unless search_criteria.name.nil?
      url += "&tag=" + CGI::escape(search_criteria.tag) unless search_criteria.tag.nil?
      url += "&country=" + CGI::escape(search_criteria.country_code) unless search_criteria.country_code.nil?
      url += "&adminCode1=" + CGI::escape(search_criteria.admin_code_1) unless search_criteria.admin_code_1.nil?
      url += "&lang=" + CGI::escape(search_criteria.language) unless search_criteria.language.nil?
      url += "&featureClass=" + CGI::escape(search_criteria.feature_class) unless search_criteria.feature_class.nil?
      url += "&maxRows=" + CGI::escape(search_criteria.max_rows) unless search_criteria.max_rows.nil?
      url += "&startRow=" + CGI::escape(search_criteria.start_row) unless search_criteria.start_row.nil?
      url += "&style=" + CGI::escape( search_criteria.style ) unless search_criteria.style.nil?
      for feature_code in search_criteria.feature_codes
        url += "&fcode=" + CGI::escape(feature_code)
      end unless search_criteria.feature_codes.nil?

      doc = REXML::Document.new fetch_results(url).body

      toponym_sr.total_results_count = doc.elements["geonames/totalResultsCount"].text
      doc.elements.each("geonames/geoname") do |element|
        toponym_sr.toponyms << element_to_toponym(element)
      end

      toponym_sr
    end
    
    def self.fetch_results(url)
      uri = URI.parse(url)
      req = Net::HTTP::Get.new(uri.path + '?' + uri.query)
      Net::HTTP.start(uri.host, uri.port) { |http| 
        http.request(req) 
      }
    end
  end
end
